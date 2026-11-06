import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_shelf/core/theme/app_theme.dart';

void main() {
  test('light theme exposes the light semantic color set', () {
    final theme = AppTheme.light;
    final colors = theme.extension<AppThemeColors>();

    expect(theme.brightness, Brightness.light);
    expect(colors, isNotNull);
    expect(colors?.background, AppColors.white);
    expect(colors?.textPrimary, AppColors.slate900);
  });

  test('dark theme exposes the dark semantic color set', () {
    final theme = AppTheme.dark;
    final colors = theme.extension<AppThemeColors>();

    expect(theme.brightness, Brightness.dark);
    expect(colors, isNotNull);
    expect(colors?.background, AppColors.slate900);
    expect(colors?.textPrimary, AppColors.mint100);
  });
}
