import '../../features/subscription/data/models/user_subscription.dart';

/// Limites gratuites du plan Free.
const _kFreeBlacklistLimit = 10;
const _kFreeChildProfileLimit = 1;
const _kFreeWorkoutHistoryWeeks = 1; // semaine index 0 uniquement

/// Singleton mis à jour par [SubscriptionCubit] après chaque load/purchase/restore.
/// Consulté par les screens pour décider si une action est accessible.
class FeatureGatingService {
  FeatureGatingService._();

  static final FeatureGatingService instance = FeatureGatingService._();

  UserSubscription _subscription = UserSubscription.empty;

  /// Appelé par SubscriptionCubit après chaque changement d'état d'abonnement.
  void update(UserSubscription subscription) {
    _subscription = subscription;
    // ignore: avoid_print
    print(
      '[FEATURE-GATING] update → plan=${subscription.planId} '
      'active=${subscription.isActive}',
    );
  }

  // ─── Getters état ─────────────────────────────────────────────────────────

  bool hasPremium() => _subscription.isActive;

  bool hasFamily() => _subscription.hasFamily;

  bool hasSport() => _subscription.hasSport;

  bool hasLifetime() => _subscription.hasLifetime;

  UserSubscription get currentSubscription => _subscription;

  // ─── Feature gates ────────────────────────────────────────────────────────

  /// Retourne true si l'utilisateur peut ajouter une entrée blacklist.
  /// Free : limité à [_kFreeBlacklistLimit] entrées.
  bool canAddBlacklistEntry(int currentCount) {
    if (hasPremium()) return true;
    return currentCount < _kFreeBlacklistLimit;
  }

  /// Retourne true si l'utilisateur peut ajouter un profil enfant.
  /// Free : limité à [_kFreeChildProfileLimit] profil.
  bool canAddChildProfile(int currentCount) {
    if (hasFamily()) return true;
    return currentCount < _kFreeChildProfileLimit;
  }

  /// Retourne true si l'utilisateur peut voir l'historique fitness de la semaine [weekIndex].
  /// Free : semaine courante (index 0) seulement.
  bool canAccessFitnessHistory(int weekIndex) {
    if (hasSport() || hasLifetime()) return true;
    return weekIndex < _kFreeWorkoutHistoryWeeks;
  }

  /// Retourne true si la synchronisation cloud est disponible (nécessite Premium).
  bool canSyncToCloud() => hasPremium();
}
