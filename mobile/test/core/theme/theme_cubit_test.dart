import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/core/security/secure_storage.dart';
import 'package:harmony/core/theme/theme_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService storage;

  setUp(() {
    storage = MockSecureStorageService();
  });

  ThemeCubit buildCubit() => ThemeCubit(storage);

  group('ThemeCubit', () {
    test('état initial est ThemeMode.system', () {
      expect(buildCubit().state, ThemeMode.system);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'load() avec "light" en storage émet ThemeMode.light',
      build: buildCubit,
      setUp: () {
        when(
          () => storage.read(key: 'user_theme_mode'),
        ).thenAnswer((_) async => 'light');
      },
      act: (cubit) => cubit.load(),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'load() avec "dark" en storage émet ThemeMode.dark',
      build: buildCubit,
      setUp: () {
        when(
          () => storage.read(key: 'user_theme_mode'),
        ).thenAnswer((_) async => 'dark');
      },
      act: (cubit) => cubit.load(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'load() avec valeur inconnue en storage reste sur ThemeMode.system',
      build: buildCubit,
      setUp: () {
        when(
          () => storage.read(key: 'user_theme_mode'),
        ).thenAnswer((_) async => null);
      },
      act: (cubit) => cubit.load(),
      expect: () => <ThemeMode>[],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'change(ThemeMode.light) écrit en storage et émet ThemeMode.light',
      build: buildCubit,
      setUp: () {
        when(
          () => storage.write(key: 'user_theme_mode', value: 'light'),
        ).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.change(ThemeMode.light),
      expect: () => [ThemeMode.light],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'change(ThemeMode.dark) écrit "dark" en storage',
      build: buildCubit,
      setUp: () {
        when(
          () => storage.write(key: 'user_theme_mode', value: 'dark'),
        ).thenAnswer((_) async {});
      },
      act: (cubit) => cubit.change(ThemeMode.dark),
      verify: (cubit) {
        verify(
          () => storage.write(key: 'user_theme_mode', value: 'dark'),
        ).called(1);
      },
    );
  });
}
