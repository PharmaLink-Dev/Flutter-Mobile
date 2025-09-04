import 'package:flutter/material.dart';

/// Centralized color system for the app.
/// Palette inspired by the provided mock (mint/teal, soft gradients).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF17C5A3); // teal-green (CTA)
  static const Color primaryDark = Color(0xFF0FAE8F);
  static const Color primaryLight = Color(0xFF66E0CC);

  // Neutrals / Text
  static const Color text = Color(0xFF22303C); // deep slate for titles
  static const Color textSecondary = Color(0xFF6B7B8A); // muted gray for body
  static const Color surface = Colors.white;

  // Backgrounds
  static const Color background = Color(0xFFF2FBF8); // soft mint background
  static const Color bgMintLight = Color(0xFFE8FBF3);
  static const Color bgMintLighter = Color(0xFFCFF6EF);

  // Status
  static const Color success = primary;
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFEF5350);

  // Extras
  static const Color outline = Color(0xFFE3F0EC);
  static const Color overlay = Color(0x3317C5A3); // 20% primary

  static const red = Colors.red;
  static const green = Colors.green;
  static const orange = Colors.orange;
  static const yellow = Color.fromARGB(255, 132, 119, 4);
  static const white = Colors.white;
  static const black = Colors.black;

  static const grey = Colors.grey;
  static const lightGrey = Color(0xFFF5F5F5);
  static const darkGrey = Color(0xFF616161);
}

class AppGradients {
  AppGradients._();

  /// Subtle mint background gradient (top → bottom)
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.bgMintLight, AppColors.bgMintLighter],
  );

  /// CTA button gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF19C7A5), Color(0xFF0BBF95)],
  );
}
