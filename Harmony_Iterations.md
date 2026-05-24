# 🔄 Harmony — Fichier des itérations
> Un sprint = 2 semaines (ou moins en mode rapide) · Référence : `CAHIER_DES_CHARGES_Harmony_Consolide.md`
> Mise à jour : 24 mai 2026

---

## Conventions de statut

| Icône | Signification |
|---|---|
| ⬜ | Non commencé |
| 🔄 | En cours |
| ✅ | Terminé et validé |
| 🔴 | Bloqué |
| ⏭️ | Reporté au sprint suivant |
| ❌ | Annulé |

---

## Vue d'ensemble des sprints

| Sprint | Phase | Thème | Statut | Dates | Commit |
|---|---|---|---|---|---|
| **Sprint 0** | Phase 0 | Fondations et architecture | ✅ Terminé | 23/05/2026 | `c4a646d` et précédents |
| **Sprint A** | UI premium | Navigation Dashboard | ✅ Terminé | 24/05/2026 | `48ecc93` |
| **Sprint B** | UI premium | Maquettes interactives modules | ✅ Terminé | 24/05/2026 | `f36a7cb` |
| **Sprint C1** | UI premium | i18n 5 langues + back button | ✅ Terminé | 24/05/2026 | `9c69cf3` |
| **Fix C1** | UI premium | Bouton retour Settings + typo IT | ✅ Terminé | 24/05/2026 | `3a45086` |
| **Sprint C2** | UI premium | Light mode + ThemeCubit + Contacts | ✅ Terminé | 24/05/2026 | `d34ce4f` |
| **Sprint C3** | UI premium | Messagerie vocale + transcriptions | ⬜ À faire | — | — |
| **Sprint 1** | Phase 1 | Filtrage appels Android natif | ⬜ À faire | — | — |
| **Sprint 2** | Phase 1 | Filtrage appels iOS + Listes avancées | ⬜ À faire | — | — |
| **Sprint 3** | Phase 1 | Géolocalisation + SOS + Tableau bord | ⬜ À faire | — | — |
| **Sprint 4** | Phase 1 | Agenda + Sync calendrier + Tests MVP | ⬜ À faire | — | — |
| **Sprint 5** | Phase 2 | IA spam + Score confiance + STT | ⬜ À faire | — | — |
| **Sprint 6** | Phase 2 | Filtrage WhatsApp Android | ⬜ À faire | — | — |
| **Sprint 7** | Phase 2 | Filtrage WhatsApp iOS + NLP | ⬜ À faire | — | — |
| **Sprint 8** | Phase 2 | Geofencing avancé + Analyse comportementale | ⬜ À faire | — | — |
| **Sprint 9** | Phase 2 | Temps écran + Rapports parentaux | ⬜ À faire | — | — |
| **Sprint 10** | Phase 3 | Traçage GPS + Détection activité | ⬜ À faire | — | — |
| **Sprint 11** | Phase 3 | Cardio + Zones FC | ⬜ À faire | — | — |
| **Sprint 12** | Phase 3 | Dashboard fitness + Statistiques | ⬜ À faire | — | — |
| **Sprint 13** | Phase 3 | Plans entraînement + Export | ⬜ À faire | — | — |
| **Sprint 14** | Phase 4 | Synchronisation cloud + Wearables | ⬜ À faire | — | — |
| **Sprint 15** | Phase 4 | Assistant vocal + SOS silencieux | ⬜ À faire | — | — |
| **Sprint 16** | Phase 4 | Monétisation + Onboarding | ⬜ À faire | — | — |
| **Sprint 17** | Phase 4 | Déploiement App Store + Play Store | ⬜ À faire | — | — |

---

## Bilan des sprints terminés

### Sprint 0 — Fondations et architecture ✅
**Phase :** 0 · **Date :** 23/05/2026

#### Livraisons
- ✅ Monorepo créé (mobile/, backend/, docs/, .github/, scripts/)
- ✅ Flutter 3.x avec architecture feature-first
- ✅ Backend FastAPI + PostgreSQL + Redis + JWT
- ✅ Auth biométrie + PIN (24/24 tests verts)
- ✅ Design system Harmony (11 widgets)
- ✅ CI/CD GitHub Actions 4-jobs

#### Métriques
- Points planifiés : 31 · Points réalisés : 31 · Vélocité : 100 %
- Bugs ouverts : 0

---

### Sprint A — Navigation Dashboard ✅
**Phase :** UI premium · **Date :** 24/05/2026

#### Livraisons
- ✅ RouteNames pour dashboard, security, family, fitness, agenda, settings
- ✅ GoRouter avec transitions slide droite vers gauche 200 ms
- ✅ 4 cartes Dashboard cliquables avec animation hover
- ✅ HarmonyEmptyState sur écrans modules
- ✅ 5 nouveaux tests de navigation

#### Métriques
- Commit : `48ecc93`

---

### Sprint B — Maquettes interactives modules ✅
**Phase :** UI premium · **Date :** 24/05/2026

#### Livraisons
- ✅ 4 fichiers mock data typés (security, family, fitness, agenda)
- ✅ Sécurité : 3 KPI, 3-mode selector, 5 toggle rules, blocked-call log
- ✅ Famille : 2 cartes enfants, map placeholder, 3 zones, 2 progress bars
- ✅ Fitness : 4 KPI grid, BarChart fl_chart hebdo, records, sessions
- ✅ Agenda : date selector, 2 day-mode cards, 3 events colorés, FAB
- ✅ 1154 lignes ajoutées · 29/29 tests verts · 0 issue analyze

#### Métriques
- Commit : `f36a7cb`

---

### Sprint C1 — i18n + back button universel ✅
**Phase :** UI premium · **Date :** 24/05/2026

#### Livraisons
- ✅ flutter_localizations + intl 0.20.2 + l10n.yaml
- ✅ 5 fichiers ARB (FR template + EN/ES/PT/IT) avec 97 clés
- ✅ LanguageCubit avec persistance SecureStorage
- ✅ HarmonyAppBar avec auto back button via context.canPop()
- ✅ SettingsScreen avec sélecteur de langue (5 lignes drapeau emoji + nom natif)
- ✅ Mock data refactorisé : strings hardcodés vers enums typés
- ✅ 10 nouveaux tests (l10n + navigation_back)
- ✅ 4742 lignes ajoutées · 39/39 tests verts · 0 issue analyze

#### Métriques
- Commit : `9c69cf3`

---

### Fix C1 — Bouton retour Settings + typo italien ✅
**Phase :** UI premium · **Date :** 24/05/2026

#### Livraisons
- ✅ Remplacement context.go() vers context.push() pour Settings + 4 modules
- ✅ Correction "Itallano" vers "Italiano" dans app_it.arb
- ✅ Audit complet des appels de navigation

#### Métriques
- Commit : `3a45086`

---

### Sprint C2 — Premium Polish + Light Mode + Contacts ✅
**Phase :** UI premium · **Date :** 24/05/2026

#### Objectif du sprint
Refonte premium suite aux retours utilisateur sur l'esthétique générique, ajout du mode clair anti-fatigue et création du menu Contacts demandé.

#### User stories réalisées

| ID | Story | Critères d'acceptation | Statut |
|---|---|---|---|
| US-C2-001 | Tokens light mode complets | ivoire #FAF8F5, gris #1F2937, WCAG AAA badges | ✅ |
| US-C2-002 | ThemeCubit 3 états | system/light/dark + persistance SecureStorage | ✅ |
| US-C2-003 | HarmonyTheme.light() et .dark() | ThemeData complets (colorScheme, textTheme, cardTheme) | ✅ |
| US-C2-004 | Refonte widgets shared (4) | Card padding 14 radius 16, Badge AAA, StatusDot double-layer, Button focus ring | ✅ |
| US-C2-005 | Nouveau HarmonyMetricCard | Icône + chiffre + label + trend | ✅ |
| US-C2-006 | Nouveau HarmonyThemeToggle | Cycle 3 modes avec animation 200 ms | ✅ |
| US-C2-007 | Nouveau HarmonyAudioWaveform | 35 barres animées avec curseur lecture | ✅ |
| US-C2-008 | Nouveau HarmonySearchBar | Focus border, bouton clear | ✅ |
| US-C2-009 | Écran Contacts (/contacts) | 5 mocks, recherche, filtres, badges adaptatifs | ✅ |
| US-C2-010 | Module Contacts sur Dashboard | Carte cliquable + showcase nouveaux widgets | ✅ |
| US-C2-011 | 12 clés i18n x 5 langues | Theme + Contacts traduits (FR/EN/ES/PT/IT) | ✅ |
| US-C2-012 | Sélecteur thème dans Settings | 3 options + HarmonyThemeToggle | ✅ |
| US-C2-013 | 13 nouveaux tests | ThemeCubit x6 + ContactsScreen x7 | ✅ |

#### Bilan du sprint

| Métrique | Valeur |
|---|---|
| Points planifiés | 13 |
| Points réalisés | 13 |
| Vélocité | 100 % |
| Tests totaux | **52 verts** |
| Issues `flutter analyze` | **0** |
| Lignes ajoutées | +2 096 |
| Lignes supprimées | -362 |
| Fichiers créés | 10 |
| Fichiers modifiés | 22 |
| Commit | **`d34ce4f`** |
| Bugs ouverts | 0 |

#### Définition of Done atteinte
- ✅ Light + Dark themes complets et toggables
- ✅ Tous les widgets adaptatifs selon Theme.brightness
- ✅ Contrastes WCAG AAA dans les 2 thèmes
- ✅ Persistance des préférences (langue + thème)
- ✅ Tests verts (52 / 52)
- ✅ Aucune issue analyze
- ✅ Documentation à jour (ARB, ADR, README)

---

## Sprint C3 — Messagerie vocale (À VENIR) ⬜

#### Périmètre prévu
- Écran Voicemail (/voicemail)
- 4-5 messages vocaux mockés avec transcriptions
- VoicemailItemCard widget (header, transcription preview, footer actions)
- Expand pour voir transcription complète + HarmonyAudioWaveform (déjà créé)
- Simulation push notification toast en haut de l'écran
- ~15 nouvelles clés i18n x 5 langues
- 5-7 nouveaux tests

---

## Sprint 1 — Filtrage appels Android natif (À VENIR) ⬜

#### Périmètre prévu (cf. cahier des charges section 3.1.1)
- TelecomManager + CallScreeningService en Kotlin
- MethodChannel Flutter et Android natif
- Latence inférieure à 200 ms (KPI critique)
- Logique de décision : blacklist/whitelist/horaires
- Permissions Android (RoleManager, CallScreening default app)
- Tests d'intégration sur émulateur

---

## Vélocité de l'équipe

| Sprint | Points planifiés | Points réalisés | Vélocité | Bugs |
|---|---|---|---|---|
| Sprint 0 | 31 | 31 | 100 % | 0 |
| Sprint A | 5 | 5 | 100 % | 0 |
| Sprint B | 12 | 12 | 100 % | 0 |
| Sprint C1 | 13 | 13 | 100 % | 0 |
| Fix C1 | 2 | 2 | 100 % | 0 |
| Sprint C2 | 13 | 13 | 100 % | 0 |

**Vélocité moyenne sur les 6 derniers sprints : 12.7 points/sprint** (mode rapide)

---

## Référence des commits sur main

```
d34ce4f feat(sprint-c2): premium polish — light mode, ThemeCubit, contacts, new widgets
243f786 chore: merge fix/sprint-c1-settings-back-button into main
3a45086 fix(navigation): SettingsScreen back button + audit navigation calls
1b92449 Merge feat/sprint-c1-i18n-back-button into main (Sprint C1)
9c69cf3 feat(sprint-c1): i18n complète 5 locales + bouton retour universel
e78060c chore: merge feat/sprint-b-mockup-screens into main
f36a7cb feat(ui): Sprint B — rich mockup screens for all 4 modules
4b4be52 chore: merge feat/sprint-0-cicd into main
8669a0d feat(ci): add GitHub Actions CI/CD pipeline (Phase 0.9)
df6ff26 chore: merge feat/sprint-a-dashboard-navigation into main
48ecc93 feat(navigation): wire dashboard cards to all main screens
```

---

*Ce fichier est la référence opérationnelle du projet. Il est mis à jour automatiquement par `Save-Sprint-C2.ps1` à la fin de chaque sprint.*
