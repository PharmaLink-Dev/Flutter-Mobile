import 'package:flutter/material.dart';
import '../../../../shared/app_colors.dart';

void showWarningDialog(
  BuildContext context, {
  required List<String> riskyIngredients,
  String? customMessage,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(
          child: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.red,
                size: 80,
              ),
              const SizedBox(height: 10),
              Text(
                'อันตรายสำหรับผู้ป่วยโรคไต!',
                textAlign: TextAlign.center,
                style: const TextStyle(
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.red,
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
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: const Text(
                'ดูรายละเอียด',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      );
    },
  );
}
