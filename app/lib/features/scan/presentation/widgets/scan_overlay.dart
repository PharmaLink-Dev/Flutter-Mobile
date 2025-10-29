import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';

class ScanOverlay extends StatefulWidget {
  final double boxSize;
  const ScanOverlay({super.key, this.boxSize = 300});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double box = widget.boxSize;
    const double radius = 24;

    return Stack(
      children: [
        // Subtle top/bottom fades to focus the frame
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),

        // Center scanning box
        Center(
          child: SizedBox(
            width: box,
            height: box,
            child: Stack(
              children: [
                // Outer subtle border
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius + 6),
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                ),

                // Inner main border
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(color: Colors.white60, width: 2),
                    ),
                  ),
                ),

                // ไม่มีจุดกึ่งกลางและมุมไฮไลต์ตามที่ขอ

                // Animated scanning line
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final double padding = 18;
                    final double track = box - padding * 2 - 2; // travel area
                    final double y = padding + track * _controller.value;
                    return Positioned(
                      left: 24,
                      right: 24,
                      top: y,
                      child: _scanLine(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _scanLine() {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: AppGradients.scanLabel,
        boxShadow: const [
          BoxShadow(color: Color(0x6617C5A3), blurRadius: 8, spreadRadius: 1),
        ],
      ),
    );
  }
  
}
