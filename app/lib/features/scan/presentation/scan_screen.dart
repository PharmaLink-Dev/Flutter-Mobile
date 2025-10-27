import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _initializing = true;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initSelectedCamera();
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      _cameraIndex = _preferBackCameraIndex(_cameras);
      await _initSelectedCamera();
    } catch (_) {
      if (mounted) setState(() => _initializing = false);
    }
  }

  int _preferBackCameraIndex(List<CameraDescription> list) {
    final backIndex = list.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    return backIndex >= 0 ? backIndex : (list.isNotEmpty ? 0 : 0);
  }

  Future<void> _initSelectedCamera() async {
    if (_cameras.isEmpty) return;
    setState(() => _initializing = true);
    final selected = _cameras[_cameraIndex];
    final controller = CameraController(
      selected,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    try {
      await controller.setFlashMode(FlashMode.off);
      _isTorchOn = false;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _controller?.dispose();
      _controller = controller;
      _initializing = false;
    });
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null) return;
    try {
      final next = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await c.setFlashMode(next);
      setState(() => _isTorchOn = !_isTorchOn);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _initSelectedCamera();
  }

  Future<void> _captureAndProceed() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      _goToCrop(bytes, fileName: 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ถ่ายภาพไม่สำเร็จ: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      _goToCrop(bytes, fileName: picked.name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกภาพ: $e')));
    }
  }

  void _goToCrop(Uint8List bytes, {required String fileName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(imageBytes: bytes, fileName: fileName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('สแกนฉลาก/บาร์โค้ด'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: preview),
          const Positioned.fill(child: ScanOverlay()),
          Positioned(
            top: 24,
            right: 16,
            child: Column(
              children: [
                _CircleIconButton(
                  icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  onTap: _toggleTorch,
                ),
                const SizedBox(height: 12),
                _CircleIconButton(
                  icon: Icons.cameraswitch,
                  onTap: _switchCamera,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CircleIconButton(icon: Icons.photo_library, onTap: _pickFromGallery),
                const SizedBox(width: 24),
                GestureDetector(
                  onTap: _captureAndProceed,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 3),
                      color: Colors.white24,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text('ไม่สามารถเปิดกล้องได้', style: TextStyle(color: Colors.white70)),
        ),
      );
    }
    return CameraPreview(c);
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CircleIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black38,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
