import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum BreathingPhaseType { inhale, holdIn, exhale, holdOut }

class BreathingPhase {
  const BreathingPhase({required this.type, required this.durationSecs});
  final BreathingPhaseType type;
  final int durationSecs;
}

class BreathingPattern {
  const BreathingPattern({
    required this.phases,
    required this.color,
  });

  final List<BreathingPhase> phases;
  final Color color;

  int get cycleSecs => phases.fold(0, (acc, p) => acc + p.durationSecs);

  static const coherence = BreathingPattern(
    phases: [
      BreathingPhase(type: BreathingPhaseType.inhale, durationSecs: 5),
      BreathingPhase(type: BreathingPhaseType.exhale, durationSecs: 5),
    ],
    color: AppColors.accentBlue,
  );

  static const relax478 = BreathingPattern(
    phases: [
      BreathingPhase(type: BreathingPhaseType.inhale, durationSecs: 4),
      BreathingPhase(type: BreathingPhaseType.holdIn, durationSecs: 7),
      BreathingPhase(type: BreathingPhaseType.exhale, durationSecs: 8),
    ],
    color: AppColors.accentPurple,
  );

  static const box = BreathingPattern(
    phases: [
      BreathingPhase(type: BreathingPhaseType.inhale, durationSecs: 4),
      BreathingPhase(type: BreathingPhaseType.holdIn, durationSecs: 4),
      BreathingPhase(type: BreathingPhaseType.exhale, durationSecs: 4),
      BreathingPhase(type: BreathingPhaseType.holdOut, durationSecs: 4),
    ],
    color: AppColors.accentCyan,
  );

  static const all = [coherence, relax478, box];
}
