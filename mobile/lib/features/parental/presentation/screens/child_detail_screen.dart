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
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_badge.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/child_profile.dart';
import '../../data/models/location_point.dart';
import '../../data/models/security_score.dart';
import '../../data/services/lock_command_service.dart';
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
