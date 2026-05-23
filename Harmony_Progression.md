# 📊 Blocker — Fichier de suivi & progression
> Mis à jour à chaque fin de sprint · Référence : `CAHIER_DES_CHARGES_Blocker_Consolide.md`

---

## État global du projet

| Champ | Valeur |
|---|---|
| **Version actuelle** | 0.1.0 — Phase 0 en cours |
| **Phase en cours** | Phase 0 — Initialisation & architecture |
| **Avancement global** | 22 % |
| **Date de début** | 2026-05-23 |
| **Date cible MVP** | 2026-09-19 (J+16 semaines) |
| **Dernière mise à jour** | 2026-05-24 |

---

## Tableau de bord des phases

| Phase | Nom | Durée prévue | Statut | Avancement | Date début | Date fin |
|---|---|---|---|---|---|---|
| **Phase 0** | Initialisation & architecture | 2 semaines | 🔄 En cours | 70 % | 2026-05-23 | — |
| **Phase 1** | MVP — Fonctionnalités core | 3 – 4 mois | ⬜ À faire | 0 % | — | — |
| **Phase 2** | Intelligence & IA | 2 – 3 mois | ⬜ À faire | 0 % | — | — |
| **Phase 3** | Fitness & performance | 2 – 3 mois | ⬜ À faire | 0 % | — | — |
| **Phase 4** | Premium & écosystème | 2 – 3 mois | ⬜ À faire | 0 % | — | — |

**Légende :** ⬜ À faire · 🔄 En cours · ✅ Terminé · 🔴 Bloqué · ⏸️ En pause

---

## Phase 0 — Initialisation & architecture

### Objectifs
Mettre en place les fondations du projet : structure du dépôt, stack technique, design system, environnements de développement et de production.

### Tâches

| # | Tâche | Responsable | Statut | Notes |
|---|---|---|---|---|
| 0.1 | Initialisation du dépôt Flutter | Dev Mobile | ✅ | Structure `lib/`, `pubspec.yaml`, design system |
| 0.2 | Mise en place du backend FastAPI | Dev Backend | ✅ | Auth JWT, health check, Docker, Alembic |
| 0.3 | Configuration PostgreSQL + Redis | Dev Backend | ✅ | docker-compose + migration initiale |
| 0.4 | Mise en place des environnements (dev / staging / prod) | DevOps | 🔄 | `.env.example` créé, CI/CD pending |
| 0.5 | Configuration SQLCipher (chiffrement local) | Dev Mobile | 🔄 | sqflite_sqlcipher dans pubspec.yaml |
| 0.6 | Design system : tokens couleurs, typographie, composants de base | Designer | ✅ | 12 composants + thèmes dark/OLED/light |
| 0.7 | Authentification biométrique + PIN (squelette) | Dev Mobile | ⬜ | Face ID / Empreinte |
| 0.8 | Structure de navigation Flutter (routes, guards) | Dev Mobile | ✅ | go_router configuré, toutes les routes |
| 0.9 | Pipeline CI/CD (GitHub Actions ou GitLab CI) | DevOps | ✅ | analyze + test + build Android/iOS |
| 0.10 | Documentation technique initiale | Tech Lead | 🔄 | README existant, à enrichir |

---

## Phase 1 — MVP (Fonctionnalités core)

### Objectifs
Livrer une première version fonctionnelle couvrant le filtrage d'appels, la gestion des listes, la géolocalisation basique et l'agenda.

### Tâches

| # | Tâche | Module | Statut | Priorité | Notes |
|---|---|---|---|---|---|
| 1.1 | Filtrage des appels entrants (Android — TelecomManager) | M1 | ⬜ | 🔴 Critique | Latence < 200 ms |
| 1.2 | Filtrage des appels entrants (iOS — CallKit) | M1 | ⬜ | 🔴 Critique | — |
| 1.3 | Filtrage des appels sortants (catégories surtaxées) | M1 | ⬜ | 🟠 Haute | — |
| 1.4 | Journal des appels bloqués (historique) | M1 | ⬜ | 🟠 Haute | — |
| 1.5 | Réponse SMS automatique pour appels bloqués | M1 | ⬜ | 🟡 Moyenne | — |
| 1.6 | Blacklist manuelle (numéros, plages, masques) | M2 | ⬜ | 🔴 Critique | — |
| 1.7 | Whitelist avec contacts prioritaires | M2 | ⬜ | 🔴 Critique | — |
| 1.8 | Modes prédéfinis (Nuit, Travail, Focus, Urgence) | M2 | ⬜ | 🟠 Haute | — |
| 1.9 | Programmation temporelle (plages horaires, jours) | M2 | ⬜ | 🟠 Haute | — |
| 1.10 | Géolocalisation basique de l'enfant (GPS toutes les 5 min) | M4 | ⬜ | 🔴 Critique | CoreLocation / FusedLocation |
| 1.11 | Bouton SOS (widget écran verrouillé) | M4 | ⬜ | 🔴 Critique | — |
| 1.12 | Agenda simple + synchronisation Google Calendar | M5 | ⬜ | 🟠 Haute | — |
| 1.13 | Tableau de bord principal (Dashboard) | UI | ⬜ | 🟠 Haute | 3 sections : Sécurité / Famille / Fitness |
| 1.14 | Interface Parent / Interface Enfant (bascule PIN) | UI | ⬜ | 🔴 Critique | — |
| 1.15 | Tests unitaires et d'intégration Phase 1 | QA | ⬜ | 🔴 Critique | Couverture > 70 % |

---

## Phase 2 — Intelligence & IA

### Objectifs
Enrichir le produit avec l'IA de détection, l'analyse comportementale, le filtrage WhatsApp et le geofencing avancé.

### Tâches

| # | Tâche | Module | Statut | Priorité | Notes |
|---|---|---|---|---|---|
| 2.1 | IA de détection spam / arnaque (TensorFlow Lite on-device) | M1 | ⬜ | 🔴 Critique | Base communautaire |
| 2.2 | Score de confiance de l'appelant | M1 | ⬜ | 🟠 Haute | — |
| 2.3 | Transcription vocale STT (messagerie vocale) | M1 | ⬜ | 🟡 Moyenne | — |
| 2.4 | Filtrage WhatsApp Android (NotificationListenerService) | M3 | ⬜ | 🔴 Critique | — |
| 2.5 | Filtrage WhatsApp iOS (MDM partiel) | M3 | ⬜ | 🟠 Haute | Contrainte sandboxing |
| 2.6 | Détection NLP de contenu suspect (cyber-harcèlement) | M3 | ⬜ | 🔴 Critique | — |
| 2.7 | Alertes parentales WhatsApp en temps réel | M3 | ⬜ | 🔴 Critique | — |
| 2.8 | Mode avion intelligent (WhatsApp coupé, appels actifs) | M3 | ⬜ | 🟠 Haute | — |
| 2.9 | Geofencing avancé (zones sécurisées avec alertes) | M4 | ⬜ | 🔴 Critique | — |
| 2.10 | Historique de parcours 30 jours (enfant) | M4 | ⬜ | 🟠 Haute | — |
| 2.11 | Analyse comportementale IA (anomalies, habitudes) | M4 | ⬜ | 🟠 Haute | — |
| 2.12 | Score de sécurité global (vert / orange / rouge) | M4 | ⬜ | 🟠 Haute | — |
| 2.13 | Rapport hebdomadaire parental automatisé | M4 | ⬜ | 🟡 Moyenne | — |
| 2.14 | Gestion du temps d'écran par application | M4 | ⬜ | 🟠 Haute | — |
| 2.15 | Anti-désinstallation (alerte parent) | M4 | ⬜ | 🟡 Moyenne | Admin device Android |

---

## Phase 3 — Fitness & performance

### Objectifs
Intégrer le module sport complet : traçage GPS, cardio, statistiques, plans d'entraînement.

### Tâches

| # | Tâche | Module | Statut | Priorité | Notes |
|---|---|---|---|---|---|
| 3.1 | Traçage de parcours GPS (distance, vitesse, dénivelé) | M6 | ⬜ | 🔴 Critique | — |
| 3.2 | Détection automatique d'activité (marche, course, vélo) | M6 | ⬜ | 🟠 Haute | Accéléromètre |
| 3.3 | Carte interactive avec tracé coloré par vitesse | M6 | ⬜ | 🟠 Haute | Mapbox / Google Maps |
| 3.4 | Intégration cardio Bluetooth (Apple Watch, Garmin, Fitbit) | M6 | ⬜ | 🟠 Haute | — |
| 3.5 | Estimation fréquence cardiaque via caméra (doigt flash) | M6 | ⬜ | 🟡 Moyenne | Fallback sans capteur |
| 3.6 | Zones de fréquence cardiaque (5 zones) | M6 | ⬜ | 🟠 Haute | — |
| 3.7 | Entraînements guidés (HIIT, endurance, fractionné) | M6 | ⬜ | 🟠 Haute | Alertes vocales |
| 3.8 | Tableaux de bord statistiques (hebdo / mensuel / annuel) | M6 | ⬜ | 🔴 Critique | MPAndroidChart / Charts iOS |
| 3.9 | Records personnels et prédictions (formule Riegel) | M6 | ⬜ | 🟡 Moyenne | — |
| 3.10 | Générateur de plans d'entraînement (8 – 16 semaines) | M6 | ⬜ | 🟠 Haute | — |
| 3.11 | Ajustement dynamique si séance manquée | M6 | ⬜ | 🟡 Moyenne | — |
| 3.12 | Export données (CSV, GPX, PDF) | M6 | ⬜ | 🟡 Moyenne | — |
| 3.13 | Intégration Apple Health / Google Fit | M6 | ⬜ | 🟠 Haute | HealthKit / Google Fit API |

---

## Phase 4 — Premium & écosystème

### Objectifs
Synchronisation cloud, intégration wearables, APIs tierces, assistant vocal, modèle économique activé.

### Tâches

| # | Tâche | Module | Statut | Priorité | Notes |
|---|---|---|---|---|---|
| 4.1 | Synchronisation cloud chiffrée (backup blacklist, règles) | Infra | ⬜ | 🔴 Critique | AWS S3 / GCS |
| 4.2 | Intégration Apple Watch (SOS, cardio, musique) | Wearables | ⬜ | 🟠 Haute | watchOS extension |
| 4.3 | Intégration Wear OS | Wearables | ⬜ | 🟠 Haute | — |
| 4.4 | Intégration Strava | APIs | ⬜ | 🟡 Moyenne | — |
| 4.5 | Assistant vocal natif (commandes de blocage) | IA | ⬜ | 🟡 Moyenne | — |
| 4.6 | Module SOS silencieux finalisé (3× bouton alimentation) | M4 | ⬜ | 🔴 Critique | — |
| 4.7 | Système d'abonnements in-app (RevenueCat ou natif) | Monetisation | ⬜ | 🔴 Critique | iOS App Store + Google Play |
| 4.8 | Widgets iOS / Android (dashboard rapide) | UI | ⬜ | 🟠 Haute | — |
| 4.9 | Onboarding interactif (tutoriel par module) | UX | ⬜ | 🟠 Haute | — |
| 4.10 | Audit de sécurité & conformité RGPD final | Sécurité | ⬜ | 🔴 Critique | — |
| 4.11 | Publication App Store (iOS) | Deploy | ⬜ | 🔴 Critique | — |
| 4.12 | Publication Google Play (Android) | Deploy | ⬜ | 🔴 Critique | — |

---

## Suivi des KPIs techniques

| Métrique | Cible | Mesuré à | Valeur actuelle | Statut |
|---|---|---|---|---|
| Latence de blocage d'appel | < 200 ms | Phase 1 | — | ⬜ |
| Surconsommation batterie | < 8 % / jour | Phase 1 | — | ⬜ |
| Taux de blocage appels indésirables | > 98 % | Phase 2 | — | ⬜ |
| Taux de détection contournement | > 95 % | Phase 2 | — | ⬜ |
| Couverture tests unitaires | > 70 % | Phase 1 | — | ⬜ |
| Couverture tests intégration | > 60 % | Phase 2 | — | ⬜ |

---

## Suivi des KPIs produit

| Métrique | Objectif 6 mois | Objectif 12 mois | Valeur actuelle |
|---|---|---|---|
| Téléchargements | 100 000 | 1 000 000 | — |
| Taux de conversion premium | 3 % | 5 % | — |
| Rétention J+7 | 40 % | 50 % | — |
| NPS | > 30 | > 60 | — |
| Temps moyen d'utilisation | 8 min / jour | 12 min / jour | — |

---

## Journal des décisions techniques (ADR)

| # | Date | Décision | Raison | Impact |
|---|---|---|---|---|
| ADR-001 | — | Flutter choisi pour le cross-platform | Performance native + unique codebase | Toutes les phases |
| ADR-002 | — | FastAPI (Python) pour le backend | Performance asynchrone, compatibilité TensorFlow | Phase 1+ |
| ADR-003 | — | SQLCipher pour le stockage local | Sécurité des données sensibles (RGPD) | Phase 0 |
| ADR-004 | — | Priorité Android pour le MVP WhatsApp | Sandboxing iOS trop restrictif pour WhatsApp | Phase 2 |
| ADR-005 | — | TensorFlow Lite on-device pour l'IA spam | Latence faible + confidentialité | Phase 2 |
| ADR-006 | 2026-05-23 | compileSdk relevé à 35 | Compatibilité sqflite_sqlcipher + androidx (exigent >= 34) | Phase 0 |
| ADR-007 | 2026-05-23 | compileSdk relevé à 36 | local_auth_android + flutter_plugin_android_lifecycle exigent >= 36 | Phase 0 |
| ADR-008 | 2026-05-24 | GitHub Actions + subosito/flutter-action@v2 | Intégration native GitHub, cache Flutter pub, matrix facile à étendre | Phase 0+ |
| ADR-009 | 2026-05-24 | Sprint B — maquettes interactives (mock data) avant backend | Permet de valider le design system et les flux UX sans attendre les APIs | Phase 1 |
| ADR-010 | 2026-05-24 | flutter_localizations (SDK) + ARB files pour l'i18n | Standard Flutter officiel, génération de code, pluriels ICU, 5 locales dès le départ (FR/EN/ES/PT/IT) | Toutes phases |

---

## Blocages actifs

> *Aucun blocage enregistré pour l'instant.*

| # | Date | Description | Module | Gravité | Résolution |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

---

## Changelog

| Version | Date | Phase | Description des changements |
|---|---|---|---|
| 0.0.0 | 2026-05-23 | Init | Création du fichier de suivi, monorepo initialisé |
| 0.1.0 | 2026-05-23 | Phase 0 | Flutter : structure feature-first, design system (12 composants), thèmes dark/OLED/light, router, dashboard. Backend : FastAPI + JWT auth + PostgreSQL + Redis + Docker + Alembic |
| 0.1.1 | 2026-05-23 | Phase 0 | fix(android) : compileSdk 31→35, puis 35→36 pour satisfaire sqflite_sqlcipher, local_auth_android et flutter_plugin_android_lifecycle |
| 0.2.0 | 2026-05-24 | Sprint A | Navigation interactive : 4 modules du dashboard câblés (Sécurité, Famille, Fitness, Agenda) — slide transition 200ms, boutons retour, HarmonyEmptyState, 5 nouveaux tests |
| 0.3.0 | 2026-05-24 | Phase 0 | CI/CD GitHub Actions : pipeline 4 jobs (analyze, test, build-android, build-ios), artifacts APK + .app.zip, concurrency cancel-in-progress |
| 0.3.1 | 2026-05-24 | Sprint B | Maquettes interactives pour 4 modules (Sécurité, Famille, Fitness, Agenda) — mock data typés, fl_chart bar chart, interactions toggles/modes |
| 0.4.0 | 2026-05-24 | Sprint C1 | i18n complète (FR/EN/ES/PT/IT, 97 clés ARB, pluriels ICU) + bouton retour universel HarmonyAppBar + SettingsScreen avec sélecteur de langue + LanguageCubit persistent + 14 tests (39 total) |

---

*Ce fichier doit être mis à jour à chaque fin de sprint ou de session de développement.*
