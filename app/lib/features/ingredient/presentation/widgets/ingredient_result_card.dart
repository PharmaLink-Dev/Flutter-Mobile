import 'package:app/features/ingredient/data/ingredient.dart';
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

/// การ์ดผลการวิเคราะห์ส่วนผสม 1 รายการ
/// ใช้ซ้ำได้ทั้งในหน้า Result และหน้าอื่น ๆ
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
    final ingredient = widget.ingredient;
    final statusColor = _statusColor(ingredient.status);
    final statusLabel =
        ingredient.status.isNotEmpty ? ingredient.status : 'ไม่พบข้อมูล';

    // แยก description เป็นส่วน explanation และ reference (ถ้ามี)
    final description = ingredient.description;
    const refLabel = 'อ้างอิง:';
    String explanationText = '';
    String referenceText = '';

    if (description.isNotEmpty) {
      final idx = description.indexOf(refLabel);
      if (idx >= 0) {
        explanationText = description.substring(0, idx).trim();
        referenceText =
            description.substring(idx + refLabel.length).trim();
      } else {
        explanationText = description.trim();
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Material(
        color: AppColors.surface,
        child: InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.darkGrey,
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          explanationText.isNotEmpty
                              ? explanationText
                              : 'ยังไม่มีรายละเอียดสำหรับส่วนผสมนี้',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.text,
                          ),
                        ),
                        if (referenceText.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'อ้างอิง',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            referenceText,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.darkGrey,
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
          ),
        ),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status.trim()) {
    case 'ปลอดภัย':
      return AppColors.success;
    case 'ควรระวัง':
      return AppColors.warning;
    case 'อันตราย':
      return AppColors.error;
    default:
      return AppColors.darkGrey;
  }
}

