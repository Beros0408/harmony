import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/voicemail/data/mock/voicemail_mocks.dart';

void main() {
  group('kVoicemails', () {
    test('retourne 4 messages', () {
      expect(kVoicemails().length, 4);
    });

    test('le premier message est urgent et non lu', () {
      final first = kVoicemails().first;
      expect(first.urgency, VoicemailUrgency.urgent);
      expect(first.isRead, isFalse);
    });

    test('au moins un message est marqué comme lu', () {
      expect(kVoicemails().any((v) => v.isRead), isTrue);
    });
  });
}
