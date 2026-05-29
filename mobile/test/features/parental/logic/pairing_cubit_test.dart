import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/services/pairing_service.dart';
import 'package:harmony/features/parental/logic/pairing_cubit.dart';

// ─── Stubs ────────────────────────────────────────────────────────────────────

class _SuccessPairingService extends PairingService {
  @override
  Future<PairingResult> generatePairingCode(String childName) async {
    return PairingResult(
      code: '123456',
      childName: childName,
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
  }
}

class _FailingPairingService extends PairingService {
  @override
  Future<PairingResult> generatePairingCode(String childName) async {
    throw Exception('Erreur réseau simulée');
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('PairingCubit', () {
    test('état initial est PairingInitial', () {
      expect(
        PairingCubit(service: _SuccessPairingService()).state,
        isA<PairingInitial>(),
      );
    });

    blocTest<PairingCubit, PairingState>(
      'generate("") ne change pas l\'état',
      build: () => PairingCubit(service: _SuccessPairingService()),
      act: (c) => c.generate(''),
      expect: () => <PairingState>[],
    );

    blocTest<PairingCubit, PairingState>(
      'generate("Emma") émet Loading puis Success avec code 123456',
      build: () => PairingCubit(service: _SuccessPairingService()),
      act: (c) => c.generate('Emma'),
      expect: () => [
        isA<PairingLoading>(),
        predicate<PairingState>(
          (s) =>
              s is PairingSuccess &&
              s.code == '123456' &&
              s.childName == 'Emma',
          'PairingSuccess code=123456 childName=Emma',
        ),
      ],
    );

    blocTest<PairingCubit, PairingState>(
      'generate("Emma") avec service en erreur émet Loading puis PairingError',
      build: () => PairingCubit(service: _FailingPairingService()),
      act: (c) => c.generate('Emma'),
      expect: () => [
        isA<PairingLoading>(),
        isA<PairingError>(),
      ],
    );

    blocTest<PairingCubit, PairingState>(
      'generate("  Lucas  ") normalise le prénom (trim)',
      build: () => PairingCubit(service: _SuccessPairingService()),
      act: (c) => c.generate('  Lucas  '),
      expect: () => [
        isA<PairingLoading>(),
        predicate<PairingState>(
          (s) => s is PairingSuccess && s.childName == 'Lucas',
          'PairingSuccess childName=Lucas (trimmed)',
        ),
      ],
    );
  });
}
