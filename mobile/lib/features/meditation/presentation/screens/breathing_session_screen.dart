import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../domain/models/breathing_pattern.dart';
import '../widgets/breathing_circle.dart';

class BreathingSessionScreen extends StatefulWidget {
  const BreathingSessionScreen({
    super.key,
    required this.pattern,
    required this.durationMinutes,
  });

  final BreathingPattern pattern;
  final int durationMinutes;

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with SingleTickerProviderStateMixin {

  static const double _minScale = 0.35;
  static const double _maxScale = 1.0;

  late AnimationController _anim;
  late Animation<double> _scaleAnim;

  int _phaseIndex = 0;
  bool _sessionDone = false;

  Timer? _holdTimer;
  Timer? _countdownTimer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
    _anim = AnimationController(vsync: this);
    _scaleAnim = Tween<double>(begin: _minScale, end: _maxScale)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _anim.addStatusListener(_onAnimStatus);
    _startPhase();
    _startCountdown();
  }

  // ── Cycle de phases ────────────────────────────────────────────────────────

  BreathingPhase get _currentPhase =>
      widget.pattern.phases[_phaseIndex % widget.pattern.phases.length];

  void _startPhase() {
    _holdTimer?.cancel();
    _anim.stop();

    final phase = _currentPhase;
    final dur = Duration(seconds: phase.durationSecs);

    switch (phase.type) {
      case BreathingPhaseType.inhale:
        _scaleAnim = Tween<double>(begin: _minScale, end: _maxScale)
            .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
        _anim.duration = dur;
        _anim.forward(from: 0.0);
      case BreathingPhaseType.exhale:
        _scaleAnim = Tween<double>(begin: _maxScale, end: _minScale)
            .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
        _anim.duration = dur;
        _anim.forward(from: 0.0);
      case BreathingPhaseType.holdIn:
      case BreathingPhaseType.holdOut:
        // Pas d'animation pendant la rétention — juste une attente.
        _holdTimer = Timer(dur, _advancePhase);
    }

    setState(() {});
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_sessionDone && mounted) {
      _advancePhase();
    }
  }

  void _advancePhase() {
    if (!mounted || _sessionDone) return;
    _phaseIndex++;
    _startPhase();
  }

  // ── Compte à rebours global ────────────────────────────────────────────────

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final next = _remainingSeconds - 1;
      setState(() => _remainingSeconds = next.clamp(0, widget.durationMinutes * 60));
      if (_remainingSeconds == 0) _endSession();
    });
  }

  // ── Fin de session ─────────────────────────────────────────────────────────

  void _endSession() {
    _countdownTimer?.cancel();
    _holdTimer?.cancel();
    _anim.stop();
    if (mounted) setState(() => _sessionDone = true);
  }

  void _restart() {
    _countdownTimer?.cancel();
    _holdTimer?.cancel();
    _anim.stop();
    setState(() {
      _phaseIndex = 0;
      _remainingSeconds = widget.durationMinutes * 60;
      _sessionDone = false;
    });
    _startPhase();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _holdTimer?.cancel();
    _anim.removeStatusListener(_onAnimStatus);
    _anim.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _phaseLabel(AppLocalizations l10n) {
    return switch (_currentPhase.type) {
      BreathingPhaseType.inhale  => l10n.breathingPhaseInhale,
      BreathingPhaseType.holdIn  => l10n.breathingPhaseHold,
      BreathingPhaseType.exhale  => l10n.breathingPhaseExhale,
      BreathingPhaseType.holdOut => l10n.breathingPhaseHold,
    };
  }

  String _formatTime(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  int get _cyclesRemaining =>
      (_remainingSeconds / widget.pattern.cycleSecs).ceil().clamp(0, 999);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = widget.pattern.color;

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé subtil selon la couleur du mode
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.18),
                  cs.surface,
                ],
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Bouton Arrêter (haut gauche)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(l10n.breathingStop),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Texte de phase (Inspire / Retiens / Expire)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _phaseLabel(l10n),
                    key: ValueKey(_phaseIndex),
                    style: tt.headlineLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Cercle animé
                AnimatedBuilder(
                  animation: _anim,
                  builder: (context, _) => BreathingCircle(
                    scale: _scaleAnim.value,
                    color: color,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Compte à rebours global
                Text(
                  _formatTime(_remainingSeconds),
                  style: AppTypography.monoMetric.copyWith(
                    color: cs.onSurface,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Cycles restants
                Text(
                  l10n.breathingCyclesRemaining(_cyclesRemaining),
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),

                const Spacer(flex: 3),
              ],
            ),
          ),

          // Overlay fin de session
          if (_sessionDone)
            _SessionEndOverlay(
              color: color,
              onRestart: _restart,
              onClose: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }
}

// ── Overlay fin de séance ────────────────────────────────────────────────────

class _SessionEndOverlay extends StatelessWidget {
  const _SessionEndOverlay({
    required this.color,
    required this.onRestart,
    required this.onClose,
  });

  final Color color;
  final VoidCallback onRestart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 600),
      child: Container(
        color: cs.surface.withValues(alpha: 0.96),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.spa_outlined, color: color, size: 40),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.breathingSessionEnd,
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.breathingSessionCongrats,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  HarmonyButton(
                    label: l10n.breathingRestart,
                    onPressed: onRestart,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  HarmonyButton(
                    label: l10n.breathingReturn,
                    variant: HarmonyButtonVariant.ghost,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
