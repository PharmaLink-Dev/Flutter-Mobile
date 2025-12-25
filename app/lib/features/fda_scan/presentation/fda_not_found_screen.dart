import 'package:flutter/material.dart';
import 'package:app/features/fda_scan/presentation/fda_flow_service.dart';
import 'widgets/fda_input_dialog.dart';
import 'package:flutter/cupertino.dart';

class FdaNotFoundScreen extends StatelessWidget {
  final String scannedRaw;
  const FdaNotFoundScreen({super.key, required this.scannedRaw});

  Future<void> _openEditDialog(BuildContext context) async {
    // Use the same UI as the existing manual input dialog
    final input = await showFdaInputDialog(context);

    if (input == null || input.isEmpty || !context.mounted) return;

    await FdaFlowService(context).fetchAndNavigate(input);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.error,
      body: Stack(
        children: [
          // Header (red gradient, rounded bottom, soft shapes)
          Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.error.withOpacity(0.8), colorScheme.error],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 56, left: 28, child: _SoftShape.circle(18, colorScheme.onError.withOpacity(0.2))),
                  Positioned(top: 96, right: 36, child: _SoftShape.rounded(44, 14, colorScheme.onError.withOpacity(0.2))),
                  Positioned(bottom: 96, left: 64, child: _SoftShape.rounded(56, 12, colorScheme.onError.withOpacity(0.1))),
                  Positioned(bottom: 120, right: 40, child: _SoftShape.circle(12, colorScheme.onError.withOpacity(0.25))),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onError,
                        ),
                        child: Center(
                          child: Icon(CupertinoIcons.xmark, size: 72, color: colorScheme.error),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ไม่พบข้อมูลผลิตภัณฑ์',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onError,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เลขที่ค้นหา: ' + scannedRaw,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onError.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Fixed bottom sheet with actions
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.50,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -6)),
                  ],
                ),
                // add larger bottom padding so the buttons are not glued to the edge
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ผลการตรวจสอบ', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.error.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.error_outline_rounded, color: colorScheme.error),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ไม่พบข้อมูลผลิตภัณฑ์',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                Text('เลขที่ค้นหา: ' + scannedRaw,
                                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _openEditDialog(context),
                          icon: const Icon(Icons.edit),
                          label: const Text('แก้ไข'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: colorScheme.outline),
                            foregroundColor: colorScheme.onSurface,
                            backgroundColor: colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('สแกนใหม่'),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(colorScheme.onError.withOpacity(0.2)),
                  ),
                  icon: Icon(CupertinoIcons.back, color: colorScheme.onError),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftShape {
  static Widget circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  static Widget rounded(double width, double height, Color color) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
}
