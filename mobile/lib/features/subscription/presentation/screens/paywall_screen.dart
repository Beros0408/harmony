import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/models/user_subscription.dart';
import '../../logic/subscription_cubit.dart';
import '../widgets/premium_badge.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  SubscriptionPeriod _period = SubscriptionPeriod.yearly;
  int _selectedPlanIndex = 1; // Famille par défaut (isPopular)

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.read<SubscriptionCubit>().restore(),
            child: Text(
              'Restaurer',
              style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
      body: BlocConsumer<SubscriptionCubit, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionLoaded && state.subscription.isActive) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Abonnement activé !')),
            );
            context.pop();
          }
          if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final plans = state is SubscriptionLoaded
              ? state.plans
              : state is SubscriptionPurchasing
                  ? state.plans
                  : SubscriptionPlan.defaults;

          final isPurchasing = state is SubscriptionPurchasing;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                // Hero header
                _HeroHeader(),
                const SizedBox(height: AppSpacing.lg),

                // Toggle mensuel / annuel
                _PeriodToggle(
                  selected: _period,
                  onChanged: (p) => setState(() => _period = p),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Plan cards
                ...plans.asMap().entries.map((entry) {
                  final i = entry.key;
                  final plan = entry.value;
                  // On exclut le plan lifetime du toggle — il s'affiche toujours
                  final effectivePeriod = plan.id == SubscriptionPlan.lifetimeId
                      ? SubscriptionPeriod.lifetime
                      : _period;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PlanCard(
                      plan: plan,
                      period: effectivePeriod,
                      isSelected: i == _selectedPlanIndex,
                      onTap: () => setState(() => _selectedPlanIndex = i),
                    ),
                  );
                }),

                const SizedBox(height: AppSpacing.lg),

                // CTA principal
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onPressed: isPurchasing
                        ? null
                        : () {
                            final plan = plans[_selectedPlanIndex];
                            final period = plan.id == SubscriptionPlan.lifetimeId
                                ? SubscriptionPeriod.lifetime
                                : _period;
                            context
                                .read<SubscriptionCubit>()
                                .purchase(plan.id, period);
                          },
                    child: isPurchasing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Commencer maintenant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),
                _TrialNote(plans: plans, selectedIndex: _selectedPlanIndex, period: _period),

                const SizedBox(height: AppSpacing.md),
                _LegalLinks(),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: const Icon(Icons.workspace_premium, color: Colors.white, size: 40),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Harmony Premium',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Débloquez toutes les fonctionnalités',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

// ─── Period Toggle ────────────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.selected, required this.onChanged});

  final SubscriptionPeriod selected;
  final ValueChanged<SubscriptionPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Mensuel',
            isSelected: selected == SubscriptionPeriod.monthly,
            onTap: () => onChanged(SubscriptionPeriod.monthly),
          ),
          _Tab(
            label: 'Annuel  −20%',
            isSelected: selected == SubscriptionPeriod.yearly,
            onTap: () => onChanged(SubscriptionPeriod.yearly),
            highlight: true,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : highlight
                          ? AppColors.accentBlue
                          : cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.period,
    required this.isSelected,
    required this.onTap,
  });

  final SubscriptionPlan plan;
  final SubscriptionPeriod period;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final price = plan.priceForPeriod(period);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.08)
              : cs.surfaceContainerLow,
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : cs.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (plan.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Text(
                      'POPULAIRE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (!plan.isPopular) const PremiumBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Prix
            if (price != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${price.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    switch (period) {
                      SubscriptionPeriod.monthly => '/mois',
                      SubscriptionPeriod.yearly => '/an',
                      SubscriptionPeriod.lifetime => ' une fois',
                    },
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                  ),
                  if (period == SubscriptionPeriod.yearly &&
                      plan.yearlyDiscount > 0) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '−${(plan.yearlyDiscount * 100).round()}%',
                      style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            if (plan.trialDays > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '${plan.trialDays} jours d\'essai gratuit',
                  style: const TextStyle(
                    color: AppColors.accentGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Features
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.accentGreen),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        f,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.75),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trial note ───────────────────────────────────────────────────────────────

class _TrialNote extends StatelessWidget {
  const _TrialNote({
    required this.plans,
    required this.selectedIndex,
    required this.period,
  });

  final List<SubscriptionPlan> plans;
  final int selectedIndex;
  final SubscriptionPeriod period;

  @override
  Widget build(BuildContext context) {
    if (selectedIndex >= plans.length) return const SizedBox.shrink();
    final plan = plans[selectedIndex];
    if (plan.trialDays == 0) return const SizedBox.shrink();

    return Text(
      'Essai gratuit ${plan.trialDays} jours — annulation à tout moment',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.45),
          ),
    );
  }
}

// ─── Legal links ─────────────────────────────────────────────────────────────

class _LegalLinks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          decoration: TextDecoration.underline,
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      children: [
        GestureDetector(
          onTap: () {},
          child: Text('Conditions d\'utilisation', style: style),
        ),
        GestureDetector(
          onTap: () {},
          child: Text('Politique de confidentialité', style: style),
        ),
      ],
    );
  }
}
