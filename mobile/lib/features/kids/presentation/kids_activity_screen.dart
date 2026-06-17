import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../logic/kids_activity_cubit.dart';

/// Écran "Mes pas" — côté enfant.
/// Affiche le compteur de pas du jour via le capteur natif pedometer.
/// Objectif fixe : 6 000 pas. Strings hardcodées en français (pas d'AppLocalizations côté enfant).
class KidsActivityScreen extends StatelessWidget {
  const KidsActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KidsActivityCubit()..load(),
      child: const _KidsActivityView(),
    );
  }
}

// ─── Vue principale ───────────────────────────────────────────────────────────

class _KidsActivityView extends StatelessWidget {
  const _KidsActivityView();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes pas'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: BlocBuilder<KidsActivityCubit, KidsActivityState>(
        builder: (context, state) {
          return switch (state) {
            KidsActivityInitial() || KidsActivityLoading() =>
              const Center(child: CircularProgressIndicator()),
            KidsActivityError(:final message) =>
              _ErrorView(message: message),
            KidsActivityLoaded() =>
              _LoadedBody(state: state),
          };
        },
      ),
    );
  }
}

// ─── Corps chargé ────────────────────────────────────────────────────────────

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});
  final KidsActivityLoaded state;

  @override
  Widget build(BuildContext context) {
    if (state.isPermissionDenied) {
      return _PermissionDeniedView(
        onRetry: () => context.read<KidsActivityCubit>().requestPermission(),
      );
    }

    final progress = (state.steps / state.goal).clamp(0.0, 1.0);
    final color = progress >= 1.0 ? AppColors.accentGreen : AppColors.accentBlue;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.xxl),

        // ── Anneau de progression ─────────────────────────────────────────
        Center(
          child: _StepRing(steps: state.steps, progress: progress, color: color),
        ),

        const SizedBox(height: AppSpacing.xxl),

        // ── Barre objectif ────────────────────────────────────────────────
        _GoalCard(
          steps: state.steps,
          goal: state.goal,
          progress: progress,
          color: color,
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Message d'encouragement ───────────────────────────────────────
        Center(
          child: Text(
            _motivation(progress),
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  String _motivation(double progress) {
    if (progress >= 1.0) return 'Objectif atteint ! Bravo !';
    if (progress >= 0.75) return 'Plus que quelques pas, courage !';
    if (progress >= 0.5) return 'À mi-chemin, continue comme ça !';
    if (progress >= 0.25) return 'Bon début, garde le rythme !';
    return 'Allez, on se lève !';
  }
}

// ─── Anneau CircularProgressIndicator ────────────────────────────────────────

class _StepRing extends StatelessWidget {
  const _StepRing({
    required this.steps,
    required this.progress,
    required this.color,
  });
  final int steps;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 14,
            strokeCap: StrokeCap.round,
            backgroundColor: cs.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$steps',
                  style: tt.displaySmall?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'pas',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Carte objectif + barre linéaire ─────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.steps,
    required this.goal,
    required this.progress,
    required this.color,
  });
  final int steps;
  final int goal;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Objectif du jour',
                style: tt.labelLarge?.copyWith(color: cs.onSurface),
              ),
              Text(
                '$goal pas',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$steps / $goal pas',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Permission refusée ───────────────────────────────────────────────────────

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.directions_walk,
            size: 72,
            color: AppColors.accentAmber,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Permission requise',
            style: tt.titleLarge?.copyWith(color: cs.onSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pour compter tes pas, KimiaCare Kids a besoin '
            'd\'accéder à l\'activité physique de ton appareil.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Autoriser'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

// ─── Erreur générique ─────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          style: TextStyle(color: cs.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
