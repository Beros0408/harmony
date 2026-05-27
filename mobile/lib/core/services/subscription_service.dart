import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';
import '../../features/subscription/data/models/user_subscription.dart';

/// Wrapper RevenueCat pour les achats in-app.
/// Si la clé API est vide ou si RevenueCat échoue → retourne UserSubscription.empty (mode dégradé).
class SubscriptionService {
  SubscriptionService._();
  static final SubscriptionService instance = SubscriptionService._();

  bool _initialized = false;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] SubscriptionService.initialize()');

    if (kPremiumDevMode) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] kPremiumDevMode=true → mode premium simulé');
      _initialized = true;
      return;
    }

    final apiKey = defaultTargetPlatform == TargetPlatform.iOS
        ? kRevenueCatIosKey
        : kRevenueCatAndroidKey;

    if (apiKey.isEmpty) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] Clé API vide → mode dégradé (aucun achat)');
      _initialized = true;
      return;
    }

    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      _initialized = true;
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] RevenueCat initialisé');
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] initialize() EXCEPTION: $e → mode dégradé');
      _initialized = true;
    }
  }

  // ─── Abonnement courant ───────────────────────────────────────────────────

  Future<UserSubscription> getCurrentSubscription() async {
    if (kPremiumDevMode) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] getCurrentSubscription() → dev premium (Family)');
      return const UserSubscription(
        planId: 'family',
        status: SubscriptionStatus.active,
        willRenew: true,
      );
    }

    try {
      final info = await Purchases.getCustomerInfo();
      final sub = _infoToSubscription(info);
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] getCurrentSubscription() → plan=${sub.planId} status=${sub.status.name}');
      return sub;
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] getCurrentSubscription() EXCEPTION: $e → free');
      return UserSubscription.empty;
    }
  }

  // ─── Achats ───────────────────────────────────────────────────────────────

  Future<UserSubscription> purchasePackage(Package package) async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] purchasePackage(${package.identifier})');
    final info = await Purchases.purchasePackage(package);
    return _infoToSubscription(info);
  }

  Future<UserSubscription> restorePurchases() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] restorePurchases()');
    final info = await Purchases.restorePurchases();
    return _infoToSubscription(info);
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] getOfferings() EXCEPTION: $e');
      return null;
    }
  }

  // ─── Mapping ─────────────────────────────────────────────────────────────

  UserSubscription _infoToSubscription(CustomerInfo info) {
    final active = info.entitlements.active;

    if (active.containsKey('premium_lifetime')) {
      return const UserSubscription(
        planId: 'lifetime',
        status: SubscriptionStatus.active,
        willRenew: false,
      );
    }
    if (active.containsKey('premium_family')) {
      return _fromEntitlement('family', active['premium_family']!);
    }
    if (active.containsKey('premium_sport')) {
      return _fromEntitlement('sport', active['premium_sport']!);
    }
    if (active.containsKey('premium_solo')) {
      return _fromEntitlement('solo', active['premium_solo']!);
    }
    return UserSubscription.empty;
  }

  UserSubscription _fromEntitlement(String planId, EntitlementInfo entitlement) {
    final expiresAt = entitlement.expirationDate != null
        ? DateTime.tryParse(entitlement.expirationDate!)
        : null;
    final status = entitlement.periodType == PeriodType.trial
        ? SubscriptionStatus.trial
        : SubscriptionStatus.active;

    return UserSubscription(
      planId: planId,
      status: status,
      expiresAt: expiresAt,
      willRenew: entitlement.willRenew,
    );
  }
}
