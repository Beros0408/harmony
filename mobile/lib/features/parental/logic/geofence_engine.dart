import 'dart:math';

import 'package:uuid/uuid.dart';

import '../data/models/geofence_event.dart';
import '../data/models/location_point.dart';
import '../data/models/safe_zone.dart';

/// Résultat d'une évaluation geofence pour un point de position donné.
class GeofenceResult {
  final List<GeofenceEvent> newEvents;
  const GeofenceResult({required this.newEvents});
  bool get hasEvents => newEvents.isNotEmpty;
}

/// Moteur de décision geofence — évalue les zones et produit des événements
/// entrée/sortie. Pure Dart, < 100ms par évaluation, testable sans plateforme.
class GeofenceEngine {
  const GeofenceEngine();

  static const _uuid = Uuid();

  /// Évalue la [point] par rapport aux [zones] actives et renvoie les nouveaux
  /// événements. [previousZoneIds] contient les IDs des zones où l'enfant
  /// était lors du dernier point connu.
  GeofenceResult evaluate({
    required LocationPoint point,
    required List<SafeZone> zones,
    required Set<String> previousZoneIds,
  }) {
    final events = <GeofenceEvent>[];
    final now = DateTime.now();

    for (final zone in zones) {
      if (!zone.isActiveAt(now)) continue;

      final distance = haversineDistance(
        point.latitude,
        point.longitude,
        zone.latitude,
        zone.longitude,
      );
      final isInside = distance <= zone.radiusMeters;
      final wasInside = previousZoneIds.contains(zone.id);

      if (isInside && !wasInside) {
        events.add(GeofenceEvent(
          id: _uuid.v4(),
          childId: point.childId,
          zoneId: zone.id,
          zoneName: zone.name,
          type: GeofenceEventType.entry,
          timestamp: now,
          location: point,
        ),);
      } else if (!isInside && wasInside) {
        events.add(GeofenceEvent(
          id: _uuid.v4(),
          childId: point.childId,
          zoneId: zone.id,
          zoneName: zone.name,
          type: GeofenceEventType.exit,
          timestamp: now,
          location: point,
        ),);
      }
    }

    return GeofenceResult(newEvents: events);
  }

  /// Calcule la distance Haversine entre deux coordonnées GPS (en mètres).
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371000.0; // rayon terrestre en mètres
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _rad(double deg) => deg * pi / 180;
}
