import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';

import 'widgets/fda_input_dialog.dart';
import 'package:app/features/fda_scan/data/fda_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/fda_scan/data/fda_search_service.dart';
import 'package:app/features/fda_scan/presentation/fda_success_screen.dart';
import 'package:app/features/fda_scan/presentation/fda_not_found_screen.dart';

class FdaScanScreen extends StatelessWidget {
  const FdaScanScreen({super.key});

  Future<void> _showFdaNotFoundDialog(BuildContext context, String rawText) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ไม่พบเลข FDA'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('ลองถ่ายใหม่หรือกรอกเลขด้วยตนเอง'),
              const SizedBox(height: 12),
              const Text('ผลลัพธ์การสแกน', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(rawText.isEmpty ? '-' : rawText),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndPresentFda(BuildContext context, String fda) async {
    try {
      final service = FdaSearchService();
      // Fetch using digits-only (no dashes/spaces), same as manual entry flow
      final query = fda.replaceAll(RegExp(r'[^0-9]'), '');
      final map = await service.fetchByFdpdtno(query);
      if (!context.mounted) return;
      if (FdaSearchService.isValidResult(map)) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FdaSuccessScreen(data: map),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FdaNotFoundScreen(scannedRaw: fda),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FdaNotFoundScreen(scannedRaw: fda),
        ),
      );
    }
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
        gradient: const LinearGradient(
          colors: [Color(0x335E6A75), Color(0x115E6A75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
                Text(label, style: textStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(
          imageBytes: bytes,
          fileName: fileName,
          onCropped: (cropped) async {
            final ocr = FdaOcr();
            final result = await ocr.recognize(cropped);
            if (!context.mounted) return;

            final fda = result.fdaNumber;
            if (fda == null) {
              await _showFdaNotFoundDialog(context, result.fullText);
              return;
            }

            await _fetchAndPresentFda(context, fda);
          },
        ),
      ),
    );
  }

  Future<void> _openFdaInputDialog(BuildContext context) async {
    final result = await showFdaInputDialog(context);
    if (result == null || result.trim().isEmpty) {
      return;
    }
    if (!context.mounted) return;
    await _fetchAndPresentFda(context, result);
  }

  Widget _fdaInputButton(BuildContext context) {
    return _actionButton(
      icon: Icons.edit,
      label: 'กรอกเลข FDA',
      onTap: () => _openFdaInputDialog(context),
    );
  }

  Future<void> _pickFromGalleryAndGoToCrop(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!context.mounted) return;
      _goToCrop(context, bytes, picked.name);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเลือกภาพ: $e')),
      );
    }
  }

  Widget _galleryUploadButton(BuildContext context) {
    return _actionButton(
      icon: Icons.upload,
      label: 'อัปโหลดรูปภาพ',
      onTap: () => _pickFromGalleryAndGoToCrop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageTemplate(
      headerTitle: 'สแกนเลข FDA',
      overlay: const ScanOverlay(width: 360, height: 100),
      guideText: 'วางเลข FDA ในกรอบ',
      showGalleryUpload: true,
      customSecondaryButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fdaInputButton(context),
          const SizedBox(height: 10),
          _galleryUploadButton(context),
        ],
      ),
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
