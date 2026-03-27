
import 'package:app/shared/app_colors.dart';
import 'package:flutter/material.dart';

class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final brightness = Theme.of(context).brightness;

    // Use the theme's background color in dark mode, or a solid black in light mode
    final backgroundColor = brightness == Brightness.dark
        ? appColors.background
        : Colors.black;

    return ColoredBox(
      color: backgroundColor,
    );
  }
}
