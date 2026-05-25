import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/parental/data/models/child_profile.dart';
import 'package:harmony/features/parental/data/repositories/i_child_profile_repository.dart';
import 'package:harmony/features/parental/logic/child_profile_cubit.dart';

class _StubChildRepo implements IChildProfileRepository {
  final List<ChildProfile> _store = [];

  @override
  Future<List<ChildProfile>> getAll() async => List.from(_store);

  @override
  Future<ChildProfile?> getById(String id) async =>
      _store.where((p) => p.id == id).firstOrNull;

  @override
  Future<void> add(ChildProfile profile) async => _store.add(profile);

  @override
  Future<void> update(ChildProfile profile) async {
    final idx = _store.indexWhere((p) => p.id == profile.id);
    if (idx >= 0) _store[idx] = profile;
  }

  @override
  Future<void> delete(String id) async => _store.removeWhere((p) => p.id == id);

  @override
  Future<void> seed(List<ChildProfile> profiles) async => _store.addAll(profiles);
}

void main() {
  group('ChildProfileCubit', () {
    late _StubChildRepo repo;

    setUp(() {
      repo = _StubChildRepo();
    });

    ChildProfileCubit buildCubit() => ChildProfileCubit(repo);

    test('état initial est ChildProfileLoading', () {
      expect(buildCubit().state, isA<ChildProfileLoading>());
    });

    blocTest<ChildProfileCubit, ChildProfileState>(
      'load() avec repo vide → ChildProfileLoaded([]) ',
      build: buildCubit,
      act: (c) => c.load(),
      expect: () => [
        isA<ChildProfileLoading>(),
        predicate<ChildProfileState>(
          (s) => s is ChildProfileLoaded && s.profiles.isEmpty,
          'ChildProfileLoaded vide',
        ),
      ],
    );

    blocTest<ChildProfileCubit, ChildProfileState>(
      'add() ajoute un profil et recharge',
      build: buildCubit,
      act: (c) async {
        await c.load();
        await c.add(const ChildProfile(id: 'p1', name: 'Lucas', age: 12, avatarColor: Colors.blue));
      },
      expect: () => [
        isA<ChildProfileLoading>(),
        predicate<ChildProfileState>((s) => s is ChildProfileLoaded && s.profiles.isEmpty),
        isA<ChildProfileLoading>(),
        predicate<ChildProfileState>((s) => s is ChildProfileLoaded && s.profiles.length == 1),
      ],
    );

    blocTest<ChildProfileCubit, ChildProfileState>(
      'remove() supprime le profil et recharge',
      build: buildCubit,
      setUp: () => repo.seed([
        const ChildProfile(id: 'p1', name: 'Lucas', age: 12, avatarColor: Colors.blue),
      ]),
      act: (c) async {
        await c.load();
        await c.remove('p1');
      },
      expect: () => [
        isA<ChildProfileLoading>(),
        predicate<ChildProfileState>((s) => s is ChildProfileLoaded && s.profiles.length == 1),
        isA<ChildProfileLoading>(),
        predicate<ChildProfileState>((s) => s is ChildProfileLoaded && s.profiles.isEmpty),
      ],
    );
  });
}
