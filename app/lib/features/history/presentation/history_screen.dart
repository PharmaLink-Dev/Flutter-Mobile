import 'dart:io';
import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyBox = Hive.box<ScanHistory>('history');
  final _fdaScanBox = Hive.box<FdaScan>('fda_scans');
  bool _isIngredientSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _historyBox.clear();
              await _fdaScanBox.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All history cleared!")),
              );
            },
            tooltip: 'Clear All History',
          )
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: _isIngredientSelected
                ? _buildIngredientHistory()
                : _buildFdaHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isIngredientSelected = true),
            style: TextButton.styleFrom(
              backgroundColor:
                  _isIngredientSelected ? Colors.blue.withOpacity(0.1) : null,
            ),
            child: const Text('Ingredient'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isIngredientSelected = false),
            style: TextButton.styleFrom(
              backgroundColor:
                  !_isIngredientSelected ? Colors.blue.withOpacity(0.1) : null,
            ),
            child: const Text('อย.'),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientHistory() {
    return ValueListenableBuilder(
      valueListenable: _historyBox.listenable(),
      builder: (context, Box<ScanHistory> box, _) {
        if (box.values.isEmpty) {
          return const Center(
            child: Text('No ingredient scan history yet.'),
          );
        }
        final items = box.values.toList().reversed.toList();
        return _buildHistoryList(items);
      },
    );
  }

  Widget _buildFdaHistory() {
    return ValueListenableBuilder(
      valueListenable: _fdaScanBox.listenable(),
      builder: (context, Box<FdaScan> box, _) {
        if (box.values.isEmpty) {
          return const Center(
            child: Text('No FDA scan history yet.'),
          );
        }
        final items = box.values.toList().reversed.toList();
        return _buildFdaScanList(items);
      },
    );
  }

  Widget _buildHistoryList(List<ScanHistory> history) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Image.file(
              File(item.imagePath),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
            title: Text(
              item.ingredients.map((e) => e.name).join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text('Scanned on: ${item.scanDate.toShortString()}'),
            trailing: IconButton(
              icon: Icon(
                item.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: item.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                // This requires item to be a HiveObject
                item.isFavorite = !item.isFavorite;
                item.save(); 
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFdaScanList(List<FdaScan> fdaScans) {
    return ListView.builder(
      itemCount: fdaScans.length,
      itemBuilder: (context, index) {
        final item = fdaScans[index];
        final productName = item.fdaData['ชื่อผลิตภัณฑ์(TH)'] ?? 'N/A';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: item.imagePath != null
                ? Image.file(File(item.imagePath!), width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.document_scanner_outlined, size: 40),
            title: Text(item.scanName),
            subtitle: Text("Product: $productName\nScanned on: ${item.scanDate.toShortString()}"),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

extension on DateTime {
  String toShortString() {
    return "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
  }
}
