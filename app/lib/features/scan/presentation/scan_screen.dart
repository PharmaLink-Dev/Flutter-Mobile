import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Added for navigation
import 'package:dotted_border/dotted_border.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    debugPrint("🔄 ScanScreen initState called");
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      // Dispose existing controller if any
      await _controller?.dispose();
      _controller = null;
      _initializeControllerFuture = null;

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = "No camera found (emulator may not support it)";
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Cannot open camera: $e";
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      _showError("Camera is not ready");
      return;
    }

    try {
      final image = await _controller!.takePicture();
      if (mounted) {
        context.go("/"); // Navigate back to home
      }
    } catch (e) {
      debugPrint("Take picture error: $e");
      _showError("Failed to take picture: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _closeCameraAndExit() async {
    try {
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint("Error disposing camera: $e");
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    context.go('/');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error if any
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.pop(), // Go back
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      );
    }

    // Loading
    if (_controller == null || _initializeControllerFuture == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text("Opening camera...", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      "Error occurred: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _closeCameraAndExit,
                      child: const Text("Back"),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_controller!)),

                // Center dotted frame
                Center(
                  child: DottedBorder(
                    borderType: BorderType
                        .RRect, // ใช้ RRect เพื่อให้ corner radius ทำงาน
                    radius: const Radius.circular(22),
                    color: Colors.white,
                    strokeWidth: 3,
                    dashPattern: const [8, 4], // length of dash / gap
                    child: Container(
                      width: 280,
                      height: 420,
                      color: Colors.transparent, // ใส่โปร่งใส
                    ),
                  ),
                ),

                // Cancel button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.5),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _closeCameraAndExit,
                        ),
                      ),
                    ),
                  ),
                ),

                // Take picture button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.camera, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}
