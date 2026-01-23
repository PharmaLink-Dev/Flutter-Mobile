import 'package:flutter/material.dart';

@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.text,
    required this.textSecondary,
    required this.surface,
    required this.background,
    required this.error,
    required this.outline,
    required this.success,
    required this.warning,
    required this.neutral,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color text;
  final Color textSecondary;
  final Color surface;
  final Color background;
  final Color error;
  final Color outline;
  final Color success;
  final Color warning;
  final Color neutral;

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? text,
    Color? textSecondary,
    Color? surface,
    Color? background,
    Color? error,
    Color? outline,
    Color? success,
    Color? warning,
    Color? neutral,
  }) {
    return AppColorExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      error: error ?? this.error,
      outline: outline ?? this.outline,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
    ThemeExtension<AppColorExtension>? other,
    double t,
  ) {
    if (other is! AppColorExtension) {
      return this;
    }
    return AppColorExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      error: Color.lerp(error, other.error, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }

  /// Light Theme Color Scheme
  static const light = AppColorExtension(
    primary: Color(0xFF17C5A3),
    primaryDark: Color(0xFF0FAE8F),
    primaryLight: Color(0xFF66E0CC),
    text: Color(0xFF22303C),
    textSecondary: Color(0xFF6B7B8A),
    surface: Colors.white,
    background: Color(0xFFF2FBF8),
    error: Color(0xFFEF5350),
    outline: Color(0xFFE3F0EC),
    success: Color(0xFF2E7D32), // Green 800
    warning: Color(0xFFFDD835), // Yellow 600 - ระมัดระวัง
    neutral: Color(0xFF6B7B8A), // Same as textSecondary
  );

  /// Dark Theme Color Scheme
  static const dark = AppColorExtension(
    primary: Color(0xFF17C5A3), // Keep primary vibrant
    primaryDark: Color(0xFF66E0CC), // Lighter for contrast
    primaryLight: Color(0xFF0FAE8F), // Darker for contrast
    text: Color(0xFFF2FBF8), // Light text for dark background
    textSecondary: Color(0xFFB0BEC5), // Muted light gray
    surface: Color(0xFF263238), // Dark surface
    background: Color(0xFF121212), // Near black background
    error: Color(0xFFCF6679), // Material standard dark error
    outline: Color(0xFF37474F), // Dark outline
    success: Color(0xFF66BB6A), // Green 300
    warning: Color(0xFFFFEB3B), // Yellow 500 - ระมัดระวัง
    neutral: Color(0xFFB0BEC5), // Same as textSecondary
  );
}

// You can keep gradients if they are used, but be mindful that
// the colors inside them are static and won't adapt to the theme.
class AppGradients {
  AppGradients._();

  // A vibrant, energetic green gradient
  static const LinearGradient button = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6EE7B7), Color(0xFF17C5A3), Color(0xFF0D9488)],
  );

  // A cooler, minty green gradient
  static const LinearGradient actionCardSecondary = LinearGradient(
    colors: [Color(0xFF5EEAD4), Color(0xFF2DD4BF), Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Dark Mode Gradients ---
  static const LinearGradient buttonDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF17C5A3), Color(0xFF0FAE8F), Color(0xFF263238)],
  );

  static const LinearGradient actionCardSecondaryDark = LinearGradient(
    colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6), Color(0xFF263238)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
