# 🔄 Blocker — Fichier des itérations
> Un sprint = 2 semaines · Référence : `CAHIER_DES_CHARGES_Blocker_Consolide.md` · Mise à jour : à chaque sprint

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

| Sprint | Phase | Thème | Statut | Dates |
|---|---|---|---|---|
| **Sprint 0** | Phase 0 | Fondations & architecture | ⬜ | — |
| **Sprint 1** | Phase 1 | Filtrage des appels (Android) | ⬜ | — |
| **Sprint 2** | Phase 1 | Filtrage des appels (iOS) + Listes | ⬜ | — |
| **Sprint 3** | Phase 1 | Géolocalisation + SOS + Tableau de bord | ⬜ | — |
| **Sprint 4** | Phase 1 | Agenda + Synchronisation calendrier + Tests MVP | ⬜ | — |
| **Sprint 5** | Phase 2 | IA spam + Score de confiance + STT | ⬜ | — |
| **Sprint 6** | Phase 2 | Filtrage WhatsApp Android | ⬜ | — |
| **Sprint 7** | Phase 2 | Filtrage WhatsApp iOS + NLP | ⬜ | — |
| **Sprint 8** | Phase 2 | Geofencing avancé + Analyse comportementale | ⬜ | — |
| **Sprint 9** | Phase 2 | Temps d'écran + Rapport parental + Tests Phase 2 | ⬜ | — |
| **Sprint 10** | Phase 3 | Traçage GPS + Détection d'activité | ⬜ | — |
| **Sprint 11** | Phase 3 | Cardio + Zones FC + Entraînements guidés | ⬜ | — |
| **Sprint 12** | Phase 3 | Dashboard fitness + Statistiques + Graphiques | ⬜ | — |
| **Sprint 13** | Phase 3 | Plans d'entraînement + Export + Apple Health/Google Fit | ⬜ | — |
| **Sprint 14** | Phase 4 | Synchronisation cloud + Wearables | ⬜ | — |
| **Sprint 15** | Phase 4 | Assistant vocal + SOS silencieux finalisé | ⬜ | — |
| **Sprint 16** | Phase 4 | Monétisation + Onboarding + Audit sécurité | ⬜ | — |
| **Sprint 17** | Phase 4 | Déploiement App Store + Google Play | ⬜ | — |

---

## Détail des sprints

---

### 🏁 Sprint 0 — Fondations & architecture
**Phase :** 0 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Mettre en place l'intégralité de l'environnement de développement, la structure du projet, le design system et les fondations de sécurité avant tout développement fonctionnel.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-001 | En tant que développeur, je veux un dépôt Flutter initialisé avec la bonne architecture | Structure `lib/` (features, core, shared), `pubspec.yaml` complet, lint configuré | 3 | ⬜ |
| US-002 | En tant que développeur, je veux un backend FastAPI opérationnel | Endpoint `/health`, structure modulaire, Dockerfile, `.env` | 5 | ⬜ |
| US-003 | En tant que développeur, je veux une base de données PostgreSQL + Redis configurée | Schéma initial, migrations Alembic, connexion Redis testée | 5 | ⬜ |
| US-004 | En tant que développeur, je veux le chiffrement local SQLCipher intégré | Base de données locale chiffrée AES-256, tests d'ouverture/fermeture | 3 | ⬜ |
| US-005 | En tant que designer, je veux un design system documenté | Tokens couleurs, typographie (Geist), composants de base Flutter | 5 | ⬜ |
| US-006 | En tant que développeur, je veux l'authentification biométrique + PIN fonctionnelle | Face ID / Empreinte + PIN de secours, persistance sécurisée | 5 | ⬜ |
| US-007 | En tant que DevOps, je veux un pipeline CI/CD configuré | Build Flutter Android + iOS, tests auto, lint, déploiement staging | 5 | ⬜ |

#### Définition of Done (DoD) Sprint 0
- [ ] Le projet Flutter compile sans erreur sur Android et iOS
- [ ] Le backend FastAPI répond sur `/health` en staging
- [ ] PostgreSQL et Redis sont connectés et fonctionnels
- [ ] L'authentification biométrique + PIN est opérationnelle
- [ ] Le design system est documenté dans `docs/design-system.md`
- [ ] Le pipeline CI/CD exécute les builds automatiquement

#### Risques identifiés
- Configuration de l'environnement iOS (certificats Xcode, provisioning) peut prendre du temps
- Compatibilité SQLCipher avec les dernières versions Flutter à vérifier

#### Notes & décisions
> *(À remplir en cours de sprint)*

#### Bilan du sprint
> *(À remplir en fin de sprint)*

| Métrique | Valeur |
|---|---|
| Points planifiés | 31 |
| Points réalisés | — |
| Vélocité | — |
| Bugs ouverts | — |
| Blocages rencontrés | — |

---

### 🏁 Sprint 1 — Filtrage des appels (Android)
**Phase :** 1 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Implémenter le filtrage des appels entrants et sortants sur Android avec `TelecomManager`, en respectant la contrainte de latence inférieure à 200 ms.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-008 | En tant qu'utilisateur, je veux bloquer automatiquement les numéros de ma blacklist | Appels bloqués en < 200 ms, notification silencieuse, log créé | 8 | ⬜ |
| US-009 | En tant qu'utilisateur, je veux recevoir les appels de ma whitelist même en mode blocage | Les contacts whitelist passent toujours, même en mode Nuit | 5 | ⬜ |
| US-010 | En tant qu'utilisateur, je veux restreindre les appels sortants vers les numéros surtaxés | Blocage 0 899, numéros premium, alerte avant composition | 5 | ⬜ |
| US-011 | En tant qu'utilisateur, je veux consulter le journal des appels bloqués | Liste chronologique : numéro, heure, motif de blocage, durée tentative | 3 | ⬜ |
| US-012 | En tant qu'utilisateur, je veux qu'un SMS automatique soit envoyé aux appels bloqués | Template SMS configurable dans les paramètres | 3 | ⬜ |

#### Définition of Done Sprint 1
- [ ] TelecomManager correctement configuré avec les permissions Android
- [ ] Latence de blocage mesurée et validée < 200 ms (5 tests consécutifs)
- [ ] Journal des appels bloqués persisté en base locale (SQLCipher)
- [ ] Tests unitaires des règles de filtrage (couverture > 70 %)
- [ ] Interface de la blacklist de base fonctionnelle

#### Notes & décisions
> *(À remplir en cours de sprint)*

#### Bilan du sprint
> *(À remplir en fin de sprint)*

| Métrique | Valeur |
|---|---|
| Points planifiés | 24 |
| Points réalisés | — |
| Vélocité | — |
| Bugs ouverts | — |

---

### 🏁 Sprint 2 — Filtrage des appels (iOS) + Gestion des listes
**Phase :** 1 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Implémenter le filtrage iOS via CallKit et compléter la gestion avancée des listes (blacklist / whitelist) avec la programmation temporelle.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-013 | En tant qu'utilisateur iOS, je veux bloquer les appels indésirables via CallKit | Appels bloqués sans affichage à l'écran, comportement identique à Android | 8 | ⬜ |
| US-014 | En tant qu'utilisateur, je veux créer des règles de blocage par plage horaire | Règle « bloquer tous sauf whitelist de 22 h à 7 h » opérationnelle | 5 | ⬜ |
| US-015 | En tant qu'utilisateur, je veux utiliser les modes prédéfinis (Nuit, Travail, Focus) | Activation/désactivation en 1 tap, transitions automatiques configurables | 5 | ⬜ |
| US-016 | En tant qu'utilisateur, je veux bloquer des plages de numéros et des pays entiers | Masques +33 6 XX XX XX XX et +44 (pays entier) fonctionnels | 5 | ⬜ |
| US-017 | En tant qu'utilisateur, je veux que le contournement d'urgence (3 appels en 5 min) fonctionne | Déblocage temporaire automatique après 3 appels répétés | 3 | ⬜ |

#### Définition of Done Sprint 2
- [ ] CallKit intégré et testé sur iOS 16+
- [ ] 5 modes prédéfinis disponibles et fonctionnels
- [ ] Plages horaires et jours de la semaine configurables
- [ ] Blacklist / Whitelist persistées localement (SQLCipher)
- [ ] Contournement d'urgence testé et validé

#### Notes & décisions
> *(À remplir en cours de sprint)*

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 3 — Géolocalisation + SOS + Tableau de bord
**Phase :** 1 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Implémenter la géolocalisation basique de l'enfant, le bouton SOS et construire le tableau de bord principal.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-018 | En tant que parent, je veux voir la position de mon enfant en temps réel | Position GPS affichée sur carte, mise à jour toutes les 5 min (mouvement) / 15 min (repos) | 8 | ⬜ |
| US-019 | En tant qu'enfant, je veux déclencher une alerte SOS depuis l'écran verrouillé | Widget SOS accessible sans déverrouiller, localisation + alerte envoyées aux contacts d'urgence | 8 | ⬜ |
| US-020 | En tant que parent, je veux recevoir une alerte si mon enfant ne répond pas au SOS | Appel automatique au 112 après 2 min sans réponse | 5 | ⬜ |
| US-021 | En tant qu'utilisateur, je veux un tableau de bord clair avec 3 sections principales | Dashboard : Sécurité / Famille / Fitness, alertes récentes, prochain RDV | 5 | ⬜ |
| US-022 | En tant que parent, je veux basculer vers l'interface parent via un code PIN | Bascule protégée, interface parent avec toutes les options de supervision | 3 | ⬜ |

#### Définition of Done Sprint 3
- [ ] Géolocalisation fonctionnelle sur Android et iOS (foreground + background)
- [ ] Consommation batterie GPS < 10 % lors des tests (cible finale : < 8 %)
- [ ] Widget SOS accessible depuis l'écran verrouillé (iOS : widget, Android : notification persistante)
- [ ] Tableau de bord affiche données réelles (non mockées)
- [ ] Interface Parent / Enfant avec bascule PIN opérationnelle

#### Notes & décisions
> *(À remplir en cours de sprint)*

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 4 — Agenda + Tests MVP complets
**Phase :** 1 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Finaliser le module agenda, intégrer la synchronisation calendrier et effectuer les tests complets de la Phase 1 avant validation du MVP.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-023 | En tant qu'utilisateur, je veux synchroniser mon agenda avec Google Calendar | Événements importés en temps réel, création depuis l'app reflétée sur Google | 8 | ⬜ |
| US-024 | En tant qu'utilisateur, je veux que les appels soient bloqués automatiquement pendant un événement « Important » | Lien agenda ↔ blocage actif pendant la durée de l'événement marqué | 5 | ⬜ |
| US-025 | En tant qu'utilisateur, je veux des rappels intelligents basés sur ma localisation et le trafic | Notification « Partez dans 15 min » calculée à partir de Google Maps | 5 | ⬜ |
| US-026 | En tant que développeur, je veux une suite de tests complète pour la Phase 1 | Couverture unitaire > 70 %, tests d'intégration pour tous les flux critiques | 8 | ⬜ |

#### Définition of Done Sprint 4 (= validation MVP)
- [ ] Tous les flux de la Phase 1 testés et validés
- [ ] Aucun bug bloquant ou critique ouvert
- [ ] Performances mesurées (latence, batterie)
- [ ] Build stable sur Android 10+ et iOS 16+
- [ ] Version 1.0.0-beta publiée en interne (TestFlight + Firebase App Distribution)

#### Notes & décisions
> *(À remplir en cours de sprint)*

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 5 — IA spam + Score de confiance + STT
**Phase :** 2 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Intégrer l'intelligence artificielle de détection de spam, le score de confiance de l'appelant et la transcription vocale STT.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-027 | En tant qu'utilisateur, je veux que les numéros spam soient automatiquement détectés et signalés | TensorFlow Lite détecte > 85 % des spams connus, score affiché à l'appel entrant | 13 | ⬜ |
| US-028 | En tant qu'utilisateur, je veux voir le score de confiance de chaque appelant inconnu | Score 0-100 affiché, couleur rouge/orange/vert, source du signalement | 5 | ⬜ |
| US-029 | En tant qu'utilisateur, je veux que mes messages vocaux soient transcrits automatiquement | Transcription STT disponible dans le journal, précision > 80 % en FR/EN | 8 | ⬜ |
| US-030 | En tant qu'utilisateur, je veux contribuer à la base communautaire en signalant un numéro | Bouton « Signaler comme spam », contribution anonyme au modèle partagé | 3 | ⬜ |

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 6 — Filtrage WhatsApp (Android)
**Phase :** 2 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Objectif du sprint
Implémenter le filtrage complet de WhatsApp sur Android via `NotificationListenerService`.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-031 | En tant que parent, je veux bloquer les messages WhatsApp d'un contact spécifique | Messages ignorés sans notification, log créé pour le parent | 8 | ⬜ |
| US-032 | En tant que parent, je veux définir des plages horaires pour WhatsApp | WhatsApp inaccessible la nuit (ex. 22 h – 7 h), sauf urgences | 5 | ⬜ |
| US-033 | En tant que parent, je veux recevoir une alerte si mon enfant reçoit un message suspect | NLP détecte mots-clés sensibles → notification parent en temps réel | 8 | ⬜ |
| US-034 | En tant que parent, je veux empêcher l'ajout de mon enfant dans des groupes non autorisés | Quitter automatiquement les groupes non whitelistés | 5 | ⬜ |

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 7 — Filtrage WhatsApp (iOS) + NLP avancé
**Phase :** 2 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

> ⚠️ Contrainte iOS : implémentation via profil MDM + Screen Time API. Fonctionnalités réduites par rapport à Android.

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-035 | En tant que parent iOS, je veux limiter WhatsApp via Screen Time | Restriction horaire WhatsApp effective sur iOS via Screen Time API | 8 | ⬜ |
| US-036 | En tant que parent, je veux un rapport hebdomadaire d'activité WhatsApp | Email / notification récapitulatif : temps d'utilisation, contacts actifs, signalements | 5 | ⬜ |
| US-037 | En tant que développeur, je veux affiner le modèle NLP de détection | Précision > 90 % sur jeu de test de 1 000 messages | 8 | ⬜ |

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 8 — Geofencing avancé + Analyse comportementale
**Phase :** 2 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### User stories

| ID | Story | Critères d'acceptation | Points | Statut |
|---|---|---|---|---|
| US-038 | En tant que parent, je veux définir des zones géographiques sécurisées | Zone dessinée sur carte, alerte immédiate si sortie de zone (< 30 s) | 8 | ⬜ |
| US-039 | En tant que parent, je veux consulter le trajet de mon enfant sur 30 jours | Historique horodaté, reconstruction du trajet sur carte, export possible | 5 | ⬜ |
| US-040 | En tant que parent, je veux être alerté si le comportement de mon enfant est anormal | IA détecte sortie des habitudes (horaire, lieu) → notification parent | 8 | ⬜ |
| US-041 | En tant que parent, je veux voir un score de sécurité global pour mon enfant | Indicateur visuel 🟢 / 🟠 / 🔴 mis à jour quotidiennement | 5 | ⬜ |

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 9 — Temps d'écran + Rapports + Tests Phase 2
**Phase :** 2 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 10 — Traçage GPS + Détection d'activité
**Phase :** 3 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 11 — Cardio + Zones FC + Entraînements guidés
**Phase :** 3 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 12 — Dashboard fitness + Statistiques + Graphiques
**Phase :** 3 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 13 — Plans d'entraînement + Export + Intégrations santé
**Phase :** 3 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 14 — Synchronisation cloud + Wearables
**Phase :** 4 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 15 — Assistant vocal + SOS silencieux finalisé
**Phase :** 4 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 16 — Monétisation + Onboarding + Audit sécurité
**Phase :** 4 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

### 🏁 Sprint 17 — Déploiement App Store + Google Play
**Phase :** 4 · **Durée :** 2 semaines · **Statut :** ⬜ À faire

#### Bilan du sprint
> *(À remplir en fin de sprint)*

---

## Vélocité de l'équipe

| Sprint | Points planifiés | Points réalisés | Vélocité | Bugs |
|---|---|---|---|---|
| Sprint 0 | 31 | — | — | — |
| Sprint 1 | 24 | — | — | — |
| Sprint 2 | 26 | — | — | — |
| Sprint 3 | 29 | — | — | — |
| Sprint 4 | 26 | — | — | — |
| Sprint 5 | 29 | — | — | — |
| Sprint 6 | 26 | — | — | — |
| Sprint 7 | 21 | — | — | — |
| Sprint 8 | 26 | — | — | — |
| … | … | … | … | … |

---

*Ce fichier est la référence opérationnelle du projet. Il complète `Blocker_Progression.md` (vue stratégique) et `Blocker_Instructions_Prompts.md` (guide d'implémentation).*
