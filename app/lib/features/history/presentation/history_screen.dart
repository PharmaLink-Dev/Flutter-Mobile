
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isIngredientSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: _isIngredientSelected
                ? _buildHistoryList(_ingredientScanHistory)
                : _buildHistoryList(_fdaScanHistory),
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

  Widget _buildHistoryList(List<Map<String, dynamic>> history) {
    return ListView.builder(
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: item['leading'] as Widget,
            title: Text(item['name'] as String),
            subtitle: Text('Scanned on: ${item['date']}'),
            trailing: IconButton(
              icon: Icon(
                (item['isFavorite'] as bool) ? Icons.favorite : Icons.favorite_border,
                color: (item['isFavorite'] as bool) ? Colors.red : null,
              ),
              onPressed: () {
                // Mock favorite toggle
                setState(() {
                  history[index]['isFavorite'] = !(item['isFavorite'] as bool);
                });
              },
            ),
          ),
        );
      },
    );
  }

  // Mock Data
  final List<Map<String, dynamic>> _ingredientScanHistory = [
    {
      'id': '1',
      'name': 'Cosmetic Ingredient',
      'date': '2024-07-28',
      'isFavorite': false,
      'leading': Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const FaIcon(FontAwesomeIcons.leaf, color: Colors.green),
      ),
    },
    {
      'id': '2',
      'name': 'Skincare Ingredient',
      'date': '2024-07-27',
      'isFavorite': true,
      'leading': Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const FaIcon(FontAwesomeIcons.leaf, color: Colors.green),
      ),
    },
  ];

  final List<Map<String, dynamic>> _fdaScanHistory = [
    {
      'id': '3',
      'name': 'FDA Product 1',
      'date': '2024-07-26',
      'isFavorite': false,
      'leading': Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const FaIcon(FontAwesomeIcons.pills, color: Colors.orange),
      ),
    },
  ];
}
