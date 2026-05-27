import '../../../../core/config/app_config.dart';
import '../../domain/i_subscription_repository.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';

/// Repository de test — aucune dépendance externe.
/// Retourne les plans locaux et simule les achats en mémoire.
/// Si [kPremiumDevMode] est vrai, getCurrentSubscription() renvoie Premium Family.
class MockSubscriptionRepository implements ISubscriptionRepository {
  MockSubscriptionRepository({UserSubscription? initialSubscription})
      : _currentSub = initialSubscription ?? _defaultSub();

  UserSubscription _currentSub;

  static UserSubscription _defaultSub() {
    if (kPremiumDevMode) {
      return const UserSubscription(
        planId: 'family',
        status: SubscriptionStatus.active,
        willRenew: true,
      );
    }
    return UserSubscription.empty;
  }

  @override
  Future<List<SubscriptionPlan>> getPlans() async => SubscriptionPlan.defaults;

  @override
  Future<UserSubscription> getCurrentSubscription() async => _currentSub;

  @override
  Future<UserSubscription> purchase(String planId, SubscriptionPeriod period) async {
    final expiresAt = period == SubscriptionPeriod.lifetime
        ? null
        : DateTime.now().add(
            period == SubscriptionPeriod.monthly
                ? const Duration(days: 30)
                : const Duration(days: 365),
          );
    _currentSub = UserSubscription(
      planId: planId,
      status: SubscriptionStatus.active,
      expiresAt: expiresAt,
      willRenew: period != SubscriptionPeriod.lifetime,
    );
    return _currentSub;
  }

  @override
  Future<UserSubscription> restorePurchases() async => _currentSub;
}
