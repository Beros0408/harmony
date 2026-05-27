import 'package:flutter_test/flutter_test.dart';
import 'package:harmony/features/subscription/data/models/user_subscription.dart';

void main() {
  group('UserSubscription', () {
    const active = UserSubscription(
      planId: 'solo',
      status: SubscriptionStatus.active,
      willRenew: true,
    );

    const trial = UserSubscription(
      planId: 'family',
      status: SubscriptionStatus.trial,
      willRenew: false,
    );

    const expired = UserSubscription(
      planId: 'solo',
      status: SubscriptionStatus.expired,
    );

    test('isActive is true for active status', () => expect(active.isActive, isTrue));
    test('isActive is true for trial status', () => expect(trial.isActive, isTrue));
    test('isActive is false for expired', () => expect(expired.isActive, isFalse));
    test('isFree is true for empty', () => expect(UserSubscription.empty.isFree, isTrue));
    test('isFree is false for active', () => expect(active.isFree, isFalse));

    test('hasSolo is true for any active plan', () => expect(active.hasSolo, isTrue));
    test('hasFamily is true for family plan', () => expect(trial.hasFamily, isTrue));
    test('hasFamily is false for solo plan', () => expect(active.hasFamily, isFalse));
    test('hasLifetime is true for lifetime plan', () {
      const lt = UserSubscription(planId: 'lifetime', status: SubscriptionStatus.active);
      expect(lt.hasLifetime, isTrue);
      expect(lt.hasFamily, isTrue);
      expect(lt.hasSport, isTrue);
    });

    group('toMap / fromMap', () {
      test('round-trips active subscription', () {
        final map = active.toMap();
        final restored = UserSubscription.fromMap(map);
        expect(restored.planId, active.planId);
        expect(restored.status, active.status);
        expect(restored.willRenew, active.willRenew);
      });

      test('round-trips with expiresAt', () {
        final expires = DateTime(2027, 6, 1);
        final sub = UserSubscription(
          planId: 'family',
          status: SubscriptionStatus.active,
          expiresAt: expires,
        );
        final restored = UserSubscription.fromMap(sub.toMap());
        expect(restored.expiresAt?.year, 2027);
        expect(restored.expiresAt?.month, 6);
      });

      test('fromMap handles missing fields gracefully', () {
        final sub = UserSubscription.fromMap({'id': 1, 'cached_at': 0});
        expect(sub.planId, 'none');
        expect(sub.status, SubscriptionStatus.none);
      });
    });
  });
}
