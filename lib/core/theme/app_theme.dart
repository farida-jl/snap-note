import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFFFFDF7);
  static const card = Colors.white;
  static const primary = Color(0xFF243B53);
  static const textPrimary = Color(0xFF172B4D);
  static const textSecondary = Color(0xFF627D98);
  static const border = Color(0xFFD9E2EC);
  static const subtle = Color(0xFFF0F2F4);
  static const accent = Color(0xFFF4B942);

  static const white = Color(0xFFFFFFFF);
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.textPrimary),
      ),
    );
  }
}
