import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum HarmonySnackBarVariant { success, error, info }

class HarmonySnackBar {
  HarmonySnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    HarmonySnackBarVariant variant = HarmonySnackBarVariant.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = switch (variant) {
      HarmonySnackBarVariant.success => AppColors.accentGreen,
      HarmonySnackBarVariant.error => AppColors.accentRed,
      HarmonySnackBarVariant.info => AppColors.accentBlue,
    };
    final icon = switch (variant) {
      HarmonySnackBarVariant.success => Icons.check_circle_outline,
      HarmonySnackBarVariant.error => Icons.error_outline,
      HarmonySnackBarVariant.info => Icons.info_outline,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
