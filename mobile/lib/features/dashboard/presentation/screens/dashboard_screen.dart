import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
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
    return Scaffold(
      appBar: HarmonyAppBar(
        title: 'Harmony',
        showGradient: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _WelcomeBanner(date: _formattedDate),
          const SizedBox(height: AppSpacing.xl),

          // Grille 2×2 des modules
          Text(
            'MES MODULES',
            style: AppTypography.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.1,
            children: const [
              _ModuleCard(
                title: 'Sécurité',
                subtitle: 'Filtrage actif',
                icon: Icons.shield_outlined,
                iconColor: AppColors.accentBlue,
                badge: 'actif',
                badgeVariant: HarmonyBadgeVariant.success,
              ),
              _ModuleCard(
                title: 'Famille',
                subtitle: 'Contrôle parental',
                icon: Icons.family_restroom,
                iconColor: AppColors.accentPurple,
                badge: '2 profils',
                badgeVariant: HarmonyBadgeVariant.purple,
              ),
              _ModuleCard(
                title: 'Fitness',
                subtitle: '0 / 8 000 pas',
                icon: Icons.directions_run,
                iconColor: AppColors.accentGreen,
                badge: 'en cours',
                badgeVariant: HarmonyBadgeVariant.info,
              ),
              _ModuleCard(
                title: 'Agenda',
                subtitle: '3 événements',
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.accentAmber,
                badge: 'aujourd\'hui',
                badgeVariant: HarmonyBadgeVariant.warning,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Section design system
          Text(
            'COMPOSANTS DU DESIGN SYSTEM',
            style: AppTypography.textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.md),

          // Boutons
          HarmonyCard(
            title: 'Boutons',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                HarmonyButton(
                  label: 'Primary',
                  onPressed: () {},
                ),
                HarmonyButton(
                  label: 'Secondary',
                  onPressed: () {},
                  variant: HarmonyButtonVariant.secondary,
                ),
                HarmonyButton(
                  label: 'Danger',
                  onPressed: () {},
                  variant: HarmonyButtonVariant.danger,
                ),
                HarmonyButton(
                  label: 'Ghost',
                  onPressed: () {},
                  variant: HarmonyButtonVariant.ghost,
                ),
                HarmonyButton(
                  label: 'Chargement',
                  onPressed: () {},
                  isLoading: true,
                ),
                HarmonyButton(
                  label: 'Avec icône',
                  onPressed: () {},
                  icon: Icons.add,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Badges
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

          // Status dots
          const HarmonyCard(
            title: 'Indicateurs de statut',
            child: Row(
              children: [
                HarmonyStatusDot(
                  status: HarmonyStatus.online,
                  pulse: true,
                ),
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

          // Toggles
          HarmonyCard(
            title: 'Interrupteurs',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HarmonyToggle(
                  value: _filterEnabled,
                  onChanged: (v) => setState(() => _filterEnabled = v),
                  label: 'Filtrage d\'appels',
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

          // Footer
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
          Text(
            'Bienvenue 👋',
            style: AppTypography.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            date,
            style: AppTypography.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Row(
            children: [
              HarmonyStatusDot(
                status: HarmonyStatus.online,
                pulse: true,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Tous les services actifs',
                style: TextStyle(
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badge,
    required this.badgeVariant,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final HarmonyBadgeVariant badgeVariant;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
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
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              HarmonyBadge(label: badge, variant: badgeVariant),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTypography.textTheme.titleMedium,
          ),
          Text(
            subtitle,
            style: AppTypography.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
