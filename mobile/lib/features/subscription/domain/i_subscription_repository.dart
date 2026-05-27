import '../data/models/subscription_plan.dart';
import '../data/models/user_subscription.dart';

abstract interface class ISubscriptionRepository {
  /// Retourne les plans disponibles (définis localement + offres RevenueCat).
  Future<List<SubscriptionPlan>> getPlans();

  /// Retourne l'abonnement courant de l'utilisateur (depuis cache puis RevenueCat).
  Future<UserSubscription> getCurrentSubscription();

  /// Déclenche l'achat d'un plan selon son identifiant.
  Future<UserSubscription> purchase(String planId, SubscriptionPeriod period);

  /// Restaure les achats depuis l'App Store / Google Play.
  Future<UserSubscription> restorePurchases();
}
