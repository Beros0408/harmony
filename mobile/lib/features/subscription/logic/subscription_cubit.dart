import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/feature_gating_service.dart';
import '../domain/i_subscription_repository.dart';
import '../data/models/subscription_plan.dart';
import '../data/models/user_subscription.dart';

// ─── States ──────────────────────────────────────────────────────────────────

sealed class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  SubscriptionLoaded({required this.plans, required this.subscription});

  final List<SubscriptionPlan> plans;
  final UserSubscription subscription;
}

class SubscriptionPurchasing extends SubscriptionState {
  SubscriptionPurchasing({required this.plans, required this.subscription});

  final List<SubscriptionPlan> plans;
  final UserSubscription subscription;
}

class SubscriptionError extends SubscriptionState {
  SubscriptionError(this.message);
  final String message;
}

// ─── Cubit ───────────────────────────────────────────────────────────────────

class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit({required ISubscriptionRepository repository})
      : _repository = repository,
        super(SubscriptionInitial());

  final ISubscriptionRepository _repository;

  Future<void> load() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] SubscriptionCubit.load()');
    emit(SubscriptionLoading());
    try {
      final plans = await _repository.getPlans();
      final sub = await _repository.getCurrentSubscription();
      FeatureGatingService.instance.update(sub);
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] load() → plan=${sub.planId} status=${sub.status.name}');
      emit(SubscriptionLoaded(plans: plans, subscription: sub));
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] load() EXCEPTION: $e');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> purchase(String planId, SubscriptionPeriod period) async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] purchase(planId=$planId, period=${period.name})');
    final current = state;
    final plans = current is SubscriptionLoaded ? current.plans : <SubscriptionPlan>[];
    final sub = current is SubscriptionLoaded ? current.subscription : UserSubscription.empty;

    emit(SubscriptionPurchasing(plans: plans, subscription: sub));
    try {
      final newSub = await _repository.purchase(planId, period);
      FeatureGatingService.instance.update(newSub);
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] purchase() → plan=${newSub.planId}');
      emit(SubscriptionLoaded(plans: plans, subscription: newSub));
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] purchase() EXCEPTION: $e');
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> restore() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] restore()');
    final current = state;
    final plans = current is SubscriptionLoaded ? current.plans : <SubscriptionPlan>[];
    final sub = current is SubscriptionLoaded ? current.subscription : UserSubscription.empty;

    emit(SubscriptionPurchasing(plans: plans, subscription: sub));
    try {
      final restored = await _repository.restorePurchases();
      FeatureGatingService.instance.update(restored);
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] restore() → plan=${restored.planId}');
      emit(SubscriptionLoaded(plans: plans, subscription: restored));
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] restore() EXCEPTION: $e');
      emit(SubscriptionError(e.toString()));
    }
  }
}
