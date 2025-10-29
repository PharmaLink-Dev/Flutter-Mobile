import 'dart:io';
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
  bool _isIngredientSelected = true; // For future use with FDA scans

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("History cleared!")),
              );
            },
            tooltip: 'Clear History',
          )
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _historyBox.listenable(),
              builder: (context, Box<ScanHistory> box, _) {
                if (box.values.isEmpty) {
                  return const Center(
                    child: Text('No history yet. Go to the Test Screen to add data.'),
                  );
                }
                final historyItems = box.values.toList().reversed.toList();

                // For now, we only have one type of history
                if (_isIngredientSelected) {
                  return _buildHistoryList(historyItems);
                } else {
                  // Placeholder for FDA History
                  return const Center(child: Text('FDA History (coming soon)'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    // ... (This widget remains the same as before)
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isIngredientSelected = true),
            style: TextButton.styleFrom(
              backgroundColor: _isIngredientSelected ? Colors.blue.withOpacity(0.1) : null,
            ),
            child: const Text('Ingredient'),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () => setState(() => _isIngredientSelected = false),
            style: TextButton.styleFrom(
              backgroundColor: !_isIngredientSelected ? Colors.blue.withOpacity(0.1) : null,
            ),
            child: const Text('อย.'),
          ),
        ),
      ],
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
                setState(() {
                  item.isFavorite = !item.isFavorite;
                  item.save(); // Save the change back to Hive
                });
              },
            ),
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
