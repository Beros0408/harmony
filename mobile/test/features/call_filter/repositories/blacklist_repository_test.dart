import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/call_filter/data/mock/security_mocks.dart';
import 'package:harmony/features/call_filter/data/repositories/blacklist_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ── Validation ────────────────────────────────────────────────────────────

  group('BlacklistRepository — isValidPhoneNumber', () {
    final repo = BlacklistRepository.instance;

    test('numéro E.164 valide retourne true', () {
      expect(repo.isValidPhoneNumber('+33612345678'), isTrue);
    });

    test('numéro local 10 chiffres retourne true', () {
      expect(repo.isValidPhoneNumber('0612345678'), isTrue);
    });

    test('numéro trop court retourne false', () {
      expect(repo.isValidPhoneNumber('123'), isFalse);
    });

    test('chaîne vide retourne false', () {
      expect(repo.isValidPhoneNumber(''), isFalse);
    });
  });

  // ── Normalisation ─────────────────────────────────────────────────────────

  group('BlacklistRepository — normalizePhoneNumber', () {
    final repo = BlacklistRepository.instance;

    test('0033 remplacé par +33', () {
      expect(repo.normalizePhoneNumber('0033612345678'), '+33612345678');
    });

    test('06 remplacé par +336', () {
      expect(repo.normalizePhoneNumber('0612345678'), '+33612345678');
    });

    test('espaces et tirets supprimés', () {
      expect(repo.normalizePhoneNumber('+33 6 12 34-56-78'), '+33612345678');
    });

    test('numéro déjà E.164 retourné sans modification', () {
      expect(repo.normalizePhoneNumber('+33612345678'), '+33612345678');
    });
  });

  // ── Mode ─────────────────────────────────────────────────────────────────

  group('BlacklistRepository — currentMode', () {
    test('mode initial est normal', () {
      expect(BlacklistRepository.instance.currentMode, FilterModeType.normal);
    });
  });
}
