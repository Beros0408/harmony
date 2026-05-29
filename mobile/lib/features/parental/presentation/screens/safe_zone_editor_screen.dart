import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_button.dart';
import '../../../../shared/widgets/harmony_text_field.dart';
import '../../data/models/safe_zone.dart';
import '../../logic/child_profile_cubit.dart';
import '../../logic/safe_zone_cubit.dart';

class SafeZoneEditorScreen extends StatefulWidget {
  const SafeZoneEditorScreen({super.key, this.zoneId});
  final String? zoneId;

  @override
  State<SafeZoneEditorScreen> createState() => _SafeZoneEditorScreenState();
}

class _SafeZoneEditorScreenState extends State<SafeZoneEditorScreen> {
  static const _uuid = Uuid();

  final _nameController = TextEditingController();
  double _radius = 200;
  SafeZoneIcon _icon = SafeZoneIcon.home;
  Color _color = AppColors.accentGreen;
  LatLng _center = const LatLng(48.8534, 2.3488);
  List<String> _selectedChildIds = [];
  SafeZone? _editing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfEditing());
  }

  void _loadIfEditing() {
    if (widget.zoneId == null) return;
    final state = context.read<SafeZoneCubit>().state;
    if (state is SafeZoneLoaded) {
      final zone = state.zones.where((z) => z.id == widget.zoneId).firstOrNull;
      if (zone != null && mounted) {
        setState(() {
          _editing = zone;
          _nameController.text = zone.name;
          _radius = zone.radiusMeters;
          _icon = zone.icon;
          _color = zone.color;
          _center = LatLng(zone.latitude, zone.longitude);
          _selectedChildIds = List.from(zone.childIds);
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditing = widget.zoneId != null;

    return Scaffold(
      appBar: HarmonyAppBar(title: isEditing ? l10n.zoneEditorEditTitle : l10n.zoneEditorAddTitle),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Carte interactive
          ClipRRect(
            borderRadius: AppRadius.xlRadius,
            child: SizedBox(
              height: 240,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15,
                  onTap: (_, point) => setState(() => _center = point),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.harmony.app',
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _center,
                        radius: _radius,
                        color: _color.withValues(alpha: 0.2),
                        borderColor: _color,
                        borderStrokeWidth: 2,
                        useRadiusInMeter: true,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 32,
                        height: 32,
                        child: Icon(Icons.location_on, color: _color, size: 32),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Appuyez sur la carte pour positionner la zone',
            style: tt.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Nom
          HarmonyTextField(
            controller: _nameController,
            label: l10n.zoneFieldName,
            hint: 'Ex: École Jules Ferry',
          ),
          const SizedBox(height: AppSpacing.lg),

          // Rayon
          Text(l10n.zoneFieldRadius, style: tt.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 50,
                  max: 5000,
                  divisions: 99,
                  activeColor: _color,
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
              Text(
                '${_radius.toInt()}m',
                style: tt.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Icône
          Text(l10n.zoneFieldIcon, style: tt.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: SafeZoneIcon.values.map((icon) {
              final isSelected = _icon == icon;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _icon = icon),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isSelected ? _color.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
                      borderRadius: AppRadius.smRadius,
                      border: Border.all(
                        color: isSelected ? _color : cs.outlineVariant,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(_iconDataFor(icon), color: isSelected ? _color : cs.onSurfaceVariant, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          _iconLabel(icon, l10n),
                          style: tt.labelSmall?.copyWith(
                            color: isSelected ? _color : cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Enfants concernés
          BlocBuilder<ChildProfileCubit, ChildProfileState>(
            builder: (context, state) {
              if (state is! ChildProfileLoaded) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enfants concernés', style: tt.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  ...state.profiles.map((child) {
                    final isSelected = _selectedChildIds.contains(child.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _selectedChildIds.add(child.id);
                        } else {
                          _selectedChildIds.remove(child.id);
                        }
                      }),
                      title: Text(l10n.familyChildAge(child.name, child.age)),
                      activeColor: _color,
                      contentPadding: EdgeInsets.zero,
                    );
                  }),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Bouton sauvegarder
          HarmonyButton(
            label: l10n.blacklistSaveButton,
            onPressed: _save,
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;

    final zone = SafeZone(
      id: _editing?.id ?? _uuid.v4(),
      name: _nameController.text.trim(),
      latitude: _center.latitude,
      longitude: _center.longitude,
      radiusMeters: _radius,
      color: _color,
      icon: _icon,
      activeDays: const [],
      childIds: _selectedChildIds,
    );

    if (_editing != null) {
      context.read<SafeZoneCubit>().updateZone(zone);
    } else {
      context.read<SafeZoneCubit>().addZone(zone);
    }
    context.pop();
  }

  IconData _iconDataFor(SafeZoneIcon icon) => switch (icon) {
        SafeZoneIcon.home => Icons.home,
        SafeZoneIcon.school => Icons.school,
        SafeZoneIcon.sport => Icons.sports_soccer,
        SafeZoneIcon.other => Icons.place,
      };

  String _iconLabel(SafeZoneIcon icon, AppLocalizations l10n) => switch (icon) {
        SafeZoneIcon.home => l10n.zoneIconHome,
        SafeZoneIcon.school => l10n.zoneIconSchool,
        SafeZoneIcon.sport => l10n.zoneIconSport,
        SafeZoneIcon.other => l10n.zoneIconOther,
      };
}
