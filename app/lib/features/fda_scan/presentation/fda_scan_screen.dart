import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';
import 'widgets/fda_input_dialog.dart';

class FdaScanScreen extends StatelessWidget {
  const FdaScanScreen({super.key});

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(imageBytes: bytes, fileName: fileName),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return ScanPageTemplate(
      headerTitle: 'สแกนเลข FDA',
      overlay: const ScanOverlay(width: 360, height: 100),
      guideText: 'วางเลข FDA ในกรอบ',
      showGalleryUpload: false,
      customSecondaryButton: _fdaInputButton(context),
      onCaptured: (bytes, fileName) async => _goToCrop(context, bytes, fileName),
    );
  }
}
