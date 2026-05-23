import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

class HarmonyEmptyState extends StatelessWidget {
  const HarmonyEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.cta,
    this.onCtaTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final String? cta;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.bgElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypography.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (cta != null && onCtaTap != null) ...[
              const SizedBox(height: AppSpacing.xl),
              TextButton(
                onPressed: onCtaTap,
                child: Text(cta!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
