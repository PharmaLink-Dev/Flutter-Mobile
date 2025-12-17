import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

class IngredientResultCard extends StatefulWidget {
  final Ingredient ingredient;

  const IngredientResultCard({
    super.key,
    required this.ingredient,
  });

  @override
  State<IngredientResultCard> createState() => _IngredientResultCardState();
}

class _IngredientResultCardState extends State<IngredientResultCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final ingredient = widget.ingredient;
    final displayName = (ingredient.searchTerm != null &&
            ingredient.searchTerm!.trim().isNotEmpty)
        ? ingredient.searchTerm!
        : ingredient.name;
    final statusColor = _statusColor(ingredient.status, appColors);
    final statusLabel =
        ingredient.status.isNotEmpty ? ingredient.status : 'ไม่มีข้อมูล';

    final double? mgValue = ingredient.mg;
    String? mgLabel;
    if (mgValue != null) {
      final bool isInt = mgValue % 1 == 0;
      final String formatted =
          isInt ? mgValue.toInt().toString() : mgValue.toStringAsFixed(1);
      mgLabel = '$formatted mg';
    }

    final description = ingredient.description;
    const refLabel = 'อ้างอิง:';
    String explanationText = '';
    String referenceText = '';

    if (description.isNotEmpty) {
      final idx = description.indexOf(refLabel);
      if (idx >= 0) {
        explanationText = description.substring(0, idx).trim();
        referenceText = description.substring(idx + refLabel.length).trim();
      } else {
        explanationText = description.trim();
      }
    }

    if (explanationText.isEmpty) {
      explanationText = 'ไม่มีรายละเอียดข้อมูล';
    }

    final cardColor = isLight
        ? appColors.surface
        : Color.lerp(appColors.surface, appColors.primary, 0.1)!;

    final expandedColor = isLight
        ? const Color(0xFFF9FAFB)
        : Color.lerp(appColors.background, appColors.primary, 0.05)!;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: appColors.outline),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isLight
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(12),
              bottom: Radius.circular(_expanded ? 0 : 12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: appColors.text,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (statusLabel.isNotEmpty) ...[
                    if (mgLabel != null) ...[
                      _InfoChip(label: mgLabel),
                      const SizedBox(width: 8),
                    ],
                    _StatusChip(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: appColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: expandedColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explanationText,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: appColors.text,
                    ),
                  ),
                  if (referenceText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Divider(
                      height: 1,
                      color: appColors.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'อ้างอิง',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: appColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      referenceText,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: appColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white, // White provides good contrast on status colors
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: appColors.text,
        ),
      ),
    );
  }
}

Color _statusColor(String status, AppColorExtension colors) {
  switch (status.trim()) {
    case 'ปลอดภัย':
      return colors.success;
    case 'ควรระวัง':
      return colors.warning;
    case 'อันตราย':
      return colors.error;
    default:
      return colors.neutral;
  }
}
