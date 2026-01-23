import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows the FDA number input dialog and returns the entered text,
/// or null if the user cancels.
Future<String?> showFdaInputDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final colorScheme = theme.colorScheme;

      String? errorText;
      String onlyDigits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
      String formatFdaPattern(String digits) {
        const groups = [2, 1, 5, 1, 4];
        final buf = StringBuffer();
        int consumed = 0;
        for (int i = 0; i < groups.length; i++) {
          if (digits.length <= consumed) break;
          final g = groups[i];
          final end = (consumed + g) <= digits.length
              ? (consumed + g)
              : digits.length;
          buf.write(digits.substring(consumed, end));
          consumed = end;
          if (consumed < digits.length && i < groups.length - 1) buf.write('-');
        }
        return buf.toString();
      }

      return StatefulBuilder(
        builder: (ctx, setState) {
          final digitsCount = onlyDigits(controller.text).length;
          errorText = digitsCount == 0 || digitsCount == 13
              ? null
              : 'กรอกตัวเลขให้ครบ 13 หลัก';
          final bool canSubmit = digitsCount == 13;
          return Dialog(
            backgroundColor: colorScheme.surface, // Use theme color
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'กรุณากรอกเลข FDA',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controller,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (raw) {
                            final digits = onlyDigits(raw);
                            final end = digits.length > 13 ? 13 : digits.length;
                            final formatted = formatFdaPattern(
                              digits.substring(0, end),
                            );
                            if (controller.text != formatted) {
                              controller
                                ..text = formatted
                                ..selection = TextSelection.collapsed(
                                  offset: formatted.length,
                                );
                            }
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            hintText: '13-1-12345-1-0001',
                            hintStyle: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.35),
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: colorScheme.surfaceVariant.withOpacity(
                              0.5,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            errorText: errorText,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outline.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  side: BorderSide(color: colorScheme.outline),
                                  backgroundColor: colorScheme.surface,
                                  foregroundColor: colorScheme.onSurface,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text(
                                  'ยกเลิก',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Opacity(
                                opacity: canSubmit ? 1.0 : 0.5,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                  onPressed: canSubmit
                                      ? () => Navigator.of(
                                          ctx,
                                        ).pop(controller.text.trim())
                                      : null,
                                  child: const Text(
                                    'ค้นหา',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      splashRadius: 18,
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
