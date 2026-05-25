import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/harmony_app_bar.dart';
import '../../../../shared/widgets/harmony_card.dart';
import '../../data/models/location_point.dart';
import '../../data/repositories/location_repository.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key, required this.childId});
  final String childId;

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  DateTime _selectedDay = DateTime.now();
  List<LocationPoint> _points = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final from = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final to = from.add(const Duration(days: 1));
    final pts = await LocationRepository.instance.getHistory(widget.childId, from, to);
    if (mounted) {
      setState(() {
        _points = pts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      appBar: HarmonyAppBar(title: l10n.childDetailTitle),
      body: Column(
        children: [
          // Sélecteur date
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() => _selectedDay = _selectedDay.subtract(const Duration(days: 1)));
                    _load();
                  },
                ),
                Expanded(
                  child: Text(
                    '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))
                      ? () {
                          setState(() => _selectedDay = _selectedDay.add(const Duration(days: 1)));
                          _load();
                        }
                      : null,
                ),
              ],
            ),
          ),

          // Carte avec polyline
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _points.isEmpty
                    ? Center(child: Text('Aucun trajet pour ce jour', style: AppTypography.textTheme.bodyMedium))
                    : _MapWithPolyline(points: _points),
          ),

          // Stats
          if (_points.isNotEmpty) _StatsCard(points: _points),
        ],
      ),
    );
  }
}

class _MapWithPolyline extends StatelessWidget {
  const _MapWithPolyline({required this.points});
  final List<LocationPoint> points;

  @override
  Widget build(BuildContext context) {
    final latLngs = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final center = latLngs.isEmpty ? const LatLng(48.8534, 2.3488) : latLngs.first;

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.harmony.app',
        ),
        PolylineLayer(
          polylines: [
            Polyline(
              points: latLngs,
              color: AppColors.accentBlue,
              strokeWidth: 3,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            if (latLngs.isNotEmpty)
              Marker(
                point: latLngs.first,
                width: 20,
                height: 20,
                child: const CircleAvatar(backgroundColor: AppColors.accentGreen, radius: 10),
              ),
            if (latLngs.length > 1)
              Marker(
                point: latLngs.last,
                width: 20,
                height: 20,
                child: const CircleAvatar(backgroundColor: AppColors.accentRed, radius: 10),
              ),
          ],
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.points});
  final List<LocationPoint> points;

  @override
  Widget build(BuildContext context) {
    final distance = _totalDistance();
    final duration = points.last.timestamp.difference(points.first.timestamp);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: HarmonyCard(
        padding: AppSpacing.md,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: 'Distance', value: '${(distance / 1000).toStringAsFixed(2)} km'),
            _Stat(label: 'Durée', value: '${hours}h${minutes.toString().padLeft(2, '0')}'),
            _Stat(label: 'Points', value: points.length.toString()),
          ],
        ),
      ),
    );
  }

  double _totalDistance() {
    if (points.length < 2) return 0;
    double total = 0;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      // Approximation rapide en degrés → mètres
      final dlat = (b.latitude - a.latitude) * 111000;
      final dlon = (b.longitude - a.longitude) * 85000;
      total += (dlat * dlat + dlon * dlon).abs();
    }
    return total;
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.textTheme.titleMedium),
        Text(label, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}
