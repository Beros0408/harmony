import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class HarmonyTheme {
  HarmonyTheme._();

  static ThemeData dark() => _buildDark();
  static ThemeData light() => _buildLight();

  static ThemeData _buildDark() {
    final colorScheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.accentBlue,
      onPrimary: AppColors.textInverse,
      primaryContainer: AppColors.bgInteractive,
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.accentPurple,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.bgElevated,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.accentCyan,
      onTertiary: AppColors.textInverse,
      tertiaryContainer: AppColors.bgElevated,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.accentRed,
      onError: AppColors.textPrimary,
      errorContainer: Color(0xFF4A1010),
      onErrorContainer: AppColors.accentRed,
      surface: AppColors.bgSurface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.bgElevated,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderDefault,
      outlineVariant: AppColors.borderSubtle,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.textInverse,
      inversePrimary: AppColors.accentBlueHover,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgBase,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlRadius,
          side: BorderSide(color: AppColors.borderDefault),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderDefault),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.accentRed),
        ),
        hintStyle: AppTypography.textTheme.bodyMedium,
        labelStyle: AppTypography.textTheme.bodyMedium,
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.accentRed),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accentGreen;
          return AppColors.bgElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.borderDefault;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accentBlue),
    );
  }

  static ThemeData _buildLight() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accentBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF1D4ED8),
      secondary: AppColors.accentPurple,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.badgePurpleBgLight,
      onSecondaryContainer: AppColors.badgePurpleTextLight,
      tertiary: AppColors.accentCyan,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFCCFBF1),
      onTertiaryContainer: Color(0xFF0D9488),
      error: AppColors.accentRed,
      onError: Colors.white,
      errorContainer: AppColors.badgeDangerBgLight,
      onErrorContainer: AppColors.badgeDangerTextLight,
      surface: AppColors.bgSurfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.bgElevatedLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderDefaultLight,
      outlineVariant: AppColors.borderSubtleLight,
      shadow: Colors.black,
      scrim: Colors.black26,
      inverseSurface: AppColors.textPrimaryLight,
      onInverseSurface: Colors.white,
      inversePrimary: AppColors.accentBlueHover,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bgBaseLight,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.bgSurfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlRadius,
          side: BorderSide(color: AppColors.borderDefaultLight),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          side: const BorderSide(color: AppColors.borderDefaultLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevatedLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.borderDefaultLight),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.borderDefaultLight),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.mdRadius,
          borderSide: BorderSide(color: AppColors.accentRed),
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textMutedLight,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        errorStyle: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.accentRed),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtleLight,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurfaceLight,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMutedLight,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMutedLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accentGreen;
          return AppColors.bgInteractiveLight;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return AppColors.borderDefaultLight;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.accentBlue),
    );
  }
}
