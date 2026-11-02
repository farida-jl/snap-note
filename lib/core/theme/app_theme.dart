import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFFF8F4EA);
  static const card = Colors.white;
  static const primary = Color(0xFF18354A);
  static const textPrimary = Color(0xFF173042);
  static const textSecondary = Color(0xFF667A86);
  static const border = Color(0xFFDDE1DD);
  static const subtle = Color(0xFFF0F1EC);
  static const accent = Color(0xFFF4B942);
  static const accentSoft = Color(0xFFFFE6A7);
  static const canvas = Color(0xFF18354A);
  static const canvasMuted = Color(0xFFAFC0C6);
  static const canvasText = Color(0xFFFFFBF2);
  static const success = Color(0xFF4E7965);

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
        secondary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Inter',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Lora',
          fontSize: 38,
          height: 1.08,
          letterSpacing: -1.4,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Lora',
          fontSize: 22,
          height: 1.2,
          letterSpacing: -.4,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
          color: AppColors.textPrimary,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
