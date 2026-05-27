import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_audio_waveform.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_metric_card.dart';
import '../../../../shared/widgets/harmony_search_bar.dart';
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
  double _waveformProgress = 0.35;

  String get _formattedDate {
    final now = DateTime.now();
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: HarmonyAppBar(
        title: l10n.dashboardTitle,
        showGradient: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: cs.onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: cs.onSurfaceVariant),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
            onPressed: () => context.push(RouteNames.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _WelcomeBanner(date: _formattedDate),
          const SizedBox(height: AppSpacing.xl),

          Text(l10n.dashboardSectionModules, style: Theme.of(context).textTheme.titleSmall),
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
              _ModuleCard(
                title: l10n.moduleContactsTitle,
                subtitle: l10n.moduleContactsSubtitle,
                icon: Icons.contacts_outlined,
                iconColor: AppColors.accentCyan,
                badge: l10n.moduleContactsBadge(5),
                badgeVariant: HarmonyBadgeVariant.info,
                onTap: () => context.push(RouteNames.contacts),
              ),
              _ModuleCard(
                title: l10n.voicemailScreenTitle,
                subtitle: l10n.voicemailNewCount(2),
                icon: Icons.voicemail_rounded,
                iconColor: AppColors.accentPurple,
                badge: '2',
                badgeVariant: HarmonyBadgeVariant.purple,
                onTap: () => context.push(RouteNames.voicemail),
              ),
              _ModuleCard(
                title: l10n.messagesModuleTitle,
                subtitle: l10n.messagesModuleSubtitle,
                icon: Icons.message_outlined,
                iconColor: const Color(0xFF25D366),
                badge: l10n.messagesModuleBadge,
                badgeVariant: HarmonyBadgeVariant.success,
                onTap: () => context.push(RouteNames.messages),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Design system showcase — dev scaffold, intentionally hardcoded
          Text('COMPOSANTS DU DESIGN SYSTEM', style: Theme.of(context).textTheme.titleSmall),
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

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Métriques',
            child: Row(
              children: [
                Expanded(
                  child: HarmonyMetricCard(
                    icon: Icons.directions_walk,
                    iconColor: AppColors.accentGreen,
                    value: '6 842',
                    label: 'Pas',
                    unit: 'pas',
                    trend: 12.5,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HarmonyMetricCard(
                    icon: Icons.local_fire_department_outlined,
                    iconColor: AppColors.accentAmber,
                    value: '312',
                    label: 'Calories',
                    unit: 'kcal',
                    trend: -3.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          HarmonyCard(
            title: 'Waveform audio',
            child: Column(
              children: [
                HarmonyAudioWaveform(
                  progress: _waveformProgress,
                  isPlaying: false,
                ),
                const SizedBox(height: AppSpacing.md),
                Slider(
                  value: _waveformProgress,
                  onChanged: (v) => setState(() => _waveformProgress = v),
                  activeColor: AppColors.accentBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          const HarmonyCard(
            title: 'Recherche',
            child: HarmonySearchBar(hintText: 'Rechercher un contact...'),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Center(
            child: Text(
              'Harmony v0.3.0 · Sprint C3',
              style: Theme.of(context).textTheme.labelSmall,
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
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF1E2D45), Color(0xFF0F1729)]
        : [cs.primaryContainer, cs.surface];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.dashboardWelcomeWave, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(date, style: Theme.of(context).textTheme.bodyMedium),
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
                    Flexible(
                      child: HarmonyBadge(label: widget.badge, variant: widget.badgeVariant),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
                Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
