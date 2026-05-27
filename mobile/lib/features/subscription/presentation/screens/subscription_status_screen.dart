import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/user_subscription.dart';
import '../../logic/subscription_cubit.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const HarmonyAppBar(title: 'Mon abonnement'),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is SubscriptionInitial || state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sub = state is SubscriptionLoaded
              ? state.subscription
              : state is SubscriptionPurchasing
                  ? state.subscription
                  : UserSubscription.empty;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _StatusCard(subscription: sub),
              const SizedBox(height: AppSpacing.md),
              if (sub.isFree) ...[
                _UpgradeCard(),
              ] else ...[
                _ManageCard(subscription: sub),
              ],
              const SizedBox(height: AppSpacing.md),
              _RestoreButton(
                isLoading: state is SubscriptionPurchasing,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Status Card ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.subscription});

  final UserSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final planLabel = switch (subscription.planId) {
      'solo' => 'Premium Solo',
      'family' => 'Premium Famille',
      'sport' => 'Premium Sport',
      'lifetime' => 'Licence à vie',
      _ => 'Gratuit',
    };

    final statusLabel = switch (subscription.status) {
      SubscriptionStatus.active => 'Actif',
      SubscriptionStatus.trial => 'Essai gratuit',
      SubscriptionStatus.expired => 'Expiré',
      SubscriptionStatus.none => 'Aucun abonnement',
    };

    final statusColor = switch (subscription.status) {
      SubscriptionStatus.active => AppColors.accentGreen,
      SubscriptionStatus.trial => AppColors.accentBlue,
      SubscriptionStatus.expired => AppColors.accentRed,
      SubscriptionStatus.none => AppColors.textMuted,
    };

    return HarmonyCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: subscription.isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                      )
                    : null,
                color: subscription.isActive ? null : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                subscription.hasLifetime
                    ? Icons.all_inclusive
                    : subscription.isActive
                        ? Icons.workspace_premium
                        : Icons.lock_outline,
                color: subscription.isActive ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    planLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  if (subscription.expiresAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Renouvellement le ${DateFormat.yMMMd('fr_FR').format(subscription.expiresAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Upgrade Card ─────────────────────────────────────────────────────────────

class _UpgradeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passer à Premium',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Débloquez la blacklist illimitée, les profils enfants et le suivi fitness avancé.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                label: const Text('Voir les plans'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: () => context.push(RouteNames.paywall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Manage Card ──────────────────────────────────────────────────────────────

class _ManageCard extends StatelessWidget {
  const _ManageCard({required this.subscription});

  final UserSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return HarmonyCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Gérer l\'abonnement'),
              subtitle: Text(
                'Modifier ou annuler via l\'App Store / Google Play',
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () {
                // Ouverture du store gérée par RevenueCat / plateforme
              },
            ),
            if (!subscription.willRenew &&
                subscription.status != SubscriptionStatus.none)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accentAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_outlined,
                        color: AppColors.accentAmber, size: 16),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Votre abonnement ne sera pas renouvelé.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.accentAmber,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Restore Button ───────────────────────────────────────────────────────────

class _RestoreButton extends StatelessWidget {
  const _RestoreButton({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_outlined, size: 16),
        label: const Text('Restaurer les achats'),
        onPressed: isLoading
            ? null
            : () => context.read<SubscriptionCubit>().restore(),
      ),
    );
  }
}
