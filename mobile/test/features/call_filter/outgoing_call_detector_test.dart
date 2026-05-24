import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/domain/outgoing_call_detector.dart';

void main() {
  const detector = OutgoingCallDetector();

  group('OutgoingCallDetector — numéros FR surtaxés', () {
    test('0899 → danger', () {
      final r = detector.assess('0899123456');
      expect(r.level, OutgoingCallRiskLevel.danger);
      expect(r.estimatedCostPerMinute, 1.50);
    });

    test('0892 → danger', () {
      final r = detector.assess('0892 12 34 56');
      expect(r.level, OutgoingCallRiskLevel.danger);
      expect(r.estimatedCostPerMinute, 0.34);
    });

    test('0890 → danger (coût faible)', () {
      final r = detector.assess('0890000000');
      expect(r.level, OutgoingCallRiskLevel.danger);
      expect(r.estimatedCostPerMinute, 0.06);
    });
  });

  group('OutgoingCallDetector — US premium', () {
    test('+1900 → danger', () {
      final r = detector.assess('+19001234567');
      expect(r.level, OutgoingCallRiskLevel.danger);
    });
  });

  group('OutgoingCallDetector — numéros sûrs', () {
    test('numéro FR standard → safe', () {
      final r = detector.assess('+33612345678');
      expect(r.level, OutgoingCallRiskLevel.safe);
    });

    test('numéro local sans + → safe', () {
      final r = detector.assess('0612345678');
      expect(r.level, OutgoingCallRiskLevel.safe);
    });

    test('numéro avec espaces → safe', () {
      final r = detector.assess('06 12 34 56 78');
      expect(r.level, OutgoingCallRiskLevel.safe);
    });
  });

  group('OutgoingCallDetector — international', () {
    test('+44 (UK, non autorisé par défaut) → warning', () {
      final r = detector.assess('+447911123456');
      expect(r.level, OutgoingCallRiskLevel.warning);
      expect(r.estimatedCostPerMinute, isNull);
    });

    test('+1 (US, autorisé par défaut) → safe', () {
      final r = detector.assess('+14155551234');
      expect(r.level, OutgoingCallRiskLevel.safe);
    });

    test('pays personnalisé autorisé → safe', () {
      const custom = OutgoingCallDetector(allowedCountryCodes: ['+44']);
      final r = custom.assess('+447911123456');
      expect(r.level, OutgoingCallRiskLevel.safe);
    });
  });

  group('OutgoingCallDetector — normalisation', () {
    test('parenthèses et tirets ignorés', () {
      final r = detector.assess('(0899) 12-34-56');
      expect(r.level, OutgoingCallRiskLevel.danger);
    });

    test('points ignorés', () {
      final r = detector.assess('08.99.12.34.56');
      expect(r.level, OutgoingCallRiskLevel.danger);
    });
  });
}
