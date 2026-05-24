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

  Color _accentColor(bool isDark) => switch (variant) {
        HarmonyBadgeVariant.success => AppColors.accentGreen,
        HarmonyBadgeVariant.warning => AppColors.accentAmber,
        HarmonyBadgeVariant.danger => AppColors.accentRed,
        HarmonyBadgeVariant.info => AppColors.accentBlue,
        HarmonyBadgeVariant.purple => AppColors.accentPurple,
        HarmonyBadgeVariant.muted => AppColors.textMuted,
      };

  Color _bgColor(bool isDark) {
    if (isDark) return _accentColor(true).withValues(alpha: 0.12);
    return switch (variant) {
      HarmonyBadgeVariant.success => AppColors.badgeSuccessBgLight,
      HarmonyBadgeVariant.warning => AppColors.badgeWarningBgLight,
      HarmonyBadgeVariant.danger => AppColors.badgeDangerBgLight,
      HarmonyBadgeVariant.info => AppColors.badgeInfoBgLight,
      HarmonyBadgeVariant.purple => AppColors.badgePurpleBgLight,
      HarmonyBadgeVariant.muted => AppColors.badgeMutedBgLight,
    };
  }

  Color _textColor(bool isDark) {
    if (isDark) return _accentColor(true);
    return switch (variant) {
      HarmonyBadgeVariant.success => AppColors.badgeSuccessTextLight,
      HarmonyBadgeVariant.warning => AppColors.badgeWarningTextLight,
      HarmonyBadgeVariant.danger => AppColors.badgeDangerTextLight,
      HarmonyBadgeVariant.info => AppColors.badgeInfoTextLight,
      HarmonyBadgeVariant.purple => AppColors.badgePurpleTextLight,
      HarmonyBadgeVariant.muted => AppColors.badgeMutedTextLight,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = _bgColor(isDark);
    final fg = _textColor(isDark);
    final border = isDark
        ? _accentColor(true).withValues(alpha: 0.2)
        : fg.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
