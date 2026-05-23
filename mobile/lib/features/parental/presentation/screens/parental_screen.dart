import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_list_tile.dart';
import '../../../../shared/widgets/harmony_snack_bar.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';
import '../../data/mock/family_mocks.dart';

class ParentalScreen extends StatelessWidget {
  const ParentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: 'Famille & Contrôle parental',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // A — Enfants
          const _SectionHeader(title: 'MES ENFANTS'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: kChildren.map((child) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: child == kChildren.last ? 0 : AppSpacing.md,
                ),
                child: _ChildCard(child: child, onTap: () {
                  HarmonySnackBar.show(
                    context,
                    message: 'Détails de ${child.name} à venir au Sprint 2',
                  );
                },),
              ),
            ),).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // B — Localisation
          const _SectionHeader(title: 'LOCALISATION EN TEMPS RÉEL'),
          const SizedBox(height: AppSpacing.md),
          const _MapPlaceholder(),
          const SizedBox(height: AppSpacing.xxl),

          // C — Zones autorisées
          const _SectionHeader(title: 'ZONES AUTORISÉES'),
          const SizedBox(height: AppSpacing.sm),
          HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              children: kSafeZones.map((zone) => HarmonyListTile(
                leadingIcon: zone.icon,
                leadingColor: zone.status == HarmonyStatus.online
                    ? AppColors.accentGreen
                    : AppColors.accentAmber,
                title: zone.name,
                subtitle: zone.detail,
                trailing: HarmonyStatusDot(status: zone.status),
              ),).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // D — Limites quotidiennes
          const _SectionHeader(title: 'LIMITES QUOTIDIENNES'),
          const SizedBox(height: AppSpacing.md),
          ...kDailyLimits.map((limit) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LimitCard(
              label: limit.label,
              value: limit.value,
              progress: limit.progress,
              color: limit.progress > 0.65 ? AppColors.accentBlue : AppColors.accentAmber,
            ),
          ),),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ─── Child profile card ──────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.onTap});
  final ChildProfile child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scoreVariant = child.score >= 85
        ? HarmonyBadgeVariant.success
        : HarmonyBadgeVariant.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: AppRadius.lgRadius,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: child.avatarColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: child.avatarColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  child.letter,
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: child.avatarColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${child.name}, ${child.age} ans',
              style: AppTypography.textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                HarmonyStatusDot(status: child.status, pulse: child.status == HarmonyStatus.online),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    child.statusText,
                    style: AppTypography.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            HarmonyBadge(label: 'Score ${child.score}', variant: scoreVariant),
          ],
        ),
      ),
    );
  }
}

// ─── Progress limit card ─────────────────────────────────────────────────────

class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });
  final String label;
  final String value;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: AppSpacing.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTypography.textTheme.labelLarge),
              Text(value, style: AppTypography.monoSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.smRadius,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.bgElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map placeholder ─────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.bgElevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.map_outlined, color: AppColors.accentBlue, size: 26),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Carte interactive à venir', style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Google Maps — Sprint 2',
              style: AppTypography.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTypography.textTheme.titleSmall);
  }
}
