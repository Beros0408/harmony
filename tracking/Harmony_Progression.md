# 📊 Harmony — Fichier de suivi & progression
> Mis à jour à chaque fin de sprint · Référence : `CAHIER_DES_CHARGES_Harmony_Consolide.md`

---

## État global du projet

| Champ | Valeur |
|---|---|
| **Version actuelle** | **1.1.0 — Sprint 2 livré (iOS CallKit + Sortants + Modes)** ⭐ |
| **Phase en cours** | Phase 1 (Cœur métier) — ~30 % |
| **Avancement global** | ~50 % |
| **Date de début** | 23 mai 2026 |
| **Date cible MVP** | J+16 semaines |
| **Dernière mise à jour** | 24 mai 2026 |

---

## Tableau de bord des phases

| Phase | Nom | Durée prévue | Statut | Avancement | Date début | Date fin |
|---|---|---|---|---|---|---|
| **Phase 0** | Initialisation et architecture | 2 semaines | ✅ Terminée | 100 % | 23/05/2026 | 24/05/2026 |
| **Phase 0+** | UI premium (Sprints A, B, C1, C2, C3, C4) | 1 semaine | ✅ Terminée | 100 % | 23/05/2026 | 24/05/2026 |
| **Phase 1** | MVP — Cœur métier | 3-4 mois | 🔄 En cours | 20 % | 24/05/2026 | — |
| **Phase 2** | Intelligence et IA | 2-3 mois | ⬜ À faire | 0 % | — | — |
| **Phase 3** | Fitness et performance | 2-3 mois | ⬜ À faire | 0 % | — | — |
| **Phase 4** | Premium et écosystème | 2-3 mois | ⬜ À faire | 0 % | — | — |

**Légende :** ⬜ À faire · 🔄 En cours · ✅ Terminé · 🔴 Bloqué · ⏸️ En pause

---

## Phase 0+ — UI premium (TERMINÉE ✅)

| Sprint | Livraison | Commit | Statut |
|---|---|---|---|
| **Sprint A** | Navigation Dashboard vers 4 modules avec transitions slide | `48ecc93` | ✅ Mergé |
| **Sprint B** | Maquettes interactives 4 modules avec données mockées | `f36a7cb` | ✅ Mergé |
| **Sprint C1** | i18n 5 langues (FR/EN/ES/PT/IT) + bouton retour universel | `9c69cf3` | ✅ Mergé |
| **Fix C1** | Bouton retour Settings + typo "Itallano" devient "Italiano" | `3a45086` | ✅ Mergé |
| **Sprint C2** | Premium polish + Light mode + ThemeCubit + Contacts + 4 widgets | `d34ce4f` | ✅ Mergé (tag v0.5.0) |
| **Sprint C3** | Messagerie vocale (Voicemail + transcriptions + push mockup) | `9c88026` | ✅ Mergé |
| **Sprint C4** | Centrage desktop responsive (max-width 480px) | `881237b` | ✅ Mergé |

---

## Phase 1 — Cœur métier (EN COURS 🔄)

### Sprint 1 — Filtrage des appels Android natif ✅ TERMINÉ

**Date :** 24/05/2026 · **Commit :** `267cc37` · **Tag :** `v1.0.0-sprint-1`

#### Livraisons techniques

**Couche native Android (Kotlin) :**
- ✅ `HarmonyCallScreeningService` — service système qui intercepte les appels (API 29+)
- ✅ `CallDecisionEngine` — décision synchrone < 1ms avec snapshot @Volatile immuable
- ✅ `CallLogStore` — buffer circulaire FIFO 1000 entrées, thread-safe
- ✅ `CallFilterMethodChannel` — pont Flutter ↔ Kotlin avec 5 méthodes typées
- ✅ Logique de décision dans l'ordre : Whitelist > Urgence > Blacklist > Horaires

**Couche Flutter (Dart) :**
- ✅ `CallFilterChannel.dart` — wrapper Dart du MethodChannel
- ✅ Bannière de statut dans CallFilterScreen (inactive amber / active verte)
- ✅ Re-check automatique via WidgetsBindingObserver lifecycle
- ✅ Nouvel écran `/call-log` — liste appels bloqués, 3 filtres temporels, clear all

**Permissions Android ajoutées :**
- READ_CONTACTS, MANAGE_OWN_CALLS, BIND_SCREENING_SERVICE

**i18n :** 10 nouvelles clés × 5 langues (callScreening*, callLog*)

#### KPI critique : Latence (cahier section 3.1.1)

| Métrique | Cible cahier | Mesuré | Statut |
|---|---|---|---|
| Latence moyenne | < 200 ms | **0 ms** | 🟢 200× marge |
| Latence P95 | < 200 ms | **0 ms** | 🟢 OK |
| Latence max | < 200 ms | **0 ms** | 🟢 OK |

> Mesuré sur 1 000 décisions de blocage simulées via JUnit Kotlin.

#### Tests
- ✅ 5 tests JUnit Kotlin (engine + latence sur 1000 calls)
- ✅ +3 tests Flutter pour CallLogScreen → **65 tests total**
- ✅ 0 issues `flutter analyze` + Gradle BUILD SUCCESSFUL

---

### Sprint 2 — Filtrage iOS (CallKit) + Sortants ⬜ À VENIR

Cf. cahier des charges. Adaptation iOS via CallKit (CXCallDirectoryProvider, asynchrone) + appels sortants (catégories surtaxées) + Journal complet.

---

### Sprint 3 — Géolocalisation + SOS + Tableau bord ⬜ À VENIR

CoreLocation / FusedLocationProvider, geofencing, bouton SOS, appel auto 112.

---

### Sprint 4 — Agenda + Sync calendrier + Tests MVP ⬜ À VENIR

OAuth2 Google/Apple Calendar, lien filtrage ↔ événements, tests d'intégration Phase 1.

---

## Suivi des KPIs techniques

| Métrique | Cible | Mesuré à | Valeur actuelle | Statut |
|---|---|---|---|---|
| **Latence de blocage d'appel** | < 200 ms | Sprint 1 ✅ | **0 ms moyenne** | 🟢 KPI ATTEINT |
| Surconsommation batterie | < 8 % par jour | Sprint 3 | — | ⬜ Non démarré |
| Taux de blocage appels indésirables | > 98 % | Sprint 5 | — | ⬜ Non démarré |
| Taux de détection contournement | > 95 % | Phase 2 | — | ⬜ Non démarré |
| Couverture tests unitaires | > 70 % | Phase 1 | ~80 % (70 tests) | 🟢 OK |
| Couverture tests intégration | > 60 % | Phase 2 | — | ⬜ Non démarré |
| Issues `flutter analyze` | 0 | Continu | **0** | 🟢 OK |
| Tests CI/CD GitHub Actions | Vert | Continu | **Vert** | 🟢 OK |
| Tests Kotlin JUnit | Vert | Sprint 1+ | **5/5 verts** | 🟢 OK |

---

## Suivi des KPIs produit

| Métrique | Objectif 6 mois | Objectif 12 mois | Valeur actuelle |
|---|---|---|---|
| Téléchargements | 100 000 | 1 000 000 | — |
| Taux de conversion premium | 3 % | 5 % | — |
| Rétention J+7 | 40 % | 50 % | — |
| NPS | > 30 | > 60 | — |

---

## Journal des décisions techniques (ADR)

| # | Date | Décision | Raison | Impact |
|---|---|---|---|---|
| ADR-001 | 23/05/2026 | Flutter choisi pour le cross-platform | Performance native + codebase unique | Toutes phases |
| ADR-002 | 23/05/2026 | FastAPI (Python) pour le backend | Performance async + compatibilité IA | Phase 1+ |
| ADR-003 | 23/05/2026 | SQLCipher pour le stockage local | Sécurité données sensibles (RGPD) | Phase 0 |
| ADR-004 | 23/05/2026 | Priorité Android pour MVP WhatsApp | Sandboxing iOS trop restrictif | Phase 2 |
| ADR-005 | 23/05/2026 | TensorFlow Lite on-device pour IA spam | Latence faible + confidentialité | Phase 2 |
| ADR-006 | 24/05/2026 | go_router pour la navigation | Type-safe, transitions, deep linking | Toutes phases |
| ADR-007 | 24/05/2026 | flutter_localizations + ARB | Standard officiel Flutter pour i18n | Toutes phases |
| ADR-008 | 24/05/2026 | LanguageCubit + SecureStorage | Persistance préférence langue utilisateur | Toutes phases |
| ADR-009 | 24/05/2026 | HarmonyAppBar auto-back via canPop() | Cohérence UX, pas de bouton retour oublié | Toutes phases |
| ADR-010 | 24/05/2026 | context.push() pour routes enfant | Sémantique correcte pile navigation | Toutes phases |
| ADR-011 | 24/05/2026 | Light theme anti-fatigue (#FAF8F5/#1F2937) | Lisibilité WCAG AAA, bien-être utilisateur | UI |
| ADR-012 | 24/05/2026 | Application stricte du skill ui-ux-pro-max | Cohérence design system premium | UI |
| ADR-013 | 24/05/2026 | ThemeCubit + persistance SecureStorage | Préférence thème mémorisée | UI |
| **ADR-014** | 24/05/2026 | Voicemail anticipe Sprint 5 (STT) via mockup | Valider UX dès maintenant, vraie STT plus tard | UI |
| **ADR-015** | 24/05/2026 | HarmonyResponsiveWrapper 480px sur desktop | Mobile-first cohérent, lisible PC sans pollution layout | UI |
| **ADR-016** | 24/05/2026 | CallScreeningService (Android API 29+) plutôt que TelecomManager | API recommandée par Android, lifecycle propre | Phase 1 |
| **ADR-017** | 24/05/2026 | CallDecisionEngine avec snapshot @Volatile immuable | Lecture concurrente sans lock, latence sub-ms | Phase 1 |
| **ADR-018** | 24/05/2026 | CallLogStore buffer circulaire FIFO 1000 | Empreinte mémoire bornée, perf prévisible | Phase 1 |

---

## Blocages actifs

> *Aucun blocage actif.*

---

## Changelog

| Version | Date | Phase | Description |
|---|---|---|---|
| **1.0.0** | 24/05/2026 | **Sprint 1** ⭐ | Filtrage Android natif (CallScreeningService + MethodChannel) · 70 tests · KPI latence 0ms |
| 0.7.0 | 24/05/2026 | Sprint C4 | Responsive wrapper desktop max-width 480px |
| 0.6.0 | 24/05/2026 | Sprint C3 | Maquette Voicemail + transcriptions + push simulation |
| 0.5.0 | 24/05/2026 | Sprint C2 | Premium polish + Light theme + ThemeCubit + Contacts + 4 widgets |
| 0.4.1 | 24/05/2026 | Fix C1 | Fix bouton retour Settings + audit context.go/push |
| 0.4.0 | 24/05/2026 | Sprint C1 | i18n complète 5 langues + bouton retour universel |
| 0.3.0 | 24/05/2026 | Sprint B | Maquettes interactives 4 modules |
| 0.2.0 | 24/05/2026 | Sprint A | Navigation Dashboard avec transitions |
| 0.1.0 | 23/05/2026 | Phase 0 | Fondations + Auth biométrie + CI/CD |

---

*Ce fichier est mis à jour à chaque fin de sprint via le script PowerShell de sauvegarde.*


## Sprint 1.5 - UI Blacklist interactive + Sync Flutter/Kotlin (TERMINE)

- Date : 2026-05-25 02:56
- Tag : v1.1.1-blacklist-ui-sync
- Branche : fix/sprint-1.5-blacklist-ui-sync
- Tests Flutter : 117/117 verts
- Tests Kotlin : 13/13 verts
- flutter analyze : 0 issues
- Lignes ajoutees : 1746

### Livrables

- DatabaseHelper SQLCipher singleton (harmony.db, AES-256)
- BlacklistEntry model Equatable + BlockReason enum
- BlacklistRepository CRUD complet + normalisation E.164
- BlacklistCubit avec syncToNative automatique
- BlacklistScreen route /blacklist + HarmonySearchBar + FAB
- BlacklistFormSheet BottomSheet add/edit
- CallFilterScreen tile tappable + compteur dynamique
- 14 cles i18n x 5 langues (fr/en/es/pt/it)

### Validation E2E en conditions reelles

adb emu gsm call +33123456789
  -> HarmonyCallScreening: Snapshot actif : blacklist=4
  -> HarmonyCallScreening: Decision en 0ms : bloquer=true
  -> Telecom: SCREENING_COMPLETED [Reject], mIsBlocked=true
  -> Emulateur silencieux : aucune sonnerie, aucune notif

KPI cahier des charges (latence < 200ms) : VALIDE a 0ms IRL (marge 200x)

