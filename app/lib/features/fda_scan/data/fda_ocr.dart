import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
 
class FdaOcrResult {
  final String fullText; // raw OCR text
  final String? fdaNumber; // only digits and dashes (2-1-5-1-4)
  final Duration duration;
  final Uint8List processedBytes;
  const FdaOcrResult({
    required this.fullText,
    required this.fdaNumber,
    required this.duration,
    required this.processedBytes,
  });
}

class FdaOcr {
  Future<FdaOcrResult> recognize(Uint8List croppedBytes) async {
    final sw = Stopwatch()..start();
    final processed = _binarize(croppedBytes);
    final file = await _writeTemp(processed);

    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text;
      final normalized = _normalizeDigitsAndDashes(text);
      final fda = _extractFdaNumber(normalized) ?? _extractFdaNumber(text);
      sw.stop();
      // ignore: avoid_print
      print('FDA OCR OUTPUT (in ${sw.elapsedMilliseconds} ms):\n$text');
      return FdaOcrResult(
        fullText: text,
        fdaNumber: fda,
        duration: sw.elapsed,
        processedBytes: processed,
      );
    } finally {
      await textRecognizer.close();
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
    }
  }

  // Extract only numbers and dashes in 2-1-5-1-4 pattern
  String? _extractFdaNumber(String s) {
    // Try per line first to reduce noise from other digits
    final pattern = RegExp(r"\b(\d{2})[\s\-]?(\d)[\s\-]?(\d{5})[\s\-]?(\d)[\s\-]?(\d{4})\b");
    for (final line in s.split(RegExp(r"\r?\n"))) {
      final mLine = pattern.firstMatch(line);
      if (mLine != null) {
        return [mLine.group(1), mLine.group(2), mLine.group(3), mLine.group(4), mLine.group(5)]
            .whereType<String>()
            .join('-');
      }
    }
    final m = pattern.firstMatch(s);
    if (m != null) {
      return [m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)].whereType<String>().join('-');
    }
    final digitsOnly = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length >= 13) {
      final segs = [
        digitsOnly.substring(0, 2),
        digitsOnly.substring(2, 3),
        digitsOnly.substring(3, 8),
        digitsOnly.substring(8, 9),
        digitsOnly.substring(9, 13),
      ];
      return segs.join('-');
    }
    return null;
  }

  String _normalizeDigitsAndDashes(String s) {
    // Map common OCR confusions and Thai digits to ASCII digits
    const map = {
      'O': '0', 'o': '0', '๐': '0', 'Ө': '0', '߀': '0',
      'I': '1', 'l': '1', '|': '1', 'ı': '1', '¹': '1', '⑴': '1',
      'Z': '2', '₂': '2',
      'S': '5', '\$': '5', 
      'B': '8', 'ß': '8',
      'g': '9', 'q': '9', 
      // Thai digits
      '๑': '1', '๒': '2', '๓': '3', '๔': '4', '๕': '5', '๖': '6', '๗': '7', '๘': '8', '๙': '9',
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

  Uint8List _binarize(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    final gray = img.grayscale(decoded);
    final t = _otsuThreshold(gray);
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final p = gray.getPixel(x, y);
        final lum = p.luminance;
        final v = lum < t ? 0 : 255;
        gray.setPixelRgba(x, y, v, v, v, 255);
      }
    }
    return Uint8List.fromList(img.encodeJpg(gray, quality: 95));
  }

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

  Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await Directory.systemTemp.createTemp('fda_ocr_');
    final file = File('${dir.path}/input.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
