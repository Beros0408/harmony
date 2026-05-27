import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/subscription/data/models/subscription_plan.dart';
import 'package:harmony/features/subscription/data/models/user_subscription.dart';
import 'package:harmony/features/subscription/data/repositories/mock_subscription_repository.dart';
import 'package:harmony/features/subscription/logic/subscription_cubit.dart';

void main() {
  group('SubscriptionCubit', () {
    SubscriptionCubit buildCubit({UserSubscription? initial}) => SubscriptionCubit(
          repository: MockSubscriptionRepository(initialSubscription: initial),
        );

    test('initial state is SubscriptionInitial', () {
      expect(buildCubit().state, isA<SubscriptionInitial>());
    });

    test('load emits Loading then Loaded', () async {
      final cubit = buildCubit();
      final future = expectLater(
        cubit.stream,
        emitsInOrder([isA<SubscriptionLoading>(), isA<SubscriptionLoaded>()]),
      );
      await cubit.load();
      await future;
    });

    test('load with free user emits Loaded with empty plan', () async {
      final cubit = buildCubit(initial: UserSubscription.empty);
      await cubit.load();

      expect(cubit.state, isA<SubscriptionLoaded>());
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.subscription.planId, 'none');
      expect(loaded.subscription.isActive, isFalse);
    });

    test('load returns 4 plans', () async {
      final cubit = buildCubit();
      await cubit.load();

      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.plans, hasLength(4));
    });

    test('purchase updates subscription and emits Loaded', () async {
      final cubit = buildCubit(initial: UserSubscription.empty);
      await cubit.load();
      await cubit.purchase(SubscriptionPlan.soloId, SubscriptionPeriod.monthly);

      expect(cubit.state, isA<SubscriptionLoaded>());
      final loaded = cubit.state as SubscriptionLoaded;
      expect(loaded.subscription.planId, 'solo');
      expect(loaded.subscription.isActive, isTrue);
    });

    test('purchase emits Purchasing then Loaded', () async {
      final cubit = buildCubit(initial: UserSubscription.empty);
      await cubit.load();

      final future = expectLater(
        cubit.stream,
        emitsInOrder([isA<SubscriptionPurchasing>(), isA<SubscriptionLoaded>()]),
      );
      await cubit.purchase(SubscriptionPlan.familyId, SubscriptionPeriod.yearly);
      await future;
    });

    test('restore does not throw', () async {
      final cubit = buildCubit();
      await cubit.load();
      await cubit.restore();
      expect(cubit.state, isA<SubscriptionLoaded>());
    });
  });
}
