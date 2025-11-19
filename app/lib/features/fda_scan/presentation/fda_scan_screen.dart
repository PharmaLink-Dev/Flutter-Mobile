import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';

import '../data/fda_ocr.dart';
import 'widgets/fda_input_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/fda_scan/presentation/fda_flow_service.dart';

class FdaScanScreen extends StatelessWidget {
  const FdaScanScreen({super.key});

  Future<void> _showFdaNotFoundDialog(
    BuildContext context,
    FdaOcrResult result,
  ) async {
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
              const Text(
                'ผลลัพธ์การสแกน',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(result.fullText.isEmpty ? '-' : result.fullText),
              if (result.normalizedText != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'ผลลัพธ์หลังปรับปรุง',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(result.normalizedText!),
              ],
              const SizedBox(height: 12),
              Text(
                'ประมวลผลใน: ${result.duration.inMilliseconds}ms',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
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
          onCropped: (cropped, _) async {
            final ocr = FdaOcr();
            final result = await ocr.recognize(cropped);
            if (!context.mounted) return;

            final fda = result.fdaNumber;
            if (fda == null) {
              await _showFdaNotFoundDialog(context, result);
              return;
            }

            await FdaFlowService(context).fetchAndNavigate(fda);
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
    await FdaFlowService(context).fetchAndNavigate(result);
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกภาพ: $e')));
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
      onCaptured: (bytes, fileName) async =>
          _goToCrop(context, bytes, fileName),
    );
  }
}
