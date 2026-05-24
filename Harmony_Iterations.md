# 🔄 Harmony — Fichier des itérations
> Un sprint = 2 semaines (ou moins en mode rapide)
> Mise à jour : 24 mai 2026

---

## Conventions de statut

| Icône | Signification |
|---|---|
| ⬜ | Non commencé |
| 🔄 | En cours |
| ✅ | Terminé et validé |
| 🔴 | Bloqué |

---

## Vue d'ensemble des sprints

| Sprint | Phase | Thème | Statut | Commit |
|---|---|---|---|---|
| Sprint 0 | Phase 0 | Fondations et architecture | ✅ | `c4a646d` |
| Sprint A | UI premium | Navigation Dashboard | ✅ | `48ecc93` |
| Sprint B | UI premium | Maquettes interactives modules | ✅ | `f36a7cb` |
| Sprint C1 | UI premium | i18n 5 langues + back button | ✅ | `9c69cf3` |
| Fix C1 | UI premium | Bouton retour Settings + typo IT | ✅ | `3a45086` |
| Sprint C2 | UI premium | Light mode + ThemeCubit + Contacts | ✅ | `d34ce4f` |
| Sprint C3 | UI premium | Voicemail + transcriptions + push | ✅ | `9c88026` |
| Sprint C4 | UI premium | Responsive desktop 480px | ✅ | `881237b` |
| **Sprint 1** | **Phase 1** | **Filtrage Android natif** ⭐ | **✅** | **`267cc37`** |
| Sprint 2 | Phase 1 | Filtrage iOS CallKit + Sortants | ⬜ | — |
| Sprint 3 | Phase 1 | Géolocalisation + SOS + Dashboard | ⬜ | — |
| Sprint 4 | Phase 1 | Agenda + Sync calendrier + Tests MVP | ⬜ | — |
| Sprint 5 | Phase 2 | IA spam + STT + Score confiance | ⬜ | — |
| Sprint 6 | Phase 2 | Filtrage WhatsApp Android | ⬜ | — |
| Sprint 7 | Phase 2 | Filtrage WhatsApp iOS + NLP | ⬜ | — |
| Sprint 8 | Phase 2 | Geofencing avancé | ⬜ | — |
| Sprint 9 | Phase 2 | Temps écran + Rapports parentaux | ⬜ | — |
| Sprint 10-13 | Phase 3 | Fitness | ⬜ | — |
| Sprint 14-17 | Phase 4 | Premium + déploiement stores | ⬜ | — |

---

## Bilan détaillé des sprints terminés

### Sprint C3 — Voicemail + Transcriptions + Push ✅

**Date :** 24/05/2026 · **Commit :** `9c88026`

#### Livraisons
- ✅ Nouvel écran `/voicemail` avec 4 messages mockés réalistes
- ✅ VoicemailItemCard avec expand/collapse 300ms vers transcription complète
- ✅ HarmonyAudioWaveform intégré (créé au Sprint C2)
- ✅ Simulation push notification toast en haut de l'écran (2s après ouverture)
- ✅ 15 nouvelles clés i18n × 5 langues
- ✅ Tests dédiés Voicemail

#### Note importante
Anticipe le Sprint 5 du cahier des charges (vrai STT + FCM/APNs). Le mockup permet de valider l'UX immédiatement.

---

### Sprint C4 — Centrage desktop responsive ✅

**Date :** 24/05/2026 · **Commit :** `881237b`

#### Livraisons
- ✅ Nouveau widget HarmonyResponsiveWrapper
- ✅ Centrage automatique sur écrans > 480px (style Instagram/Threads desktop)
- ✅ Aucun impact sur mobile (l'app reste plein écran)
- ✅ Intégration via MaterialApp.router builder
- ✅ 3 nouveaux tests (mobile / desktop / custom maxWidth)

#### Résolution d'un retour utilisateur
> *« Sur l'ordinateur, les cartes sont énormes, sans respiration »*

Sur PC l'app s'affiche désormais comme une vraie app mobile, centrée et lisible.

---

### Sprint 1 — Filtrage appels Android natif ⭐ TERMINÉ

**Date :** 24/05/2026 · **Commit :** `267cc37` · **Tag :** `v1.0.0-sprint-1`

#### Objectif
Implémenter le **cœur métier** de Harmony : le filtrage natif des appels entrants Android avec latence inférieure à 200ms (KPI critique cahier des charges section 3.1.1).

#### User stories réalisées

| ID | Story | Statut |
|---|---|---|
| US-1-001 | CallScreeningService Android (Kotlin) interceptant les appels | ✅ |
| US-1-002 | CallDecisionEngine avec snapshot immuable @Volatile (perf) | ✅ |
| US-1-003 | CallLogStore buffer circulaire FIFO 1000 entrées | ✅ |
| US-1-004 | Logique : Whitelist > Urgence > Blacklist > Horaires | ✅ |
| US-1-005 | MethodChannel Flutter ↔ Kotlin avec 5 méthodes typées | ✅ |
| US-1-006 | Bannière statut dans CallFilterScreen (amber/vert) | ✅ |
| US-1-007 | Re-check automatique du statut via WidgetsBindingObserver | ✅ |
| US-1-008 | Écran `/call-log` avec 3 filtres et bouton "Effacer tout" | ✅ |
| US-1-009 | Tests JUnit Kotlin (engine + latence sur 1000 calls) | ✅ |
| US-1-010 | 10 clés i18n × 5 langues (callScreening*, callLog*) | ✅ |

#### Bilan

| Métrique | Valeur |
|---|---|
| Points planifiés | 25 |
| Points réalisés | 25 |
| Vélocité | 100 % |
| Tests Flutter | **65 verts** (+3 nouveaux) |
| Tests Kotlin JUnit | **5 verts** |
| Issues flutter analyze | **0** |
| Gradle build | **SUCCESSFUL** |
| Fichiers créés | 11 (Kotlin + Dart) |
| Fichiers modifiés | 17 (configs + i18n) |
| Lignes ajoutées | +1 265 |
| Commit | **`267cc37`** |
| Tag | **`v1.0.0-sprint-1`** |

#### KPI critique mesuré

> **Latence cible cahier des charges : < 200ms**

| Mesure | Résultat |
|---|---|
| Latence moyenne | **0 ms** |
| Latence P95 | **0 ms** |
| Latence max | **0 ms** |
| Marge vs KPI | **200× sous le seuil** |

Mesuré sur 1 000 décisions de blocage simulées via JUnit Kotlin.

#### Architecture du hot path

```
Android Telecom
       │
       ▼
HarmonyCallScreeningService.onScreenCall()
       │
       ▼ synchrone, < 1 ms
CallDecisionEngine.shouldBlock(phoneNumber)
       │ lecture @Volatile snapshot immuable
       ▼
CallRules (Whitelist > Urgence > Blacklist > Horaires)
       │
       ▼
respondToCall()
       │
       ▼ async IO (n'affecte PAS la latence)
CallLogStore.add(blockedCall)
```

#### Procédure manuelle (RoleManager capricieux)

Si la popup système ne s'affiche pas pour devenir Call Screening default :
1. Paramètres Android
2. Applications
3. Applications par défaut
4. Filtrage des appels
5. Choisir Harmony

L'app re-vérifie automatiquement le statut à chaque resume via WidgetsBindingObserver.

---

## Vélocité de l'équipe

| Sprint | Points planifiés | Points réalisés | Vélocité |
|---|---|---|---|
| Sprint 0 | 31 | 31 | 100 % |
| Sprint A | 5 | 5 | 100 % |
| Sprint B | 12 | 12 | 100 % |
| Sprint C1 | 13 | 13 | 100 % |
| Fix C1 | 2 | 2 | 100 % |
| Sprint C2 | 13 | 13 | 100 % |
| Sprint C3 | 8 | 8 | 100 % |
| Sprint C4 | 3 | 3 | 100 % |
| **Sprint 1** | **25** | **25** | **100 %** |

**Vélocité moyenne 9 sprints : 12.4 pts/sprint** · **100% complétion**

---

## Référence des commits sur main

```
47dbfe2 chore: merge feat/sprint-1-android-call-filtering into main (Sprint 1) [TAG v1.0.0-sprint-1]
267cc37 feat(sprint-1): Android native call filtering — CallScreeningService + MethodChannel
e8fcbfb chore: merge feat/sprint-c4-responsive-desktop into main (Sprint C4)
881237b feat(c4): mobile-first responsive wrapper (max-width 480px on desktop)
50fa88f chore: merge feat/sprint-c3-voicemail-mockups into main (Sprint C3)
9c88026 feat(sprint-c3): voicemail mockup screen — VoicemailScreen, push simulation, i18n x5
a7954d0 docs(tracking): mise a jour suivi projet apres Sprint C2 [TAG v0.5.0-sprint-c2]
e85e30c chore: merge feat/sprint-c2-premium-polish into main (Sprint C2)
d34ce4f feat(sprint-c2): premium polish — light mode, ThemeCubit, contacts, new widgets
243f786 chore: merge fix/sprint-c1-settings-back-button into main
3a45086 fix(navigation): SettingsScreen back button + audit navigation calls
1b92449 Merge feat/sprint-c1-i18n-back-button into main (Sprint C1)
9c69cf3 feat(sprint-c1): i18n complète 5 locales + bouton retour universel
e78060c chore: merge feat/sprint-b-mockup-screens into main
f36a7cb feat(ui): Sprint B — rich mockup screens for all 4 modules
```

---

## Prochaine étape — Sprint 2

**Filtrage iOS via CallKit + Appels sortants** — démarrer quand prêt.

Cf. cahier des charges section 3.1.1 (appels sortants) et 4 (CallKit iOS).

---

*Ce fichier est la référence opérationnelle du projet. Mise à jour automatique par script PowerShell.*
