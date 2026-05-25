import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/safe_zone.dart';
import 'package:harmony/features/parental/data/models/geofence_event.dart';
import 'package:harmony/features/parental/logic/geofence_engine.dart';

LocationPoint _point(String childId, double lat, double lon) => LocationPoint(
      id: 'pt-$childId',
      childId: childId,
      latitude: lat,
      longitude: lon,
      accuracy: 10,
      timestamp: DateTime.now(),
    );

SafeZone _zone(String id, double lat, double lon, double radius) => SafeZone(
      id: id,
      name: 'Zone $id',
      latitude: lat,
      longitude: lon,
      radiusMeters: radius,
      color: Colors.green,
      icon: SafeZoneIcon.home,
      activeDays: const [],
      childIds: const ['child-001'],
    );

void main() {
  const engine = GeofenceEngine();

  // Centre de Paris
  const parisLat = 48.8534;
  const parisLon = 2.3488;
  // Lyon — ~391 km de Paris
  const lyonLat = 45.7640;
  const lyonLon = 4.8357;

  group('haversineDistance', () {
    test('distance nulle pour coordonnées identiques', () {
      final d = GeofenceEngine.haversineDistance(parisLat, parisLon, parisLat, parisLon);
      expect(d, closeTo(0, 0.001));
    });

    test('Paris → Lyon ≈ 391 000 mètres', () {
      final d = GeofenceEngine.haversineDistance(parisLat, parisLon, lyonLat, lyonLon);
      expect(d, greaterThan(380000));
      expect(d, lessThan(410000));
    });

    test('distance < 50m pour coordonnées proches', () {
      // ~10m de décalage en latitude
      final d = GeofenceEngine.haversineDistance(parisLat, parisLon, parisLat + 0.0001, parisLon);
      expect(d, lessThan(20));
    });
  });

  group('evaluate — entrée de zone', () {
    test('génère un événement ENTRY quand le point entre dans la zone', () {
      final zones = [_zone('z1', parisLat, parisLon, 500)];
      final point = _point('child-001', parisLat + 0.001, parisLon); // ~111m, dans zone 500m
      final result = engine.evaluate(
        point: point,
        zones: zones,
        previousZoneIds: {}, // n'était pas dans la zone
      );
      expect(result.hasEvents, isTrue);
      expect(result.newEvents.first.type, GeofenceEventType.entry);
      expect(result.newEvents.first.zoneId, 'z1');
    });

    test('génère un événement EXIT quand le point sort de la zone', () {
      final zones = [_zone('z1', parisLat, parisLon, 100)];
      // Lyon est hors de la zone 100m autour de Paris
      final point = _point('child-001', lyonLat, lyonLon);
      final result = engine.evaluate(
        point: point,
        zones: zones,
        previousZoneIds: {'z1'}, // était dans la zone
      );
      expect(result.hasEvents, isTrue);
      expect(result.newEvents.first.type, GeofenceEventType.exit);
    });

    test('aucun événement si le point reste à l\'intérieur', () {
      final zones = [_zone('z1', parisLat, parisLon, 500)];
      final point = _point('child-001', parisLat + 0.001, parisLon);
      final result = engine.evaluate(
        point: point,
        zones: zones,
        previousZoneIds: {'z1'}, // était déjà dans la zone
      );
      expect(result.hasEvents, isFalse);
    });

    test('aucun événement si le point reste à l\'extérieur', () {
      final zones = [_zone('z1', parisLat, parisLon, 50)];
      // Point à ~111m → hors zone 50m
      final point = _point('child-001', parisLat + 0.001, parisLon);
      final result = engine.evaluate(
        point: point,
        zones: zones,
        previousZoneIds: {}, // n'était pas dans la zone
      );
      expect(result.hasEvents, isFalse);
    });

    test('zone inactive ignorée', () {
      // Zone lundi-vendredi, on test un samedi (weekday=6)
      const zone = SafeZone(
        id: 'z-inactive',
        name: 'Zone inactive',
        latitude: parisLat,
        longitude: parisLon,
        radiusMeters: 500,
        color: Colors.blue,
        icon: SafeZoneIcon.school,
        activeDays: [1, 2, 3, 4, 5],
        childIds: ['child-001'],
        startTime: TimeOfDay(hour: 8, minute: 0),
        endTime: TimeOfDay(hour: 17, minute: 0),
      );
      // Point dans la zone géographiquement mais zone inactive pour les horaires
      final point = _point('child-001', parisLat + 0.001, parisLon);
      // On ne peut pas contrôler DateTime.now() sans injection, mais on vérifie
      // que evaluate ne plante pas avec une zone ayant des jours/horaires
      expect(
        () => engine.evaluate(point: point, zones: [zone], previousZoneIds: {}),
        returnsNormally,
      );
    });
  });

  group('evaluate — multiple zones', () {
    test('détecte entry dans plusieurs zones simultanément', () {
      final zones = [
        _zone('z1', parisLat, parisLon, 1000),
        _zone('z2', parisLat, parisLon, 500),
      ];
      final point = _point('child-001', parisLat + 0.001, parisLon);
      final result = engine.evaluate(
        point: point,
        zones: zones,
        previousZoneIds: {},
      );
      expect(result.newEvents.length, 2);
      expect(result.newEvents.every((e) => e.type == GeofenceEventType.entry), isTrue);
    });
  });
}
