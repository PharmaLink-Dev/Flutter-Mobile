import 'package:flutter/material.dart';

/// Centralized color system for the app.
/// Palette inspired by the provided mock (mint/teal, soft gradients).
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF17C5A3); // teal-green (CTA)
  static const Color primaryDark = Color(0xFF0FAE8F);
  static const Color primaryLight = Color(0xFF66E0CC);

  // New colors
  static const Color aqua = Color(0xFF1DCEDF); // bright cyan-green (new)
  static const Color aquaLight = Color(0xFF9CF6FB); // light cyan (new)
  static const Color mint = Color(0xFF78FFD6); // mint green (new)
  static const Color tealBright = Color(0xFF00C9A7); // bright teal (new)

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
}

class AppGradients {
  AppGradients._();

  /// Subtle mint background gradient (top → bottom)
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.bgMintLight,
      AppColors.bgMintLighter,
    ],
  );

  /// CTA button gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF19C7A5),
      Color(0xFF0BBF95),
    ],
  );

  // New gradients
  static const LinearGradient scanLabel = LinearGradient(
    colors: [AppColors.primary, AppColors.tealBright], // (new)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fdaNumber = LinearGradient(
    colors: [AppColors.aquaLight, AppColors.aqua], // (new)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintBlue = LinearGradient(
    colors: [AppColors.mint, AppColors.aqua], // (new)
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

