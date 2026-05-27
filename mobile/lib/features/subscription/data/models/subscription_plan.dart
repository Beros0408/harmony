import 'package:equatable/equatable.dart';

/// Période de facturation d'un plan.
enum SubscriptionPeriod { monthly, yearly, lifetime }

/// Représente un plan d'abonnement Harmony.
class SubscriptionPlan extends Equatable {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.oneTimePrice,
    this.isPopular = false,
    this.trialDays = 0,
  });

  // Identifiants stables utilisés dans RevenueCat et FeatureGatingService
  static const String soloId = 'solo';
  static const String familyId = 'family';
  static const String sportId = 'sport';
  static const String lifetimeId = 'lifetime';

  final String id;
  final String name;

  /// Prix mensuel (null pour le plan à vie).
  final double? monthlyPrice;

  /// Prix annuel (null pour le plan à vie).
  final double? yearlyPrice;

  /// Prix unique (uniquement pour le plan à vie).
  final double? oneTimePrice;

  final List<String> features;
  final bool isPopular;

  /// Nombre de jours d'essai gratuit (0 = pas de trial).
  final int trialDays;

  double? priceForPeriod(SubscriptionPeriod period) => switch (period) {
        SubscriptionPeriod.monthly => monthlyPrice,
        SubscriptionPeriod.yearly => yearlyPrice,
        SubscriptionPeriod.lifetime => oneTimePrice,
      };

  /// Économie annuelle par rapport au mensuel (0–1).
  double get yearlyDiscount {
    if (monthlyPrice == null || yearlyPrice == null || monthlyPrice! <= 0) return 0;
    final fullYear = monthlyPrice! * 12;
    return (fullYear - yearlyPrice!) / fullYear;
  }

  @override
  List<Object?> get props =>
      [id, name, monthlyPrice, yearlyPrice, oneTimePrice, features, isPopular, trialDays];

  /// Plans Harmony définis dans le CDC §6.2.
  static List<SubscriptionPlan> get defaults => const [
        SubscriptionPlan(
          id: soloId,
          name: 'Premium Solo',
          monthlyPrice: 4.99,
          yearlyPrice: 49.99,
          trialDays: 7,
          features: [
            'Blacklist illimitée',
            'Modes de filtrage avancés',
            'Historique complet des séances',
            'Alertes push intelligentes',
          ],
        ),
        SubscriptionPlan(
          id: familyId,
          name: 'Premium Famille',
          monthlyPrice: 9.99,
          yearlyPrice: 99.99,
          isPopular: true,
          features: [
            'Tout Premium Solo',
            'Profils enfants illimités',
            'Contrôle parental avancé',
            'Zones géographiques illimitées',
            'Partage en famille',
          ],
        ),
        SubscriptionPlan(
          id: sportId,
          name: 'Premium Sport',
          monthlyPrice: 6.99,
          yearlyPrice: 69.99,
          features: [
            'Tout Premium Solo',
            'Suivi fitness avancé (BPM, VO2max)',
            'Programmes d\'entraînement',
            'Statistiques de performance',
          ],
        ),
        SubscriptionPlan(
          id: lifetimeId,
          name: 'Licence à vie',
          monthlyPrice: null,
          yearlyPrice: null,
          oneTimePrice: 149.99,
          features: [
            'Accès à toutes les fonctionnalités',
            'Mises à jour à vie',
            'Support prioritaire',
            'Aucun abonnement mensuel',
          ],
        ),
      ];
}
