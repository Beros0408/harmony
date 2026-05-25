import 'dart:math' as math;

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
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../../../shared/widgets/harmony_status_dot.dart';
import '../../data/models/child_profile.dart';
import '../../data/models/location_point.dart';
import '../../data/models/safe_zone.dart';
import '../../data/models/security_score.dart';
import '../../logic/child_profile_cubit.dart';
import '../../logic/location_cubit.dart';
import '../../logic/safe_zone_cubit.dart';
import '../widgets/sos_button.dart';

class ParentalScreen extends StatefulWidget {
  const ParentalScreen({super.key});

  @override
  State<ParentalScreen> createState() => _ParentalScreenState();
}

class _ParentalScreenState extends State<ParentalScreen> {
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChildProfileCubit>().load();
      context.read<SafeZoneCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.familyScreenTitle),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.safeZoneEditor),
        backgroundColor: AppColors.accentGreen,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: Text(l10n.familyAddZoneFAB, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // A — Enfants
          _SectionHeader(title: l10n.familyChildrenSection),
          const SizedBox(height: AppSpacing.md),
          _ChildrenSection(),
          const SizedBox(height: AppSpacing.xxl),

          // B — Bouton SOS
          _SosBanner(),
          const SizedBox(height: AppSpacing.xxl),

          // C — Carte temps réel
          _SectionHeader(title: l10n.familyMapSection),
          const SizedBox(height: AppSpacing.md),
          _MapSection(mapController: _mapController),
          const SizedBox(height: AppSpacing.xxl),

          // D — Zones autorisées
          _SectionHeader(title: l10n.familyZonesSection),
          const SizedBox(height: AppSpacing.sm),
          _ZonesSection(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}

// ─── Children section ─────────────────────────────────────────────────────────

class _ChildrenSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildProfileCubit, ChildProfileState>(
      builder: (context, profileState) {
        if (profileState is ChildProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (profileState is! ChildProfileLoaded || profileState.profiles.isEmpty) {
          return const SizedBox.shrink();
        }
        return BlocBuilder<LocationCubit, LocationState>(
          builder: (context, locState) {
            final locs = locState is LocationTracking ? locState.latestByChild : <String, LocationPoint>{};
            final zones = _zonesFrom(context);
            return Row(
              children: profileState.profiles
                  .map((child) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: child == profileState.profiles.last ? 0 : AppSpacing.md,
                          ),
                          child: _ChildCard(
                            child: child,
                            score: profileState.scores[child.id],
                            location: locs[child.id],
                            zones: zones,
                            onTap: () => context.push('${RouteNames.childDetail}/${child.id}'),
                          ),
                        ),
                      ),)
                  .toList(),
            );
          },
        );
      },
    );
  }

  List<SafeZone> _zonesFrom(BuildContext context) {
    final s = context.read<SafeZoneCubit>().state;
    return s is SafeZoneLoaded ? s.zones : [];
  }
}

// ─── SOS banner ──────────────────────────────────────────────────────────────

class _SosBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildProfileCubit, ChildProfileState>(
      builder: (context, state) {
        final name = state is ChildProfileLoaded && state.profiles.isNotEmpty
            ? state.profiles.first.name
            : '';
        return SosButton(childName: name);
      },
    );
  }
}

// ─── Child card ──────────────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.onTap,
    this.score,
    this.location,
    this.zones = const [],
  });

  final ChildProfile child;
  final SecurityScore? score;
  final LocationPoint? location;
  final List<SafeZone> zones;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scoreVal = score?.value ?? 50;
    final scoreVariant = scoreVal >= 70
        ? HarmonyBadgeVariant.success
        : scoreVal >= 40
            ? HarmonyBadgeVariant.warning
            : HarmonyBadgeVariant.danger;

    final statusText = _locationText(l10n);
    final dotStatus = _dotStatus();

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
                  child.name[0].toUpperCase(),
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    color: child.avatarColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.familyChildAge(child.name, child.age),
              style: AppTypography.textTheme.labelLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                HarmonyStatusDot(status: dotStatus, pulse: dotStatus == HarmonyStatus.online),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    statusText,
                    style: AppTypography.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            HarmonyBadge(
              label: l10n.childSecurityScore(scoreVal),
              variant: scoreVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _locationText(AppLocalizations l10n) {
    if (location == null) return l10n.childInTransit;
    for (final zone in zones) {
      final dist = _haversine(
        location!.latitude,
        location!.longitude,
        zone.latitude,
        zone.longitude,
      );
      if (dist <= zone.radiusMeters) return l10n.childAtZone(zone.name);
    }
    return l10n.childInTransit;
  }

  HarmonyStatus _dotStatus() {
    final val = score?.value ?? 50;
    if (val >= 70) return HarmonyStatus.online;
    if (val >= 40) return HarmonyStatus.warning;
    return HarmonyStatus.offline;
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) *
            math.cos(lat2 * math.pi / 180) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

// ─── Map section ─────────────────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  const _MapSection({required this.mapController});
  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locState) {
        if (locState is LocationPermissionRequired) {
          return _PermissionBanner(l10n: l10n);
        }

        final locations = locState is LocationTracking ? locState.latestByChild : <String, LocationPoint>{};
        final center = _center(locations.values.toList());

        return BlocBuilder<SafeZoneCubit, SafeZoneState>(
          builder: (context, zoneState) {
            final zones = zoneState is SafeZoneLoaded ? zoneState.zones : <SafeZone>[];
            return ClipRRect(
              borderRadius: AppRadius.xlRadius,
              child: SizedBox(
                height: 240,
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.harmony.app',
                    ),
                    CircleLayer(
                      circles: zones
                          .map((z) => CircleMarker(
                                point: LatLng(z.latitude, z.longitude),
                                radius: z.radiusMeters,
                                color: z.color.withValues(alpha: 0.2),
                                borderColor: z.color,
                                borderStrokeWidth: 2,
                                useRadiusInMeter: true,
                              ),)
                          .toList(),
                    ),
                    MarkerLayer(
                      markers: locations.entries
                          .map((e) => Marker(
                                point: LatLng(e.value.latitude, e.value.longitude),
                                width: 40,
                                height: 40,
                                child: _ChildMarker(childId: e.key),
                              ),)
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  LatLng _center(List<LocationPoint> pts) {
    if (pts.isEmpty) return const LatLng(48.8534, 2.3488);
    final lat = pts.map((p) => p.latitude).reduce((a, b) => a + b) / pts.length;
    final lon = pts.map((p) => p.longitude).reduce((a, b) => a + b) / pts.length;
    return LatLng(lat, lon);
  }
}

class _ChildMarker extends StatelessWidget {
  const _ChildMarker({required this.childId});
  final String childId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChildProfileCubit, ChildProfileState>(
      builder: (context, state) {
        var color = AppColors.accentBlue;
        var initial = '?';
        if (state is ChildProfileLoaded) {
          final p = state.profiles.where((p) => p.id == childId).firstOrNull;
          if (p != null) {
            color = p.avatarColor;
            initial = p.name[0].toUpperCase();
          }
        }
        return Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: AppSpacing.lg,
      child: Column(
        children: [
          const Icon(Icons.location_off, color: AppColors.accentAmber, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.permissionLocationTitle, style: AppTypography.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.permissionLocationBody, style: AppTypography.textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          HarmonyButton(
            label: l10n.permissionLocationGrant,
            onPressed: () => context.read<LocationCubit>().requestPermissions([]),
          ),
        ],
      ),
    );
  }
}

// ─── Zones section ───────────────────────────────────────────────────────────

class _ZonesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SafeZoneCubit, SafeZoneState>(
      builder: (context, state) {
        if (state is SafeZoneLoading) return const Center(child: CircularProgressIndicator());
        if (state is! SafeZoneLoaded || state.zones.isEmpty) return const SizedBox.shrink();
        return _ZonesList(zones: state.zones);
      },
    );
  }
}

class _ZonesList extends StatelessWidget {
  const _ZonesList({required this.zones});
  final List<SafeZone> zones;

  @override
  Widget build(BuildContext context) {
    return HarmonyCard(
      padding: AppSpacing.md,
      child: Column(
        children: zones.map((zone) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: zone.color.withValues(alpha: 0.15),
                borderRadius: AppRadius.smRadius,
              ),
              child: Icon(_iconFor(zone.icon), color: zone.color, size: 20),
            ),
            title: Text(zone.name, style: AppTypography.textTheme.labelLarge),
            subtitle: Text(
              '${zone.radiusMeters.toInt()}m · ${_schedule(zone)}',
              style: AppTypography.textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => context.push('${RouteNames.safeZoneEditor}/${zone.id}'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.accentRed),
                  onPressed: () => context.read<SafeZoneCubit>().deleteZone(zone.id),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(SafeZoneIcon icon) => switch (icon) {
        SafeZoneIcon.home => Icons.home,
        SafeZoneIcon.school => Icons.school,
        SafeZoneIcon.sport => Icons.sports_soccer,
        SafeZoneIcon.other => Icons.place,
      };

  String _schedule(SafeZone z) {
    if (z.startTime != null && z.endTime != null) {
      return '${z.startTime!.hour}h-${z.endTime!.hour}h';
    }
    return '24h/24';
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
