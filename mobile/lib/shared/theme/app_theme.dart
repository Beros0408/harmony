import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'harmony_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => HarmonyTheme.dark();
  static ThemeData get lightTheme => HarmonyTheme.light();

  static ThemeData get oledTheme {
    final base = HarmonyTheme.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgBaseOled,
      colorScheme: base.colorScheme.copyWith(
        surface: const Color(0xFF0A0F1E),
        surfaceContainerHighest: const Color(0xFF0F1729),
      ),
    );
  }
}
