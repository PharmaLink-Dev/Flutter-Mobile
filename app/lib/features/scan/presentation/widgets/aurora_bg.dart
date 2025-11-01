import 'package:flutter/material.dart';
import 'package:app/shared/app_colors.dart';

/// Matte dark background (no gradients) — near-black for a minimal look.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.black, // ดำด้านๆ ไม่ดำสนิท
    );
  }
}
