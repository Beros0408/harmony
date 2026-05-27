import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harmony/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/services/feature_gating_service.dart';
import '../../../../shared/widgets/ad_banner.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_empty_state.dart';
import '../../../subscription/presentation/widgets/upgrade_prompt.dart';
import '../../data/models/daily_steps.dart';
import '../../data/models/workout_session.dart';
import '../../logic/fitness_cubit.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FitnessCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.fitnessScreenTitle,
        actions: [
          BlocBuilder<FitnessCubit, FitnessState>(
            builder: (context, state) => IconButton(
              icon: state is FitnessLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_outlined),
              onPressed:
                  state is FitnessLoading ? null : () => context.read<FitnessCubit>().load(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FitnessCubit, FitnessState>(
        builder: (context, state) => switch (state) {
          FitnessInitial() || FitnessLoading() =>
            const Center(child: CircularProgressIndicator()),
          FitnessPermissionDenied() => HarmonyEmptyState(
              icon: Icons.directions_walk_outlined,
              title: l10n.fitnessPermissionTitle,
              subtitle: l10n.fitnessPermissionSubtitle,
              cta: l10n.fitnessPermissionAllowCta,
              onCtaTap: () => context.read<FitnessCubit>().requestActivityAccess(),
            ),
          FitnessError(:final message) => HarmonyEmptyState(
              icon: Icons.error_outline,
              title: 'Erreur',
              subtitle: message,
              cta: 'Réessayer',
              onCtaTap: () => context.read<FitnessCubit>().load(),
            ),
          FitnessLoaded(:final today, :final weeklySteps, :final goal, :final recentWorkouts, :final activeWorkout) =>
            _FitnessBody(
              today: today,
              weeklySteps: weeklySteps,
              goal: goal,
              recentWorkouts: recentWorkouts,
              activeWorkout: activeWorkout,
            ),
        },
      ),
      floatingActionButton: BlocBuilder<FitnessCubit, FitnessState>(
        builder: (context, state) {
          if (state is! FitnessLoaded) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            heroTag: 'fitness_fab',
            onPressed: () => _showWorkoutSheet(context, state.activeWorkout, l10n),
            backgroundColor: AppColors.accentBlue,
            icon: Icon(
              state.activeWorkout != null ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
              color: Colors.white,
            ),
            label: Text(
              state.activeWorkout != null ? l10n.fitnessStopWorkout : l10n.fitnessStartWorkout,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  void _showWorkoutSheet(
      BuildContext context, WorkoutSession? active, AppLocalizations l10n) {
    if (active != null) {
      context.read<FitnessCubit>().stopWorkout(steps: active.stepsTotal);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FitnessCubit>(),
        child: _WorkoutPickerSheet(l10n: l10n),
      ),
    );
  }
}

// ─── Corps principal ──────────────────────────────────────────────────────────

class _FitnessBody extends StatefulWidget {
  const _FitnessBody({
    required this.today,
    required this.weeklySteps,
    required this.goal,
    required this.recentWorkouts,
    this.activeWorkout,
  });

  final DailySteps today;
  final List<DailySteps> weeklySteps;
  final int goal;
  final List<WorkoutSession> recentWorkouts;
  final WorkoutSession? activeWorkout;

  @override
  State<_FitnessBody> createState() => _FitnessBodyState();
}

class _FitnessBodyState extends State<_FitnessBody> {
  late double _goalSlider;

  @override
  void initState() {
    super.initState();
    _goalSlider = widget.goal.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final dayLabels = [
      l10n.fitnessWeekdayMon,
      l10n.fitnessWeekdayTue,
      l10n.fitnessWeekdayWed,
      l10n.fitnessWeekdayThu,
      l10n.fitnessWeekdayFri,
      l10n.fitnessWeekdaySat,
      l10n.fitnessWeekdaySun,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
      children: [
        // Séance active
        if (widget.activeWorkout != null) ...[
          _ActiveWorkoutBanner(session: widget.activeWorkout!, l10n: l10n),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Section 1 — Aujourd'hui
        Text(l10n.fitnessSectionToday, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        _TodayCard(today: widget.today, l10n: l10n),
        const SizedBox(height: AppSpacing.lg),

        // Section 2 — Stats du jour
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                icon: Icons.local_fire_department,
                color: AppColors.accentAmber,
                value: widget.today.caloriesEstimated.toStringAsFixed(0),
                label: l10n.fitnessCalories,
                unit: l10n.fitnessCaloriesUnit,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.straighten,
                color: AppColors.accentGreen,
                value: widget.today.distanceKm.toStringAsFixed(1),
                label: l10n.fitnessDistance,
                unit: l10n.fitnessDistanceUnit,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                icon: Icons.timer_outlined,
                color: AppColors.accentPurple,
                value: widget.today.activeMinutesEstimated.toString(),
                label: l10n.fitnessActiveMinutes,
                unit: 'min',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Section 3 — Activité hebdomadaire
        Text(l10n.fitnessSectionWeekly, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.md),
        HarmonyCard(
          padding: AppSpacing.lg,
          child: SizedBox(
            height: 160,
            child: _WeeklyBarChart(
              weeklySteps: widget.weeklySteps,
              goal: widget.goal,
              dayLabels: dayLabels,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Section 4 — Objectif quotidien
        Text(l10n.fitnessGoalTitle, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        HarmonyCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.fitnessGoalSteps(_goalSlider.toInt()),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.accentBlue),
              ),
              Slider(
                value: _goalSlider,
                min: 4000,
                max: 15000,
                divisions: 22,
                activeColor: AppColors.accentBlue,
                label: _goalSlider.toInt().toString(),
                onChanged: (v) => setState(() => _goalSlider = v),
                onChangeEnd: (v) =>
                    context.read<FitnessCubit>().updateGoal(v.toInt()),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('4 000', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  Text('15 000', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Section 5 — Séances récentes
        if (widget.recentWorkouts.isNotEmpty) ...[
          Text(l10n.fitnessSectionSessions, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: widget.recentWorkouts
                  .take(5)
                  .map((s) => _WorkoutTile(session: s, l10n: l10n))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!FeatureGatingService.instance.canAccessFitnessHistory(1))
            _WorkoutHistoryLock(),
          const SizedBox(height: AppSpacing.xxl),
        ],
        const AdBanner(),
      ],
    );
  }
}

// ─── Workout history lock ──────────────────────────────────────────────────────

class _WorkoutHistoryLock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => UpgradePrompt.show(
        context,
        title: 'Historique Premium',
        description:
            'Accédez à l\'historique complet de vos séances avec Premium Sport.',
        icon: Icons.fitness_center_outlined,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: AppColors.accentAmber),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Historique des semaines précédentes — Premium Sport',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                    ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.accentAmber),
          ],
        ),
      ),
    );
  }
}

// ─── Carte d'aujourd'hui ──────────────────────────────────────────────────────

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.today, required this.l10n});
  final DailySteps today;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final progress = today.progressRatio.clamp(0.0, 1.0);
    final color = today.goalReached ? AppColors.accentGreen : AppColors.accentBlue;

    return HarmonyCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Icon(
                today.goalReached ? Icons.check_circle : Icons.directions_walk,
                color: color,
                size: 28,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatSteps(today.stepCount)} / ${_formatSteps(today.goalSteps)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                ),
                Text(
                  l10n.fitnessSteps,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSteps(int n) {
    if (n >= 1000) {
      final k = n ~/ 1000;
      final r = (n % 1000) ~/ 100;
      return r > 0 ? '$k ${r}00' : '$k 000';
    }
    return n.toString();
  }
}

// ─── Mini stat card ───────────────────────────────────────────────────────────

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.unit,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: AppSpacing.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
          Text(unit, style: Theme.of(context).textTheme.labelSmall),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Graphique hebdomadaire ───────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({
    required this.weeklySteps,
    required this.goal,
    required this.dayLabels,
  });
  final List<DailySteps> weeklySteps;
  final int goal;
  final List<String> dayLabels;

  @override
  Widget build(BuildContext context) {
    final values = weeklySteps.map((d) => d.stepCount.toDouble()).toList();
    // Complète à 7 si la liste est courte
    while (values.length < 7) values.insert(0, 0);
    final maxY = ([...values, goal.toDouble()].reduce((a, b) => a > b ? a : b)) * 1.2;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: List.generate(values.length, (i) {
          final isToday = i == values.length - 1;
          final goalReached = values[i] >= goal;
          final color = goalReached
              ? AppColors.accentGreen
              : isToday
                  ? AppColors.accentBlue
                  : AppColors.accentBlue.withValues(alpha: 0.35);
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i] > 0 ? values[i] : 0,
                color: color,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
            ],
          );
        }),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: goal.toDouble(),
              color: AppColors.accentAmber.withValues(alpha: 0.5),
              strokeWidth: 1.5,
              dashArray: [6, 4],
            ),
          ],
        ),
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.6),
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

// ─── Séance active banner ─────────────────────────────────────────────────────

class _ActiveWorkoutBanner extends StatelessWidget {
  const _ActiveWorkoutBanner({required this.session, required this.l10n});
  final WorkoutSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.12),
        borderRadius: AppRadius.lgRadius,
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_filled, color: AppColors.accentGreen, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fitnessWorkoutRunning,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.accentGreen),
                ),
                Text(
                  session.type.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.read<FitnessCubit>().stopWorkout(),
            child: Text(l10n.fitnessStopWorkout,
                style: const TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }
}

// ─── Tuile séance récente ─────────────────────────────────────────────────────

class _WorkoutTile extends StatelessWidget {
  const _WorkoutTile({required this.session, required this.l10n});
  final WorkoutSession session;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final icon = switch (session.type) {
      WorkoutType.walking => Icons.directions_walk,
      WorkoutType.running => Icons.directions_run,
      WorkoutType.cycling => Icons.directions_bike,
    };
    final label = switch (session.type) {
      WorkoutType.walking => l10n.fitnessWorkoutTypeWalk,
      WorkoutType.running => l10n.fitnessWorkoutTypeRun,
      WorkoutType.cycling => l10n.fitnessWorkoutTypeCycle,
    };
    final dur = session.duration;
    final detail = '${dur.inMinutes} min · ${session.distanceKm.toStringAsFixed(1)} km';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.12),
          borderRadius: AppRadius.smRadius,
        ),
        child: Icon(icon, color: AppColors.accentBlue, size: 18),
      ),
      title: Text(label, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(detail, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

// ─── Sélecteur de type de séance ─────────────────────────────────────────────

class _WorkoutPickerSheet extends StatelessWidget {
  const _WorkoutPickerSheet({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.fitnessStartWorkout,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.lg),
          ...WorkoutType.values.map((type) {
            final icon = switch (type) {
              WorkoutType.walking => Icons.directions_walk,
              WorkoutType.running => Icons.directions_run,
              WorkoutType.cycling => Icons.directions_bike,
            };
            final label = switch (type) {
              WorkoutType.walking => l10n.fitnessWorkoutTypeWalk,
              WorkoutType.running => l10n.fitnessWorkoutTypeRun,
              WorkoutType.cycling => l10n.fitnessWorkoutTypeCycle,
            };
            return ListTile(
              leading: Icon(icon, color: AppColors.accentBlue),
              title: Text(label),
              onTap: () {
                Navigator.of(context).pop();
                context.read<FitnessCubit>().startWorkout(type);
              },
            );
          }),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
