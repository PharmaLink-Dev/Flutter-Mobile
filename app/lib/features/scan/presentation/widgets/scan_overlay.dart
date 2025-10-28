import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class ScanOverlay extends StatelessWidget {
  final double boxSize;
  const ScanOverlay({super.key, this.boxSize = 280});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // gradient top/bottom for nicer UI
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
        Center(
          child: DottedBorder(
            borderType: BorderType.Rect,
            color: Colors.white,
            strokeWidth: 3,
            dashPattern: const [8, 4],
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

