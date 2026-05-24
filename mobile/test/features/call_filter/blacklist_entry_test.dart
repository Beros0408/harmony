import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';

void main() {
  final now = DateTime(2026, 5, 25, 10, 0, 0);

  final entry = BlacklistEntry(
    id: 'abc-123',
    phoneNumber: '+33612345678',
    label: 'Spam',
    reason: BlockReason.spam,
    createdAt: now,
    updatedAt: now,
  );

  group('BlacklistEntry — toMap / fromMap', () {
    test('toMap produit les clés attendues', () {
      final map = entry.toMap();
      expect(map['id'], 'abc-123');
      expect(map['phone_number'], '+33612345678');
      expect(map['label'], 'Spam');
      expect(map['reason'], 'spam');
      expect(map['created_at'], now.millisecondsSinceEpoch);
      expect(map['updated_at'], now.millisecondsSinceEpoch);
    });

    test('fromMap reconstruit un BlacklistEntry identique', () {
      final roundtrip = BlacklistEntry.fromMap(entry.toMap());
      expect(roundtrip, entry);
    });

    test('fromMap raison inconnue → spam par défaut', () {
      final map = entry.toMap()..['reason'] = 'unknown_reason';
      final result = BlacklistEntry.fromMap(map);
      expect(result.reason, BlockReason.spam);
    });

    test('label null survit au roundtrip', () {
      final noLabel = BlacklistEntry(
        id: 'x',
        phoneNumber: '+33600000000',
        label: null,
        reason: BlockReason.other,
        createdAt: now,
        updatedAt: now,
      );
      final result = BlacklistEntry.fromMap(noLabel.toMap());
      expect(result.label, isNull);
    });
  });

  group('BlacklistEntry — copyWith', () {
    test('copyWith reason met à jour uniquement la raison', () {
      final updated = entry.copyWith(reason: BlockReason.harassment);
      expect(updated.reason, BlockReason.harassment);
      expect(updated.id, entry.id);
      expect(updated.phoneNumber, entry.phoneNumber);
      expect(updated.createdAt, entry.createdAt);
    });

    test('copyWith label null efface le label', () {
      final updated = entry.copyWith(label: null);
      expect(updated.label, isNull);
    });

    test('copyWith updatedAt met à jour la date', () {
      final later = DateTime(2026, 5, 26);
      final updated = entry.copyWith(updatedAt: later);
      expect(updated.updatedAt, later);
      expect(updated.createdAt, entry.createdAt);
    });
  });
}
