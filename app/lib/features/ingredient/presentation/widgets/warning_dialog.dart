
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

void showWarningDialog(
  BuildContext context, {
  required List<String> riskyIngredients,
  String? customMessage,
}) {
  // NEW: Get theme-aware colors
  final appColors = Theme.of(context).extension<AppColorExtension>()!;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(
          child: Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                // CHANGED: Use error color from theme
                color: appColors.error,
                size: 80,
              ),
              const SizedBox(height: 10),
              const Text(
                'อันตรายสำหรับผู้ป่วยโรคไต!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ตรวจพบส่วนผสมที่อาจเป็นอันตรายสูง:'),
            const SizedBox(height: 5),
            Text(
              riskyIngredients.join(', '),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // CHANGED: Use error color from theme
                color: appColors.error,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              customMessage ??
                  'ส่วนผสมเหล่านี้อาจส่งผลเสียต่อผู้ป่วยโรคไต\nกรุณาปรึกษาแพทย์',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              // CHANGED: Use theme-aware colors for the button
              style: ElevatedButton.styleFrom(
                backgroundColor: appColors.error,
                foregroundColor: Colors.white, // White text is usually readable on red
              ),
              child: const Text(
                'ดูรายละเอียด',
              ),
            ),
          ),
        ],
      );
    },
  );
}
