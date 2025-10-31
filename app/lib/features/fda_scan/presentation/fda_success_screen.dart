import 'package:flutter/material.dart';
import 'fda_result_bottom_sheet.dart';

class FdaSuccessScreen extends StatelessWidget {
  final Map<String, String?> data;

  const FdaSuccessScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF1ABC9C),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.50,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF38EF7D), Color(0xFF11998E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // decorative shapes
                  Positioned(top: 56, left: 28, child: _SoftShape.circle(18, Colors.white24)),
                  Positioned(top: 96, right: 36, child: _SoftShape.rounded(44, 14, Colors.white24)),
                  Positioned(bottom: 96, left: 64, child: _SoftShape.rounded(56, 12, Colors.white12)),
                  Positioned(bottom: 120, right: 40, child: _SoftShape.circle(12, Colors.white30)),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Solid white circle + green check
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Center(
                          child: Icon(Icons.check, size: 72, color: Color(0xFF2ECC71)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'ผลิตภัณฑ์ขึ้นทะเบียน !',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ข้อมูลตรวจสอบจากฐานข้อมูล\nสำนักงานคณะกรรมการอาหารและยา กระทรวงสาธารณสุข',
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

          // Fixed-position bottom sheet (not draggable)
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              bottom: false,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.56,
                child: FdaResultBottomSheet(data: data),
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
