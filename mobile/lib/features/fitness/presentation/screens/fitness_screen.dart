import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_list_tile.dart';
import '../../data/mock/fitness_mocks.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Fitness & Performance',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // A — Stats du jour
          const _SectionHeader(title: "AUJOURD'HUI"),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4,
            children: kTodayStats.map((s) => _StatCard(stat: s)).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // B — Activité hebdomadaire
          const _SectionHeader(title: 'ACTIVITÉ HEBDOMADAIRE'),
          const SizedBox(height: AppSpacing.md),
          HarmonyCard(
            padding: AppSpacing.lg,
            child: SizedBox(
              height: 160,
              child: _WeeklyBarChart(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // C — Records
          const _SectionHeader(title: 'MES RECORDS'),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kPersonalRecords.map((r) => HarmonyListTile(
                leadingIcon: r.icon,
                leadingColor: r.color,
                title: r.title,
                subtitle: r.detail,
              ),).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // D — Dernières séances
          const _SectionHeader(title: 'DERNIÈRES SÉANCES'),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kRecentSessions.map((s) => HarmonyListTile(
                leadingIcon: s.icon,
                leadingColor: AppColors.accentBlue,
                title: s.type,
                subtitle: s.detail,
              ),).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final FitnessStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: stat.color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smRadius,
                ),
                child: Icon(stat.icon, color: stat.color, size: 15),
              ),
              Text(stat.label, style: AppTypography.textTheme.labelSmall),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stat.value, style: AppTypography.monoMetric.copyWith(fontSize: 22, color: stat.color)),
              if (stat.unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(stat.unit!, style: AppTypography.textTheme.bodySmall),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Weekly bar chart ────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxY = kWeeklySteps.reduce((a, b) => a > b ? a : b) * 1.15;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(kWeeklySteps.length, (i) {
          final isToday = i == kWeeklySteps.length - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: kWeeklySteps[i],
                color: isToday ? AppColors.accentBlue : AppColors.accentBlue.withValues(alpha: 0.35),
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= kWeekDayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    kWeekDayLabels[i],
                    style: AppTypography.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.textTheme.titleSmall);
  }
}
