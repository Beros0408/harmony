import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/core/services/feature_gating_service.dart';
import 'package:harmony/features/subscription/data/models/user_subscription.dart';

void main() {
  final service = FeatureGatingService.instance;

  setUp(() => service.update(UserSubscription.empty));

  group('FeatureGatingService — free plan', () {
    test('hasPremium is false', () => expect(service.hasPremium(), isFalse));
    test('hasFamily is false', () => expect(service.hasFamily(), isFalse));
    test('hasSport is false', () => expect(service.hasSport(), isFalse));

    test('canAddBlacklistEntry allows below limit', () {
      expect(service.canAddBlacklistEntry(0), isTrue);
      expect(service.canAddBlacklistEntry(9), isTrue);
    });

    test('canAddBlacklistEntry blocks at limit', () {
      expect(service.canAddBlacklistEntry(10), isFalse);
      expect(service.canAddBlacklistEntry(15), isFalse);
    });

    test('canAddChildProfile allows 0 children', () {
      expect(service.canAddChildProfile(0), isTrue);
    });

    test('canAddChildProfile blocks at limit', () {
      expect(service.canAddChildProfile(1), isFalse);
    });

    test('canAccessFitnessHistory allows week 0 only', () {
      expect(service.canAccessFitnessHistory(0), isTrue);
      expect(service.canAccessFitnessHistory(1), isFalse);
    });

    test('canSyncToCloud is false', () => expect(service.canSyncToCloud(), isFalse));
  });

  group('FeatureGatingService — premium solo', () {
    setUp(() => service.update(const UserSubscription(
          planId: 'solo',
          status: SubscriptionStatus.active,
        )));

    test('hasPremium is true', () => expect(service.hasPremium(), isTrue));
    test('canAddBlacklistEntry ignores limit', () {
      expect(service.canAddBlacklistEntry(100), isTrue);
    });
    test('canSyncToCloud is true', () => expect(service.canSyncToCloud(), isTrue));
    test('hasFamily is false for solo', () => expect(service.hasFamily(), isFalse));
  });

  group('FeatureGatingService — premium family', () {
    setUp(() => service.update(const UserSubscription(
          planId: 'family',
          status: SubscriptionStatus.active,
        )));

    test('hasFamily is true', () => expect(service.hasFamily(), isTrue));
    test('canAddChildProfile allows unlimited', () {
      expect(service.canAddChildProfile(50), isTrue);
    });
  });

  group('FeatureGatingService — lifetime', () {
    setUp(() => service.update(const UserSubscription(
          planId: 'lifetime',
          status: SubscriptionStatus.active,
        )));

    test('hasLifetime is true', () => expect(service.hasLifetime(), isTrue));
    test('canAccessFitnessHistory allows all weeks', () {
      expect(service.canAccessFitnessHistory(52), isTrue);
    });
  });
}
