import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';
import 'widgets/fda_input_dialog.dart';
import 'package:app/features/fda_scan/data/fda_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/fda_scan/data/fda_search_service.dart';

class FdaScanScreen extends StatelessWidget {
  const FdaScanScreen({super.key});

  // UI helpers
  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showFdaResultDialog(
    BuildContext context,
    Map<String, String?> data,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        final entries = data.entries
            .map((e) => '${e.key}: ${e.value ?? '-'}')
            .join('\n');
        return AlertDialog(
          title: const Text('ผลการค้นหา FDA'),
          content: SingleChildScrollView(child: Text(entries)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFdaNotFoundDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('ไม่พบเลข FDA'),
        content: Text('ลองถ่ายใหม่หรือกรอกเลขด้วยตนเอง'),
      ),
    );
  }

  Future<void> _fetchAndPresentFda(BuildContext context, String fda) async {
    try {
      final service = FdaSearchService();
      final map = await service.fetchByFdpdtno(fda);
      if (!context.mounted) return;
      await _showFdaResultDialog(context, map);
    } catch (e) {
      if (!context.mounted) return;
      _showSnack(context, 'ดึงข้อมูลไม่สำเร็จ: $e');
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
              await _showFdaNotFoundDialog(context);
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
      if (!context.mounted) return;
      _showSnack(context, 'กรุณากรอกเลข FDA');
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
        ],
      ),
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
