# 📱 Harmony — Application mobile

Application Flutter pour iOS et Android. Filtrage d'appels intelligent, contrôle parental et suivi fitness.

---

## Prérequis

| Outil | Version minimale |
|-------|------------------|
| Flutter | 3.22+ |
| Dart | 3.4+ |
| Xcode | 15+ (Mac uniquement, pour iOS) |
| Android Studio | 2024+ |
| CocoaPods | 1.14+ (Mac uniquement) |

---

## Installation

```bash
# Installer les dépendances Dart/Flutter
flutter pub get

# iOS uniquement (Mac requis)
cd ios && pod install && cd ..
```

---

## Lancement

```bash
# Navigateur (le plus simple)
flutter run -d chrome

# Émulateur Android (émulateur lancé dans Android Studio)
flutter run

# Simulateur iOS (Mac uniquement)
flutter run -d "iPhone 15"

# Appareil physique branché en USB
flutter run

# Voir tous les appareils disponibles
flutter devices
```

---

## Architecture

L'application suit le pattern **feature-first** :

```
lib/
├── main.dart                    # Point d'entrée
├── app.dart                     # Widget racine (MaterialApp.router)
├── core/
│   ├── constants/               # Tokens design system
│   │   ├── app_colors.dart      # Palette complète (dark/light/OLED)
│   │   ├── app_typography.dart  # Styles de texte Geist + Mono
│   │   ├── app_spacing.dart     # Grille 4px
│   │   └── app_radius.dart      # Rayons de bordure
│   ├── errors/                  # Failures et exceptions custom
│   ├── network/                 # Client Dio avec intercepteurs
│   ├── router/                  # go_router (routes + noms)
│   ├── security/                # flutter_secure_storage wrapper
│   └── utils/                   # Extensions, logger
├── features/
│   ├── auth/                    # Authentification (Sprint 1)
│   ├── dashboard/               # Tableau de bord principal
│   ├── call_filter/             # Filtrage d'appels (Sprint 2)
│   ├── parental/                # Contrôle parental (Sprint 3)
│   ├── agenda/                  # Agenda (Sprint 4)
│   └── fitness/                 # Fitness (Sprint 5)
└── shared/
    ├── theme/                   # AppTheme dark/OLED/light
    └── widgets/                 # Composants réutilisables
```

---

## Design system

Composants disponibles dans `lib/shared/widgets/` :

| Widget | Description |
|--------|-------------|
| `HarmonyButton` | Bouton avec variants primary/secondary/danger/ghost, tailles sm/md/lg, état loading |
| `HarmonyCard` | Carte avec titre, badge, action et ombre |
| `HarmonyBadge` | Badge coloré avec variants success/warning/danger/info/purple/muted |
| `HarmonyStatusDot` | Indicateur de statut avec animation ping pour online |
| `HarmonyToggle` | Switch animé 36×20px avec label |
| `HarmonyTextField` | Champ de texte avec icône et validation |
| `HarmonyListTile` | Tuile avec icône colorée, titre et sous-titre |
| `HarmonyLoadingSkeleton` | Placeholder shimmer animé |
| `HarmonyEmptyState` | Écran vide avec icône, titre et CTA |
| `HarmonySnackBar` | Notification toast avec variants success/error/info |
| `HarmonyAppBar` | AppBar avec gradient optionnel |

Toutes les couleurs passent par `AppColors` — aucune valeur codée en dur.

---

## Tests

```bash
# Tous les tests
flutter test

# Avec couverture
flutter test --coverage
```

Tests disponibles :
- `test/widget_test.dart` — démarrage de l'app
- `test/widgets/harmony_button_test.dart` — HarmonyButton
- `test/widgets/harmony_badge_test.dart` — HarmonyBadge

---

## Lint et analyse statique

```bash
# Analyse statique (doit retourner 0 erreur)
flutter analyze

# Vérification du formatage
dart format --set-exit-if-changed lib/ test/
```

Le lint strict est activé dans `analysis_options.yaml` :
- `strict-casts`, `strict-inference`, `strict-raw-types`
- `avoid_print`, `prefer_const_constructors`, `require_trailing_commas`
