import 'dart:typed_data';
import 'package:app/shared/app_colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'aurora_bg.dart';
import 'package:flutter/cupertino.dart';

typedef OnCaptured = Future<void> Function(Uint8List bytes, String fileName);

class ScanPageTemplate extends StatefulWidget {
  final Widget overlay;
  final String guideText;
  final OnCaptured onCaptured;
  final bool showGalleryUpload;
  final Widget? customSecondaryButton;
  final String headerTitle;

  const ScanPageTemplate({
    super.key,
    required this.overlay,
    required this.guideText,
    required this.onCaptured,
    this.showGalleryUpload = true,
    this.customSecondaryButton,
    this.headerTitle = 'สแกน',
  });

  @override
  State<ScanPageTemplate> createState() => _ScanPageTemplateState();
}

class _ScanPageTemplateState extends State<ScanPageTemplate>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _initializing = false;
  bool _isTorchOn = false;
  bool _openingCamera = false;
  String? _cameraError;

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
    if (_controller == null || !_controller!.value.isInitialized) return;
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
    } catch (e) {
      if (!mounted) return;
      final errorText = 'ไม่สามารถเปิดกล้องได้: $e';
      setState(() {
        _initializing = false;
        _cameraError = errorText;
      });
      final appColors = Theme.of(context).extension<AppColorExtension>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: appColors.error),
      );
    }
  }

  int _preferBackCameraIndex(List<CameraDescription> list) {
    final backIndex = list.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );
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
        _controller = controller;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorText = 'ไม่สามารถเปิดกล้องได้: $e';
      setState(() {
        _initializing = false;
        _cameraError = errorText;
      });
      final appColors = Theme.of(context).extension<AppColorExtension>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText), backgroundColor: appColors.error),
      );
    }
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null) return;
    try {
      final newMode = _isTorchOn ? FlashMode.off : FlashMode.torch;
      await c.setFlashMode(newMode);
      if (mounted) setState(() => _isTorchOn = !_isTorchOn);
    } catch (_) {}
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return;
    try {
      final file = await c.takePicture();
      final bytes = await file.readAsBytes();
      await widget.onCaptured(
        bytes,
        'camera_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ถ่ายภาพไม่สำเร็จ: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      await widget.onCaptured(bytes, picked.name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ไม่สามารถเลือกภาพ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _buildPreview();
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AuroraBackground()),
          Positioned.fill(child: preview),
          Positioned.fill(child: widget.overlay),
          // Glass header with back + flash controls
          Positioned(
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: _PlainHeader(
                title: widget.headerTitle,
                isTorchOn: _isTorchOn,
                onBack: () => context.go('/'),
                onToggleTorch:
                    (_controller != null && _controller!.value.isInitialized)
                    ? _toggleTorch
                    : null,
              ),
            ),
          ),
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
                  Text(
                    widget.guideText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPrimaryButton(),
                  const SizedBox(height: 10),
                  if (widget.customSecondaryButton != null)
                    widget.customSecondaryButton!
                  else if (widget.showGalleryUpload)
                    _buildUploadButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final ready = _controller != null && _controller!.value.isInitialized;
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: AppGradients.button, // This gradient is kept for vibrancy
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            if (!ready) {
              setState(() => _openingCamera = true);
              await _initCamera();
              if (!mounted) return;
              setState(() => _openingCamera = false);
            } else {
              await _capture();
            }
          },
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_openingCamera)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(
                    ready ? Icons.camera : Icons.camera_alt,
                    color: Colors.white,
                  ),
                const SizedBox(width: 8),
                Text(
                  _openingCamera
                      ? 'กำลังเปิดกล้อง…'
                      : (ready ? 'ถ่ายภาพ' : 'เริ่มสแกน'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLight ? Colors.white24 : appColors.outline),
        gradient: LinearGradient(
          colors: isLight
              ? const [Color(0x335E6A75), Color(0x115E6A75)]
              : [
                  appColors.surface.withValues(alpha: 0.8),
                  appColors.surface.withValues(alpha: 0.5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _openingCamera ? null : _pickFromGallery,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.upload,
                  color: isLight ? Colors.white : appColors.text,
                ),
                const SizedBox(width: 8),
                Text(
                  'อัพโหลดรูปภาพ',
                  style: TextStyle(
                    color: isLight ? Colors.white : appColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_initializing) {
      // NEW: Get theme-aware colors
      final appColors = Theme.of(context).extension<AppColorExtension>()!;
      return ColoredBox(
        // CHANGED: Use background color from theme
        color: appColors.background,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const SizedBox.shrink();
    }
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: c.value.previewSize!.height,
          height: c.value.previewSize!.width,
          child: CameraPreview(c),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return InkResponse(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isLight
              ? const Color(0x335E6A75)
              : appColors.surface.withValues(alpha: 0.5),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _PlainHeader extends StatelessWidget {
  final String title;
  final bool isTorchOn;
  final VoidCallback onBack;
  final VoidCallback? onToggleTorch;

  const _PlainHeader({
    required this.title,
    required this.isTorchOn,
    required this.onBack,
    required this.onToggleTorch,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLight
            ? const Color(0x335E6A75)
            : appColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _RoundIconButton(icon: CupertinoIcons.back, onTap: onBack),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: isTorchOn ? Icons.flash_on : Icons.flash_off,
            onTap: onToggleTorch,
          ),
        ],
      ),
    );
  }
}
