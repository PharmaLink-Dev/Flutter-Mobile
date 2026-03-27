import 'dart:io';
import 'package:app/features/history/data/fda_scan.dart';
import 'package:app/features/history/data/scan_history.dart';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'history_utils.dart';

// ============================================
// Toggle Buttons
// ============================================
class HistoryToggleButtons extends StatelessWidget {
  final bool isIngredientSelected;
  final Function(bool) onToggle;

  const HistoryToggleButtons({
    super.key,
    required this.isIngredientSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'Ingredient',
              isSelected: isIngredientSelected,
              onTap: () => onToggle(true),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'FDA',
              isSelected: !isIngredientSelected,
              onTap: () => onToggle(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? appColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// Empty State
// ============================================
class EmptyState extends StatelessWidget {
  final String message;

  const EmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: appColors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: appColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ============================================
// Time Group Header
// ============================================
class TimeGroupHeader extends StatelessWidget {
  final String title;

  const TimeGroupHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: appColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ============================================
// Ingredient Card
// ============================================
class IngredientCard extends StatelessWidget {
  final ScanHistory item;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const IngredientCard({
    super.key,
    required this.item,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final ingredientsPreview = item.ingredients.map((e) => e.name).take(3).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key('ingredient_${item.scanDate.millisecondsSinceEpoch}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: appColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: appColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Delete Item?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
                ),
                content: Text(
                  'Are you sure you want to delete this scan?',
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
                        'Delete',
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
          },
          onDismissed: (direction) {
            onDelete();
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Image
                    Hero(
                      tag: 'ingredient_${item.scanDate.millisecondsSinceEpoch}',
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: appColors.background,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.imageBytes != null
                              ? Image.memory(
                                  item.imageBytes!,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(item.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      color: appColors.textSecondary.withValues(alpha: 0.5),
                                      size: 32,
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.scanName, // Use the custom scan name
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contains: $ingredientsPreview',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: appColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: appColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatTime(item.scanDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favorite Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          item.isFavorite = !item.isFavorite;
                          item.save();
                          onFavoriteToggle();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            item.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item.isFavorite
                                ? appColors.error
                                : appColors.textSecondary.withValues(alpha: 0.7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// FDA Card
// ============================================
class FdaCard extends StatelessWidget {
  final FdaScan item;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const FdaCard({
    super.key,
    required this.item,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: Key('fda_${item.scanDate.millisecondsSinceEpoch}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: appColors.error,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 28),
          ),
          confirmDismiss: (direction) async {
            // Re-using the same dialog logic from IngredientCard
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: appColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Delete Item?',
                  style: TextStyle(fontWeight: FontWeight.bold, color: appColors.text),
                ),
                content: Text(
                  'Are you sure you want to delete this scan?',
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
                        'Delete',
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
          },
          onDismissed: (direction) {
            onDelete();
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // FDA Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: appColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.verified_user,
                        color: appColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.scanName ?? 'FDA Scan', // Use product name, with fallback
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: appColors.text,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.fdaNumber, // Show FDA Number as subtitle
                            style: TextStyle(
                              fontSize: 14,
                              color: appColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: appColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.formatTime(item.scanDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: appColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favorite Button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          item.isFavorite = !item.isFavorite;
                          item.save();
                          onFavoriteToggle();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            item.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: item.isFavorite
                                ? appColors.error
                                : appColors.textSecondary.withValues(alpha: 0.7),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
