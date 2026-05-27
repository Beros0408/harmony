# Setup RevenueCat (Sprint 8)

## Configuration

1. Créer un compte sur [app.revenuecat.com](https://app.revenuecat.com)
2. Créer une nouvelle app (Android + iOS)
3. Copier les clés API dans `mobile/lib/core/config/app_config.dart` :
   ```dart
   const String kRevenueCatAndroidKey = 'goog_XXX';
   const String kRevenueCatIosKey = 'appl_XXX';
   ```

## Entitlements à configurer dans RevenueCat

| Identifiant RevenueCat | Plan Harmony |
|----------------------|--------------|
| `premium_solo`       | Solo         |
| `premium_family`     | Famille      |
| `premium_sport`      | Sport        |
| `premium_lifetime`   | Lifetime     |

## Produits (App Store Connect / Google Play Console)

Créer les produits abonnement avec les identifiants suivants et les associer aux entitlements :

- `solo_monthly` → premium_solo
- `solo_yearly` → premium_solo
- `family_monthly` → premium_family
- `family_yearly` → premium_family
- `sport_monthly` → premium_sport
- `sport_yearly` → premium_sport
- `lifetime_purchase` → premium_lifetime

## Mode développement

Passer `kPremiumDevMode = true` dans `app_config.dart` pour simuler un abonnement Premium Family sans achat réel. Utile pour développer les écrans gated.

## Mode dégradé

Si les clés API sont vides ou si RevenueCat échoue, l'app retourne `UserSubscription.empty` (plan Free) sans planter. Le cache SQLCipher (table `user_subscription`) est invalidé après 24h.

## Logs

Tous les logs RevenueCat sont préfixés `[SUBSCRIPTION-DEBUG]` — désactiver en production.
