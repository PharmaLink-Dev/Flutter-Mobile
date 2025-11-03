import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// [DATA CLASS]
/// Class สำหรับเก็บผลลัพธ์
class FdaOcrResult {
  final String fullText; // ข้อความดิบๆ ที่ OCR อ่านได้
  final String? fdaNumber; // เลข อย. ที่สกัดและจัดรูปแบบแล้ว (xx-x-xxxxx-x-xxxx)
  final Duration duration; // เวลาที่ใช้ประมวลผล
  final Uint8List processedBytes; // ภาพที่ผ่าน Pre-processing (Binarized)
  final String? normalizedText;

  const FdaOcrResult({
    required this.fullText,
    required this.fdaNumber,
    this.normalizedText,
    required this.duration,
    required this.processedBytes,
  });
}

/// [MAIN CLASS]
/// Class หลักสำหรับจัดการกระบวนการ OCR เลข อย.
class FdaOcr {
  /// ฟังก์ชันหลัก: รับภาพที่ Crop มา แล้วพยายามหาเลข อย.
  Future<FdaOcrResult> recognize(Uint8List croppedBytes) async {
    final sw = Stopwatch()..start();

    // --- 1. PRE-PROCESSING ---
    // แปลงภาพเป็น ขาว-ดำ (Binarize) เพื่อให้ ML Kit อ่านง่ายขึ้น
    final processed = _binarize(croppedBytes);

    // สร้างไฟล์ชั่วคราว (ง่ายที่สุดสำหรับ ML Kit)
    final file = await _writeTemp(processed);
    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // --- 2. OCR ---
      // สั่ง ML Kit ให้อ่านภาพ
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text; // Text ดิบ

      // --- 3. POST-PROCESSING (Two-Pass Logic ที่ปลอดภัย) ---

      // PASS 1: พยายามหาจาก "Text ดิบ" ก่อน (ไม่ Normalize)
      // นี่คือวิธีที่ปลอดภัยที่สุด ถ้าเจอคือจบ
      String? fda = _extractFdaNumber(text);
      String? normalized;

      // PASS 2: ถ้า Pass 1 ไม่เจอ (fda == null)
      if (fda == null) {
        normalized = _normalizeDigitsAndDashes(text);
        fda = _extractFdaNumber(normalized);
      }

      sw.stop();
      return FdaOcrResult(
        fullText: text, // คืนค่า text ดิบเสมอ
        fdaNumber: fda, // คืนค่า fda ที่หาเจอ
        normalizedText: normalized,
        duration: sw.elapsed,
        processedBytes: processed,
      );
    } finally {
      // เคลียร์ทรัพยากร
      await textRecognizer.close();
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
    }
  }

  // ===================================================================
  // PRE-PROCESSING (ง่ายและผลลัพธ์ดี)
  // ===================================================================

  /// [PRE-PROCESSING]
  /// แปลงภาพเป็น ขาว-ดำ (Binarization)
  Uint8List _binarize(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    // 1. แปลงเป็นสีเทา
    final gray = img.grayscale(decoded);

    // 2. หาจุดตัด ขาว/ดำ ที่ดีที่สุด (Otsu)
    // ใช้ fallback ภายในไฟล์นี้เพื่อความเข้ากันได้กับแพ็กเกจ image ปัจจุบัน
    final t = _otsuThreshold(gray);

    // 3. ทำให้ภาพเป็น ขาว (255) หรือ ดำ (0)
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final lum = gray.getPixel(x, y).luminance;
        final v = lum < t ? 0 : 255;
        gray.setPixelRgba(x, y, v, v, v, 255);
      }
    }
    return Uint8List.fromList(img.encodeJpg(gray, quality: 95));
  }

  // ===================================================================
  // POST-PROCESSING (ทำความสะอาด และ สกัด)
  // ===================================================================

  /// [POST-PROCESSING - Step 1: Clean]
  /// ทำความสะอาด String ดิบ
  /// - แก้ไขตัวอักษรที่ OCR มักสับสน (O -> 0, l -> 1, S -> 5)
  /// - แปลงขีดกลางหลายๆ แบบ ให้เป็นขีดกลางมาตรฐาน (-)
  String _normalizeDigitsAndDashes(String s) {
    // Map เฉพาะอักษรที่ OCR สับสน (ลบเลขไทยออกตามโจทย์)
    const map = {
      'O': '0', 'o': '0', 'Ө': '0', '߀': '0',
      'I': '1', 'l': '1', '|': '1', 'ı': '1', '¹': '1', '⑴': '1',
      'Z': '2', '₂': '2',
      'S': '5', '\$': '5',
      'B': '8', 'ß': '8',
      'g': '9', 'q': '9',
    };
    final sb = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      sb.write(map[ch] ?? ch);
    }
    var out = sb.toString();
    // Normalize various dash characters to simple '-'
    out = out.replaceAll(RegExp('[\u2012\u2013\u2014\u2015\u2212\u2043\u30FC]'), '-');
    return out;
  }

  /// [POST-PROCESSING - Step 2: Extract & Validate]
  /// สกัดเลข อย. 13 หลัก และใช้ "Safety Net" ตรวจสอบ Prefix
  String? _extractFdaNumber(String s) {
    // Pattern: 13 หลัก (xx-x-xxxxx-x-xxxx)
    // [\s\-]? หมายถึง อนุญาตให้เป็น "ช่องว่าง" หรือ "ขีดกลาง" หรือ "ไม่มีเลย"
    // ลบ \b (word boundary) ออก เพื่อให้ค้นหา Pattern ที่ซ่อนอยู่ใน String ได้
    final pattern = RegExp(r"(\d{2})[\s\-]?(\d)[\s\-]?(\d{5})[\s\-]?(\d)[\s\-]?(\d{4})");

    String? validateAndJoin(Match m) {
      final prefixStr = m.group(1); // ดึง 2 ตัวแรก
      if (prefixStr == null) return null;
      final prefix = int.tryParse(prefixStr);
      // ---- SAFETY NET (00-78) ---- เพื่อกันเลข barcode
      if (prefix == null || prefix < 0 || prefix > 78) {
        return null;
      }
      return [m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)]
          .whereType<String>()
          .join('-');
    }

    // 1. ลองค้นหาทีละบรรทัดก่อน (ลด Noise)
    for (final line in s.split(RegExp(r"\r?\n"))) {
      for (final mLine in pattern.allMatches(line)) {
        final fda = validateAndJoin(mLine);
        if (fda != null) return fda; // เจอ + Prefix ถูก
      }
    }

    // 2. ถ้าทีละบรรทัดไม่เจอ ให้ค้นหาจากทั้งก้อน
    for (final m in pattern.allMatches(s)) {
      final fda = validateAndJoin(m);
      if (fda != null) return fda; // เจอ + Prefix ถูก
    }

    return null; // ไม่เจออะไรที่ตรงเงื่อนไขเลย
  }

  // ===================================================================
  // FILE HELPER
  // ===================================================================

  /// สร้างไฟล์ชั่วคราวสำหรับส่งให้ ML Kit (วิธีที่ง่ายที่สุด)
  Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await Directory.systemTemp.createTemp('fda_ocr_');
    final file = File('${dir.path}/input.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Fallback Otsu threshold (ใช้เมื่อแพ็กเกจ image ไม่มีฟังก์ชันสำเร็จรูป)
  int _otsuThreshold(img.Image gray) {
    final hist = List<int>.filled(256, 0);
    final total = gray.width * gray.height;
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        hist[gray.getPixel(x, y).luminance.toInt()]++;
      }
    }
    double sum = 0;
    for (int i = 0; i < 256; i++) sum += i * hist[i];
    double sumB = 0;
    int wB = 0;
    int wF = 0;
    double varMax = -1;
    int threshold = 140; // fallback
    for (int t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      wF = total - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final varBetween = wB * wF * (mB - mF) * (mB - mF);
      if (varBetween > varMax) {
        varMax = varBetween;
        threshold = t;
      }
    }
    return threshold;
  }
}
