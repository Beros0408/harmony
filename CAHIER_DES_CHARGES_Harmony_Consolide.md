# 📋 Cahier des charges — Application mobile *Blocker*
### Version consolidée (fusion KIMI × DeepSeek)

---

> **Statut :** Version 1.0 — Consolidée  
> **Date :** Mai 2025  
> **Auteurs :** Analyse et fusion des cahiers KIMI & DeepSeek

---

## Table des matières

1. [Identification du projet](#1-identification-du-projet)
2. [Vision et positionnement](#2-vision-et-positionnement)
3. [Fonctionnalités détaillées](#3-fonctionnalités-détaillées)
   - [Module 1 — Filtrage des appels](#module-1--filtrage-des-appels)
   - [Module 2 — Gestion des listes](#module-2--gestion-des-listes-blacklist--whitelist)
   - [Module 3 — Filtrage WhatsApp](#module-3--filtrage-whatsapp)
   - [Module 4 — Contrôle parental intelligent](#module-4--contrôle-parental-intelligent)
   - [Module 5 — Agenda et planification intelligente](#module-5--agenda-et-planification-intelligente)
   - [Module 6 — Fitness et performance](#module-6--fitness-et-performance)
   - [Module 7 — Sécurité et confidentialité](#module-7--sécurité-et-confidentialité)
4. [Architecture technique](#4-architecture-technique)
5. [Interface utilisateur (UX/UI)](#5-interface-utilisateur-uxui)
6. [Modèle économique](#6-modèle-économique)
7. [Roadmap de développement](#7-roadmap-de-développement)
8. [Indicateurs de performance (KPIs)](#8-indicateurs-de-performance-kpis)
9. [Risques et mitigations](#9-risques-et-mitigations)
10. [Recommandations stratégiques](#10-recommandations-stratégiques-post-mvp)

---

## 1. Identification du projet

| Élément | Description |
|---|---|
| **Nom du projet** | Blocker |
| **Type** | Application mobile native (iOS & Android) |
| **Catégorie** | Sécurité / Contrôle parental / Productivité / Fitness |
| **Modèle économique** | Freemium (version gratuite + abonnements premium) |
| **Cible principale** | Parents d'enfants mineurs, professionnels, sportifs, séniors |
| **Plateformes** | iOS 16+ et Android 10+ (Flutter cross-platform recommandé) |

---

## 2. Vision et positionnement

### Vision produit

Devenir l'application de référence tout-en-un pour la gestion sécurisée des communications, le contrôle parental intelligent et le suivi de performance personnelle.

### Proposition de valeur unique

> *« La seule application qui protège vos communications, supervise vos enfants en toute intelligence et optimise votre performance physique — dans une seule interface. »*

### Différenciation concurrentielle

| Concurrent | Avantage de Blocker |
|---|---|
| Google Family Link | Ajout du fitness, filtrage WhatsApp, agenda intégré |
| Life360 | Filtrage d'appels avancé, IA comportementale, coaching sportif |
| Applications de blocage simples | Contrôle parental + agenda + sport dans un seul produit |

---

## 3. Fonctionnalités détaillées

---

### Module 1 — Filtrage des appels

#### 3.1.1 Appels entrants

- **Filtrage par numéro** : acceptation ou refus automatique selon les règles configurées
- **Identification en temps réel** : affichage du nom et de l'entreprise via base de données intégrée (type Truecaller)
- **Géolocalisation de l'appelant** : affichage du pays et de la ville basé sur l'indicatif téléphonique
- **Score de confiance** : algorithme d'évaluation du risque (spam, arnaque, inconnu) alimenté par les signalements communautaires et une IA apprenante
- **Messagerie vocale intelligente** : transcription automatique des messages vocaux (STT — Speech to Text)
- **Réponse automatique** : SMS configurables pour les appels bloqués
- **Latence de décision** : inférieure à 200 ms entre réception de l'appel et action de blocage *(exigence technique critique)*

#### 3.1.2 Appels sortants

- Restriction par catégorie : numéros surtaxés, internationaux, numéros premium (0 899, etc.)
- Budget d'appels mensuel configurable
- Alerte avant tout appel coûteux (notification avec estimation du coût)
- Journal détaillé : historique complet avec durée, coût et localisation

---

### Module 2 — Gestion des listes (Blacklist / Whitelist)

#### 3.2.1 Blacklist avancée

| Critère | Détail |
|---|---|
| Numéros spécifiques | Saisie manuelle, import depuis les contacts ou l'historique |
| Plages de numéros | Ex. : bloquer tous les +33 6 12 34 56 XX |
| Masques internationaux | Bloquer un pays entier (+44 Royaume-Uni, +212 Maroc…) |
| Mots-clés SMS | Bloquer les SMS contenant « URGENT », « GRATUIT », des liens suspects |
| Base communautaire | Partage anonyme des numéros de spam entre utilisateurs |

#### 3.2.2 Programmation temporelle

- **Règles récurrentes** : ex. « Bloquer tous les appels sauf famille entre 22 h et 7 h du lundi au vendredi »
- **Modes prédéfinis disponibles** :

| Mode | Plage / Usage |
|---|---|
| 🌙 Mode Nuit | 22 h – 7 h |
| 📚 Mode Travail / École | 8 h – 18 h |
| 🎯 Mode Focus | Session de travail ou de révision, durée libre |
| 🏖️ Mode Week-end | Entièrement paramétrable |
| 🚨 Mode Urgence | Tout passe sauf liste blanche |

- **Lien avec l'agenda** : pendant un événement marqué « Important » ou « Sport », les appels et notifications WhatsApp sont automatiquement suspendus
- **Calendrier d'exceptions** : jours fériés, vacances scolaires, dates personnalisées
- **Transitions automatiques** : passage d'un mode à l'autre sans intervention manuelle

#### 3.2.3 Liste blanche

- Contacts prioritaires toujours autorisés (famille, médecin, urgences)
- Contournement d'urgence : trois appels répétés en moins de cinq minutes débloquent temporairement l'accès
- Code PIN parental pour lever manuellement les restrictions à tout moment

---

### Module 3 — Filtrage WhatsApp

> ⚠️ **Contrainte technique importante**
> Sur iOS, l'interception WhatsApp est limitée par le sandboxing d'Apple. L'approche retenue sera un profil de configuration MDM (gestion d'appareils mobiles) pour le contrôle parental, couplé à CallKit pour les appels. Sur Android, le `NotificationListenerService` permet une intégration beaucoup plus complète.

#### 3.3.1 Filtrage des communications

- Blocage des messages et appels WhatsApp par contact ou par plage horaire
- Filtrage de groupes : interdiction d'ajout à des groupes non autorisés, quitter automatiquement les groupes non conformes
- Détection de contenu suspect : analyse NLP des messages entrants (cyber-harcèlement, mots-clés sensibles, contenu inapproprié)
- Alertes parentales en temps réel en cas de message suspect reçu par l'enfant
- **Mode avion intelligent** : désactiver le réseau pour WhatsApp uniquement, sans bloquer les appels d'urgence

#### 3.3.2 Statistiques WhatsApp

- Temps d'utilisation quotidien et hebdomadaire
- Nombre de messages échangés par contact
- Score d'activité suspecte (fréquence, horaires, nature du contenu)
- Rapport hebdomadaire d'activité téléphonique envoyé automatiquement aux parents

---

### Module 4 — Contrôle parental intelligent

#### 3.4.1 Supervision de l'enfant (moins de 18 ans)

| Fonctionnalité | Description |
|---|---|
| **Géolocalisation en temps réel** | Position GPS actualisée toutes les 5 min (en mouvement), toutes les 15 min (au repos) |
| **Zones sécurisées (geofencing)** | Définition de zones autorisées (école, domicile, club sportif) — alerte immédiate si sortie de zone |
| **Historique de parcours** | Reconstruction du trajet sur 30 jours avec horodatage |
| **Bouton SOS** | Widget accessible depuis l'écran verrouillé — envoie localisation + alerte aux contacts d'urgence |
| **SOS silencieux** | Appuyer trois fois sur le bouton d'alimentation → enregistrement audio + envoi de position |
| **Appel d'urgence automatique** | Aucune réponse du parent dans les 2 min suivant le SOS → appel automatique au 112 |
| **Anti-désinstallation** | Alerte envoyée au parent si l'enfant tente de désinstaller l'application |

#### 3.4.2 Analyse comportementale par IA

- **Détection d'anomalies** : alerte si l'enfant s'écarte brusquement de ses habitudes (horaires, lieux fréquentés)
- **Analyse des communications** : détection de contacts suspects (écart d'âge anormal, messages à caractère sexuel via NLP)
- **Détection de fugue** : algorithme de prédiction basé sur l'historique et le comportement en temps réel
- **Score de sécurité global** : tableau de bord parental avec indicateur visuel (🟢 vert / 🟠 orange / 🔴 rouge)

#### 3.4.3 Gestion du temps d'écran

- Limite de durée configurable par application (WhatsApp, jeux, réseaux sociaux)
- Verrouillage à distance de l'appareil depuis le téléphone du parent
- **Système de récompenses** : déblocage de temps d'écran supplémentaire selon les tâches accomplies (devoirs, sport)
- **Mode Sommeil** : écran verrouillé, appels bloqués — sauf urgences

---

### Module 5 — Agenda et planification intelligente

#### 3.5.1 Calendrier et rendez-vous

- Synchronisation multi-sources : Google Calendar, Outlook, Apple Calendar
- Import automatique : scan des SMS et e-mails pour détecter les rendez-vous confirmés
- Rappels intelligents : suggestion de départ basée sur la distance et le trafic en temps réel
- Disponibilité croisée : partage de créneaux avec la famille ou les collègues
- Mode Famille : agenda partagé avec visualisation des activités de chaque membre

#### 3.5.2 Planification d'activités

- **Catégories** : Sport, Médical, Professionnel, Scolaire, Loisirs
- **Récurrence avancée** : tous les 15 du mois, troisième mardi, etc.
- **Gestion des tâches** : liste intégrée avec priorisation selon la matrice d'Eisenhower
- **Intégration météo** : alerte automatique si pluie prévue pour une activité extérieure

---

### Module 6 — Fitness et performance

#### 3.6.1 Traçage de parcours

| Métrique | Détail |
|---|---|
| **Distance** | Kilométrage précis (GPS + accéléromètre) |
| **Vitesse** | Minimale / moyenne / maximale, rythme au kilomètre |
| **Dénivelé** | Gain et perte d'altitude |
| **Cartographie** | Carte interactive avec tracé coloré par vitesse |
| **Détection automatique** | Reconnaissance du type d'activité (marche, course, vélo) via accéléromètre |
| **Itinéraires favoris** | Sauvegarde et comparaison des parcours réguliers |

#### 3.6.2 Cardio-training

- Intégration capteurs Bluetooth : ceinture cardio, Apple Watch, Garmin, Fitbit
- Estimation via caméra (doigt sur le flash) en l'absence de capteur externe
- Zones de fréquence cardiaque : repos, brûlage des graisses, cardio, anaérobie, maximum
- Entraînements guidés : HIIT, endurance, fractionné — avec alertes vocales
- Tests de fitness : test de Cooper (12 min), VMA estimée, VO₂max approximée

#### 3.6.3 Tableau de bord et statistiques

- Vues hebdomadaire, mensuelle et annuelle avec courbes de progression
- Records personnels sur distances standards (5 km, 10 km, semi-marathon, marathon)
- Comparaison : résultats actuels versus semaine précédente et versus objectif fixé
- Comparaison communautaire : percentile par rapport aux utilisateurs du même âge et sexe
- **Prédictions** : estimation du temps sur marathon à partir des performances sur 10 km (formule de Riegel)
- **Export des données** : CSV, GPX, PDF, intégration Strava / Apple Health / Google Fit

#### 3.6.4 Planification d'entraînement

- Générateur de plans personnalisés selon l'objectif (perte de poids, 10 km, marathon) sur 8 à 16 semaines
- **Ajustement dynamique** : si une séance est manquée, le plan est automatiquement recalculé
- **Périodisation automatique** : cycles de charge et de récupération intégrés

---

### Module 7 — Sécurité et confidentialité

#### 3.7.1 Protection des données

- **Chiffrement local** : SQLCipher (AES-256) pour toutes les données sensibles stockées sur l'appareil
- **Chiffrement des transmissions** : TLS 1.3
- **Authentification** : biométrie (Face ID / empreinte digitale) + code PIN de secours
- **Mode invité** : accès restreint si le téléphone est prêté
- **Effacement à distance** : suppression sélective des données en cas de vol ou perte

#### 3.7.2 Conformité réglementaire

- **RGPD / CCPA** : consentement explicite, droit à l'oubli, portabilité des données
- **Contrôle parental légal** : surveillance ciblée sur les contenus à risque uniquement — pas de surveillance exhaustive
- **Géolocalisation de l'appelant** : uniquement avec consentement utilisateur explicite
- **Certifications visées** : ISO 27001, audit de sécurité par un tiers indépendant

---

## 4. Architecture technique

### 4.1 Stack recommandée

| Couche | Technologie |
|---|---|
| **Mobile** | Flutter (cross-platform, iOS & Android) |
| **Backend** | Node.js / Python (FastAPI) |
| **Base de données** | PostgreSQL (données structurées) + Redis (cache temps réel) |
| **Chiffrement local** | SQLCipher |
| **IA / ML** | TensorFlow Lite (on-device) + API cloud pour les modèles lourds |
| **Géolocalisation** | GPS natif + Google Maps API / Mapbox — `CoreLocation` (iOS) / `FusedLocationProvider` (Android) |
| **Filtrage des appels** | `TelecomManager` (Android) / `CallKit` (iOS) |
| **Filtrage WhatsApp (Android)** | `NotificationListenerService` |
| **Push Notifications** | Firebase Cloud Messaging (FCM) + APNs (iOS) |
| **Santé & fitness** | HealthKit (iOS) / Google Fit (Android) |
| **Stockage cloud** | AWS S3 / Google Cloud Storage |
| **Analytics** | Mixpanel / Amplitude |
| **Graphiques** | MPAndroidChart (Android) / Charts (iOS) |

### 4.2 Infrastructure

- **Architecture microservices** : scalabilité indépendante par module
- **Temps réel** : WebSockets pour la géolocalisation et les alertes
- **Fonctionnement hors connexion** (*offline-first*) pour le filtrage d'appels, avec synchronisation différée

### 4.3 Contraintes de performance

| Contrainte | Valeur cible |
|---|---|
| Latence de blocage d'appel | < 200 ms |
| Surconsommation batterie | < 8 % par jour |
| Mise à jour GPS (en mouvement) | Toutes les 5 minutes |
| Mise à jour GPS (au repos) | Toutes les 15 minutes |

### 4.4 Permissions requises

| Permission | Usage |
|---|---|
| Téléphone (lecture & modification) | Blocage des appels entrants et sortants |
| Notifications | Filtrage WhatsApp (Android) |
| Localisation (avant-plan & arrière-plan) | Géolocalisation, geofencing |
| Contacts (optionnel) | Import de la blacklist / whitelist |
| Fitness (HealthKit / Google Fit) | Données cardio et activité physique |

---

## 5. Interface utilisateur (UX/UI)

### 5.1 Design system

| Élément | Détail |
|---|---|
| **Thèmes** | Clair / Sombre / OLED (noir pur) — dark mode obligatoire |
| **Accessibilité** | WCAG 2.1 AA minimum, taille de police ajustable, VoiceOver / TalkBack |
| **Langues v1** | FR, EN, ES, DE, IT, PT, ZH |
| **Langues v2** | AR, JA, KO |

### 5.2 Tableau de bord principal

```
┌──────────────────────────────────────────────────┐
│  TABLEAU DE BORD PRINCIPAL                       │
│                                                  │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐  │
│  │  Sécurité  │  │  Famille   │  │  Fitness   │  │
│  │ (bouclier) │  │   (cœur)   │  │  (course)  │  │
│  └────────────┘  └────────────┘  └────────────┘  │
│                                                  │
│  [ Carte de géolocalisation de l'enfant ]        │
│  [ Prochain rendez-vous ] [ Séance du jour ]     │
│  [ Alertes récentes ]     [ Appels bloqués ]     │
└──────────────────────────────────────────────────┘
```

### 5.3 Interfaces distinctes

| Interface | Accès | Fonctionnalités |
|---|---|---|
| **Parent** | Code PIN ou biométrie | Tableau de supervision, alertes, rapports, paramétrage des restrictions |
| **Enfant** | Standard | Fonctionnalités visibles limitées, bouton SOS toujours accessible |

La bascule entre les deux interfaces est protégée par un code parental.

### 5.4 Widgets et raccourcis

- **Widget iOS / Android** : géolocalisation de l'enfant, prochain rendez-vous, distance du jour, nombre de blocages
- **Apple Watch / Wear OS** : bouton SOS, rythme cardiaque en temps réel, contrôle de la musique pendant le sport

---

## 6. Modèle économique

### 6.1 Version gratuite

- Filtrage d'appels basique (10 numéros en blacklist)
- Géolocalisation en temps réel (1 enfant)
- Agenda personnel
- Traçage de parcours (5 derniers enregistrements)
- Publicités non intrusives

### 6.2 Abonnements premium

| Plan | Prix indicatif | Contenu |
|---|---|---|
| **Premium Solo** | 4,99 €/mois | Toutes les fonctionnalités, hors contrôle parental multi-enfants |
| **Premium Famille** | 9,99 €/mois | Jusqu'à 5 profils enfants, localisation familiale partagée, agenda familial |
| **Premium Sport** | 6,99 €/mois | Plans d'entraînement, intégration montres connectées, statistiques avancées |
| **Licence à vie** | 149,99 € | Accès permanent à l'intégralité des fonctionnalités |

### 6.3 Achats intégrés

- Blacklist illimitée (numéros et mots-clés)
- Plans d'entraînement spécialisés (marathon, triathlon)
- Thèmes d'interface personnalisés

---

## 7. Roadmap de développement

### Phase 1 — MVP *(3 à 4 mois)*

- [ ] Filtrage des appels entrants et sortants
- [ ] Blacklist avec plages horaires et modes prédéfinis
- [ ] Géolocalisation basique de l'enfant
- [ ] Agenda simple avec synchronisation calendrier
- [ ] Tableau de bord minimal

### Phase 2 — Intelligence *(2 à 3 mois)*

- [ ] IA de détection spam et arnaque (base communautaire)
- [ ] Analyse comportementale de l'enfant
- [ ] Filtrage WhatsApp (Android complet, iOS partiel via MDM)
- [ ] Geofencing avancé avec historique de trajets
- [ ] Rapport hebdomadaire parental automatisé

### Phase 3 — Fitness *(2 à 3 mois)*

- [ ] Traçage de parcours GPS
- [ ] Intégration cardio (Bluetooth + estimation via caméra)
- [ ] Tableaux de statistiques et graphiques
- [ ] Générateur de plans d'entraînement

### Phase 4 — Premium et écosystème *(2 à 3 mois)*

- [ ] Synchronisation cloud chiffrée
- [ ] Intégration wearables (Apple Watch, Wear OS)
- [ ] API tierces (Strava, Apple Health, Google Fit)
- [ ] Assistant vocal natif
- [ ] Module SOS silencieux finalisé

---

## 8. Indicateurs de performance (KPIs)

### KPIs produit

| Métrique | Objectif 6 mois | Objectif 12 mois |
|---|---|---|
| Téléchargements | 100 000 | 1 000 000 |
| Taux de conversion premium | 3 % | 5 % |
| Rétention J+7 | 40 % | 50 % |
| NPS (satisfaction utilisateur) | > 30 | > 60 |
| Temps moyen d'utilisation | 8 min / jour | 12 min / jour |

### KPIs techniques

| Métrique | Cible |
|---|---|
| Taux de blocage des appels indésirables | > 98 % |
| Latence de blocage | < 200 ms |
| Surconsommation batterie | < 8 % / jour |
| Tentatives de contournement détectées | Taux > 95 % |

---

## 9. Risques et mitigations

| Risque | Impact | Mitigation |
|---|---|---|
| Limitations iOS (CallKit, sandboxing WhatsApp) | 🔴 Élevé | Approche MDM pour le contrôle parental iOS ; priorité Android pour le MVP |
| Confidentialité des données de l'enfant | 🔴 Critique | Chiffrement de bout en bout, consentement parental explicite, audit RGPD |
| Consommation excessive de batterie (GPS permanent) | 🟠 Moyen | Optimisation algorithmique, réveil intelligent par geofence, fréquence adaptative |
| Contournement par l'enfant (désinstallation) | 🟠 Moyen | Alerte anti-désinstallation, mode administrateur d'appareil (Android) |
| Concurrence (Google Family Link, Life360) | 🟠 Moyen | Différenciation par l'approche tout-en-un, l'IA comportementale et le fitness intégré |

---

## 10. Recommandations stratégiques (post-MVP)

| Fonctionnalité | Description |
|---|---|
| **Mode Senior** | Détection de chute via accéléromètre, rappels médicaments, interface simplifiée |
| **Intégration domotique** | Lien avec caméras intérieures et alarmes de la maison |
| **Coach virtuel IA** | Conseils personnalisés basés sur les données de sport, de sommeil et de communication |
| **Communauté parentale** | Forum modéré, partage des listes noires de spam entre utilisateurs |
| **Détection du stress** | Analyse de la fréquence vocale et cardiaque lors des appels entrants |
| **Version smartwatch** | Contrôle du blocage depuis le poignet (Wear OS / watchOS) |
| **Blockchain pour la preuve d'appel** | Horodatage immuable pour les litiges liés au harcèlement téléphonique |
| **Assistant vocal natif** | Commandes vocales pour gérer les règles de blocage sans ouvrir l'application |

---

## Annexe — Synthèse des apports de la fusion

| Élément | Source principale | Apport de la fusion |
|---|---|---|
| Profondeur fonctionnelle | KIMI | Conservée intégralement |
| APIs et contraintes techniques concrètes | DeepSeek | Intégrées dans l'architecture |
| KPIs techniques (latence, batterie) | DeepSeek | Ajoutés aux indicateurs de performance |
| Fonctionnalités originales (SOS silencieux, mode avion intelligent) | DeepSeek | Intégrées dans les modules concernés |
| Modèle économique détaillé | KIMI | Conservé et enrichi |
| Roadmap phasée avec jalons | KIMI | Enrichie des livrables DeepSeek |
| Recommandations stratégiques | KIMI | Complétées par les idées DeepSeek |

---

*Document généré à partir de l'analyse croisée des cahiers des charges KIMI et DeepSeek — Application Blocker.*
