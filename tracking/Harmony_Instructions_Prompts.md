# 🧭 Harmony — Instructions et Prompts par étape
> Guide d'implémentation complet · À utiliser avec Claude Code ou tout agent IA
> Mise à jour : **29 mai 2026** — v2.4.4-sprint-A-pairing-parent

---

## Dernière session — 29 mai 2026

| Champ | Valeur |
|---|---|
| **Version livrée** | `v2.3.2` → `v2.4.4-sprint-A-pairing-parent` |
| **Tests Flutter** | 325 / 325 ✅ (+5 PairingCubit) |
| **flutter analyze** | 78 issues (baseline stable) |
| **Push** | `origin main --tags` ✅ |

### Ce qui a été fait

**Corrections UI/UX :**
- **v2.3.2** — Overflow boutons voicemail : `Row` → 3 `Expanded` + `TextOverflow.ellipsis`
- **v2.3.3** — Cards enfants + `SafeZoneEditorScreen` theme-aware (`AppColors.bgSurface/bgBase` → `cs.surface`, `AppTypography.textTheme` static → `Theme.of(context).textTheme`)

**Backend FastAPI + Supabase (Sprint 9) :**
- Projet Supabase "harmony-backend" créé (West EU Ireland, gratuit) — 5 tables dont `pairing_codes`
- `database: connected` validé via `/health`
- `NullPool` + `statement_cache_size=0` pour compatibilité asyncpg + transaction pooler PgBouncer
- `POST /api/v1/pairing/generate` opérationnel
- Fix SQL : `CAST(:parent_id AS uuid)` (syntaxe `::uuid` confond le parseur `sqlalchemy.text()`)
- Abandon Docker (erreur DISM 0x80240021) → Supabase + Vercel

**Sprint A — appairage côté parent :**
- `AddChildPairingScreen` : code 6 chiffres GeistMono, compte à rebours 10 min, copie presse-papier
- `ApiConfig.baseUrl` runtime : `10.0.2.2:8000` émulateur Android / `localhost:8000` sinon
- Mur premium déplacé à la finalisation (pas à l'ouverture de l'écran)
- 5 tests `PairingCubit` avec stub service

### Règles émergentes à retenir

- Jamais `const TextStyle(color: AppColors.textMuted)` dans un widget partagé — dark-only (`#4A6080`). Utiliser `isDark ? AppColors.textMuted : const Color(0xFF757575)`.
- `textMutedLight` est `#757575` (WCAG AA). Ne pas redescendre en dessous pour du texte fonctionnel en mode clair.
- `String.fromEnvironment` est compile-time — ne JAMAIS y brancher `Platform.isAndroid`. Utiliser un getter runtime (`ApiConfig.baseUrl`).
- Le `::uuid` dans `sqlalchemy.text()` confond le parseur de paramètres nommés. Toujours utiliser `CAST(:param AS uuid)`.
- Le check `canAddChildProfile` appartient à la création du profil, pas à l'ouverture d'un écran de préparation.
- `parent_id` UUID local (session token) est un placeholder — à remplacer par le vrai user ID backend quand l'auth JWT sera implémentée.

---

## État actuel du projet (post-v2.4.4)

| Élément | Valeur |
|---|---|
| **Version** | **v2.4.4-sprint-A-pairing-parent** ⭐ |
| Dernier commit sur main | `c93eea5` (fix SQL pairing) |
| Tag courant | `v2.4.4-sprint-A-pairing-parent` |
| Tests Flutter verts | 325 / 325 |
| Tests Kotlin JUnit verts | 13 / 13 |
| Issues flutter analyze | 78 (baseline stable) |
| Langues supportées | FR · EN · ES · PT · IT (5) |
| Thèmes supportés | System · Light · Dark |
| **Latence filtrage Android** | **0 ms** (KPI < 200 ms) |
| **Avancement global** | **96 %** mobile · Backend **20 %** |
| **Backend** | FastAPI + Supabase connecté ✅ |
| **Sprint A** | Parent ✅ · Enfant ⬜ |

---

## Enseignements techniques — Session 29 mai 2026

| Leçon | Règle |
|---|---|
| `String.fromEnvironment` est compile-time | Ne jamais y brancher `Platform.isAndroid` — créer un getter **runtime** (`ApiConfig.baseUrl`) avec `kDebugMode && Platform.isAndroid` |
| Émulateur Android ≠ `localhost` | Depuis l'AVD, la machine hôte est `10.0.2.2`. Sur appareil physique : utiliser l'IP LAN ou `--dart-define` |
| `::uuid` dans `sqlalchemy.text()` | Le `::` est ambigu pour le parseur de paramètres nommés → `:parent_id` non détecté, reste littéral. Toujours `CAST(:param AS uuid)` |
| asyncpg + Supabase transaction pooler | PgBouncer (transaction mode) ne supporte pas les prepared statements : `NullPool` SQLAlchemy + `connect_args={"statement_cache_size": 0}` |
| `parent_id` = session UUID local | UUID v4 généré localement par `AuthBloc`. À remplacer par vrai user ID backend quand `POST /auth/register` + JWT seront implémentés |
| Feature gating et écrans de préparation | Le mur premium protège la **création** d'une ressource, pas l'écran qui prépare cette création. Vérifier au `finalize()`, pas au `push()` |
| Test d'un service avec singleton statique | Constructeur public + classe de stub qui hérite du service (override sans toucher `HarmonyServices`) |

---

## Stack technique (rappel)

```
Mobile         = Flutter 3.x (Dart) + bloc/cubit + go_router
Android natif  = Kotlin + CallScreeningService API 29+
Backend        = Python 3.12 + FastAPI + asyncpg (NullPool) — déployé sur Vercel
BDD            = Supabase (PostgreSQL 16, West EU Ireland) — Redis 7 (optionnel dev)
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

*Mise à jour : 24 mai 2026 après livraison Sprint 1 (Android natif filtering).*
