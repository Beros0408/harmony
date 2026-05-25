import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../logic/sos_cubit.dart';

class SosActiveScreen extends StatelessWidget {
  const SosActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SosCubit, SosState>(
      listener: (context, state) {
        if (state is SosResolved) {
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is! SosActive) {
          return const Scaffold(
            backgroundColor: AppColors.accentRed,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        final remaining = context.read<SosCubit>().callDelay - state.elapsed;
        final remainingClamped = remaining.isNegative ? Duration.zero : remaining;
        final mins = remainingClamped.inMinutes.remainder(60).toString().padLeft(2, '0');
        final secs = remainingClamped.inSeconds.remainder(60).toString().padLeft(2, '0');
        final countdownStr = '$mins:$secs';

        // Déclenche appel 112 automatiquement après 2 minutes
        if (remaining.isNegative || remaining == Duration.zero) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            launchUrl(Uri.parse('tel:112'));
          });
        }

        return Scaffold(
          backgroundColor: AppColors.accentRed,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 80),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    l10n.sosActiveTitle,
                    style: AppTypography.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    state.alert.childName,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // GPS position
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${state.alert.location.latitude.toStringAsFixed(5)}, '
                          '${state.alert.location.longitude.toStringAsFixed(5)}',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Countdown 112
                  Text(
                    l10n.sosActiveCountdown,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    countdownStr,
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Bouton annuler
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _confirmCancel(context, l10n, state.alert.id),
                      child: Text(l10n.sosActiveCancel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context, AppLocalizations l10n, String alertId) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sosActiveCancel),
        content: Text(l10n.sosCancelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SosCubit>().cancel(alertId);
            },
            child: Text(l10n.sosActiveCancel, style: const TextStyle(color: AppColors.accentRed)),
          ),
        ],
      ),
    );
  }
}
