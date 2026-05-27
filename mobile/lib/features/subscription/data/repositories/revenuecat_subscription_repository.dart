import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../../core/database/database_helper.dart';
import '../../../../core/services/subscription_service.dart';
import '../../domain/i_subscription_repository.dart';
import '../models/subscription_plan.dart';
import '../models/user_subscription.dart';

const _tableName = 'user_subscription';

/// Repository de production : RevenueCat + cache SQLCipher (table user_subscription).
/// Singleton — accès via [RevenueCatSubscriptionRepository.instance].
class RevenueCatSubscriptionRepository implements ISubscriptionRepository {
  RevenueCatSubscriptionRepository._();

  static final RevenueCatSubscriptionRepository instance =
      RevenueCatSubscriptionRepository._();

  // ─── Plans ────────────────────────────────────────────────────────────────

  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] RevenueCatSubscriptionRepository.getPlans()');
    return SubscriptionPlan.defaults;
  }

  // ─── Abonnement courant ───────────────────────────────────────────────────

  @override
  Future<UserSubscription> getCurrentSubscription() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] getCurrentSubscription() — cache then RevenueCat');

    // 1. Retourne le cache SQLCipher si disponible (inférieur à 24h)
    final cached = await _getCached();
    if (cached != null) {
      // ignore: avoid_print
      print('[SUBSCRIPTION-DEBUG] getCurrentSubscription() ← cache plan=${cached.planId}');
      return cached;
    }

    // 2. Requête RevenueCat
    final sub = await SubscriptionService.instance.getCurrentSubscription();
    await _upsert(sub);
    return sub;
  }

  // ─── Achat ────────────────────────────────────────────────────────────────

  @override
  Future<UserSubscription> purchase(String planId, SubscriptionPeriod period) async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] purchase(planId=$planId, period=${period.name})');

    final offerings = await SubscriptionService.instance.getOfferings();
    if (offerings == null || offerings.current == null) {
      throw Exception('Aucune offre RevenueCat disponible');
    }

    // Cherche le package correspondant au planId + période
    final packages = offerings.current!.availablePackages;
    final suffix = switch (period) {
      SubscriptionPeriod.monthly => '_monthly',
      SubscriptionPeriod.yearly => '_yearly',
      SubscriptionPeriod.lifetime => '_lifetime',
    };

    final pkg = packages.firstWhere(
      (p) => p.identifier.contains(planId) && p.identifier.contains(suffix),
      orElse: () => packages.firstWhere(
        (p) => p.identifier.contains(planId),
      ),
    );

    final sub = await SubscriptionService.instance.purchasePackage(pkg);
    await _upsert(sub);
    return sub;
  }

  // ─── Restore ─────────────────────────────────────────────────────────────

  @override
  Future<UserSubscription> restorePurchases() async {
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] restorePurchases()');
    final sub = await SubscriptionService.instance.restorePurchases();
    await _upsert(sub);
    return sub;
  }

  // ─── Cache SQLCipher ─────────────────────────────────────────────────────

  Future<UserSubscription?> _getCached() async {
    final db = await DatabaseHelper.db;
    final rows = await db.query(_tableName, where: 'id = 1');
    if (rows.isEmpty) return null;

    final row = rows.first;
    final cachedAt = row['cached_at'] as int? ?? 0;
    final age = DateTime.now().millisecondsSinceEpoch - cachedAt;
    // Cache valide 24h
    if (age > const Duration(hours: 24).inMilliseconds) return null;

    return UserSubscription.fromMap(row);
  }

  Future<void> _upsert(UserSubscription sub) async {
    final db = await DatabaseHelper.db;
    await db.insert(
      _tableName,
      sub.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // ignore: avoid_print
    print('[SUBSCRIPTION-DEBUG] _upsert plan=${sub.planId} status=${sub.status.name}');
  }
}
