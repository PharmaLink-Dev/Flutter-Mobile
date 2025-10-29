import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:app/shared/app_colors.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/aurora_bg.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _initializing = false;
  bool _isTorchOn = false;
  bool _openingCamera = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
    try {
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
      });
    } catch (e) {
      if (!mounted) return;
      // หากเปิดกล้องล้มเหลว ให้ยกเลิกสถานะโหลดและไม่แสดง preview
      setState(() {
        _controller?.dispose();
        _controller = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เปิดกล้องไม่สำเร็จ: $e')),
      );
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
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
      // พื้นหลังโปร่งใส ใช้ AuroraBackground ใน Stack
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: _RoundIconButton(icon: Icons.arrow_back, onTap: () => context.go('/')),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _RoundIconButton(
              icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
              onTap: (_controller != null && _controller!.value.isInitialized)
                  ? _toggleTorch
                  : null,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground()),
          Positioned.fill(child: preview),
          // Overlay with frame + animated scanning line
          const Positioned.fill(child: ScanOverlay()),
          // Top guide card
          // Bottom instruction, tips, and buttons
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'วางฉลากให้อยู่ในกรอบ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Primary gradient button
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppGradients.scanLabel,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          final ready = _controller != null && _controller!.value.isInitialized;
                          if (!ready) {
                            setState(() => _openingCamera = true);
                            await _initCamera();
                            if (!mounted) return;
                            setState(() => _openingCamera = false);
                          } else {
                            await _captureAndProceed();
                          }
                        },
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PrimaryButtonIcon(),
                              SizedBox(width: 8),
                              _PrimaryButtonLabel(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Secondary upload button
                  Container(
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
                        onTap: _openingCamera ? null : _pickFromGallery,
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, color: Colors.white),
                              SizedBox(width: 8),
                              Text('อัพโหลดรูปภาพ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      return const ColoredBox(
        color: AppColors.background,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      // ยังไม่เริ่มสแกน: ไม่แสดง preview
      return const SizedBox.shrink();
    }
    return CameraPreview(c);
  }
}

class _PrimaryButtonLabel extends StatelessWidget {
  const _PrimaryButtonLabel();
  @override
  Widget build(BuildContext context) {
    final st = context.findAncestorStateOfType<_ScanScreenState>();
    final bool ready = st?._controller != null && st!._controller!.value.isInitialized;
    final bool opening = st?._openingCamera == true;
    return Text(
      opening ? 'กำลังเปิดกล้อง…' : (ready ? 'ถ่ายภาพ' : 'เริ่มสแกน'),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
    );
  }
}

class _PrimaryButtonIcon extends StatelessWidget {
  const _PrimaryButtonIcon();
  @override
  Widget build(BuildContext context) {
    final st = context.findAncestorStateOfType<_ScanScreenState>();
    final bool ready = st?._controller != null && st!._controller!.value.isInitialized;
    final bool opening = st?._openingCamera == true;
    if (opening) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return Icon(ready ? Icons.camera : Icons.camera_alt, color: Colors.white);
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.08),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
