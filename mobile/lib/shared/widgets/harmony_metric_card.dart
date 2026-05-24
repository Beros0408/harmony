import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'harmony_card.dart';

class HarmonyMetricCard extends StatelessWidget {
  const HarmonyMetricCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.unit,
    this.trend,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String? unit;
  // positive = up (good), negative = down, null = no trend indicator
  final double? trend;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              if (trend != null) _TrendChip(trend: trend!),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.textTheme.headlineSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                  letterSpacing: -0.5,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Text(unit!, style: AppTypography.textTheme.bodySmall),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.trend});
  final double trend;

  @override
  Widget build(BuildContext context) {
    final isUp = trend > 0;
    final color = isUp ? AppColors.accentGreen : AppColors.accentRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${trend.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
