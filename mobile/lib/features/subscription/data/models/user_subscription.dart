import 'package:equatable/equatable.dart';

/// Statut de l'abonnement utilisateur.
enum SubscriptionStatus { active, trial, expired, none }

/// État d'abonnement de l'utilisateur courant.
class UserSubscription extends Equatable {
  const UserSubscription({
    this.planId = 'none',
    this.status = SubscriptionStatus.none,
    this.expiresAt,
    this.willRenew = false,
    this.trialEndsAt,
  });

  final String planId;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final bool willRenew;
  final DateTime? trialEndsAt;

  // ─── Helpers ────────────────────────────────────────────────────────────────

  bool get isActive =>
      status == SubscriptionStatus.active || status == SubscriptionStatus.trial;

  bool get isFree =>
      status == SubscriptionStatus.none || status == SubscriptionStatus.expired;

  /// Accès au moins au niveau Solo.
  bool get hasSolo => isActive;

  /// Accès au niveau Famille (profils enfants illimités).
  bool get hasFamily =>
      isActive && (planId == 'family' || planId == 'lifetime');

  /// Accès au niveau Sport (fitness avancé).
  bool get hasSport =>
      isActive && (planId == 'sport' || planId == 'lifetime');

  bool get hasLifetime => isActive && planId == 'lifetime';

  // ─── Sérialisation SQLCipher ─────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id': 1,
        'plan_id': planId,
        'status': status.name,
        'expires_at': expiresAt?.millisecondsSinceEpoch,
        'will_renew': willRenew ? 1 : 0,
        'trial_ends_at': trialEndsAt?.millisecondsSinceEpoch,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };

  factory UserSubscription.fromMap(Map<String, dynamic> map) => UserSubscription(
        planId: map['plan_id'] as String? ?? 'none',
        status: SubscriptionStatus.values.firstWhere(
          (s) => s.name == (map['status'] as String? ?? 'none'),
          orElse: () => SubscriptionStatus.none,
        ),
        expiresAt: map['expires_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['expires_at'] as int)
            : null,
        willRenew: (map['will_renew'] as int? ?? 0) == 1,
        trialEndsAt: map['trial_ends_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['trial_ends_at'] as int)
            : null,
      );

  static const UserSubscription empty = UserSubscription();

  @override
  List<Object?> get props =>
      [planId, status, expiresAt, willRenew, trialEndsAt];
}
