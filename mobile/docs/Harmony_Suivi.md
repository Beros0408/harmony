# 📋 Harmony — Journal tactique de développement
> Suivi détaillé session par session · Complémentaire à Harmony_Progression.md (stratégique) et Harmony_Iterations.md (opérationnel)

---

## Session du 27–28 mai 2026

### Contexte d'entrée

Projet à l'état **v2.0.0-cdc-complete** (Sprint 7 terminé). Les 7 modules du cahier des charges sont fonctionnels. Priorités : monétisation (Sprint 8), direction artistique, et polish UX.

---

### Sprint 8 — Paywall RevenueCat + Feature Gating + AdMob

**Tag :** `v2.1.0-paywall` · **27 mai 2026**

#### Décisions prises

1. **RevenueCat** retenu plutôt qu'une implémentation billing custom — gestion des entitlements, receipts et restore cross-platform sans logique maison.
2. **AdMob TEST IDs** en développement — les prod IDs seront configurés au moment du déploiement store pour éviter toute violation de la politique AdMob.
3. **Baseline 80 issues flutter analyze** acceptée — issues sont des lint warnings (prefer_const, use_super_parameters) non-bloquants, corrigibles en sprint dédié.

#### Plans tarifaires finalisés

| Plan | Tarif | Fonctionnalités gated |
|---|---|---|
| Free | Gratuit | Sécurité (filtrage basique) |
| Solo | 4,99€/mois | + Blacklist illimitée + Messages |
| Famille | 8,99€/mois | + Parental contrôle GPS |
| Sport | 6,99€/mois | + Fitness avancé |
| Lifetime | 79,99€ | Tout débloqué |

#### Hotfixes immédiats post-Sprint 8

**v2.1.1 — Feature gating blacklist :**
- Bug 1 : `count > 0` utilisait le count filtré (après gating) → remplacé par count total DB
- Bug 2 : `context` capturé après pop du BottomSheet → `GoRouter` capturé avant le pop

**v2.1.2 — RenderFlex overflow S22 :**
- `voicemailNewCount(2)` générait "2 nouveaux messages" (23 chars) trop long pour la Row
- Fix : badge court `'2'` + `Flexible` wrapper + `TextOverflow.ellipsis`
- Règle établie : toujours utiliser `Flexible` + ellipsis sur les badges dans les layouts contraints

---

### Mini-Sprint Visuels v2.2.0 — Direction Artistique

**Tag :** `v2.2.0-visuals` · **27 mai 2026**

#### Philosophie DA Harmony

Images Unsplash choisies pour leur résonance émotionnelle avec chaque module :
- Sécurité : forêt brumeuse (cocon protecteur)
- Famille : coucher de soleil chaleureux
- Fitness : jogging en forêt (vitalité)
- Agenda : bureau zen avec carnet et café (organisation sereine)
- Méditation : océan calme au lever du soleil
- Contacts : friends autour d'un thé (liens humains)
- Messagerie vocale : femme au casque (écoute paisible)
- Messages : lettre manuscrite calligraphiée (correspondance précieuse)

#### Contrainte WCAG AA respectée

Overlay sombre sur chaque image : gradient 0x73000000 (45%) en haut → 0xBF000000 (75%) en bas.
Texte blanc sur fond foncé → ratio de contraste > 4.5:1 conforme WCAG AA.

#### Écran Méditation ajouté

5 sessions mockées (Respiration 4-7-8, Body Scan, Visualisation, Sophrologie, Cohérence cardiaque).
Sera connecté à des vrais contenus audio en Phase 2.

---

### Hotfixes v2.2.1 → v2.2.3 — Finitions DA

**v2.2.1 — Splash → Landing page intentionnelle :**
- Suppression de la navigation automatique 2.5s → expérience intentionnelle
- Bouton CTA glassmorphism avec fond blanc 15% + blur
- Fade-in en 2 étapes : texte (900ms) puis bouton (990–1800ms)
- Raison : une landing page crée une première impression premium

**v2.2.2 — Dashboard 8/8 completion :**
- Les 3 cards restantes (Contacts, Voicemail, Messages) avaient des images manquantes
- Dashboard maintenant 100% émotionnellement cohérent

**v2.2.3 — Dashboard propre :**
- La section de démo du design system (`_SystemColorsSection` etc.) avait été laissée dans le Dashboard utilisateur
- Extraite vers `ComponentsDemoScreen` accessible uniquement via `/dev/components`
- Dashboard redevient un écran produit (8 cards modules uniquement)

---

### Mini-Sprint UX v2.2.4 → v2.2.5 — Welcome card dynamique

#### v2.2.4 — Messages overflow + tap détail

**Overflow S22 :**
- Diagnostic : émulateur S22 (360px wide) — la Row badge était constrained sans `Flexible`
- Pattern établi (leçon v2.1.2) : tout badge dans une Row doit être dans `Flexible` + ellipsis

**MessageDetailScreen :**
- GoRouter `state.extra` pour passer le `CapturedMessage` complet sans sérialisation
- Route `/message-detail` — pas de paramètre URL (objet complexe)

#### v2.2.5 — Welcome card dynamique

**PulsingDot :**
- Animation `ScaleTransition` 0.8→1.2 puis `FadeTransition` 0.5→1.0
- Cycle 4s (2s aller + 2s retour) — loop infinie
- Couleur `AppColors.accentGreen` avec opacité progressive

**WigglingEmoji :**
- `AnimationController` one-shot (pas de repeat) — économie batterie
- `RotationTransition` ±15° (0.458→0.542) avec Curves.elasticOut
- `WidgetsBinding.addPostFrameCallback` pour déclencher (TEST-SAFE — pas de `Future.delayed`)

**7 fixes tests induits par v2.2.5 :**

| Fix | Cause | Solution |
|---|---|---|
| `WigglingEmoji` timer pending | `Future.delayed(600ms)` après pump | `addPostFrameCallback` |
| Cards off-screen 800×600 viewport | `_WelcomeBanner` plus haute avec 3 stats | `_scrollTo` avant chaque tap |
| `FitnessCubit` not found | `AdBanner` charge ads → FitnessScreen nécessite le cubit | `_EmptyFitnessRepo` stub + provider |
| `AdBanner.initState()` crash | `Theme.of(context)` en initState (InheritedWidget interdit) | `defaultTargetPlatform` |
| Auth tests binding error | `FlutterSecureStorage` appelle platform channels | `MockTokenStorage` via `ITokenStorage` |
| `HarmonyAppBar` GoRouter throw | `GoRouter.of(context)` throw sans GoRouter dans l'arbre | `GoRouter.maybeOf()?.canPop() ?? false` |
| `CupertinoLocalizations` missing | Locale `fr` + MaterialApp sans `GlobalCupertinoLocalizations.delegate` | Ajout du delegate |

---

### Hotfix v2.2.6 — Date dynamique i18n

**Tag :** `v2.2.6-dynamic-date` · **28 mai 2026**

#### Diagnostic

Date affichée dans `_WelcomeBanner` : "mercredi 27 mai 2026" (figée sur la veille).

Investigation :
- `DateTime.now()` était correct — ce n'était pas un bug de date
- `_formattedDate` getter utilisait `DateFormat('EEEE d MMMM yyyy', 'fr_FR')` — locale hardcodée
- `main.dart` n'initialisait que `initializeDateFormatting('fr_FR')` — 4 locales manquantes

#### Fix

```dart
String _formattedDate(BuildContext context) {
  final now = DateTime.now();
  final lang = Localizations.localeOf(context).languageCode;
  switch (lang) {
    case 'fr': return DateFormat('EEEE d MMMM yyyy', 'fr').format(now);
    case 'es': return DateFormat("EEEE d 'de' MMMM yyyy", 'es').format(now);
    case 'it': return DateFormat('EEEE d MMMM yyyy', 'it').format(now);
    case 'pt': return DateFormat("EEEE, d 'de' MMMM yyyy", 'pt').format(now);
    default:   return DateFormat('EEEE, MMMM d yyyy', 'en').format(now);
  }
}
```

#### Règle établie

> Toujours passer `context` pour le formatage de dates. Jamais hardcoder la locale.
> Toujours initialiser les 5 locales intl dans `main()` avant `runApp()`.

#### Bug non corrigé documenté

"Belle nuit 🌟" s'affichait à 11h59 AM sur émulateur Pixel 7. Cause probable : horloge système émulateur en UTC (non en heure locale). `DateTime.now().hour` est correct côté code Dart — ce n'est pas un bug applicatif.

---

## État technique au 28 mai 2026

### KPIs

| Métrique | Valeur |
|---|---|
| Tests Flutter | **320 verts** |
| Tests Kotlin JUnit | **13 verts** |
| Issues flutter analyze | **80** (baseline stable) |
| Tags git majeurs | **13** (v1.0.0 → v2.2.6) |
| Modules CDC | **7/7** (M1 Sécurité, M2 Famille, M3 Messages, M4 Parental, M5 Méditation, M6 Fitness, M7 Agenda) |

### État des modules

| Module | % | Notes |
|---|---|---|
| M1 Sécurité (filtrage appels) | 90% | Android natif 0ms, iOS CallKit, Blacklist SQLCipher — manque tests S22 |
| M2 Famille (parental + SOS) | 90% | GPS live OSM, SOS tel:112 validé IRL, ChildSettings, SosContacts |
| M3 Messages (WhatsApp/SMS) | 100% | NotificationListener + règles SQLCipher + permission flow |
| M4 Parental (contrôle) | 90% | GPS + geofence + scores — ChildSettings + SosContacts Sprint 7 |
| M5 Méditation | 30% | Sessions mockées — contenu audio + vrais timer Sprint 9+ |
| M6 Fitness | 80% | Pedometer + SQLCipher + BLoC + fl_chart — intégration HealthKit Sprint 9+ |
| M7 Agenda | 85% | table_calendar + Eisenhower + NotifService — Google Calendar OAuth2 partiel |
| DA Harmony | 100% | Toutes images Unsplash, WCAG AA, SplashScreen, HarmonyBadge rose |
| Paywall | 95% | RevenueCat + Feature Gating + AdMob TEST — prod IDs à configurer |

### Prochains chantiers identifiés

1. **Sprint 9 — Backend FastAPI** : endpoints auth, profil utilisateur, sync agenda
2. **Tests E2E S22** : validation des corrections overflow sur vrai device Samsung
3. **Docker** : containeriser le backend FastAPI
4. **Mini-stats réelles** : connecter les 3 stats Welcome card aux vrais cubits (filtrés/pas/events)
5. **Prod IDs AdMob** : remplacer les TEST IDs avant déploiement store
6. **SOS contacts persistance** : SQLCipher migration (ADR-031 — reporté Sprint 7)

---

*Journal mis à jour en fin de session — complète Harmony_Progression.md et Harmony_Iterations.md.*
