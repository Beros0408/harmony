import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../domain/models/breathing_pattern.dart';
import 'breathing_session_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  BreathingPattern _selectedPattern = BreathingPattern.coherence;
  int _selectedMinutes = 3;

  static const _durations = [1, 3, 5];

  int get _totalCycles =>
      (_selectedMinutes * 60 / _selectedPattern.cycleSecs).round().clamp(1, 999);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero AppBar avec image océan (reprend le visuel du dashboard)
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppColors.bgBase,
            leading: BackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.breathingTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/océan calme, lever du soleil.png',
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x22000000), Color(0xBB000000)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Choix du mode ─────────────────────────────────────────────
                Text(
                  l10n.breathingChooseMode.toUpperCase(),
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                for (final pattern in BreathingPattern.all) ...[
                  _PatternCard(
                    pattern: pattern,
                    selected: _selectedPattern == pattern,
                    onTap: () => setState(() => _selectedPattern = pattern),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ── Choix de la durée ──────────────────────────────────────────
                Text(
                  l10n.breathingChooseDuration.toUpperCase(),
                  style: tt.titleSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    for (int i = 0; i < _durations.length; i++) ...[
                      _DurationChip(
                        label: _durationLabel(l10n, _durations[i]),
                        selected: _selectedMinutes == _durations[i],
                        onTap: () =>
                            setState(() => _selectedMinutes = _durations[i]),
                      ),
                      if (i < _durations.length - 1)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Info cycles calculés
                Text(
                  '≈ $_totalCycles cycles · ${_selectedPattern.cycleSecs}s / cycle',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xxl),

                HarmonyButton(
                  label: l10n.breathingStart,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BreathingSessionScreen(
                        pattern: _selectedPattern,
                        durationMinutes: _selectedMinutes,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(AppLocalizations l10n, int min) {
    if (min == 1) return l10n.breathingDuration1;
    if (min == 3) return l10n.breathingDuration3;
    return l10n.breathingDuration5;
  }
}

// ── Carte de mode de respiration ─────────────────────────────────────────────

class _PatternCard extends StatelessWidget {
  const _PatternCard({
    required this.pattern,
    required this.selected,
    required this.onTap,
  });

  final BreathingPattern pattern;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final color = pattern.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.10)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? color : cs.outline,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Icône colorée
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: selected ? 0.22 : 0.10),
              ),
              child: Icon(Icons.air_rounded, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name(l10n), style: tt.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    _desc(l10n),
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }

  String _name(AppLocalizations l10n) {
    if (pattern == BreathingPattern.coherence) return l10n.breathingModeCoherence;
    if (pattern == BreathingPattern.relax478) return l10n.breathingModeRelax;
    return l10n.breathingModeBox;
  }

  String _desc(AppLocalizations l10n) {
    if (pattern == BreathingPattern.coherence) return l10n.breathingModeCoherenceDesc;
    if (pattern == BreathingPattern.relax478) return l10n.breathingModeRelaxDesc;
    return l10n.breathingModeBoxDesc;
  }
}

// ── Chip de sélection de durée ────────────────────────────────────────────────

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accentBlue.withValues(alpha: 0.12)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected ? AppColors.accentBlue : cs.outline,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: tt.labelLarge?.copyWith(
            color: selected ? AppColors.accentBlue : cs.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
