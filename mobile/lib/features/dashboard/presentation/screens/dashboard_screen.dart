import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';
import '../../../../shared/widgets/harmony_toggle.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _filterEnabled = true;
  bool _parentalEnabled = false;

  String get _formattedDate {
    final now = DateTime.now();
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.dashboardTitle,
        showGradient: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _WelcomeBanner(date: _formattedDate),
          const SizedBox(height: AppSpacing.xl),

          Text(l10n.dashboardSectionModules, style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
            children: [
              _ModuleCard(
                title: l10n.moduleSecurityTitle,
                subtitle: l10n.moduleSecuritySubtitle,
                icon: Icons.shield_outlined,
                iconColor: AppColors.accentBlue,
                badge: l10n.moduleSecurityBadge,
                badgeVariant: HarmonyBadgeVariant.success,
                onTap: () => context.push(RouteNames.security),
              ),
              _ModuleCard(
                title: l10n.moduleFamilyTitle,
                subtitle: l10n.moduleFamilySubtitle,
                icon: Icons.family_restroom,
                iconColor: AppColors.accentPurple,
                badge: l10n.moduleFamilyBadgeProfiles(2),
                badgeVariant: HarmonyBadgeVariant.purple,
                onTap: () => context.push(RouteNames.family),
              ),
              _ModuleCard(
                title: l10n.moduleFitnessTitle,
                subtitle: l10n.moduleFitnessSubtitle(0, 8000),
                icon: Icons.directions_run,
                iconColor: AppColors.accentGreen,
                badge: l10n.moduleFitnessBadge,
                badgeVariant: HarmonyBadgeVariant.info,
                onTap: () => context.push(RouteNames.fitness),
              ),
              _ModuleCard(
                title: l10n.moduleAgendaTitle,
                subtitle: l10n.moduleAgendaSubtitle(3),
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.accentAmber,
                badge: l10n.moduleAgendaBadge,
                badgeVariant: HarmonyBadgeVariant.warning,
                onTap: () => context.push(RouteNames.agenda),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Design system showcase — dev scaffold, intentionally hardcoded
          Text('COMPOSANTS DU DESIGN SYSTEM', style: AppTypography.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Boutons',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                HarmonyButton(label: 'Primary', onPressed: () {}),
                HarmonyButton(label: 'Secondary', onPressed: () {}, variant: HarmonyButtonVariant.secondary),
                HarmonyButton(label: 'Danger', onPressed: () {}, variant: HarmonyButtonVariant.danger),
                HarmonyButton(label: 'Ghost', onPressed: () {}, variant: HarmonyButtonVariant.ghost),
                HarmonyButton(label: 'Chargement', onPressed: () {}, isLoading: true),
                HarmonyButton(label: 'Avec icône', onPressed: () {}, icon: Icons.add),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Badges',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                HarmonyBadge(label: 'Succès', variant: HarmonyBadgeVariant.success),
                HarmonyBadge(label: 'Avertissement', variant: HarmonyBadgeVariant.warning),
                HarmonyBadge(label: 'Danger', variant: HarmonyBadgeVariant.danger),
                HarmonyBadge(label: 'Info', variant: HarmonyBadgeVariant.info),
                HarmonyBadge(label: 'Purple', variant: HarmonyBadgeVariant.purple),
                HarmonyBadge(label: 'Muet', variant: HarmonyBadgeVariant.muted),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Indicateurs de statut',
            child: Row(
              children: [
                HarmonyStatusDot(status: HarmonyStatus.online, pulse: true),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.warning),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.error),
                SizedBox(width: AppSpacing.lg),
                HarmonyStatusDot(status: HarmonyStatus.offline),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Interrupteurs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HarmonyToggle(
                  value: _filterEnabled,
                  onChanged: (v) => setState(() => _filterEnabled = v),
                  label: "Filtrage d'appels",
                ),
                const SizedBox(height: AppSpacing.md),
                HarmonyToggle(
                  value: _parentalEnabled,
                  onChanged: (v) => setState(() => _parentalEnabled = v),
                  label: 'Contrôle parental',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Center(
            child: Text(
              'Harmony v0.1.0 · Sprint 0',
              style: AppTypography.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2D45), Color(0xFF0F1729)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashboardWelcomeWave, style: AppTypography.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(date, style: AppTypography.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const HarmonyStatusDot(status: HarmonyStatus.online, pulse: true),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.dashboardAllServicesActive,
                style: const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.badgeVariant,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final HarmonyBadgeVariant badgeVariant;
  final VoidCallback? onTap;

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _pressed ? 0.7 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          scale: _pressed ? 0.97 : 1.0,
          child: HarmonyCard(
            padding: AppSpacing.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.iconColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.icon, color: widget.iconColor, size: 18),
                    ),
                    HarmonyBadge(label: widget.badge, variant: widget.badgeVariant),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(widget.title, style: AppTypography.textTheme.titleMedium),
                Text(widget.subtitle, style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
