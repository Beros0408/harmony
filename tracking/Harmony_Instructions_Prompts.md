# 🧭 Harmony — Instructions et Prompts par étape
> Guide d'implémentation complet · À utiliser avec Claude Code ou tout agent IA
> Mise à jour : 24 mai 2026 après livraison Sprint 1

---

## État actuel du projet (post-Sprint 1)

| Élément | Valeur |
|---|---|
| **Version** | **1.0.0** — Alpha fonctionnelle ⭐ |
| Dernier commit sur main | `47dbfe2` (Sprint 1) |
| Tag courant | `v1.0.0-sprint-1` |
| Tests Flutter verts | 65 / 65 |
| Tests Kotlin JUnit verts | 5 / 5 |
| Issues flutter analyze | 0 |
| Langues supportées | FR · EN · ES · PT · IT (5) |
| Thèmes supportés | System · Light · Dark |
| **Latence filtrage Android** | **0 ms** (KPI < 200 ms) |

---

## Stack technique (rappel)

```
Mobile         = Flutter 3.x (Dart) + bloc/cubit + go_router
Android natif  = Kotlin + CallScreeningService API 29+
Backend        = Python 3.12 + FastAPI + asyncpg + Redis
BDD            = PostgreSQL 16 + Redis 7
Sécurité       = SQLCipher (local), TLS 1.3 (réseau), AES-256
i18n           = flutter_localizations + intl 0.20.2 + ARB files
IA             = TensorFlow Lite (à venir Phase 2)
Design         = UI/UX Pro Max Skill (dark + light, tokens CSS)
CI/CD          = GitHub Actions (analyze, test, build Android, build iOS)
```

---

## Règles de qualité à respecter dans chaque prompt

- Dark + Light themes obligatoires (3 états : system/light/dark)
- Aucune couleur codée en dur — utiliser les tokens `AppColors`
- Chaque écran enfant doit utiliser `HarmonyAppBar` (back button auto)
- Toutes les nouvelles chaînes UI traduites dans 5 langues
- Tests unitaires requis pour tout code métier (couverture > 70 %)
- Code en anglais, commentaires en français
- Branche dédiée `feat/sprint-XX-description`, merge --no-ff sur main, tag si version majeure

---

## SPRINT 2 — Filtrage iOS CallKit + Appels sortants (À LANCER) ⬜

**Objectif :** Adapter le filtrage à iOS via CallKit (CXCallDirectoryProvider) et compléter avec la gestion des appels sortants (catégories surtaxées, numéros premium, etc.).

**Pré-requis :**
- Sprint 1 mergé ✅
- macOS avec Xcode (recommandé) OU émulateur iOS via Codemagic CI
- Connaissance basique Swift / CallKit

**Prompt à coller dans Claude Code :**

```
SPRINT 2 — Filtrage iOS CallKit + Appels sortants

CONTEXTE :
Le Sprint 1 a livré le filtrage Android natif (HarmonyCallScreeningService) avec latence 0ms. Maintenant on adapte à iOS via CallKit qui a une approche différente (asynchrone via CXCallDirectoryProvider) puis on ajoute la gestion des appels sortants (commune Android/iOS).

OBJECTIF :
- Implémentation iOS du filtrage via CXCallDirectoryProvider
- App Extension iOS dédiée (Call Directory Extension)
- Gestion des appels sortants : détection des numéros surtaxés, alertes avant composition
- KPI : déclenchement de l'alerte sortant en < 100ms

PHASE 1 — STRUCTURE iOS
- Créer App Extension "HarmonyCallDirectoryExtension" via Xcode
- Cible iOS 16+ (cohérent avec Android API 29+)
- Configurer App Groups pour partager la base de règles entre app principale et extension

PHASE 2 — CXCallDirectoryProvider en Swift
- Subclasse de CXCallDirectoryProvider
- beginRequest(with context:) qui charge les règles depuis App Group
- addIdentificationEntry + addBlockingEntry selon les règles
- Re-publication via context.completeRequest()

PHASE 3 — Adaptation MethodChannel pour iOS
- CallFilterChannel côté Swift dans AppDelegate
- Méthodes iOS : reloadExtension(), isExtensionEnabled(), syncRulesToExtension()
- Documentation : l'utilisateur doit activer manuellement Harmony dans Paramètres > Téléphone > Blocage et identification

PHASE 4 — Détection appels sortants (commun)
- Côté Flutter : interception via TelephonyProvider (Android) / NetworkExtension callbacks (iOS)
- Catégories à détecter : 0 899, +1-900 (US premium), numéros internationaux hors whitelist pays
- UI : dialog d'alerte AVANT que l'appel soit lancé, avec coût estimé

PHASE 5 — Tests
- Tests Swift via XCTest pour le filtrage iOS
- Tests Flutter pour le dialog d'alerte sortant
- Test e2e simulé : passer un appel vers 0 899 X X X X X → vérifier que l'alerte apparaît

PHASE 6 — Traductions i18n (8 clés × 5 langues)
- iosScreeningInstructions, iosScreeningStepSettings, etc.
- outgoingCallAlertTitle, outgoingCallAlertDescription, outgoingCallContinueButton, outgoingCallCancelButton

PHASE 7 — Commit
- Branche feat/sprint-2-ios-callkit-outgoing
- Tag v1.1.0-sprint-2
- Merge --no-ff sur main

CONFIRMER chaque phase. À LA FIN dis-moi :
- Hash du commit + tag
- Tests verts (Flutter + Kotlin + Swift)
- Si tu as réussi à tester l'extension iOS sur simulateur ou si ça nécessite un device réel
```

---

## SPRINT 3 — Géolocalisation + SOS + Tableau de bord enrichi ⬜

**Objectif :** Module Famille/Contrôle parental avec géolocalisation temps réel et bouton SOS (cahier section 3.4).

**À venir :** prompt complet quand on en sera là.

Composants prévus :
- Permissions location foreground + background (Android 14 + iOS 17)
- FusedLocationProvider (Android) / CoreLocation (iOS)
- Geofencing natif (zones sécurisées, alertes entrée/sortie)
- Widget SOS accessible écran verrouillé
- Appel auto 112 après timeout 2min sans réponse parent

---

## SPRINT 4 — Agenda + Sync calendrier + Tests MVP ⬜

**Objectif :** Finaliser le MVP de Phase 1 avec OAuth2 Google/Apple Calendar + tests d'intégration complets.

---

## SPRINTS 5 à 17 — Voir cahier des charges

Phases 2 (IA), 3 (Fitness), 4 (Premium + déploiement stores). Détail dans `Harmony_Iterations.md`.

---

## PROMPTS TRANSVERSAUX

### Prompt fix rapide

```
FIX RAPIDE — [TITRE DU BUG]

CONTEXTE :
[Description du bug]

CORRECTION :
[Solution attendue]

ÉTAPES :
1. Édite le(s) fichier(s)
2. flutter analyze (0 issues)
3. flutter test (tous verts)
4. Commit + push :
   - git checkout -b fix/[nom-du-fix]
   - git add -A
   - git commit -m "fix([scope]): [description]"
   - git push -u origin fix/[nom-du-fix]
   - git checkout main && git merge --no-ff fix/[nom-du-fix]
   - git push origin main

CONFIRMER avec un check après chaque étape.
```

### Prompt nouveau widget

```
NOUVEAU WIDGET HARMONY — [NomDuWidget]

CONTRAINTES :
- Adaptatif dark + light (utiliser Theme.of(context).brightness)
- Aucune couleur hardcodée
- Animation d'entrée 200ms easeOut
- Accessibilité : Semantics + tooltip si interactif
- Tests unitaires (3 minimum)
- Code en anglais, commentaires en français

À CRÉER :
- mobile/lib/shared/widgets/[snake_case_name].dart
- mobile/test/widgets/[snake_case_name]_test.dart
```

### Prompt revue de fin de sprint

```
REVUE FIN DE SPRINT — Sprint [N]

TÂCHES RÉALISÉES :
[Liste]

MÉTRIQUES :
- Tests verts : X / X
- Issues analyze : 0
- Commit : [hash]

RÉDIGE :
1. Bilan honnête
2. Mise à jour Harmony_Iterations.md
3. Mise à jour Harmony_Progression.md (changelog + ADR)
4. Ajustements sprint suivant
```

---

## Workflow Git imposé

Chaque sprint :
1. `git checkout -b feat/sprint-XX-description`
2. Travail sur la branche
3. Tests verts + 0 issues analyze
4. Commit conventionnel
5. `git push -u origin feat/sprint-XX-description`
6. `git checkout main && git merge --no-ff feat/sprint-XX-description`
7. `git push origin main`
8. Tag si version majeure : `git tag -a vX.Y.Z -m "Sprint XX - Description"`
9. Sauvegarde des fichiers de suivi via script PowerShell

---

## Skills utilisés

| Skill | Usage | Phases |
|---|---|---|
| ui-ux-pro-max | Design system + widgets | Toutes |
| frontend-design | Choix esthétiques | Phase 0, UI premium |
| docx | Rapports parentaux | Phase 2, 3 |
| pdf | Export fitness, politique conf | Phase 3, 4 |

---

---

## Sessions 29–31 mai 2026 — Leçons techniques Sprint A + B

### Supabase + asyncpg + SQLAlchemy

| Leçon | Règle |
|---|---|
| `NullPool` obligatoire avec Supabase transaction pooler | Le PgBouncer de Supabase ne supporte pas les prepared statements — `NullPool` + `statement_cache_size=0` dans `connect_args` sont **les deux** nécessaires (cf. ADR-039) |
| `CAST(:x AS uuid)` et non `:x::uuid` | `::uuid` dans une chaîne `sqlalchemy.text()` confond le parseur — `::` est ambigu entre l'opérateur PostgreSQL et le délimiteur de paramètre nommé SQLAlchemy (cf. ADR-041) |
| `clock_timestamp()` et non `now()` pour les comparaisons de dates critiques | `now()` = timestamp de début de transaction → peut être stale avec connection pooling. `clock_timestamp()` = horloge murale réelle (cf. ADR-046) |
| `code::text = :code` pour contourner l'ambiguïté de type asyncpg | Sans cast explicite, asyncpg peut inférer un type incorrect pour le paramètre si la colonne n'est pas strictement `text` — le cast `::text` garantit une comparaison textuelle (cf. ADR-047) |
| Nettoyage code reçu : `re.sub(r"[^\d]", "", code)` | Espaces internes, NBSP, caractères Unicode "digit-like" peuvent passer `.strip()` sans être filtrés — regex plus robuste |
| Logs temporaires de diagnostic : les retirer après confirmation | Toujours noter dans le commit que les logs sont temporaires (commentaire "LOG TEMPORAIRE — à retirer") ; cleanup en commit séparé avec tag |

### Android DeviceAdminReceiver + DevicePolicyManager

| Leçon | Règle |
|---|---|
| `DeviceAdminReceiver` doit être déclaré dans `AndroidManifest.xml` avec `android:permission="BIND_DEVICE_ADMIN"` et `<meta-data android:name="android.app.device_admin" android:resource="@xml/device_admin" />` | Sans ces deux déclarations, le système Android ne reconnaît pas le receiver et `isAdminActive()` retourne toujours `false` |
| `requestAdmin()` est fire-and-forget — l'intent système est asynchrone | Ne jamais attendre un retour de `requestAdmin()` ; utiliser `WidgetsBindingObserver.didChangeAppLifecycleState(resumed)` pour rafraîchir l'état après retour dans l'app |
| `res/xml/device_admin.xml` doit déclarer `<force-lock />` | Sans cette politique, `DevicePolicyManager.lockNow()` lance une `SecurityException` même si l'admin est actif |
| `android:description` dans le receiver doit être une `@string/` resource | Android affiche cette description dans l'écran système de demande d'admin — les strings littérales ne sont pas acceptées dans ce contexte |

### Polling 15 s côté enfant

| Leçon | Règle |
|---|---|
| Singleton timer en Dart : `Timer.periodic` dans un singleton | Le singleton `CommandPollingService.instance` garantit qu'un seul timer tourne, même si l'écran est reconstruit plusieurs fois |
| `start(childId)` idempotent | Vérifier `_running && _childId == childId` avant de démarrer — évite les doubles timers |
| Le polling doit survivre au dépilage de l'écran | Ne pas appeler `stop()` dans `dispose()` de l'écran admin — le polling doit continuer en arrière-plan tant que l'app est vivante |
| `try/catch` global dans `_poll()` | Réseau coupé, HarmonyServices non initialisé, etc. — ne jamais laisser une exception non capturée planter silencieusement un timer |

### Gestion des enfants fictifs → réels

| Leçon | Règle |
|---|---|
| `loadFromApi()` séparé de `load()` dans le cubit | Préserve la compatibilité des tests qui mockent `IChildProfileRepository` — les tests existants continuent d'utiliser `load()` sans modification |
| `catch (_)` en fallback de `loadFromApi()` | `HarmonyServices.dioClient` est `late final` — avant `init()`, l'accès lance `LateInitializationError` (un `Error`, pas une `Exception`). `catch (_)` intercepte les deux |
| `_EmptyChildrenCard` compacte (pas de grande carte) | Une carte trop haute pousse le contenu en bas de la `ListView` hors du viewport — les tests `find.text()` ne trouvent pas les textes hors du viewport lazy-rendered |
| Couleur avatar déterministe depuis UUID | `palette[id.hashCode.abs() % palette.length]` — reproductible à chaque build, stable entre sessions |

### Logique `isInSchedule` (plages traversant minuit)

| Leçon | Règle |
|---|---|
| Deux cas distincts pour `start > end` (traversée minuit) | (1) `now >= start` → partie avant-minuit → vérifier **jour courant** ; (2) `now < end` → partie après-minuit → vérifier **jour précédent** (`currentDay == 1 ? 7 : currentDay - 1`) |
| Utiliser `DateTime.now()` injectable via paramètre `{DateTime? now}` | Permet les tests déterministes sans dépendre de l'horloge système — `isInSchedule(schedule, now: DateTime(2026,5,4,22,0))` |
| Tester les frontières exactes (`start` et `end`) | `start <= now` (dans) vs `start == now` (dans) vs `end <= now` (hors) — la frontière haute est exclusive (`< end`) |
| Arrays PostgreSQL `int[]` via `CAST('{1,2,5}' AS int[])` | Avec `sqlalchemy.text()` + asyncpg, passer le tableau comme string `'{1,2,5}'` et caster en `int[]` côté SQL — asyncpg ne peut pas inférer le type array depuis un paramètre Python list sans type hint |

### Tests et infrastructure

| Leçon | Règle |
|---|---|
| `pumpAndSettle()` timeout sur `CircularProgressIndicator` | Préférer `pump()` + `pump()` (deux frames) pour les tests avec indicateurs de chargement — `pumpAndSettle()` attend indéfiniment si une animation boucle |
| Tests de services stateless purs (ex `isInSchedule`) | Extraire la logique en fonction libre (pas méthode de classe) pour maximiser la testabilité sans mock |
| APK enfant `--target=lib/main_kids.dart` | Spécifier le target Dart pour l'app enfant — sans ça, `flutter build apk` utilise `lib/main.dart` (app parent) |

---

*Mise à jour : 31 mai 2026 après livraison Sprints A + B1 + B2 + B3 (appairage + verrouillage + horaires).*
