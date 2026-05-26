import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/fitness/data/models/workout_session.dart';
import 'package:harmony/features/fitness/data/repositories/mock_fitness_repository.dart';
import 'package:harmony/features/fitness/logic/fitness_cubit.dart';

void main() {
  group('FitnessCubit — load', () {
    blocTest<FitnessCubit, FitnessState>(
      'émet Loading puis Loaded avec permission accordée',
      build: () => FitnessCubit(repository: MockFitnessRepository()),
      act: (c) => c.load(),
      expect: () => [
        isA<FitnessLoading>(),
        isA<FitnessLoaded>(),
      ],
    );

    blocTest<FitnessCubit, FitnessState>(
      'Loaded contient 7 jours hebdomadaires',
      build: () => FitnessCubit(repository: MockFitnessRepository()),
      act: (c) => c.load(),
      expect: () => [
        isA<FitnessLoading>(),
        isA<FitnessLoaded>().having(
          (s) => (s as FitnessLoaded).weeklySteps.length,
          'weeklySteps.length',
          7,
        ),
      ],
    );

    blocTest<FitnessCubit, FitnessState>(
      'émet PermissionDenied si permission refusée',
      build: () => FitnessCubit(
        repository: MockFitnessRepository(permissionGranted: false),
      ),
      act: (c) => c.load(),
      expect: () => [
        isA<FitnessLoading>(),
        isA<FitnessPermissionDenied>(),
      ],
    );
  });

  group('FitnessCubit — objectif', () {
    blocTest<FitnessCubit, FitnessState>(
      'updateGoal met à jour l\'objectif',
      build: () => FitnessCubit(repository: MockFitnessRepository(goal: 8000)),
      act: (c) async {
        await c.load();
        await c.updateGoal(10000);
      },
      expect: () => [
        isA<FitnessLoading>(),
        isA<FitnessLoaded>().having((s) => (s as FitnessLoaded).goal, 'goal', 8000),
        isA<FitnessLoading>(),
        isA<FitnessLoaded>().having((s) => (s as FitnessLoaded).goal, 'goal', 10000),
      ],
    );
  });

  group('FitnessCubit — séances', () {
    blocTest<FitnessCubit, FitnessState>(
      'startWorkout crée une séance active',
      build: () => FitnessCubit(repository: MockFitnessRepository()),
      act: (c) async {
        await c.load();
        await c.startWorkout(WorkoutType.running);
      },
      verify: (c) {
        final state = c.state;
        expect(state, isA<FitnessLoaded>());
        expect((state as FitnessLoaded).activeWorkout, isNotNull);
        expect(state.activeWorkout!.type, WorkoutType.running);
      },
    );

    blocTest<FitnessCubit, FitnessState>(
      'stopWorkout clôture la séance active',
      build: () => FitnessCubit(repository: MockFitnessRepository()),
      act: (c) async {
        await c.load();
        await c.startWorkout(WorkoutType.walking);
        await c.stopWorkout(steps: 500);
      },
      verify: (c) {
        final state = c.state;
        expect(state, isA<FitnessLoaded>());
        expect((state as FitnessLoaded).activeWorkout, isNull);
        expect(state.recentWorkouts.length, 1);
      },
    );
  });
}
