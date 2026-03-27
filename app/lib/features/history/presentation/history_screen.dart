import 'dart:io';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/history/data/scan_history.dart';

import 'package:app/features/fda_scan/presentation/fda_success_screen.dart';
import 'package:app/features/ingredient/presentation/result_Page.dart';

import 'package:app/features/ingredient/data/ingredient.dart';
import 'history_widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'history_utils.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyBox = Hive.box<ScanHistory>('history');
  final _fdaScanBox = Hive.box<FdaScan>('fda_scans');
  bool _isIngredientSelected = true;
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primaryHeader),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor:
            appColors.surface, // Automatically colors title and icons
        title: Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: appColors.surface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? appColors.error : appColors.surface,
            ),
            onPressed: () =>
                setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            tooltip: 'Show Favorites Only',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: Column(
        children: [
          HistoryToggleButtons(
            isIngredientSelected: _isIngredientSelected,
            onToggle: (value) => setState(() => _isIngredientSelected = value),
          ),
          Expanded(
            child: _isIngredientSelected
                ? _buildIngredientHistory()
                : _buildFdaHistory(),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToIngredientResult(ScanHistory item) async {
    final List<Ingredient> ingredientsForDisplay = item.ingredients.map((
      histIng,
    ) {
      return Ingredient(
        name: histIng.name,
        status: histIng.status,
        riskLevel: histIng.riskLevel,
        description: histIng.description,
      );
    }).toList();

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultPage(
          ingredients: ingredientsForDisplay,
          imageBytes: item.imageBytes,
          imagePath: item.imagePath,
          heroTag: 'ingredient_${item.scanDate.millisecondsSinceEpoch}',
        ),
      ),
    );
  }

  Widget _buildIngredientHistory() {
    return ValueListenableBuilder(
      valueListenable: _historyBox.listenable(),
      builder: (context, Box<ScanHistory> box, _) {
        if (box.values.isEmpty) {
          return const EmptyState(message: 'No ingredient scan history yet.');
        }

        var items = box.values.toList();

        if (_showFavoritesOnly) {
          items = items.where((item) => item.isFavorite).toList();
          if (items.isEmpty) {
            return const EmptyState(message: 'No favorite items yet.');
          }
        }

        items.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.scanDate.compareTo(a.scanDate);
        });

        final grouped = HistoryGrouper.groupByTimeRange(
          items,
          (item) => item.scanDate,
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final group = grouped[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimeGroupHeader(title: group['title'] as String),
                ...List.generate(
                  (group['items'] as List<ScanHistory>).length,
                  (i) => IngredientCard(
                    item: (group['items'] as List<ScanHistory>)[i],
                    onFavoriteToggle: () => setState(() {}),
                    onDelete: () => _deleteIngredientItem(
                      (group['items'] as List<ScanHistory>)[i],
                    ),
                    onTap: () => _navigateToIngredientResult(
                      (group['items'] as List<ScanHistory>)[i],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFdaHistory() {
    return ValueListenableBuilder(
      valueListenable: _fdaScanBox.listenable(),
      builder: (context, Box<FdaScan> box, _) {
        if (box.values.isEmpty) {
          return const EmptyState(message: 'No FDA scan history yet.');
        }

        var items = box.values.toList();

        if (_showFavoritesOnly) {
          items = items.where((item) => item.isFavorite).toList();
          if (items.isEmpty) {
            return const EmptyState(message: 'No favorite items yet.');
          }
        }

        items.sort((a, b) {
          if (a.isFavorite && !b.isFavorite) return -1;
          if (!a.isFavorite && b.isFavorite) return 1;
          return b.scanDate.compareTo(a.scanDate);
        });

        final grouped = HistoryGrouper.groupByTimeRange(
          items,
          (item) => item.scanDate,
        );

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final group = grouped[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TimeGroupHeader(title: group['title'] as String),
                ...List.generate(
                  (group['items'] as List<FdaScan>).length,
                  (i) => FdaCard(
                    item: (group['items'] as List<FdaScan>)[i],
                    onFavoriteToggle: () => setState(() {}),
                    onDelete: () =>
                        _deleteFdaItem((group['items'] as List<FdaScan>)[i]),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FdaSuccessScreen(
                            data: (group['items'] as List<FdaScan>)[i].fdaData,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteIngredientItem(ScanHistory item) async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    await item.delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted'),
          backgroundColor: appColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteFdaItem(FdaScan item) async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    await item.delete();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item deleted'),
          backgroundColor: appColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear All History?',
          style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
        ),
        content: Text(
          'This will permanently delete all your scan history. This action cannot be undone.',
          style: TextStyle(color: appColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: appColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: appColors.error.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Delete All',
                style: TextStyle(
                  color: appColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete ?? false) {
      await _historyBox.clear();
      await _fdaScanBox.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All history cleared!'),
            backgroundColor: appColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
