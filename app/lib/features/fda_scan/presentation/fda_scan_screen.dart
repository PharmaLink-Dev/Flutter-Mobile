import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';
import 'widgets/fda_input_dialog.dart';
import 'package:app/features/fda_scan/data/fda_ocr.dart';
import 'package:image_picker/image_picker.dart';

class FdaScanScreen extends StatelessWidget {
  const FdaScanScreen({super.key});

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(
          imageBytes: bytes,
          fileName: fileName,
          onCropped: (cropped) async {
            final ocr = FdaOcr();
            final result = await ocr.recognize(cropped);
            if (!context.mounted) return null;
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('OCR (${result.duration.inMilliseconds} ms)'),
                content: Text(result.fdaNumber ?? '(ไม่พบเลข FDA)'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ปิด'),
                  ),
                ],
              ),
            );
            return null;
          },
        ),
      ),
    );
  }

  Future<void> _pickFromGalleryDebug(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (context.mounted) {
        _goToCrop(context, bytes, picked.name);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เลือกภาพไม่สำเร็จ: $e')),
      );
    }
  }

  Future<void> _openFdaInputDialog(BuildContext context) async {
    final result = await showFdaInputDialog(context);
    if (result != null && result.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ค้นหา: $result')));
      // TODO: นำทางไปหน้าผลลัพธ์หรือเรียก API ตรวจสอบ
    }
  }

  Widget _fdaInputButton(BuildContext context) {
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
          onTap: () => _openFdaInputDialog(context),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, color: Colors.white),
                SizedBox(width: 8),
                Text('กรอกเลข FDA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _debugUploadButton(BuildContext context) {
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
          onTap: () => _pickFromGalleryDebug(context),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload, color: Colors.white),
                SizedBox(width: 8),
                Text('อัปโหลดรูป (debug)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScanPageTemplate(
      headerTitle: 'สแกนเลข FDA',
      overlay: const ScanOverlay(width: 360, height: 100),
      guideText: 'วางเลข FDA ในกรอบ',
      showGalleryUpload: false,
      customSecondaryButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _fdaInputButton(context),
          const SizedBox(height: 10),
          _debugUploadButton(context),
        ],
      ),
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
