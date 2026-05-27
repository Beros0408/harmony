import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';

/// BottomSheet réutilisable affiché quand l'utilisateur atteint une limite Free.
///
/// Usage :
/// ```dart
/// UpgradePrompt.show(
///   context,
///   title: 'Blacklist complète',
///   description: 'Passez en Premium pour des entrées illimitées.',
/// );
/// ```
class UpgradePrompt extends StatelessWidget {
  const UpgradePrompt({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.workspace_premium_outlined,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpgradePrompt(
        title: title,
        description: description,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Icon gradient
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEAB308), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // CTA Premium
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined, size: 18),
                label: const Text('Passer à Premium'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () {
                  // Capture router before pop — context is deactivated after BottomSheet dismissal
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push(RouteNames.paywall);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Pas maintenant',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
