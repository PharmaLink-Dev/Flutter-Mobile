import 'package:flutter/material.dart';
import 'package:app/features/fda_scan/data/fda_search_service.dart';
import 'fda_success_screen.dart';
import 'widgets/fda_input_dialog.dart';

class FdaNotFoundScreen extends StatelessWidget {
  final String scannedRaw;
  const FdaNotFoundScreen({super.key, required this.scannedRaw});

  Future<void> _openEditDialog(BuildContext context) async {
    // Use the same UI as the existing manual input dialog
    final input = await showFdaInputDialog(context);

    if (input == null || input.isEmpty || !context.mounted) return;

    try {
      final service = FdaSearchService();
      final map = await service.fetchByFdpdtno(input);
      if (!context.mounted) return;
      if (FdaSearchService.isValidResult(map)) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => FdaSuccessScreen(data: map)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบข้อมูลจากเลขที่กรอก')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ดึงข้อมูลไม่สำเร็จ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEF4444),
      body: Stack(
        children: [
          // Header (red gradient, rounded bottom, soft shapes)
          Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF87171), Color(0xFFEF4444)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 56, left: 28, child: _SoftShape.circle(18, Colors.white24)),
                  Positioned(top: 96, right: 36, child: _SoftShape.rounded(44, 14, Colors.white24)),
                  Positioned(bottom: 96, left: 64, child: _SoftShape.rounded(56, 12, Colors.white12)),
                  Positioned(bottom: 120, right: 40, child: _SoftShape.circle(12, Colors.white30)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Icon(Icons.close, size: 72, color: Color(0xFFEF4444)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ไม่พบข้อมูลผลิตภัณฑ์',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'เลขที่สแกนได้: ' + scannedRaw,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.95),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, -6)),
                  ],
                ),
                // add larger bottom padding so the buttons are not glued to the edge
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ผลการตรวจสอบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('ไม่พบข้อมูลผลิตภัณฑ์',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0B1F17))),
                                const SizedBox(height: 4),
                                Text('เลขที่สแกนได้: ' + scannedRaw,
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF3B4B52))),
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
                            side: const BorderSide(color: Color(0x3322303C)),
                            foregroundColor: Color(0xFF22303C),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
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
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.white24),
                  ),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
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
