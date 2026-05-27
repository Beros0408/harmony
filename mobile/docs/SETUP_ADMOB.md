# Setup AdMob (Sprint 8)

## IDs de test (actifs, ne pas modifier en dev)

Les bannières utilisent les Ad Unit IDs de test Google — elles affichent des annonces de test, jamais de vraies publicités.

| Plateforme | Ad Unit ID test |
|-----------|----------------|
| Android   | `ca-app-pub-3940256099942544/6300978111` |
| iOS       | `ca-app-pub-3940256099942544/2934735716` |

L'App ID AdMob test (AndroidManifest.xml) : `ca-app-pub-3940256099942544~3347511713`

## Passage en production

1. Créer un compte [admob.google.com](https://admob.google.com)
2. Créer une app Android + iOS
3. Créer des blocs d'annonces Bannière pour chaque plateforme
4. Remplacer les IDs de test dans `mobile/lib/shared/widgets/ad_banner.dart` :
   ```dart
   static const String _androidTestId = 'ca-app-pub-VOTRE_ID/BLOC_ID';
   static const String _iosTestId = 'ca-app-pub-VOTRE_ID/BLOC_ID_IOS';
   ```
5. Mettre à jour l'App ID dans `AndroidManifest.xml` et `Info.plist` (iOS)

## Règles d'affichage

- La bannière est **masquée** pour tout utilisateur avec un abonnement actif (`FeatureGatingService.hasPremium()`)
- La bannière n'apparaît **jamais** dans : SOS, contrôle parental actif, appels d'urgence
- Elle s'affiche sur : BlacklistScreen, FitnessScreen

## Widget

```dart
// Ajouter à n'importe quel screen (s'auto-masque si Premium)
const AdBanner()
```
