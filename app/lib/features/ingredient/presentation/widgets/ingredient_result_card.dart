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
    final ingredient = widget.ingredient;
    final statusColor = _statusColor(ingredient.status);
    final statusLabel = ingredient.status.isNotEmpty ? ingredient.status : 'ไม่มีข้อมูล';

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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)), // สีเทาอ่อนๆ แบบในรูป
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  // ชื่อส่วนผสม
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700, 
                        fontSize: 15,
                        color: Color(0xFF1F2937),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Status Chip
                  if (statusLabel.isNotEmpty) ...[
                    _StatusChip(
                      label: statusLabel,
                      color: statusColor,
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Icon Arrow
                  Padding(
                    padding: const EdgeInsets.only(top: 2), 
                    child: Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),


          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              // 2. พื้นหลังสีเทาอ่อนสำหรับเนื้อหาที่ขยายออกมา
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB), // สีเทาอ่อนมาก (Cool Gray 50)
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    explanationText.isNotEmpty
                        ? explanationText
                        : 'ไม่มีรายละเอียดข้อมูล',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Color(0xFF4B5563), 
                    ),
                  ),
                  if (referenceText.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 12),
                    const Text(
                      'อ้างอิง',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      referenceText,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF6B7280),
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
      // ปรับขนาด Chip ให้เหมือนในรูป (มนๆ เล็กๆ)
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12), // มนมากหน่อย
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 11, 
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