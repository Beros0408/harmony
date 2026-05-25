import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/geofence_event.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/security_score.dart';
import 'package:harmony/features/parental/data/models/sos_alert.dart';
import 'package:harmony/features/parental/logic/security_score_calculator.dart';

LocationPoint _dummyLocation() => LocationPoint(
      id: 'loc-test',
      childId: 'c1',
      latitude: 48.85,
      longitude: 2.35,
      accuracy: 10,
      timestamp: DateTime.now(),
    );

GeofenceEvent _event(GeofenceEventType type) => GeofenceEvent(
      id: 'ev-${type.index}',
      childId: 'c1',
      zoneId: 'z1',
      zoneName: 'Zone',
      type: type,
      timestamp: DateTime.now(),
      location: _dummyLocation(),
    );

void main() {
  const calculator = SecurityScoreCalculator();
  const childId = 'c1';

  group('SecurityScoreCalculator', () {
    test('score max 100 sans events ni SOS', () {
      final score = calculator.calculate(
        childId: childId,
        recentEvents: [],
        recentSosAlerts: [],
      );
      expect(score.value, 100); // 40+30+20+10
      expect(score.level, SecurityScoreLevel.good);
    });

    test('score réduit avec plusieurs sorties de zone', () {
      final events = List.generate(5, (_) => _event(GeofenceEventType.exit));
      final score = calculator.calculate(
        childId: childId,
        recentEvents: events,
        recentSosAlerts: [],
      );
      expect(score.value, lessThan(100));
    });

    test('score réduit avec alerte SOS récente', () {
      final sosAlerts = [
        SosAlert(
          id: 'sos-1',
          childId: childId,
          childName: 'Lucas',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          location: _dummyLocation(),
          status: SosStatus.resolved,
        ),
      ];
      final score = calculator.calculate(
        childId: childId,
        recentEvents: [],
        recentSosAlerts: sosAlerts,
      );
      // -20 pts pour SOS récent
      expect(score.value, 80);
    });

    test('SOS vieux (>7 jours) n\'affecte pas le score', () {
      final sosAlerts = [
        SosAlert(
          id: 'sos-old',
          childId: childId,
          childName: 'Lucas',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          location: _dummyLocation(),
          status: SosStatus.resolved,
        ),
      ];
      final score = calculator.calculate(
        childId: childId,
        recentEvents: [],
        recentSosAlerts: sosAlerts,
      );
      expect(score.value, 100);
    });

    test('score toujours entre 0 et 100', () {
      final manyExits = List.generate(20, (_) => _event(GeofenceEventType.exit));
      final manySos = [
        SosAlert(
          id: 'sos-1',
          childId: childId,
          childName: 'Lucas',
          timestamp: DateTime.now(),
          location: _dummyLocation(),
          status: SosStatus.active,
        ),
      ];
      final score = calculator.calculate(
        childId: childId,
        recentEvents: manyExits,
        recentSosAlerts: manySos,
      );
      expect(score.value, greaterThanOrEqualTo(0));
      expect(score.value, lessThanOrEqualTo(100));
    });

    test('childId est préservé dans le score', () {
      final score = calculator.calculate(
        childId: childId,
        recentEvents: [],
        recentSosAlerts: [],
      );
      expect(score.childId, childId);
    });
  });
}
