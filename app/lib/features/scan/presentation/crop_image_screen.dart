import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

typedef CropCallback = Future<void> Function(Uint8List croppedBytes, String originalFilename);

class CropImageScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String fileName;
  final CropCallback onCropped;

  const CropImageScreen({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.onCropped,
  });

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final _controller = CropController();
  bool _isUploading = false;
  bool _isReady = false;

  Future<void> _onCropped(Uint8List cropped) async {
    setState(() => _isUploading = true);
    try {
      await widget.onCropped(cropped, widget.fileName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
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
            onPressed: _isUploading || !_isReady
                ? null
                : () {
                    try {
                      _controller.crop();
                    } catch (e) {
                      // ป้องกันเคส InvalidRectError จากไลบรารีเมื่อกรอบไม่พร้อม/ไม่ถูกต้อง
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ไม่สามารถครอบภาพได้ กรุณาลองปรับกรอบแล้วกดใหม่')),
                      );
                    }
                  },
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
              maskColor: Colors.black.withValues(alpha: 0.5),
              onCropped: _onCropped,
              // เปิดปุ่มเฉพาะเมื่อสถานะพร้อม เพื่อลดโอกาสเกิด InvalidRectError
              onStatusChanged: (status) {
                setState(() => _isReady = status == CropStatus.ready);
              },
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
