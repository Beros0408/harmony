import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/sos_cubit.dart';

class SosButton extends StatefulWidget {
  const SosButton({super.key, required this.childName});
  final String childName;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _holding = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _onLongPressStart(LongPressStartDetails _) {
    setState(() {
      _holding = true;
      _progress = 0;
    });
    _startCountdown();
  }

  void _startCountdown() async {
    const steps = 30;
    for (var i = 0; i <= steps; i++) {
      if (!_holding || !mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!_holding || !mounted) return;
      setState(() => _progress = i / steps);
    }
    if (_holding && mounted) {
      _holding = false;
      _triggerSos();
    }
  }

  void _onLongPressEnd(LongPressEndDetails _) {
    if (mounted) setState(() => _holding = false);
  }

  void _triggerSos() {
    context.read<SosCubit>().trigger(childName: widget.childName);
    context.push(RouteNames.sosActive);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final scale = _holding ? 1.0 : 1.0 + _pulse.value * 0.05;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.accentRed.withValues(alpha: _holding ? 0.25 : 0.12),
                borderRadius: AppRadius.lgRadius,
                border: Border.all(color: AppColors.accentRed, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sos, color: AppColors.accentRed, size: 28),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.sosButtonLabel,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.accentRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (_holding) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadius.smRadius,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.bgElevated,
                        valueColor: const AlwaysStoppedAnimation(AppColors.accentRed),
                        minHeight: 6,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.sosHoldHint,
                      style: AppTypography.textTheme.bodySmall?.copyWith(color: AppColors.accentRed),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
