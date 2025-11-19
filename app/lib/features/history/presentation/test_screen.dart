import 'dart:io';
import 'dart:typed_data';
import 'package:app/features/fda_scan/data/fda_search_service.dart';
import 'package:app/features/history/data/fda_scan.dart';
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
  final _fdaScanBox = Hive.box<FdaScan>('fda_scans');
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  // --- Button Handlers ---

  Future<void> _handleIngredientUploadTest() async {
    final XFile? pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final bytes = await pickedFile.readAsBytes();
    await _runIngredientFlow(imageBytes: bytes, source: "Uploaded Image");
  }

  Future<void> _handleIngredientMockTest() async {
    final Uint8List mockImageBytes = _createMockImage();
    await _runIngredientFlow(imageBytes: mockImageBytes, source: "Mock Image");
  }

  /// New combined FDA Test: Upload image, then fetch data for a hardcoded FDA number.
  Future<void> _handleFdaUploadAndSaveTest() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image selection cancelled.")));
      return;
    }

    setState(() => _isLoading = true);
    const fdaNumber = '1310044910142'; // Hardcoded FDA number for the test

    try {
      final imageBytes = await pickedFile.readAsBytes();
      final imagePath = await _saveImageToCache(imageBytes);
      if (imagePath == null) throw Exception("Failed to save image.");

      final data = await FdaSearchService().fetchByFdpdtno(fdaNumber);

      final newFdaScan = FdaScan(
        id: const Uuid().v4(),
        fdaNumber: fdaNumber,
        scanDate: DateTime.now(),
        fdaData: data,
        imagePath: imagePath, // Now we save the image path
        scanName: "Test: $fdaNumber",
      );

      await _fdaScanBox.put(newFdaScan.id, newFdaScan);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ FDA Scan for $fdaNumber with image saved!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("FDA test flow failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- Core Logic for Ingredients ---

  Future<void> _runIngredientFlow(
      {required Uint8List imageBytes, required String source}) async {
    setState(() => _isLoading = true);
    try {
      final ingredients = [
        Ingredient(name: "Source: $source", description: "Test Data", safetyLevel: "Safe"),
        Ingredient(name: "Glycerin", description: "Humectant", safetyLevel: "Safe"),
      ];
      final imagePath = await _saveImageToCache(imageBytes);
      if (imagePath == null) throw Exception("Failed to save image.");

      final newHistory = ScanHistory(
        id: const Uuid().v4(),
        imagePath: imagePath,
        ingredients: ingredients,
        scanDate: DateTime.now(),
      );
      await _historyBox.put(newHistory.id, newHistory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Success! Saved from $source.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Flow Failed: $e")));
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
        title: const Text('Test Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _historyBox.clear();
              await _fdaScanBox.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All Hive boxes cleared!")),
              );
            },
            tooltip: 'Clear All Hive Boxes',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _handleIngredientUploadTest,
              child: const Text('1. Ingredient: Upload & Save'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleIngredientMockTest,
              child: const Text('2. Ingredient: Mock & Save'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleFdaUploadAndSaveTest,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100),
              child: const Text('3. FDA: Upload & Save Test'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _buildSection(
                      title: 'Ingredient Scans',
                      box: _historyBox,
                      builder: (box) => _buildHistoryListView(box.values.toList().reversed.toList()),
                    ),
                  ),
                  const VerticalDivider(width: 20),
                  Expanded(
                    child: _buildSection(
                      title: 'FDA Scans',
                      box: _fdaScanBox,
                      builder: (box) => _buildFdaScanListView(box.values.toList().reversed.toList()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection<T extends HiveObject>(
      {required String title, required Box<T> box, required Widget Function(Box<T>) builder}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box<T> box, _) {
              if (box.values.isEmpty) return Center(child: Text('$title history is empty.'));
              return builder(box);
            },
          ),
        ),
      ],
    );
  }

  ListView _buildHistoryListView(List<ScanHistory> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Image.file(File(item.imagePath), width: 60, height: 60, fit: BoxFit.cover),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.scanDate.toShortString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      Wrap(spacing: 4, children: item.ingredients.map((ing) => Chip(label: Text(ing.name, style: const TextStyle(fontSize: 10)))).toList()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  ListView _buildFdaScanListView(List<FdaScan> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final productName = item.fdaData['ชื่อผลิตภัณฑ์(TH)'] ?? 'N/A';
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: item.imagePath != null
                ? Image.file(File(item.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.document_scanner_outlined, size: 40),
            title: Text(item.scanName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Product: $productName"),
          ),
        );
      },
    );
  }
}

extension on DateTime {
  String toShortString() => "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
}
