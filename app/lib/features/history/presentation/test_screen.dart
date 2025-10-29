import 'dart:io';
import 'dart:typed_data';
import 'package:app/features/history/data/ingredient.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final _historyBox = Hive.box<ScanHistory>('history');
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  // --- Core Logic (accepts image bytes) ---
  Future<void> _runFlow({required Uint8List imageBytes, required String source}) async {
    setState(() => _isLoading = true);

    try {
      final List<Ingredient> mockIngredients = [
        Ingredient(name: "Source: $source", description: "Test Data", safetyLevel: "Safe"),
        Ingredient(name: "Glycerin", description: "Humectant", safetyLevel: "Safe"),
        Ingredient(name: "Phenoxyethanol", description: "Preservative", safetyLevel: "Warning"),
      ];

      // CRITICAL STEP: Save image to cache and get the path
      final String? imagePath = await _saveImageToCache(imageBytes);
      if (imagePath == null) throw Exception("Failed to save image.");

      // LOG aS REQUESTED: Print the file path to the console
      print("✅ Image saved to cache at: $imagePath");

      final newHistory = ScanHistory(
        id: const Uuid().v4(),
        imagePath: imagePath,
        ingredients: mockIngredients,
        scanDate: DateTime.now(),
      );
      await _historyBox.put(newHistory.id, newHistory);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Success! Saved from $source. Path: $imagePath")),
      );

    } catch (e) {
      print("❌ Flow Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Flow Failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Button Handlers ---

  /// Runs the flow with a generated mock image
  Future<void> _handleMockTest() async {
    final Uint8List mockImageBytes = _createMockImage();
    await _runFlow(imageBytes: mockImageBytes, source: "Mock Image");
  }

  /// Runs the flow with an image uploaded from the gallery
  Future<void> _handleUploadTest() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      print("No image selected.");
      return; // User cancelled the picker
    }

    final Uint8List uploadedImageBytes = await pickedFile.readAsBytes();
    await _runFlow(imageBytes: uploadedImageBytes, source: "Uploaded Image");
  }

  // --- Helper Functions ---

  Uint8List _createMockImage() {
    final mockImage = img.Image(width: 100, height: 100);
    img.fill(mockImage, color: img.ColorRgb8(100, 150, 200));
    return Uint8List.fromList(img.encodePng(mockImage));
  }

  Future<String?> _saveImageToCache(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${const Uuid().v4()}.png';
    final filePath = '${tempDir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Caching Flow'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _historyBox.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Hive box cleared!")),
              );
            },
            tooltip: 'Clear Hive Box',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _handleUploadTest,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('1. Upload, Save & Test'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleMockTest,
              child: const Text('2. Run with Mock Image'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Data in Hive Box:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _historyBox.listenable(),
                builder: (context, Box<ScanHistory> box, _) {
                  if (box.values.isEmpty) {
                    return const Center(child: Text('Hive box is empty. Press a button to test.'));
                  }
                  final historyItems = box.values.toList().reversed.toList();
                  return ListView.builder(
                    itemCount: historyItems.length,
                    itemBuilder: (context, index) {
                      final item = historyItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // CRITICAL TEST: Load image from file path
                              Image.file(
                                File(item.imagePath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print("❌ Error loading image for item ${item.id}: $error");
                                  return const Icon(Icons.error, color: Colors.red, size: 40);
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Scan from: ${item.scanDate.toShortString()}"),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4.0,
                                      runSpacing: 4.0,
                                      children: item.ingredients.map((ing) {
                                        return Chip(
                                          label: Text(ing.name, style: const TextStyle(fontSize: 12)),
                                          backgroundColor: _getColorForSafety(ing.safetyLevel),
                                          padding: EdgeInsets.zero,
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSafety(String safetyLevel) {
    switch (safetyLevel) {
      case "Safe":
        return Colors.green.shade100;
      case "Warning":
        return Colors.orange.shade100;
      case "Danger":
        return Colors.red.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}

extension on DateTime {
  String toShortString() {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }
}
