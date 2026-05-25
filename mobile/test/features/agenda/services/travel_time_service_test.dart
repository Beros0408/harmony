import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/agenda/data/services/travel_time_service.dart';

void main() {
  group('TravelTimeService', () {
    late TravelTimeService service;

    setUp(() {
      service = TravelTimeService.instance;
      service.clearCache();
    });

    test('fallback driving returns reasonable duration', () async {
      final result = await service.calculateTravelTime(
        origin: '48.8566,2.3522',
        destination: '48.8606,2.3376',
        mode: TravelMode.driving,
      );
      expect(result.isEstimated, isTrue);
      expect(result.durationMinutes, greaterThan(0));
    });

    test('fallback walking is slower than driving', () async {
      const origin = '48.8566,2.3522';
      const dest = '43.2965,5.3811';
      final driving = await service.calculateTravelTime(
        origin: origin,
        destination: dest,
        mode: TravelMode.driving,
      );
      final walking = await service.calculateTravelTime(
        origin: origin,
        destination: dest,
        mode: TravelMode.walking,
      );
      service.clearCache();
      expect(walking.durationMinutes, greaterThan(driving.durationMinutes));
    });

    test('non-parseable locations return default duration', () async {
      final result = await service.calculateTravelTime(
        origin: 'Paris, France',
        destination: 'Lyon, France',
        mode: TravelMode.driving,
      );
      expect(result.isEstimated, isTrue);
      expect(result.durationMinutes, equals(15));
    });

    test('cache returns same result on second call', () async {
      const origin = '48.8566,2.3522';
      const dest = '48.8606,2.3376';
      final first = await service.calculateTravelTime(
        origin: origin,
        destination: dest,
      );
      final second = await service.calculateTravelTime(
        origin: origin,
        destination: dest,
      );
      expect(second.durationMinutes, equals(first.durationMinutes));
      expect(second.isEstimated, equals(first.isEstimated));
    });

    test('clearCache forces fresh calculation', () async {
      const origin = '48.8566,2.3522';
      const dest = '48.8606,2.3376';
      await service.calculateTravelTime(origin: origin, destination: dest);
      service.clearCache();
      final fresh = await service.calculateTravelTime(
        origin: origin,
        destination: dest,
      );
      expect(fresh, isNotNull);
    });

    test('all travel modes return positive duration', () async {
      for (final mode in TravelMode.values) {
        final result = await service.calculateTravelTime(
          origin: 'Paris',
          destination: 'Lyon',
          mode: mode,
        );
        service.clearCache();
        expect(
          result.durationMinutes,
          greaterThan(0),
          reason: 'Mode $mode should return positive duration',
        );
      }
    });
  });
}
