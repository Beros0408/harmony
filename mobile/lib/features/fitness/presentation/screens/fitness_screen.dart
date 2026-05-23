import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:harmony/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final dayLabels = [
      l10n.fitnessWeekdayMon,
      l10n.fitnessWeekdayTue,
      l10n.fitnessWeekdayWed,
      l10n.fitnessWeekdayThu,
      l10n.fitnessWeekdayFri,
      l10n.fitnessWeekdaySat,
      l10n.fitnessWeekdaySun,
    ];

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.fitnessScreenTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // A — Stats du jour
          _SectionHeader(title: l10n.fitnessSectionToday),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.4,
            children: kTodayStats
                .map(
                  (s) => _StatCard(
                    stat: s,
                    label: _statLabel(s.type, l10n),
                    unit: _statUnit(s.type, l10n),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // B — Activité hebdomadaire
          _SectionHeader(title: l10n.fitnessSectionWeekly),
          const SizedBox(height: AppSpacing.md),
          HarmonyCard(
            padding: AppSpacing.lg,
            child: SizedBox(
              height: 160,
              child: _WeeklyBarChart(dayLabels: dayLabels),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // C — Records
          _SectionHeader(title: l10n.fitnessSectionRecords),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kPersonalRecords
                  .map(
                    (r) => HarmonyListTile(
                      leadingIcon: r.icon,
                      leadingColor: r.color,
                      title: _recordTitle(r.type, l10n),
                      subtitle: _recordDetail(r.type, l10n),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // D — Dernières séances
          _SectionHeader(title: l10n.fitnessSectionSessions),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kRecentSessions
                  .map(
                    (s) => HarmonyListTile(
                      leadingIcon: s.icon,
                      leadingColor: AppColors.accentBlue,
                      title: _sessionType(s.type, l10n),
                      subtitle: _sessionDetail(s.type, l10n),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  String _statLabel(FitnessStatType type, AppLocalizations l10n) => switch (type) {
        FitnessStatType.steps => l10n.fitnessSteps,
        FitnessStatType.calories => l10n.fitnessCalories,
        FitnessStatType.distance => l10n.fitnessDistance,
        FitnessStatType.heartRate => l10n.fitnessHeartRate,
      };

  String? _statUnit(FitnessStatType type, AppLocalizations l10n) => switch (type) {
        FitnessStatType.steps => l10n.fitnessStepsGoal(8000),
        FitnessStatType.calories => l10n.fitnessCaloriesUnit,
        FitnessStatType.distance => l10n.fitnessDistanceUnit,
        FitnessStatType.heartRate => l10n.fitnessHeartRateUnit,
      };

  String _recordTitle(PersonalRecordType type, AppLocalizations l10n) => switch (type) {
        PersonalRecordType.longestWalk => l10n.fitnessRecordLongestWalk,
        PersonalRecordType.mostSteps => l10n.fitnessRecordMostSteps,
        PersonalRecordType.fastestRun => l10n.fitnessRecordFastestRun,
      };

  String _recordDetail(PersonalRecordType type, AppLocalizations l10n) => switch (type) {
        PersonalRecordType.longestWalk => l10n.fitnessRecordLongestWalkDesc,
        PersonalRecordType.mostSteps => l10n.fitnessRecordMostStepsDesc,
        PersonalRecordType.fastestRun => l10n.fitnessRecordFastestRunDesc,
      };

  String _sessionType(SessionType type, AppLocalizations l10n) => switch (type) {
        SessionType.walk => l10n.fitnessSessionWalk,
        SessionType.run => l10n.fitnessSessionRun,
        SessionType.bike => l10n.fitnessSessionBike,
      };

  String _sessionDetail(SessionType type, AppLocalizations l10n) => switch (type) {
        SessionType.walk => l10n.fitnessSessionWalkDesc,
        SessionType.run => l10n.fitnessSessionRunDesc,
        SessionType.bike => l10n.fitnessSessionBikeDesc,
      };
}

// ─── Stat card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.label, this.unit});
  final FitnessStat stat;
  final String label;
  final String? unit;

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
              Text(label, style: AppTypography.textTheme.labelSmall),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stat.value, style: AppTypography.monoMetric.copyWith(fontSize: 22, color: stat.color)),
              if (unit != null) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(unit!, style: AppTypography.textTheme.bodySmall),
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
  const _WeeklyBarChart({required this.dayLabels});
  final List<String> dayLabels;

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
                if (i < 0 || i >= dayLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dayLabels[i],
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
