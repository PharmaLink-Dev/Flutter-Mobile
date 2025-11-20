import 'dart:typed_data';
import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:flutter/material.dart';
import 'package:app/features/scan/presentation/crop_image_screen.dart';
import 'package:app/features/scan/presentation/widgets/scan_overlay.dart';
import 'package:app/features/scan/presentation/widgets/scan_page_template.dart';

import 'confirmation_page.dart';
import 'package:app/features/ingredient/data/typhoon-ocr.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isLoading = false;
  final _scanService = TyphoonService();

  void _goToCrop(BuildContext context, Uint8List bytes, String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(
          imageBytes: bytes,
          fileName: fileName,
          onCropped: (croppedBytes, originalFilename) async {
            setState(() => _isLoading = true);
            Navigator.of(context).pop();

            try {
              final scanResult = await _scanService.uploadAndScanImage(
                croppedBytes,
              );
              if (!context.mounted) return;

              final List<dynamic> rawIngredients =
                  scanResult['ingredients'] ?? [];
              final List<Ingredient> ingredients = rawIngredients.map((item) {
                return Ingredient(
                  name: item['name'] ?? 'Unknown',
                  status: item['status'] ?? '',
                );
              }).toList();

              final String imagePath = scanResult['imagePath'] ?? '';

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ConfirmationPage(
                    ingredients: ingredients,
                    imagePath: imagePath,
                    scannedImageBytes: croppedBytes,
                  ),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(e.toString())));
            } finally {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScanPageTemplate(
            headerTitle: 'สแกนสาร',
            overlay: const ScanOverlay(width: 320, height: 320),
            guideText: 'วางฉลากให้อยู่ในกรอบ',
            showGalleryUpload: true,
            onCaptured: (bytes, fileName) async =>
                _goToCrop(context, bytes, fileName),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'กำลังอัปโหลดและสแกน...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
