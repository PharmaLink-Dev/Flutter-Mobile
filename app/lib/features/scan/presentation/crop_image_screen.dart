import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:app/features/scan/data/ocr_uploader.dart';

class CropImageScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String fileName;

  const CropImageScreen({super.key, required this.imageBytes, this.fileName = 'image.jpg'});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final _controller = CropController();
  bool _isUploading = false;

  Future<void> _onCropped(Uint8List cropped) async {
    setState(() => _isUploading = true);
    try {
      final uploader = OcrUploader();
      final resp = await uploader.uploadImageBytes(cropped, filename: widget.fileName);
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'อัปโหลดสำเร็จ' : 'อัปโหลดไม่สำเร็จ (${resp.statusCode})')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == 'Scan');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการอัปโหลด: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ครอบภาพ'),
        actions: [
          IconButton(
            onPressed: _isUploading ? null : () => _controller.crop(),
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Crop(
              controller: _controller,
              image: widget.imageBytes,
              baseColor: Colors.black,
              maskColor: Colors.black.withOpacity(0.5),
              onCropped: _onCropped,
              withCircleUi: false,
              cornerDotBuilder: (size, edgeAlignment) => Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

