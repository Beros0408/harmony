import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum HarmonyBadgeVariant { success, warning, danger, info, purple, muted }

class HarmonyBadge extends StatelessWidget {
  const HarmonyBadge({
    super.key,
    required this.label,
    this.variant = HarmonyBadgeVariant.info,
    this.icon,
  });

  final String label;
  final HarmonyBadgeVariant variant;
  final IconData? icon;

  Color get _accentColor => switch (variant) {
        HarmonyBadgeVariant.success => AppColors.accentGreen,
        HarmonyBadgeVariant.warning => AppColors.accentAmber,
        HarmonyBadgeVariant.danger => AppColors.accentRed,
        HarmonyBadgeVariant.info => AppColors.accentBlue,
        HarmonyBadgeVariant.purple => AppColors.accentPurple,
        HarmonyBadgeVariant.muted => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    final color = _accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
