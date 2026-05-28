import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmony/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/pulsing_dot.dart';
import '../../../../shared/widgets/wiggling_emoji.dart';

// Chemins des images Unsplash placées dans assets/images/
class _Images {
  static const securite   = 'assets/images/forêt brumeuse, cocon protecteur.png';
  static const famille    = 'assets/images/famille au coucher du soleil, chaleureux.png';
  static const fitness    = 'assets/images/joguese -dans-la foret.png';
  static const agenda     = 'assets/images/bureau zen, carnet et café.png';
  static const meditation = 'assets/images/océan calme, lever du soleil.png';
  static const contacts   = 'assets/images/liens humains chaleureux — friends tea conversation.png';
  static const messagerie = 'assets/images/écoute paisible — woman headphones pastel.png';
  static const messages   = 'assets/images/correspondance précieuse — handwritten letter calligraphy.png';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _formattedDate(BuildContext context) {
    final now = DateTime.now();
    final lang = Localizations.localeOf(context).languageCode;
    switch (lang) {
      case 'fr':
        return DateFormat('EEEE d MMMM yyyy', 'fr').format(now);
      case 'es':
        return DateFormat("EEEE d 'de' MMMM yyyy", 'es').format(now);
      case 'it':
        return DateFormat('EEEE d MMMM yyyy', 'it').format(now);
      case 'pt':
        return DateFormat("EEEE, d 'de' MMMM yyyy", 'pt').format(now);
      default:
        return DateFormat('EEEE, MMMM d yyyy', 'en').format(now);
    }
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
          _WelcomeBanner(date: _formattedDate(context)),
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
                backgroundImage: _Images.securite,
                onTap: () => context.push(RouteNames.security),
              ),
              _ModuleCard(
                title: l10n.moduleFamilyTitle,
                subtitle: l10n.moduleFamilySubtitle,
                icon: Icons.family_restroom,
                iconColor: AppColors.accentPurple,
                badge: l10n.moduleFamilyBadgeProfiles(2),
                badgeVariant: HarmonyBadgeVariant.purple,
                backgroundImage: _Images.famille,
                onTap: () => context.push(RouteNames.family),
              ),
              _ModuleCard(
                title: l10n.moduleFitnessTitle,
                subtitle: l10n.moduleFitnessSubtitle(0, 8000),
                icon: Icons.directions_run,
                iconColor: AppColors.accentGreen,
                badge: l10n.moduleFitnessBadge,
                badgeVariant: HarmonyBadgeVariant.info,
                backgroundImage: _Images.fitness,
                onTap: () => context.push(RouteNames.fitness),
              ),
              _ModuleCard(
                title: l10n.moduleMeditationTitle,
                subtitle: l10n.moduleMeditationSubtitle,
                icon: Icons.self_improvement,
                iconColor: AppColors.accentRose,
                badge: l10n.moduleMeditationBadge,
                badgeVariant: HarmonyBadgeVariant.rose,
                backgroundImage: _Images.meditation,
                onTap: () => context.push(RouteNames.meditation),
              ),
              _ModuleCard(
                title: l10n.moduleAgendaTitle,
                subtitle: l10n.moduleAgendaSubtitle(3),
                icon: Icons.calendar_today_outlined,
                iconColor: AppColors.accentAmber,
                badge: l10n.moduleAgendaBadge,
                badgeVariant: HarmonyBadgeVariant.warning,
                backgroundImage: _Images.agenda,
                onTap: () => context.push(RouteNames.agenda),
              ),
              _ModuleCard(
                title: l10n.moduleContactsTitle,
                subtitle: l10n.moduleContactsSubtitle,
                icon: Icons.contacts_outlined,
                iconColor: AppColors.accentCyan,
                badge: l10n.moduleContactsBadge(5),
                badgeVariant: HarmonyBadgeVariant.info,
                backgroundImage: _Images.contacts,
                onTap: () => context.push(RouteNames.contacts),
              ),
              _ModuleCard(
                title: l10n.voicemailScreenTitle,
                subtitle: l10n.voicemailNewCount(2),
                icon: Icons.voicemail_rounded,
                iconColor: AppColors.accentPurple,
                badge: '2',
                badgeVariant: HarmonyBadgeVariant.purple,
                backgroundImage: _Images.messagerie,
                onTap: () => context.push(RouteNames.voicemail),
              ),
              _ModuleCard(
                title: l10n.messagesModuleTitle,
                subtitle: l10n.messagesModuleSubtitle,
                icon: Icons.message_outlined,
                iconColor: const Color(0xFF25D366),
                badge: l10n.messagesModuleBadge,
                badgeVariant: HarmonyBadgeVariant.success,
                backgroundImage: _Images.messages,
                onTap: () => context.push(RouteNames.messages),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.date});
  final String date;

  // Salutation contextuelle selon l'heure de la journée
  String _greeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return l10n.greetingMorning;
    if (hour >= 12 && hour < 18) return l10n.greetingAfternoon;
    if (hour >= 18 && hour < 22) return l10n.greetingEvening;
    return l10n.greetingNight;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? const [Color(0xFF1E2D45), Color(0xFF0F1729)]
        : [cs.primaryContainer, cs.surface];

    // Mini-stat locale : helper interne pour éviter la répétition
    Widget statRow(IconData icon, Color iconColor, String text) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? cs.onSurfaceVariant : const Color(0xFF555555),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outline : const Color(0xFFE0E0E0),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne salutation : emoji animé + texte contextuel
          Row(
            children: [
              const WigglingEmoji(emoji: '👋', fontSize: 24),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  _greeting(l10n),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(date, style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF8BA3C7)
                          : const Color(0xFF616161),
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Pastille pulsante + statut global
          Row(
            children: [
              const PulsingDot(),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.dashboardAllServicesActive,
                style: TextStyle(
                  color: isDark ? AppColors.accentGreen : const Color(0xFF1A7A4A),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // 3 mini-stats (données mockées — seront connectées aux cubits en v2.3)
          statRow(
            Icons.shield_outlined,
            AppColors.accentBlue,
            l10n.welcomeStatsFiltered(12),
          ),
          statRow(
            Icons.directions_walk,
            AppColors.accentGreen,
            l10n.welcomeStatsSteps(6240, 8000),
          ),
          statRow(
            Icons.calendar_today_outlined,
            AppColors.accentRose,
            l10n.welcomeStatsEvents(3),
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
    this.backgroundImage,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String badge;
  final HarmonyBadgeVariant badgeVariant;
  final String? backgroundImage;
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
          child: widget.backgroundImage != null
              ? _buildImageCard(context)
              : _buildColorCard(context),
        ),
      ),
    );
  }

  // Card avec image Unsplash en fond + overlay sombre pour lisibilité WCAG AA
  Widget _buildImageCard(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.backgroundImage!, fit: BoxFit.cover),
          // gradient sombre : lisibilité texte blanc (WCAG AA)
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x73000000), // 45% opacité en haut
                  Color(0xBF000000), // 75% opacité en bas
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(widget.icon, color: Colors.white, size: 18),
                    ),
                    Flexible(
                      child: HarmonyBadge(label: widget.badge, variant: widget.badgeVariant),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      widget.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card colorée sémantique (sans image) — style original
  Widget _buildColorCard(BuildContext context) {
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
    );
  }
}
