import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/subscription/data/models/subscription_plan.dart';

void main() {
  group('SubscriptionPlan', () {
    const solo = SubscriptionPlan(
      id: 'solo',
      name: 'Solo',
      monthlyPrice: 4.99,
      yearlyPrice: 49.99,
      features: ['Feature A'],
      trialDays: 7,
    );

    const lifetime = SubscriptionPlan(
      id: 'lifetime',
      name: 'Lifetime',
      monthlyPrice: null,
      yearlyPrice: null,
      oneTimePrice: 149.99,
      features: ['All features'],
    );

    test('priceForPeriod monthly returns monthlyPrice', () {
      expect(solo.priceForPeriod(SubscriptionPeriod.monthly), 4.99);
    });

    test('priceForPeriod yearly returns yearlyPrice', () {
      expect(solo.priceForPeriod(SubscriptionPeriod.yearly), 49.99);
    });

    test('priceForPeriod lifetime returns oneTimePrice', () {
      expect(lifetime.priceForPeriod(SubscriptionPeriod.lifetime), 149.99);
    });

    test('yearlyDiscount is ~17% for solo', () {
      // monthly*12 = 59.88 ; yearly = 49.99 ; discount ≈ 16.5%
      expect(solo.yearlyDiscount, greaterThan(0.15));
      expect(solo.yearlyDiscount, lessThan(0.20));
    });

    test('yearlyDiscount is 0 when prices are null', () {
      expect(lifetime.yearlyDiscount, 0.0);
    });

    test('defaults contains 4 plans', () {
      expect(SubscriptionPlan.defaults, hasLength(4));
    });

    test('defaults has exactly one popular plan', () {
      final popular = SubscriptionPlan.defaults.where((p) => p.isPopular).toList();
      expect(popular, hasLength(1));
      expect(popular.first.id, SubscriptionPlan.familyId);
    });

    test('lifetime plan has no monthlyPrice', () {
      final lt = SubscriptionPlan.defaults.firstWhere((p) => p.id == SubscriptionPlan.lifetimeId);
      expect(lt.monthlyPrice, isNull);
      expect(lt.oneTimePrice, isNotNull);
    });

    test('solo plan has 7-day trial', () {
      final s = SubscriptionPlan.defaults.firstWhere((p) => p.id == SubscriptionPlan.soloId);
      expect(s.trialDays, 7);
    });
  });
}
