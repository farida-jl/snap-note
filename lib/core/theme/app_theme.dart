import 'package:flutter/material.dart';

abstract final class AppColors {
  static const mint900 = Color(0xFF52625B);
  static const mint800 = Color(0xFF6C8177);
  static const mint700 = Color(0xFF86A194);
  static const mint600 = Color(0xFFA0C0B1);
  static const mint500 = Color(0xFFBADFCE);
  static const mint400 = Color(0xFFC6E5D7);
  static const mint300 = Color(0xFFD3EBE0);
  static const mint200 = Color(0xFFDFF0E8);
  static const mint100 = Color(0xFFECF6F1);

  static const orange900 = Color(0xFF69290E);
  static const orange800 = Color(0xFF8A3613);
  static const orange700 = Color(0xFFAB4317);
  static const orange600 = Color(0xFFCD501C);
  static const orange500 = Color(0xFFEE5D20);
  static const orange400 = Color(0xFFF17A48);
  static const orange300 = Color(0xFFF49770);
  static const orange200 = Color(0xFFF7B498);
  static const orange100 = Color(0xFFFAD2C1);

  static const gold900 = Color(0xFF6B511D);
  static const gold800 = Color(0xFF8E6B26);
  static const gold700 = Color(0xFFB08530);
  static const gold600 = Color(0xFFD29F39);
  static const gold500 = Color(0xFFF4B942);
  static const gold400 = Color(0xFFF6C664);
  static const gold300 = Color(0xFFF8D286);
  static const gold200 = Color(0xFFFADFA8);
  static const gold100 = Color(0xFFFCEBCA);

  static const slate900 = Color(0xFF0E1516);
  static const slate800 = Color(0xFF131B1E);
  static const slate700 = Color(0xFF172225);
  static const slate600 = Color(0xFF1C282C);
  static const slate500 = Color(0xFF202F33);
  static const slate400 = Color(0xFF485458);
  static const slate300 = Color(0xFF707A7C);
  static const slate200 = Color(0xFF989FA1);
  static const slate100 = Color(0xFFC1C5C6);

  static const white = Color(0xFFFFFFFF);
}

@immutable
final class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.card,
    required this.primary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.subtle,
    required this.accent,
    required this.onAccent,
    required this.canvas,
    required this.canvasMuted,
    required this.success,
  });

  static const light = AppThemeColors(
    background: AppColors.white,
    card: AppColors.white,
    primary: AppColors.slate500,
    textPrimary: AppColors.slate900,
    textSecondary: AppColors.slate400,
    border: AppColors.slate500,
    subtle: AppColors.mint200,
    accent: AppColors.gold500,
    onAccent: AppColors.slate900,
    canvas: AppColors.slate500,
    canvasMuted: AppColors.mint600,
    success: AppColors.mint900,
  );

  static const dark = AppThemeColors(
    background: AppColors.slate900,
    card: AppColors.slate800,
    primary: AppColors.gold100,
    textPrimary: AppColors.mint100,
    textSecondary: AppColors.mint600,
    border: AppColors.mint300,
    subtle: AppColors.slate700,
    accent: AppColors.gold600,
    onAccent: AppColors.slate500,
    canvas: AppColors.slate700,
    canvasMuted: AppColors.mint600,
    success: AppColors.mint500,
  );

  final Color background;
  final Color card;
  final Color primary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color subtle;
  final Color accent;
  final Color onAccent;
  final Color canvas;
  final Color canvasMuted;
  final Color success;

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? card,
    Color? primary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? subtle,
    Color? accent,
    Color? onAccent,
    Color? canvas,
    Color? canvasMuted,
    Color? canvasText,
    Color? success,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      card: card ?? this.card,
      primary: primary ?? this.primary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      subtle: subtle ?? this.subtle,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      canvas: canvas ?? this.canvas,
      canvasMuted: canvasMuted ?? this.canvasMuted,
      success: success ?? this.success,
    );
  }

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      canvasMuted: Color.lerp(canvasMuted, other.canvasMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

extension AppThemeBuildContext on BuildContext {
  AppThemeColors get appColors => Theme.of(this).extension<AppThemeColors>()!;
}

abstract final class AppTheme {
  static ThemeData get light =>
      _build(brightness: Brightness.light, colors: AppThemeColors.light);

  static ThemeData get dark =>
      _build(brightness: Brightness.dark, colors: AppThemeColors.dark);

  static ThemeData _build({
    required Brightness brightness,
    required AppThemeColors colors,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: colors.primary,
        primary: colors.primary,
        onPrimary: brightness == Brightness.light
            ? AppColors.white
            : AppColors.slate900,
        secondary: colors.accent,
        onSecondary: colors.onAccent,
        surface: colors.background,
        onSurface: colors.textPrimary,
        outline: colors.border,
      ),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Lora',
          fontSize: 38,
          height: 1.08,
          letterSpacing: -1.4,
          color: colors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Lora',
          fontSize: 22,
          height: 1.2,
          letterSpacing: -.4,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: colors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: colors.textSecondary,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .7,
          color: colors.textPrimary,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.accent),
      extensions: [colors],
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
