import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/child_profile.dart';
import 'package:harmony/features/parental/data/models/geofence_event.dart';
import 'package:harmony/features/parental/data/models/location_point.dart';
import 'package:harmony/features/parental/data/models/safe_zone.dart';
import 'package:harmony/features/parental/data/models/security_score.dart';
import 'package:harmony/features/parental/data/models/sos_alert.dart';

void main() {
  group('ChildProfile', () {
    const profile = ChildProfile(
      id: 'test-001',
      name: 'Lucas',
      age: 12,
      avatarColor: Colors.blue,
    );

    test('toMap / fromMap round-trip', () {
      final map = profile.toMap();
      final restored = ChildProfile.fromMap(map);
      expect(restored.id, profile.id);
      expect(restored.name, profile.name);
      expect(restored.age, profile.age);
    });

    test('copyWith remplace les champs ciblés', () {
      final updated = profile.copyWith(name: 'Emma', age: 9);
      expect(updated.name, 'Emma');
      expect(updated.age, 9);
      expect(updated.id, profile.id);
    });

    test('equality par id', () {
      const same = ChildProfile(id: 'test-001', name: 'Autre', age: 5, avatarColor: Colors.red);
      expect(profile, same);
    });
  });

  group('LocationPoint', () {
    final point = LocationPoint(
      id: 'pt-001',
      childId: 'child-001',
      latitude: 48.8534,
      longitude: 2.3488,
      accuracy: 10.0,
      timestamp: DateTime(2026, 5, 25, 10, 0),
    );

    test('toMap / fromMap round-trip', () {
      final map = point.toMap();
      final restored = LocationPoint.fromMap(map);
      expect(restored.latitude, point.latitude);
      expect(restored.longitude, point.longitude);
      expect(restored.childId, point.childId);
    });
  });

  group('SafeZone', () {
    const zone = SafeZone(
      id: 'zone-001',
      name: 'Maison',
      latitude: 48.8534,
      longitude: 2.3488,
      radiusMeters: 250,
      color: Colors.green,
      icon: SafeZoneIcon.home,
      activeDays: [],
      childIds: ['child-001'],
    );

    test('toMap / fromMap round-trip', () {
      final map = zone.toMap();
      final restored = SafeZone.fromMap(map);
      expect(restored.name, zone.name);
      expect(restored.radiusMeters, zone.radiusMeters);
      expect(restored.icon, zone.icon);
      expect(restored.childIds, contains('child-001'));
    });

    test('isActiveAt — zone 24h/24 est toujours active', () {
      expect(zone.isActiveAt(DateTime.now()), isTrue);
    });

    test('isActiveAt — zone avec horaires respectées', () {
      final zoneWithSchedule = zone.copyWith(
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
      );
      final inRange = DateTime(2026, 5, 25, 12, 0); // 12h
      final outOfRange = DateTime(2026, 5, 25, 20, 0); // 20h
      expect(zoneWithSchedule.isActiveAt(inRange), isTrue);
      expect(zoneWithSchedule.isActiveAt(outOfRange), isFalse);
    });
  });

  group('SecurityScore', () {
    test('level green pour score >= 70', () {
      final score = SecurityScore(childId: 'c1', value: 85, lastUpdate: DateTime.now());
      expect(score.level, SecurityScoreLevel.good);
    });

    test('level warning pour score 40-69', () {
      final score = SecurityScore(childId: 'c1', value: 55, lastUpdate: DateTime.now());
      expect(score.level, SecurityScoreLevel.warning);
    });

    test('level danger pour score < 40', () {
      final score = SecurityScore(childId: 'c1', value: 20, lastUpdate: DateTime.now());
      expect(score.level, SecurityScoreLevel.danger);
    });

    test('toMap / fromMap round-trip', () {
      final score = SecurityScore(childId: 'c1', value: 80, lastUpdate: DateTime(2026, 5, 25));
      final restored = SecurityScore.fromMap(score.toMap());
      expect(restored.value, 80);
      expect(restored.childId, 'c1');
    });
  });

  group('SosAlert', () {
    final location = LocationPoint(
      id: 'loc-001',
      childId: 'child-001',
      latitude: 48.8534,
      longitude: 2.3488,
      accuracy: 5,
      timestamp: DateTime.now(),
    );

    test('copyWith status', () {
      final alert = SosAlert(
        id: 'sos-001',
        childId: 'child-001',
        childName: 'Lucas',
        timestamp: DateTime.now(),
        location: location,
        status: SosStatus.active,
      );
      final resolved = alert.copyWith(status: SosStatus.resolved);
      expect(resolved.status, SosStatus.resolved);
      expect(resolved.id, alert.id);
    });
  });

  group('GeofenceEvent', () {
    test('type entry / exit distinguishable', () {
      expect(GeofenceEventType.entry != GeofenceEventType.exit, isTrue);
    });
  });
}
