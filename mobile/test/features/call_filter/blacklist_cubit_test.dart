import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:harmony/features/call_filter/data/models/blacklist_entry.dart';
import 'package:harmony/features/call_filter/data/repositories/i_blacklist_repository.dart';
import 'package:harmony/features/call_filter/logic/blacklist_cubit.dart';

class MockBlacklistRepository extends Mock implements IBlacklistRepository {}

BlacklistEntry _entry({String id = 'e1', String phone = '+33611111111'}) {
  final now = DateTime(2026, 5, 25);
  return BlacklistEntry(
    id: id,
    phoneNumber: phone,
    label: 'Test',
    reason: BlockReason.spam,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockBlacklistRepository repo;

  setUp(() {
    repo = MockBlacklistRepository();
    registerFallbackValue(_entry());
  });

  group('BlacklistCubit — état initial', () {
    test('état initial : liste vide, pas de chargement, pas d\'erreur', () {
      final cubit = BlacklistCubit(repo);
      expect(cubit.state.entries, isEmpty);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.error, isNull);
    });
  });

  group('BlacklistCubit — loadEntries', () {
    blocTest<BlacklistCubit, BlacklistState>(
      'loadEntries émet isLoading=true puis la liste des entrées',
      build: () => BlacklistCubit(repo),
      setUp: () {
        when(() => repo.getAll()).thenAnswer(
          (_) async => [_entry()],
        );
      },
      act: (cubit) => cubit.loadEntries(),
      expect: () => [
        const BlacklistState(isLoading: true),
        BlacklistState(entries: [_entry()]),
      ],
    );

    blocTest<BlacklistCubit, BlacklistState>(
      'loadEntries émet erreur si getAll lance une exception',
      build: () => BlacklistCubit(repo),
      setUp: () {
        when(() => repo.getAll()).thenThrow(Exception('DB error'));
      },
      act: (cubit) => cubit.loadEntries(),
      expect: () => [
        const BlacklistState(isLoading: true),
        isA<BlacklistState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('BlacklistCubit — search', () {
    blocTest<BlacklistCubit, BlacklistState>(
      'search met à jour searchQuery et entries',
      build: () => BlacklistCubit(repo),
      setUp: () {
        when(() => repo.search(any())).thenAnswer(
          (_) async => [_entry()],
        );
      },
      act: (cubit) => cubit.search('test'),
      expect: () => [
        const BlacklistState(searchQuery: 'test', isLoading: true),
        BlacklistState(searchQuery: 'test', entries: [_entry()]),
      ],
    );
  });

  group('BlacklistCubit — addEntry', () {
    blocTest<BlacklistCubit, BlacklistState>(
      'addEntry appelle repo.add puis recharge la liste',
      build: () => BlacklistCubit(repo),
      setUp: () {
        when(() => repo.add(any())).thenAnswer((_) async {});
        when(() => repo.search(any())).thenAnswer(
          (_) async => [_entry()],
        );
      },
      act: (cubit) => cubit.addEntry(_entry()),
      verify: (_) {
        verify(() => repo.add(any())).called(1);
      },
      expect: () => [
        const BlacklistState(isLoading: true),
        BlacklistState(entries: [_entry()]),
      ],
    );
  });

  group('BlacklistCubit — deleteEntry', () {
    blocTest<BlacklistCubit, BlacklistState>(
      'deleteEntry appelle repo.delete puis recharge la liste',
      build: () => BlacklistCubit(repo),
      seed: () => BlacklistState(entries: [_entry()]),
      setUp: () {
        when(() => repo.delete(any())).thenAnswer((_) async {});
        when(() => repo.search(any())).thenAnswer((_) async => []);
      },
      act: (cubit) => cubit.deleteEntry('e1'),
      verify: (_) {
        verify(() => repo.delete('e1')).called(1);
      },
      expect: () => [
        BlacklistState(entries: [_entry()], isLoading: true),
        const BlacklistState(),
      ],
    );
  });
}
