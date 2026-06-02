import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/user_session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/child_profile.dart';
import '../../data/models/location_point.dart';
import '../../data/models/security_score.dart';
import '../../data/services/content_filter_api_service.dart';
import '../../data/services/lock_command_service.dart';
import '../../data/services/unlink_parent_service.dart';
import '../../logic/child_profile_cubit.dart';
import '../../logic/location_cubit.dart';
import '../widgets/schedules_section.dart';

class ChildDetailScreen extends StatelessWidget {
  const ChildDetailScreen({super.key, required this.childId});
  final String childId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(
        title: l10n.childDetailTitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.childSettingsTitle,
            onPressed: () => context.push('${RouteNames.childDetail}/$childId/settings'),
          ),
        ],
      ),
      body: BlocBuilder<ChildProfileCubit, ChildProfileState>(
        builder: (context, state) {
          if (state is! ChildProfileLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = state.profiles.where((p) => p.id == childId).firstOrNull;
          if (profile == null) return const Center(child: Text('Enfant introuvable'));

          final score = state.scores[childId];
          return _ChildDetailBody(profile: profile, score: score);
        },
      ),
    );
  }
}

class _ChildDetailBody extends StatelessWidget {
  const _ChildDetailBody({required this.profile, this.score});
  final ChildProfile profile;
  final SecurityScore? score;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scoreVal = score?.value ?? 50;
    final scoreVariant = scoreVal >= 70
        ? HarmonyBadgeVariant.success
        : scoreVal >= 40
            ? HarmonyBadgeVariant.warning
            : HarmonyBadgeVariant.danger;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        // Entête profil
        HarmonyCard(
          padding: AppSpacing.lg,
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: profile.avatarColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: profile.avatarColor.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    profile.name[0].toUpperCase(),
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: profile.avatarColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.familyChildAge(profile.name, profile.age),
                      style: AppTypography.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    HarmonyBadge(
                      label: l10n.childSecurityScore(scoreVal),
                      variant: scoreVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Carte centrée sur l'enfant
        _ChildMap(childId: profile.id, avatarColor: profile.avatarColor),
        const SizedBox(height: AppSpacing.lg),

        // Bouton historique
        OutlinedButton.icon(
          onPressed: () => context.push('${RouteNames.childDetail}/${profile.id}/history'),
          icon: const Icon(Icons.route),
          label: Text(l10n.childDetailTitle),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Bouton verrouillage à distance (Sprint B2)
        _LockButton(childId: profile.id),
        const SizedBox(height: AppSpacing.xl),

        // Section horaires de coucher (Sprint B3)
        SchedulesSection(childId: profile.id),
        const SizedBox(height: AppSpacing.xl),

        // Section filtrage de contenu (Sprint C)
        _ContentFilterSection(childId: profile.id),
        const SizedBox(height: AppSpacing.xl),

        // Section demandes de déliage (Sprint Délier)
        _UnlinkRequestsSection(childId: profile.id),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }
}

// ─── Bouton de verrouillage à distance ───────────────────────────────────────

class _LockButton extends StatefulWidget {
  const _LockButton({required this.childId});
  final String childId;

  @override
  State<_LockButton> createState() => _LockButtonState();
}

class _LockButtonState extends State<_LockButton> {
  bool _sending = false;

  Future<void> _onLockPressed() async {
    setState(() => _sending = true);
    try {
      await LockCommandService.instance.sendLock(widget.childId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de verrouillage envoyée.'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : impossible d\'envoyer la commande ($e).'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      icon: _sending
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.lock_outline),
      label: const Text('Verrouiller le téléphone'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accentAmber,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      ),
      onPressed: _sending ? null : _onLockPressed,
    );
  }
}

// ─── Section filtrage de contenu (Sprint C) ──────────────────────────────────

class _ContentFilterSection extends StatefulWidget {
  const _ContentFilterSection({required this.childId});
  final String childId;

  @override
  State<_ContentFilterSection> createState() => _ContentFilterSectionState();
}

class _ContentFilterSectionState extends State<_ContentFilterSection> {
  final _service = ContentFilterApiService.instance;

  bool _enabled = false;
  bool _loading = true;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final state = await _service.getFilterState(widget.childId);
      if (mounted) setState(() => _enabled = state.enabled);
    } catch (_) {
      // Silently fallback to désactivé si le réseau est coupé
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(bool value) async {
    if (_toggling) return;
    setState(() => _toggling = true);
    try {
      await _service.setFilterState(childId: widget.childId, enabled: value);
      if (mounted) setState(() => _enabled = value);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : impossible de modifier le filtrage ($e).'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FILTRAGE DU CONTENU',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        HarmonyCard(
          padding: AppSpacing.md,
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          color: _enabled
                              ? AppColors.accentGreen
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DNS familial (CleanBrowsing)',
                                style: tt.bodyMedium,
                              ),
                              Text(
                                _enabled ? 'Filtrage actif' : 'Désactivé',
                                style: tt.bodySmall?.copyWith(
                                  color: _enabled
                                      ? AppColors.accentGreen
                                      : cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_toggling)
                          const SizedBox(
                            width: 36,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Switch(value: _enabled, onChanged: _toggle),
                      ],
                    ),
                    if (_enabled) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.08),
                          borderRadius: AppRadius.mdRadius,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 14,
                              color: AppColors.accentGreen,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                'Les sites pour adultes, malware et phishing sont '
                                'bloqués automatiquement par le résolveur DNS '
                                'CleanBrowsing Family (185.228.168.168).',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

// ─── Carte de localisation ───────────────────────────────────────────────────

class _ChildMap extends StatelessWidget {
  const _ChildMap({required this.childId, required this.avatarColor});
  final String childId;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        final locations = state is LocationTracking ? state.latestByChild : <String, LocationPoint>{};
        final point = locations[childId];
        final center = point != null
            ? LatLng(point.latitude, point.longitude)
            : const LatLng(48.8534, 2.3488);

        return ClipRRect(
          borderRadius: AppRadius.xlRadius,
          child: SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 15),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.harmony.app',
                ),
                if (point != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: center,
                        width: 48,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Section demandes de déliage (Sprint Délier) ─────────────────────────────

/// Polling toutes les 15 s côté parent pour détecter si l'enfant demande à délier son appareil.
/// Affiche un dialog d'approbation dès qu'une demande en attente est détectée.
class _UnlinkRequestsSection extends StatefulWidget {
  const _UnlinkRequestsSection({required this.childId});
  final String childId;

  @override
  State<_UnlinkRequestsSection> createState() => _UnlinkRequestsSectionState();
}

class _UnlinkRequestsSectionState extends State<_UnlinkRequestsSection> {
  static const _pollInterval = Duration(seconds: 15);

  final _service = UnlinkParentService.instance;
  Timer? _timer;

  List<UnlinkPendingItem> _pending = [];
  bool _loading                    = true;
  bool _dialogOpen                 = false;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final parentId = UserSession.instance.parentId;
    if (parentId == null) return;

    try {
      final items = await _service.getPendingRequests(parentId);
      if (!mounted) return;

      // Filtre uniquement les demandes concernant cet enfant
      final forThisChild = items.where((r) => r.childId == widget.childId).toList();

      setState(() {
        _pending = forThisChild;
        _loading  = false;
      });

      // Affiche le dialog dès qu'une demande arrive, une seule fois à la fois
      if (forThisChild.isNotEmpty && !_dialogOpen) {
        _showUnlinkDialog(forThisChild.first);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showUnlinkDialog(UnlinkPendingItem request) async {
    _dialogOpen = true;
    final cs = Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.link_off, size: 32, color: AppColors.accentAmber),
        title: Text(
          '${request.childName} demande à délier son appareil',
          textAlign: TextAlign.center,
          style: Theme.of(ctx).textTheme.titleMedium,
        ),
        content: Text(
          'Si tu approuves, l\'appareil sera retiré du contrôle parental '
          'et Harmony Kids sera désactivé sur ce téléphone.',
          textAlign: TextAlign.center,
          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          // Bouton Refuser
          OutlinedButton.icon(
            icon: const Icon(Icons.close),
            label: const Text('Refuser'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.accentRed),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleReject(request);
            },
          ),
          // Bouton Approuver
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Approuver'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _handleApprove(request);
            },
          ),
        ],
      ),
    );

    _dialogOpen = false;
  }

  Future<void> _handleApprove(UnlinkPendingItem request) async {
    final parentId = UserSession.instance.parentId;
    if (parentId == null) return;
    try {
      await _service.approve(request.id, parentId);
      if (!mounted) return;
      setState(() => _pending.removeWhere((r) => r.id == request.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Déliage de ${request.childName} approuvé.'),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'approbation : $e'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleReject(UnlinkPendingItem request) async {
    final parentId = UserSession.instance.parentId;
    if (parentId == null) return;
    try {
      await _service.reject(request.id, parentId);
      if (!mounted) return;
      setState(() => _pending.removeWhere((r) => r.id == request.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande de déliage de ${request.childName} refusée.'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du refus : $e'),
          backgroundColor: AppColors.accentRed,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Aucune demande en attente : section invisible (pas de bruit inutile dans l'UI)
    if (_loading || _pending.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DÉLIAGE EN ATTENTE',
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final req in _pending)
          _UnlinkPendingCard(
            request: req,
            onApprove: () => _handleApprove(req),
            onReject: () => _handleReject(req),
          ),
      ],
    );
  }
}

/// Carte affichée pour chaque demande de déliage en attente dans la liste parent.
class _UnlinkPendingCard extends StatelessWidget {
  const _UnlinkPendingCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final UnlinkPendingItem request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_off, color: AppColors.accentAmber, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${request.childName} demande à délier son appareil',
                  style: tt.labelMedium?.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accentRed,
                    side: const BorderSide(color: AppColors.accentRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Approuver'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
