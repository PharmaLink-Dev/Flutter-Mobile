import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;

/// [DATA CLASS]
/// Class สำหรับเก็บผลลัพธ์
class FdaOcrResult {
  final String fullText; // ข้อความดิบๆ ที่ OCR อ่านได้
  final String?
  fdaNumber; // เลข อย. ที่สกัดและจัดรูปแบบแล้ว (xx-x-xxxxx-x-xxxx)
  final Duration duration; // เวลาที่ใช้ประมวลผล
  final Uint8List processedBytes; // ภาพที่ผ่าน Pre-processing
  final String? normalizedText;
  final int passNumber; // Which OCR pass succeeded (1, 2, or 3)

  const FdaOcrResult({
    required this.fullText,
    required this.fdaNumber,
    this.normalizedText,
    required this.duration,
    required this.processedBytes,
    this.passNumber = 1,
  });
}

/// [MAIN CLASS]
/// Enhanced OCR with multi-layer preprocessing pipeline
class FdaOcr {
  /// Main function: Multi-pass OCR with enhanced preprocessing
  Future<FdaOcrResult> recognize(Uint8List croppedBytes) async {
    final sw = Stopwatch()..start();

    // Decode image once
    final decoded = img.decodeImage(croppedBytes);
    if (decoded == null) {
      // Fallback to original if decode fails
      return FdaOcrResult(
        fullText: '',
        fdaNumber: null,
        duration: sw.elapsed,
        processedBytes: croppedBytes,
      );
    }

    // --- MULTI-PASS OCR STRATEGY ---

    // PASS 1: Enhanced preprocessing (best quality)
    try {
      final result = await _tryOcrWithPreprocessing(
        decoded,
        _enhancedPreprocessing,
        1,
      );
      if (result.fdaNumber != null) {
        sw.stop();
        return result.copyWith(duration: sw.elapsed);
      }
    } catch (e) {
      print('OCR Pass 1 failed: $e');
    }

    // PASS 2: Alternative preprocessing (more aggressive)
    try {
      final result = await _tryOcrWithPreprocessing(
        decoded,
        _aggressivePreprocessing,
        2,
      );
      if (result.fdaNumber != null) {
        sw.stop();
        return result.copyWith(duration: sw.elapsed);
      }
    } catch (e) {
      print('OCR Pass 2 failed: $e');
    }

    // PASS 3: Minimal preprocessing (fallback)
    try {
      final result = await _tryOcrWithPreprocessing(
        decoded,
        _minimalPreprocessing,
        3,
      );
      sw.stop();
      return result.copyWith(duration: sw.elapsed);
    } catch (e) {
      print('OCR Pass 3 failed: $e');
      sw.stop();
      return FdaOcrResult(
        fullText: '',
        fdaNumber: null,
        duration: sw.elapsed,
        processedBytes: croppedBytes,
        passNumber: 3,
      );
    }
  }

  /// Try OCR with specific preprocessing function
  Future<FdaOcrResult> _tryOcrWithPreprocessing(
    img.Image original,
    Uint8List Function(img.Image) preprocessor,
    int passNumber,
  ) async {
    // Apply preprocessing
    final processed = preprocessor(original);

    // Create temp file for ML Kit
    final file = await _writeTemp(processed);
    final inputImage = InputImage.fromFilePath(file.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      // Run OCR
      final recognizedText = await textRecognizer.processImage(inputImage);
      final text = recognizedText.text;

      // Post-processing: Extract FDA number
      String? fda = _extractFdaNumber(text);
      String? normalized;

      // If not found, try with normalization
      if (fda == null) {
        normalized = _normalizeDigitsAndDashes(text);
        fda = _extractFdaNumber(normalized);
      }

      return FdaOcrResult(
        fullText: text,
        fdaNumber: fda,
        normalizedText: normalized,
        duration: Duration.zero, // Will be set by caller
        processedBytes: processed,
        passNumber: passNumber,
      );
    } finally {
      await textRecognizer.close();
      try {
        await file.parent.delete(recursive: true);
      } catch (_) {}
    }
  }

  // ===================================================================
  // PREPROCESSING STRATEGIES
  // ===================================================================

  /// Enhanced preprocessing: CLAHE + Sharpen + Adaptive threshold
  Uint8List _enhancedPreprocessing(img.Image original) {
    // 1. Upscale if too small
    var image = _upscaleIfNeeded(original, 640);

    // 2. Convert to grayscale
    image = img.grayscale(image);

    // 3. Noise reduction (light Gaussian blur)
    image = _reduceNoise(image);

    // 4. Contrast enhancement (CLAHE)
    image = _enhanceContrast(image);

    // 5. Sharpening
    image = _sharpenImage(image);

    // 6. Adaptive thresholding
    image = _adaptiveThreshold(image);

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  /// Aggressive preprocessing: More aggressive sharpening and contrast
  Uint8List _aggressivePreprocessing(img.Image original) {
    var image = _upscaleIfNeeded(original, 800);
    image = img.grayscale(image);

    // More aggressive contrast
    image = _enhanceContrast(image, clipLimit: 3.0);

    // Stronger sharpening
    image = _sharpenImage(image, strength: 2.0);

    // Standard binarization
    final threshold = _otsuThreshold(image);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final lum = image.getPixel(x, y).luminance;
        final v = lum < threshold ? 0 : 255;
        image.setPixelRgba(x, y, v, v, v, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  /// Minimal preprocessing: Just basic binarization (original approach)
  Uint8List _minimalPreprocessing(img.Image original) {
    var image = img.grayscale(original);
    final threshold = _otsuThreshold(image);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final lum = image.getPixel(x, y).luminance;
        final v = lum < threshold ? 0 : 255;
        image.setPixelRgba(x, y, v, v, v, 255);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: 95));
  }

  // ===================================================================
  // IMAGE ENHANCEMENT FUNCTIONS
  // ===================================================================

  /// Upscale image if it's too small
  img.Image _upscaleIfNeeded(img.Image image, int minSize) {
    final minDimension = image.width < image.height
        ? image.width
        : image.height;

    if (minDimension < minSize) {
      final scale = minSize / minDimension;
      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();
      return img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );
    }

    return image;
  }

  /// Noise reduction using Gaussian blur
  img.Image _reduceNoise(img.Image image) {
    // Light Gaussian blur to reduce noise
    return img.gaussianBlur(image, radius: 1);
  }

  /// CLAHE (Contrast Limited Adaptive Histogram Equalization)
  img.Image _enhanceContrast(img.Image image, {double clipLimit = 2.0}) {
    // Simplified CLAHE implementation
    // For production, consider using a more sophisticated implementation

    // Apply histogram equalization
    final histogram = List<int>.filled(256, 0);

    // Build histogram
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final lum = image.getPixel(x, y).luminance.toInt();
        histogram[lum]++;
      }
    }

    // Calculate cumulative distribution
    final cdf = List<int>.filled(256, 0);
    cdf[0] = histogram[0];
    for (int i = 1; i < 256; i++) {
      cdf[i] = cdf[i - 1] + histogram[i];
    }

    // Normalize CDF
    final totalPixels = image.width * image.height;
    final cdfMin = cdf.firstWhere((v) => v > 0);

    // Apply equalization
    final result = img.Image.from(image);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final lum = image.getPixel(x, y).luminance.toInt();
        final newLum = ((cdf[lum] - cdfMin) * 255 / (totalPixels - cdfMin))
            .round()
            .clamp(0, 255);
        result.setPixelRgba(x, y, newLum, newLum, newLum, 255);
      }
    }

    return result;
  }

  /// Sharpen image to enhance edges
  img.Image _sharpenImage(img.Image image, {double strength = 1.0}) {
    // Manual convolution implementation for sharpening
    final result = img.Image.from(image);
    final w = image.width;
    final h = image.height;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        // Get surrounding pixels
        final center = image.getPixel(x, y).luminance;
        final top = image.getPixel(x, y - 1).luminance;
        final bottom = image.getPixel(x, y + 1).luminance;
        final left = image.getPixel(x - 1, y).luminance;
        final right = image.getPixel(x + 1, y).luminance;

        // Apply sharpening kernel: center * (5 + 4*strength) - edges * strength
        final sharpened =
            (center * (5.0 + 4.0 * strength) -
                    top * strength -
                    bottom * strength -
                    left * strength -
                    right * strength)
                .clamp(0, 255)
                .toInt();

        result.setPixelRgba(x, y, sharpened, sharpened, sharpened, 255);
      }
    }

    return result;
  }

  /// Adaptive thresholding
  img.Image _adaptiveThreshold(img.Image image) {
    // Use Otsu as base threshold
    final globalThreshold = _otsuThreshold(image);

    // Apply local adaptive thresholding in blocks
    const blockSize = 32;
    final result = img.Image.from(image);

    for (int by = 0; by < image.height; by += blockSize) {
      for (int bx = 0; bx < image.width; bx += blockSize) {
        // Calculate local threshold for this block
        int sum = 0;
        int count = 0;

        for (int y = by; y < by + blockSize && y < image.height; y++) {
          for (int x = bx; x < bx + blockSize && x < image.width; x++) {
            sum += image.getPixel(x, y).luminance.toInt();
            count++;
          }
        }

        final localMean = count > 0 ? sum ~/ count : globalThreshold;
        final localThreshold = (localMean * 0.9).toInt(); // Slightly below mean

        // Apply threshold to block
        for (int y = by; y < by + blockSize && y < image.height; y++) {
          for (int x = bx; x < bx + blockSize && x < image.width; x++) {
            final lum = image.getPixel(x, y).luminance.toInt();
            final v = lum < localThreshold ? 0 : 255;
            result.setPixelRgba(x, y, v, v, v, 255);
          }
        }
      }
    }

    return result;
  }

  // ===================================================================
  // POST-PROCESSING (Enhanced)
  // ===================================================================

  /// Enhanced character normalization
  String _normalizeDigitsAndDashes(String s) {
    // Expanded character mapping for common OCR errors
    const map = {
      // Zero variants
      'O': '0', 'o': '0', 'Ө': '0', '߀': '0', 'Q': '0', 'D': '0',

      // One variants
      'I': '1', 'l': '1', '|': '1', 'ı': '1', '¹': '1', 'i': '1', 'L': '1',

      // Two variants
      'Z': '2', 'z': '2', '₂': '2',

      // Three variants
      'E': '3',

      // Four variants
      'A': '4', 'h': '4',

      // Five variants
      'S': '5', 's': '5', '\$': '5',

      // Six variants
      'G': '6', 'b': '6',

      // Seven variants
      'T': '7', 't': '7',

      // Eight variants
      'B': '8', 'ß': '8',

      // Nine variants
      'g': '9', 'q': '9',

      // Dash variants
      '.': '-', '·': '-', 'ˑ': '-', '・': '-', ',': '-', '_': '-',

      // Remove noise
      '/': '', '\\': '', ' ': '',
    };

    final sb = StringBuffer();
    for (final r in s.runes) {
      final ch = String.fromCharCode(r);
      sb.write(map[ch] ?? ch);
    }

    var out = sb.toString();
    // Normalize various dash characters to simple '-'
    out = out.replaceAll(
      RegExp(r'[\u2012\u2013\u2014\u2015\u2212\u2043\u30FC]'),
      '-',
    );

    return out;
  }

  /// Extract FDA number with enhanced pattern matching
  String? _extractFdaNumber(String s) {
    // Pattern: 13 digits (xx-x-xxxxx-x-xxxx)
    // Allow flexible spacing/dashes
    final pattern = RegExp(
      r'(\d{2})[\s\-]?(\d)[\s\-]?(\d{5})[\s\-]?(\d)[\s\-]?(\d{4})',
    );

    String? validateAndJoin(Match m) {
      final prefixStr = m.group(1);
      if (prefixStr == null) return null;
      final prefix = int.tryParse(prefixStr);

      // Safety net: FDA prefix range (00-78)
      if (prefix == null || prefix < 0 || prefix > 78) {
        return null;
      }

      return [
        m.group(1),
        m.group(2),
        m.group(3),
        m.group(4),
        m.group(5),
      ].whereType<String>().join('-');
    }

    // 1. Try line by line first (reduces noise)
    for (final line in s.split(RegExp(r'\r?\n'))) {
      for (final mLine in pattern.allMatches(line)) {
        final fda = validateAndJoin(mLine);
        if (fda != null) return fda;
      }
    }

    // 2. Try full text
    for (final m in pattern.allMatches(s)) {
      final fda = validateAndJoin(m);
      if (fda != null) return fda;
    }

    return null;
  }

  // ===================================================================
  // HELPER FUNCTIONS
  // ===================================================================

  /// Create temporary file for ML Kit
  Future<File> _writeTemp(Uint8List bytes) async {
    final dir = await Directory.systemTemp.createTemp('fda_ocr_');
    final file = File('${dir.path}/input.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Otsu threshold calculation
  int _otsuThreshold(img.Image gray) {
    final hist = List<int>.filled(256, 0);
    final total = gray.width * gray.height;

    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        hist[gray.getPixel(x, y).luminance.toInt()]++;
      }
    }

    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * hist[i];
    }

    double sumB = 0;
    int wB = 0;
    int wF = 0;
    double varMax = -1;
    int threshold = 140;

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

/// Extension to copy FdaOcrResult with modifications
extension FdaOcrResultExtension on FdaOcrResult {
  FdaOcrResult copyWith({
    String? fullText,
    String? fdaNumber,
    String? normalizedText,
    Duration? duration,
    Uint8List? processedBytes,
    int? passNumber,
  }) {
    return FdaOcrResult(
      fullText: fullText ?? this.fullText,
      fdaNumber: fdaNumber ?? this.fdaNumber,
      normalizedText: normalizedText ?? this.normalizedText,
      duration: duration ?? this.duration,
      processedBytes: processedBytes ?? this.processedBytes,
      passNumber: passNumber ?? this.passNumber,
    );
  }
}
