import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../data/services/usage_stats_service.dart';

/// Écran d'onboarding pour la permission PACKAGE_USAGE_STATS.
/// Explique pourquoi l'accès à l'usage est nécessaire (bien-être, transparence),
/// et guide l'utilisateur pour l'activer dans les réglages Android.
class ScreenTimePermissionScreen extends StatefulWidget {
  const ScreenTimePermissionScreen({super.key});

  @override
  State<ScreenTimePermissionScreen> createState() =>
      _ScreenTimePermissionScreenState();
}

class _ScreenTimePermissionScreenState
    extends State<ScreenTimePermissionScreen> with WidgetsBindingObserver {
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Recheck à chaque retour au premier plan (l'utilisateur peut revenir des réglages)
    if (state == AppLifecycleState.resumed) _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await UsageStatsService.instance.isPermissionGranted();
    if (mounted) setState(() => _granted = granted);
  }

  Future<void> _openSettings() async {
    await UsageStatsService.instance.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Suivi du temps d\'écran'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xl),

            // Icône illustrative
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 44,
                  color: AppColors.accentBlue,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            Text(
              'Mesure de l\'usage des applications',
              style: tt.titleLarge?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'Pour t\'aider à mieux gérer ton temps d\'écran, '
              'Harmony a besoin de savoir quelles applications tu utilises '
              'et pendant combien de temps.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Détails de ce qui est mesuré
            _InfoRow(
              icon: Icons.phone_android_outlined,
              text: 'Temps passé sur chaque application ce jour-là',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.lock_outline,
              text: 'Ces données restent sur ton appareil et entre toi et ton parent uniquement',
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.block_outlined,
              text: 'Aucune lecture du contenu des messages ni des photos',
            ),

            const Spacer(),

            // Statut actuel
            _PermissionStatusChip(granted: _granted),
            const SizedBox(height: AppSpacing.lg),

            // Bouton principal
            if (!_granted)
              FilledButton.icon(
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Activer dans les réglages Android'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _openSettings,
              )
            else
              FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Accès activé — retourner'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),

            if (!_granted) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Android affichera la liste des apps autorisées.\n'
                'Trouve "KimiaCare Kids" et active l\'accès.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.accentBlue),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class _PermissionStatusChip extends StatelessWidget {
  const _PermissionStatusChip({required this.granted});
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final color = granted ? AppColors.accentGreen : AppColors.accentAmber;
    final icon  = granted ? Icons.check_circle_outline : Icons.warning_amber_outlined;
    final label = granted ? 'Accès accordé' : 'Accès non encore accordé';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
