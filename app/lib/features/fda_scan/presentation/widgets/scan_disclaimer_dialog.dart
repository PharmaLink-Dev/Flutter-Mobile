import 'package:flutter/material.dart';

/// Shows a disclaimer dialog before scanning
/// Returns true if user accepts, false/null if cancelled
Future<bool?> showScanDisclaimerDialog(BuildContext context) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must make a choice
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: colorScheme.error,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'คำเตือนสำคัญ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผลการสแกนนี้เป็นเพียงข้อมูลอ้างอิงเบื้องต้นเท่านั้น',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      '• ไม่สามารถใช้เป็นคำแนะนำทางการแพทย์หรือการวินิจฉัยโรคได้',
                      theme,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      '• ข้อมูลอาจไม่ครบถ้วนหรือไม่เป็นปัจจุบัน',
                      theme,
                      colorScheme,
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      '• กรุณาปรึกษาแพทย์หรือเภสัชกรก่อนการใช้ยาหรือผลิตภัณฑ์เสริมอาหารทุกครั้ง',
                      theme,
                      colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'การใช้งานแอปนี้ไม่ทดแทนการปรึกษาผู้เชี่ยวชาญทางการแพทย์',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'ยอมรับและดำเนินการต่อ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      );
    },
  );
}

Widget _buildBulletPoint(
  String text,
  ThemeData theme,
  ColorScheme colorScheme,
) {
  return Text(
    text,
    style: theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      height: 1.5,
    ),
  );
}
