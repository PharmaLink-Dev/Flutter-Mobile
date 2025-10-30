import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(imageBytes: bytes, fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageTemplate(
      headerTitle: 'สแกนสาร',
      overlay: const ScanOverlay(width: 300, height: 500),
      guideText: 'วางฉลากให้อยู่ในกรอบ',
      showGalleryUpload: true,
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
