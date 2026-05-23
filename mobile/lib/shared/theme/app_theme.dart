import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.bgBase,
        surface: AppColors.bgSurface,
        elevated: AppColors.bgElevated,
      );

  static ThemeData get oledTheme => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.bgBaseOled,
        surface: const Color(0xFF0A0F1E),
        elevated: const Color(0xFF0F1729),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.bgBaseLight,
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.textPrimaryLight,
          displayColor: AppColors.textPrimaryLight,
        ),
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color elevated,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
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
      errorContainer: const Color(0xFF4A1010),
      onErrorContainer: AppColors.accentRed,
      surface: surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: elevated,
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
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // Cards — CardThemeData requis depuis Flutter 3.27+
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.xlRadius,
          side: BorderSide(color: AppColors.borderDefault),
        ),
        margin: EdgeInsets.zero,
      ),

      // Boutons primaires
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Boutons texte
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Boutons outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderDefault),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),

      // Champs de saisie
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        errorStyle: AppTypography.textTheme.bodySmall
            ?.copyWith(color: AppColors.accentRed),
      ),

      // Diviseurs
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // Barre de navigation bas
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textMuted,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Switch (toggle)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accentGreen;
          }
          return AppColors.bgElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return AppColors.borderDefault;
        }),
      ),

      // Barre de progression
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accentBlue,
      ),
    );
  }
}
