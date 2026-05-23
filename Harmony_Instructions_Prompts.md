# 🧭 Blocker — Instructions & Prompts par étape
> Guide d'implémentation complet · À utiliser avec Claude Code ou tout agent IA  
> Référence : `CAHIER_DES_CHARGES_Blocker_Consolide.md` · Skills : `ui-ux-pro-max`, `frontend-design`

---

## Comment utiliser ce fichier

1. **Suivre l'ordre des sprints** défini dans `Blocker_Iterations.md`
2. **Avant chaque étape**, lire la section correspondante ici
3. **Copier le prompt** associé et l'envoyer à l'agent IA (Claude Code, Claude.ai, etc.)
4. **Valider les critères d'acceptation** avant de passer à l'étape suivante
5. **Mettre à jour** `Blocker_Progression.md` et `Blocker_Iterations.md` après chaque tâche

---

## Conventions & règles globales

### Stack obligatoire
```
Mobile     → Flutter 3.x (Dart)
Backend    → Python 3.12 + FastAPI
BDD        → PostgreSQL 16 + Redis 7
Sécurité   → SQLCipher (local), TLS 1.3 (réseau), AES-256
IA         → TensorFlow Lite (on-device)
Design     → UI/UX Pro Max Skill (dark mode first, tokens CSS)
```

### Règles de qualité à respecter dans chaque prompt
- Dark mode obligatoire (OLED noir pur disponible)
- Aucune couleur codée en dur — utiliser les tokens CSS du design system
- Chaque composant doit avoir un état de chargement et un état vide
- Accessibilité WCAG 2.1 AA minimum (ARIA, focus, contraste)
- Tests unitaires requis pour tout code métier (couverture > 70 %)
- Pas de `any` en TypeScript / pas de type dynamique non contrôlé en Dart
- Commentaires en français, code en anglais

---

## PHASE 0 — Fondations & architecture

---

### Étape 0.1 — Initialisation du projet Flutter

**Objectif :** Créer la structure complète du projet Flutter avec architecture feature-first.

**Contexte :** Application mobile cross-platform (iOS & Android) avec dark mode obligatoire, design system basé sur des tokens de couleur, navigation par routes nommées.

**Prompt :**
```
Tu es un expert Flutter. Crée la structure complète d'un projet Flutter 3.x pour une application appelée "Blocker".

Architecture à utiliser : Feature-first (clean architecture)
Structure attendue :
lib/
  core/
    constants/        ← couleurs, typographie, dimensions
    errors/           ← gestion des erreurs centralisée
    network/          ← intercepteurs HTTP, gestion des tokens
    security/         ← SQLCipher, chiffrement AES-256
    utils/            ← extensions, helpers
  features/
    auth/             ← biométrie + PIN
    dashboard/        ← tableau de bord principal
    call_filter/      ← module filtrage appels
    parental/         ← contrôle parental
    agenda/           ← planning
    fitness/          ← sport et santé
  shared/
    widgets/          ← composants réutilisables
    theme/            ← design system complet

Design system à implémenter :
- Palette dark mode (fond #0a0f1e, surface #0f1729, elevated #1a2236)
- Accents : bleu #3b82f6, vert #10b981, rouge #ef4444, amber #f59e0b
- Typographie : Geist + Geist Mono (Google Fonts)
- Tokens exposés via ThemeExtension Flutter

Génère :
1. Le pubspec.yaml complet avec toutes les dépendances nécessaires
2. La structure de dossiers avec fichiers index
3. Le fichier core/constants/app_colors.dart avec tous les tokens
4. Le fichier core/constants/app_typography.dart
5. Le fichier shared/theme/app_theme.dart (ThemeData dark + light + OLED)
6. Le fichier main.dart avec MaterialApp configuré
7. Un README.md expliquant l'architecture

Contraintes :
- Flutter 3.x minimum
- Null safety obligatoire
- Aucun import circulaire
- Commentaires en français, code en anglais
```

---

### Étape 0.2 — Backend FastAPI

**Objectif :** Créer le squelette du backend avec authentification JWT, structure modulaire et base de données.

**Prompt :**
```
Tu es un expert FastAPI et Python 3.12. Crée le backend complet pour l'application "Blocker".

Architecture : Modulaire par feature (même organisation que le frontend)
Structure :
app/
  api/
    v1/
      auth/           ← endpoints auth
      calls/          ← filtrage appels
      parental/       ← contrôle parental
      fitness/        ← sport
      agenda/         ← planning
  core/
    config.py         ← settings Pydantic
    security.py       ← JWT, bcrypt, tokens
    database.py       ← connexion PostgreSQL (asyncpg) + Redis
    middleware.py     ← CORS, rate limiting, logging
  models/             ← SQLAlchemy 2.0 (async)
  schemas/            ← Pydantic v2
  services/           ← logique métier
  tests/              ← pytest

Génère :
1. pyproject.toml avec toutes les dépendances (FastAPI, SQLAlchemy 2.0 async, Alembic, asyncpg, Redis, python-jose, passlib, pydantic-settings)
2. app/core/config.py avec tous les paramètres d'environnement via Pydantic BaseSettings
3. app/core/database.py avec connexion async PostgreSQL + Redis
4. app/core/security.py avec JWT (access + refresh tokens), bcrypt
5. app/models/user.py (utilisateur de base avec rôles : parent, enfant, admin)
6. app/api/v1/auth/ complet (register, login, refresh, logout)
7. Dockerfile et docker-compose.yml (app + PostgreSQL + Redis)
8. Script de migration Alembic initial
9. app/tests/test_auth.py (tests des endpoints auth)
10. Endpoint GET /health retournant le statut de toutes les dépendances

Contraintes :
- Async partout (async/await)
- Gestion d'erreurs centralisée avec codes HTTP appropriés
- Logs structurés (JSON) via structlog
- RGPD : aucune donnée personnelle en clair dans les logs
- TLS 1.3 pour les communications (configurer les headers de sécurité)
```

---

### Étape 0.3 — Design system Flutter complet

**Objectif :** Créer tous les composants de base réutilisables conformes au design system.

**Prompt :**
```
Tu es un expert Flutter et UI/UX. Crée le design system complet pour l'application "Blocker".

Basé sur les tokens suivants (dark mode par défaut) :
- Fond page : #0a0f1e
- Surface carte : #0f1729
- Surface élevée : #1a2236
- Interactif (hover) : #1e2d45
- Bordure subtile : #1e2d45
- Bordure défaut : #2a3f5f
- Texte principal : #e8edf5
- Texte secondaire : #8ba3c7
- Texte muet : #4a6080
- Accent bleu : #3b82f6
- Accent vert : #10b981
- Accent rouge : #ef4444
- Accent amber : #f59e0b
- Accent violet (IA) : #8b5cf6

Crée les composants suivants dans lib/shared/widgets/ :
1. BlockerButton (primary, secondary, danger, ghost) avec états loading/disabled + animation
2. BlockerCard (avec titre, badge optionnel, actions) — bords arrondis xl, ombre noire
3. BlockerTextField (avec icône, validation, état d'erreur)
4. BlockerBadge (couleurs sémantiques : succès, avertissement, danger, info, neutre)
5. BlockerStatusDot (pulsant si actif, couleur selon statut) — pour les modes de blocage
6. BlockerBottomSheet (modale du bas, poignée de glissement)
7. BlockerListTile (icône colorée, titre, sous-titre, action droite)
8. BlockerToggle (switch stylisé avec label)
9. BlockerLoadingSkeleton (placeholder animé pour le chargement)
10. BlockerEmptyState (illustration + titre + CTA)
11. BlockerSnackBar (succès, erreur, info — positionnée en bas)
12. BlockerAppBar (avec gradient subtil, actions, titre centré)

Pour chaque composant :
- Version dark mode obligatoire (fond transparent + tokens)
- Animation de transition (200 ms ease-in-out)
- État de focus accessible (bordure accent bleu)
- Documentation du constructeur (paramètres, valeurs par défaut)
- Exemple d'utilisation en commentaire

Police : Geist (normal) + Geist Mono (chiffres, données techniques)
Aucune couleur codée en dur — utiliser uniquement les tokens AppColors.
```

---

## PHASE 1 — MVP (Fonctionnalités core)

---

### Étape 1.1 — Filtrage des appels Android (TelecomManager)

**Objectif :** Implémenter le blocage d'appels natif Android avec une latence < 200 ms.

**Prompt :**
```
Tu es un expert Flutter et Android natif. Implémente le module de filtrage des appels pour Android dans l'application "Blocker".

Contexte technique :
- Flutter avec channel de méthodes (MethodChannel) vers le code natif Android
- API Android : TelecomManager + InCallService + CallScreeningService
- Latence exigée : < 200 ms entre réception de l'appel et décision de blocage
- Stockage local : SQLCipher (base chiffrée AES-256)

À implémenter :

1. Code natif Android (Kotlin) :
   - CallScreeningService : intercepte les appels entrants
   - Logique de décision synchrone (< 200 ms) basée sur la blacklist locale
   - Gestion de la whitelist (toujours autoriser)
   - Enregistrement dans le log local (SQLCipher)
   - AndroidManifest.xml : permissions et déclarations de services

2. Code Flutter (Dart) :
   - CallFilterService : service principal de gestion des règles
   - CallFilterRepository : accès base de données SQLCipher locale
   - Modèles : CallRule, BlockedCall, CallMode (Nuit, Travail, Focus, Urgence)
   - CallFilterBloc : gestion d'état (flutter_bloc)

3. Base de données locale (SQLCipher via sqflite_sqlcipher) :
   - Table call_rules (numéro, type, plage horaire, mode, actif)
   - Table blocked_calls (numéro, timestamp, motif, durée tentative)
   - Requêtes optimisées (index sur numéro + timestamp)

4. Tests :
   - Tests unitaires de la logique de décision (> 70 % couverture)
   - Test de performance : 100 appels simulés → latence moyenne < 200 ms

5. UI (lib/features/call_filter/screens/) :
   - Écran de liste des règles actives (BlockerListTile)
   - Formulaire d'ajout de règle (numéro, plage horaire, mode)
   - Page du journal des appels bloqués (liste avec filtres)

Utilise les composants du design system (BlockerCard, BlockerListTile, etc.).
Dark mode obligatoire. Commentaires en français.
```

---

### Étape 1.2 — Filtrage des appels iOS (CallKit)

**Prompt :**
```
Tu es un expert Flutter et iOS natif. Implémente le filtrage des appels pour iOS dans l'application "Blocker" en utilisant CallKit.

Contexte technique :
- Flutter avec MethodChannel vers code natif Swift
- API iOS : CallKit (CXCallDirectoryProvider pour la blocklist)
- Contrainte : CXCallDirectoryProvider est mis à jour de manière asynchrone (pas de décision temps réel comme Android)
- Approche : pré-charger la blacklist dans l'extension CallKit

À implémenter :

1. Extension iOS Swift (CallDirectory Extension) :
   - CXCallDirectoryProvider : ajoute les numéros bloqués dans le répertoire système
   - Mécanisme de mise à jour de l'extension quand la blacklist change (CXCallDirectoryManager.sharedInstance.reloadExtension)
   - Gestion de la whitelist avec CXCallDirectoryManager

2. Code Swift bridge :
   - AppDelegate modifications pour CallKit
   - MethodChannel : Flutter → Swift pour déclencher la mise à jour de l'extension

3. Code Flutter :
   - Adaptation du CallFilterService (détection OS → iOS vs Android)
   - Synchronisation blacklist → extension CallKit à chaque modification
   - UI identique à Android (réutilisation des composants)

4. Info.plist : permissions et déclarations nécessaires

5. Tests sur simulateur iOS 16+ et device réel

Documente clairement les limitations iOS vs Android (pas de blocage temps réel, délai de mise à jour de l'extension).
```

---

### Étape 1.3 — Blacklist avancée (UI + logique)

**Prompt :**
```
Tu es un expert Flutter. Implémente le module complet de gestion de la blacklist/whitelist pour "Blocker".

Fonctionnalités à implémenter :

1. Types de règles :
   - Numéro exact (saisie manuelle ou import depuis les contacts)
   - Plage de numéros (ex : +33 6 12 34 56 XX — utiliser un masque regex)
   - Pays entier (masque d'indicatif : +44 pour UK, +212 pour Maroc, etc.)
   - Mot-clé SMS (ex : "GRATUIT", "URGENT", regex sur le contenu)

2. Programmation temporelle :
   - Jours de la semaine (cases à cocher)
   - Plage horaire (TimePicker début/fin)
   - Modes prédéfinis (Nuit, Travail, Focus, Week-end, Urgence)
   - Calendrier d'exceptions (dates spécifiques où la règle ne s'applique pas)

3. UI à créer (lib/features/call_filter/) :
   - BlacklistScreen : liste toutes les règles avec statut actif/inactif
   - AddRuleScreen : formulaire multi-étapes (type de règle → paramètres → plages horaires)
   - ModeScreen : sélection et configuration des 5 modes prédéfinis
   - RuleDetailScreen : édition d'une règle existante

4. Logique métier :
   - Évaluation des règles dans l'ordre de priorité (whitelist > urgence > blacklist)
   - Contournement d'urgence : 3 appels en 5 min → déblocage temporaire 15 min
   - Code PIN pour lever les restrictions manuellement (dialog sécurisé)

5. Import/Export :
   - Import depuis les contacts du téléphone (permission_handler)
   - Export de la blacklist en JSON chiffré

Utilise les composants du design system. Animations sur les transitions de liste (stagger).
Tests unitaires pour la logique d'évaluation des règles.
```

---

### Étape 1.4 — Géolocalisation basique + SOS

**Prompt :**
```
Tu es un expert Flutter et géolocalisation mobile. Implémente le module de géolocalisation et le bouton SOS pour "Blocker".

Fonctionnalités :

1. Géolocalisation de l'enfant :
   - Position GPS toutes les 5 min si en mouvement, 15 min si au repos (économie batterie)
   - Détection mouvement/repos via accéléromètre (sensors_plus)
   - Envoi de la position au backend via WebSocket (temps réel) ou HTTP (différé)
   - Stockage local des 30 derniers jours de positions (SQLCipher)
   - Permissions : foreground + background location (iOS et Android)

2. Bouton SOS :
   - Widget accessible depuis l'écran verrouillé (iOS : widget de notification persistante, Android : overlay flottant)
   - Au déclenchement : envoie localisation GPS + alerte push à tous les contacts d'urgence
   - Si aucune réponse parent en 2 min : appel automatique au 112 (url_launcher tel:112)
   - SOS silencieux : détection de 3 pressions sur le bouton physique d'alimentation (Android : PowerButtonService)

3. Affichage carte (interface parent) :
   - Carte Google Maps / Mapbox avec marqueur enfant en temps réel
   - Historique du trajet (polyligne colorée)
   - Bouton "Contacter mon enfant" (appel direct)

4. Backend (endpoints FastAPI) :
   - POST /api/v1/location : reçoit et stocke les positions
   - GET /api/v1/location/{child_id}/current : position actuelle
   - GET /api/v1/location/{child_id}/history : historique 30 jours
   - POST /api/v1/sos/trigger : déclenche l'alerte SOS (FCM push vers parent)
   - WebSocket /ws/location/{child_id} : flux temps réel

5. Optimisation batterie :
   - FusedLocationProvider (Android) / CoreLocation avec CLActivityType (iOS)
   - Mise en veille si l'enfant est immobile depuis > 10 min
   - Cible : < 10 % de surconsommation batterie

Utilise le design system. Carte intégrée dans le tableau de bord parent.
```

---

### Étape 1.5 — Tableau de bord principal

**Prompt :**
```
Tu es un expert Flutter et UI/UX. Implémente le tableau de bord principal de "Blocker" selon le design system défini.

Structure du dashboard (3 onglets principaux + vue unifiée) :

1. Vue unifiée (écran d'accueil) :
   - Header : nom de l'utilisateur, heure, score de sécurité global (LED colorée)
   - Carte géolocalisation de l'enfant (mini-carte 200px de hauteur)
   - Grille 3 boutons : Sécurité / Famille / Fitness (BlockerCard avec icône + métrique)
   - Section "Alertes récentes" (liste des 5 dernières alertes)
   - Section "Prochain rendez-vous" (carte agenda)
   - Section "Séance du jour" (objectif fitness)
   - Compteur "Appels bloqués aujourd'hui"

2. Section Sécurité :
   - Modes actifs (badge + toggle rapide)
   - Stats du jour : appels bloqués, SMS filtrés, tentatives WhatsApp
   - Accès rapide : blacklist, journal, paramètres

3. Section Famille :
   - Position enfant(s) en temps réel (liste si plusieurs enfants)
   - Score de sécurité par enfant (🟢 / 🟠 / 🔴)
   - Alertes parentales récentes
   - Accès rapide : géofencing, WhatsApp, temps d'écran

4. Section Fitness :
   - Distance du jour (grand chiffre avec unité)
   - Calories, durée d'activité
   - Graphique de la semaine (Recharts équivalent Flutter : fl_chart)
   - Prochain entraînement planifié

Animations :
- Entrée en stagger (chaque carte apparaît avec 50 ms de décalage)
- Mise à jour des données avec transition fade (pas de clignotement)
- Pull-to-refresh avec indicateur personnalisé aux couleurs de Blocker

État de chargement : skeleton pour chaque section (BlockerLoadingSkeleton).
État vide : BlockerEmptyState avec message contextuel.
Dark mode obligatoire. Responsive (téléphone + tablette).
```

---

### Étape 1.6 — Agenda + Synchronisation calendrier

**Prompt :**
```
Tu es un expert Flutter. Implémente le module agenda de "Blocker" avec synchronisation Google Calendar.

Fonctionnalités :

1. Calendrier local :
   - Vue mois, semaine, jour (navigation tactile fluide)
   - Catégories colorées : Sport 🏃, Médical 🏥, Pro 💼, Scolaire 📚, Loisirs 🎭
   - Récurrences avancées : quotidien, hebdomadaire, mensuel (ex : 3e mardi du mois)
   - Tâches intégrées avec matrice d'Eisenhower (urgent/important)

2. Synchronisation Google Calendar :
   - OAuth2 (google_sign_in + googleapis)
   - Import des événements existants au premier lancement
   - Synchronisation bidirectionnelle (modifications locales → Google, et vice-versa)
   - Synchronisation Apple Calendar via CalDAV (iOS)

3. Lien avec le filtrage d'appels :
   - Événement marqué "Important" ou "Sport" → activation automatique du Mode Focus
   - Durée de blocage = durée de l'événement + 15 min de tampon

4. Rappels intelligents :
   - Calcul du temps de trajet (Google Maps Distance Matrix API)
   - Notification : "Partez dans X min pour arriver à l'heure"
   - Alerte météo si activité extérieure + pluie prévue (OpenWeatherMap API)

5. Mode Famille :
   - Agenda partagé (parent voit les événements de l'enfant)
   - Code couleur par membre de la famille
   - Notifications si l'enfant ajoute/modifie un événement

6. UI :
   - AgendaScreen avec vue calendrier + liste des prochains événements
   - AddEventScreen : formulaire complet (titre, catégorie, lieu, récurrence, participants)
   - TaskScreen : liste de tâches par quadrant (matrice d'Eisenhower)

Backend (FastAPI) : endpoints CRUD pour les événements, synchronisation des calendriers.
```

---

## PHASE 2 — Intelligence & IA

---

### Étape 2.1 — IA de détection spam (TensorFlow Lite)

**Prompt :**
```
Tu es un expert ML et Flutter. Implémente le système de détection de spam on-device pour "Blocker".

Architecture :

1. Modèle TensorFlow Lite (on-device) :
   - Modèle de classification binaire : spam / légitime
   - Features : indicatif pays, longueur du numéro, heure de l'appel, fréquence des appels récents, présence dans la base communautaire
   - Format : .tflite optimisé pour mobile (< 2 Mo)
   - Intégration Flutter : tflite_flutter
   - Inférence en < 50 ms (bien en dessous de la contrainte des 200 ms totaux)

2. Base communautaire :
   - API backend : GET /api/v1/spam/check?number=+33... → score + source
   - Mise à jour quotidienne du modèle local si nouvelle version disponible
   - Contribution utilisateur : POST /api/v1/spam/report (anonymisé)
   - Cache Redis côté backend pour les numéros fréquemment consultés

3. Score de confiance (0 à 100) :
   - 0-30 : 🔴 Très suspect (bloquer automatiquement si règle active)
   - 31-60 : 🟠 Incertain (afficher un avertissement)
   - 61-100 : 🟢 Probablement légitime (autoriser)

4. Affichage pendant l'appel entrant :
   - Bannière d'avertissement si score < 50 (couleur orange/rouge)
   - Nom/entreprise si identifié dans la base
   - Pays et indicatif de l'appelant
   - Bouton "Signaler comme spam"

5. Modèle backend (fallback cloud pour les modèles lourds) :
   - Endpoint POST /api/v1/spam/analyze : analyse approfondie via modèle cloud
   - Utilisé uniquement si le modèle local est incertain (score 40-60)
   - Rate limiting : max 50 appels/jour en version gratuite

Tests : jeu de test de 1 000 numéros (500 spam, 500 légitimes) — précision attendue > 85 %.
```

---

### Étape 2.2 — Filtrage WhatsApp Android

**Prompt :**
```
Tu es un expert Android natif et Flutter. Implémente le filtrage complet de WhatsApp sur Android pour "Blocker".

Approche technique :
- NotificationListenerService : intercepte les notifications WhatsApp
- Accessibilité Android (AccessibilityService) pour la suppression des notifications
- Aucun accès au contenu chiffré E2E de WhatsApp — analyse des métadonnées et des extraits de notification uniquement

À implémenter :

1. Service Android natif (Kotlin) :
   - WhatsAppNotificationService étend NotificationListenerService
   - Extraction : expéditeur, extrait du message (visible dans la notification), timestamp, type (message individuel / groupe)
   - Application des règles : contact bloqué → supprimer la notification + logger
   - Règles horaires : si heure hors plage autorisée → supprimer la notification
   - Alertes parent : si contenu contient mots-clés sensibles → push FCM au compte parent

2. Analyse NLP légère on-device :
   - Modèle TFLite de détection de contenu sensible (cyber-harcèlement, mots à risque)
   - Basé sur les extraits de notification (100-150 caractères max)
   - Faux positifs acceptables → notification parent pour validation humaine

3. Mode avion intelligent WhatsApp :
   - Via AccessibilityService : détecter et fermer l'app WhatsApp si hors plage horaire
   - Alternative : bloquer l'accès réseau de WhatsApp via VPN local (VpnService Android)
   - Préférer VPN local (plus fiable et moins intrusif que l'accessibilité)

4. Backend :
   - POST /api/v1/whatsapp/event : reçoit les événements filtrés (anonymisés)
   - POST /api/v1/whatsapp/alert : envoie une alerte parent via FCM
   - GET /api/v1/whatsapp/stats/{child_id} : statistiques hebdomadaires

5. UI (interface parent) :
   - WhatsAppRulesScreen : liste des contacts bloqués, plages horaires
   - WhatsAppStatsScreen : graphiques d'utilisation (fl_chart)
   - AlertHistoryScreen : historique des alertes avec validation parent

⚠️ Mention légale obligatoire dans l'onboarding : informer l'enfant de la supervision.
```

---

### Étape 2.3 — Geofencing avancé

**Prompt :**
```
Tu es un expert Flutter et géolocalisation. Implémente le geofencing avancé pour le contrôle parental de "Blocker".

Fonctionnalités :

1. Création de zones sécurisées :
   - Interface de dessin sur carte (cercle ou polygone, rayon min 50m)
   - Zones prédéfinies : Domicile, École, Club sportif, Chez grands-parents
   - Chaque zone a : nom, rayon, couleur, icône, plage horaire d'application
   - Limite version gratuite : 3 zones / enfant

2. Déclencheurs d'alertes :
   - Sortie de zone : notification push au parent en < 30 secondes
   - Entrée dans une zone inconnue (non sauvegardée) : alerte orange
   - Trajet inhabituel détecté (déviation > 500 m du trajet habituel) : alerte orange
   - Vitesse anormale (> 80 km/h alors qu'habituellement à pied) : alerte rouge

3. Historique & cartographie :
   - Tracé du parcours des 30 derniers jours sur carte (polyligne avec timestamps)
   - Heatmap des zones fréquentées
   - Export PDF du rapport mensuel (positions + alertes)

4. Architecture backend :
   - Service de geofencing côté serveur (calcul distance Haversine)
   - Worker Redis pour les vérifications périodiques de position
   - Webhook FCM déclenché si enfant hors zone
   - Table PostgreSQL : geofence_zones, geofence_events

5. Optimisation batterie :
   - Geofence natif Android (GeofencingClient) et iOS (CLRegion) — moins gourmands que le GPS continu
   - GPS haute précision activé uniquement si sortie de zone détectée

6. UI :
   - GeofenceMapScreen : carte avec toutes les zones dessinées
   - ZoneEditorScreen : création/édition d'une zone (dessin interactif)
   - AlertsScreen : historique des entrées/sorties de zones

Backend : endpoints CRUD zones + endpoint de réception des positions.
Tests : simulation de trajet avec 100 positions GPS → validation des alertes.
```

---

### Étape 2.4 — Analyse comportementale IA

**Prompt :**
```
Tu es un expert ML et Flutter. Implémente le système d'analyse comportementale IA pour "Blocker".

Objectif : détecter automatiquement les comportements anormaux de l'enfant et alerter le parent.

Algorithmes à implémenter (côté backend Python) :

1. Modèle de baseline comportementale :
   - Collecte de données sur 2 semaines pour établir la baseline (horaires habituels, lieux fréquentés, fréquence des communications)
   - Algorithme : Z-score + DBSCAN pour la détection d'anomalies de localisation
   - Mise à jour de la baseline chaque semaine (rolling window)

2. Détecteurs d'anomalies :
   - Horaire : appels/messages à des heures inhabituelles (> 2 écarts-types)
   - Géographique : déplacement vers lieu jamais visité avant 22h
   - Communication : nouvelle relation intense (> 20 messages/jour avec contact inconnu)
   - Contact suspect : écart d'âge anormal détecté si infos disponibles
   - Prédiction de fugue : algorithme basé sur pattern (retrait progressif, communications nocturnes, déplacements inhabituels)

3. Score de sécurité global (0-100) :
   - Agrégation pondérée des différents signaux
   - 🟢 70-100 : tout va bien
   - 🟠 40-69 : surveiller
   - 🔴 0-39 : alerte parent requise
   - Mise à jour quotidienne à minuit

4. Backend FastAPI :
   - Service comportemental (behaviour_service.py) avec analyse quotidienne (Celery + Redis)
   - POST /api/v1/behaviour/analyze/{child_id} : déclencher une analyse manuelle
   - GET /api/v1/behaviour/score/{child_id} : score actuel + facteurs
   - GET /api/v1/behaviour/anomalies/{child_id} : liste des anomalies récentes

5. UI Flutter (interface parent) :
   - BehaviourDashboard : score global avec gauge animée (fl_chart)
   - AnomalyList : liste des anomalies avec niveau de gravité
   - BehaviourTimeline : frise chronologique des événements suspects

Confidentialité : toutes les analyses se font sur des données agrégées, pas sur le contenu des messages.
```

---

## PHASE 3 — Fitness & performance

---

### Étape 3.1 — Traçage GPS & détection d'activité

**Prompt :**
```
Tu es un expert Flutter et fitness mobile. Implémente le module de traçage GPS et de détection d'activité pour "Blocker".

Fonctionnalités :

1. Enregistrement de séance :
   - Démarrage/arrêt manuel de l'enregistrement
   - Détection automatique d'activité via accéléromètre (pedometer + sensors_plus) :
     * Marche (< 7 km/h)
     * Course (7-20 km/h)
     * Vélo (> 20 km/h ou cadence de pédalage)
   - GPS haute précision pendant la séance (Kalman filter pour lisser le tracé)
   - Données collectées : distance, vitesse (min/moy/max), dénivelé, calories estimées, durée

2. Carte interactive de la séance :
   - Tracé coloré par vitesse (dégradé vert→amber→rouge)
   - Marqueurs : départ, arrivée, records de vitesse
   - Export GPX de la séance
   - Comparaison avec la même séance précédente (superposition)

3. Métriques en temps réel pendant la séance :
   - Overlay HUD : distance, vitesse actuelle, rythme au km, durée
   - Alertes vocales (TTS) : "5 km parcourus", "Rythme trop lent", etc.
   - Widget de veille : données visibles sans déverrouiller

4. Base de données locale des séances (SQLCipher) :
   - Table workout_sessions (métadonnées)
   - Table gps_points (points GPS bruts — compression après 30 jours)
   - Table workout_laps (tours automatiques tous les kilomètres)

5. Backend FastAPI :
   - POST /api/v1/workouts : sauvegarde séance (synchronisation cloud)
   - GET /api/v1/workouts/{user_id} : liste des séances
   - POST /api/v1/workouts/export/gpx : génère fichier GPX

6. UI :
   - WorkoutScreen : carte plein écran + HUD données pendant la séance
   - WorkoutSummaryScreen : résumé post-séance avec carte et graphiques
   - WorkoutHistoryScreen : liste des séances passées avec filtres

Optimisation batterie : GPS en haute précision uniquement pendant la séance active.
Tests : simulation de séance avec tracé GPS artificiel (100 points).
```

---

### Étape 3.2 — Cardio + Statistiques + Plans d'entraînement

**Prompt :**
```
Tu es un expert Flutter, fitness et data viz. Implémente les modules cardio, statistiques et planification d'entraînement pour "Blocker".

MODULE CARDIO :

1. Intégration Bluetooth (flutter_blue_plus) :
   - Scan et connexion aux capteurs BLE (profils GATT : Heart Rate Service 0x180D)
   - Compatible : Apple Watch (via HealthKit), Garmin, Fitbit, ceintures Polar/Garmin
   - Persistance de la connexion pendant toute la séance
   - Fallback : estimation FC via caméra (doigt sur flash — PPG via camera package)

2. Zones de fréquence cardiaque (5 zones) :
   - Calcul automatique basé sur FCmax = 220 - âge
   - Zone 1 : récupération (< 60 %)
   - Zone 2 : endurance (60-70 %)
   - Zone 3 : aérobie (70-80 %)
   - Zone 4 : seuil anaérobie (80-90 %)
   - Zone 5 : effort maximal (> 90 %)
   - Affichage temps passé par zone (graphique en barres)

MODULE STATISTIQUES (fl_chart) :

3. Graphiques à créer :
   - Courbe de distance hebdomadaire / mensuelle / annuelle (LineChart)
   - Histogramme des allures par séance (BarChart)
   - Graphique FC moyenne par séance (LineChart avec zones colorées)
   - Évolution du poids (si renseigné) (LineChart)
   - Radar de performance (vitesse, endurance, régularité, progression) (RadarChart)
   - Camembert temps passé par type d'activité (PieChart)

4. Records personnels :
   - Meilleur 5 km, 10 km, semi-marathon, marathon (temps et allure)
   - Comparaison avec semaine précédente
   - Prédiction marathon via formule Riegel : t2 = t1 × (d2/d1)^1.06

MODULE PLANS D'ENTRAÎNEMENT :

5. Générateur de plans :
   - Formulaire : objectif (perte de poids / 5K / 10K / semi / marathon), niveau (débutant / intermédiaire / avancé), disponibilité (jours/semaine), délai
   - Génération d'un plan sur 8-16 semaines avec périodisation (charge → décharge 3:1)
   - Types de séances : sortie longue, fractionné, tempo, récupération
   - Si séance manquée → recalcul automatique du plan

6. UI :
   - StatsScreen : tableau de bord fitness complet avec tous les graphiques
   - HeartRateScreen : moniteur FC temps réel + zones
   - TrainingPlanScreen : plan hebdomadaire avec détail des séances
   - RecordsScreen : palmarès personnel avec progression

Export : CSV (toutes les données), PDF (rapport mensuel), intégration Strava / Apple Health / Google Fit.
```

---

## PHASE 4 — Premium & déploiement

---

### Étape 4.1 — Système de monétisation (In-App Purchases)

**Prompt :**
```
Tu es un expert Flutter et monétisation mobile. Implémente le système d'abonnements in-app pour "Blocker".

Plans à implémenter :
- Premium Solo : 4,99 €/mois ou 49,99 €/an
- Premium Famille : 9,99 €/mois ou 99,99 €/an (jusqu'à 5 enfants)
- Premium Sport : 6,99 €/mois ou 69,99 €/an
- Licence à vie : 149,99 € (achat unique)

1. Intégration RevenueCat (purchases_flutter) :
   - Configuration iOS (StoreKit) + Android (Google Play Billing)
   - Entitlements : solo, famille, sport, lifetime
   - Vérification côté backend (webhook RevenueCat → FastAPI)
   - Gestion des restaurations d'achat

2. Paywall UI :
   - Écran de présentation des plans (carrousel des fonctionnalités)
   - Comparaison des plans (tableau claire)
   - Mise en avant du plan Famille (le plus rentable)
   - Trial gratuit 7 jours pour Premium Solo

3. Feature gating :
   - SubscriptionService : vérifie le plan actif avant d'accéder aux fonctionnalités premium
   - Afficher un prompt upgrade (non intrusif) si l'utilisateur tente d'accéder à une fonctionnalité payante
   - Version gratuite : blacklist 10 numéros, 1 enfant, 5 séances sport

4. Backend :
   - Webhook RevenueCat → validation et mise à jour de l'abonnement en BDD
   - Endpoint GET /api/v1/subscriptions/status : plan actif de l'utilisateur
   - Gestion des expirations et renouvellements

5. Conformité stores :
   - Mentions légales requises par Apple et Google
   - Politique de remboursement visible
   - Lien vers les conditions d'utilisation et la politique de confidentialité
```

---

### Étape 4.2 — Audit sécurité, RGPD & déploiement

**Prompt :**
```
Tu es un expert sécurité mobile et conformité RGPD. Effectue l'audit complet de sécurité de "Blocker" et prépare le déploiement.

AUDIT SÉCURITÉ :

1. Vérifications côté application mobile :
   - Certificate pinning (http_certificate_pinning) : empêche les attaques MITM
   - Vérification de l'intégrité de l'APK/IPA (détection de falsification)
   - Obfuscation du code Dart (--obfuscate --split-debug-info)
   - Détection du root/jailbreak (flutter_jailbreak_detection)
   - Effacement des données sensibles de la mémoire après utilisation

2. Vérifications côté backend :
   - Headers de sécurité HTTP (CSP, HSTS, X-Frame-Options, X-Content-Type)
   - Rate limiting (slowapi) sur tous les endpoints sensibles
   - Validation exhaustive des entrées (Pydantic + validation custom)
   - Audit des requêtes SQL (injection, N+1)
   - Rotation automatique des secrets (JWT, clés API)

3. Conformité RGPD :
   - Écran de consentement au premier lancement (granulaire : localisation, communications, analyse)
   - Droit à l'oubli : endpoint DELETE /api/v1/users/me (suppression de toutes les données)
   - Portabilité : export JSON de toutes les données utilisateur
   - Minimisation des données : ne collecter que le strict nécessaire
   - Registre des traitements documenté
   - DPO désigné (si applicable)

DÉPLOIEMENT APP STORE :

4. Apple App Store :
   - Checklist de soumission : icônes, captures d'écran, descriptions (FR/EN), mots-clés
   - Privacy Nutrition Label : déclarer tous les types de données collectées
   - Review Guidelines compliance : contrôle parental (catégorie 4+ et description claire)
   - TestFlight beta : 100 testeurs avant soumission officielle

5. Google Play Store :
   - Questionnaire sécurité des données (Data Safety)
   - Target API level 34 (Android 14)
   - Play Integrity API pour l'anti-tampering
   - Déclaration des permissions sensibles (localisation background, téléphone)

6. Monitoring post-lancement :
   - Sentry (sentry_flutter) pour le crash reporting
   - Firebase Analytics pour les métriques d'usage
   - Alertes automatiques si crash rate > 1 %

Génère aussi le document de politique de confidentialité complet (RGPD/CCPA) en français et en anglais.
```

---

## PROMPTS TRANSVERSAUX

---

### Prompt Design System — Nouveau composant

```
Tu es un expert Flutter et UI/UX. Crée un nouveau composant pour le design system de "Blocker".

Nom du composant : [NOM_DU_COMPOSANT]
Usage : [DESCRIPTION_DU_COMPOSANT]

Contraintes obligatoires :
- Dark mode (fond transparent, utiliser uniquement les tokens AppColors)
- Variantes : [LISTE_DES_VARIANTES]
- États : normal, hover (InkWell), loading, disabled, error
- Animation d'entrée : fade + slide-in 200 ms ease-out
- Accessibilité : Semantics widget, label ARIA, focusable au clavier
- Aucune couleur codée en dur
- Commentaires en français, code en anglais

Tokens à utiliser :
- AppColors.bgSurface pour le fond
- AppColors.borderDefault pour les bordures
- AppColors.textPrimary pour le texte principal
- AppColors.accentBlue pour les CTAs

Génère :
1. Le widget Flutter complet (Stateless ou Stateful selon le besoin)
2. Un exemple d'utilisation dans un écran test
3. La documentation du constructeur (paramètres, types, valeurs par défaut)
```

---

### Prompt Debug & révision de code

```
Tu es un expert Flutter/FastAPI. Analyse ce code et identifie les problèmes suivants :
1. Bugs potentiels (null safety, race conditions, fuites mémoire)
2. Problèmes de performance (requêtes N+1, rebuilds inutiles)
3. Failles de sécurité (injection, données en clair)
4. Non-respect du design system (couleurs codées en dur, composants non conformes)
5. Tests manquants pour la logique métier

Code à analyser :
[COLLER LE CODE ICI]

Pour chaque problème identifié :
- Décrire le problème et son impact
- Proposer la correction avec le code corrigé
- Indiquer la priorité (🔴 Critique / 🟠 Haute / 🟡 Moyenne)
```

---

### Prompt Tests automatisés

```
Tu es un expert en tests Flutter et Python. Crée une suite de tests complète pour le module suivant de "Blocker" :

Module : [NOM_DU_MODULE]
Fonctionnalité testée : [DESCRIPTION]

Crée :
1. Tests unitaires (couverture > 70 %) :
   - Logique métier pure (sans dépendances externes)
   - Cas nominaux + cas limites + cas d'erreur
   - Mocks des dépendances (mockito / pytest-mock)

2. Tests d'intégration :
   - Flux complet de bout en bout
   - Test de la base de données (base de test isolée)
   - Test des endpoints API (TestClient FastAPI / integration_test Flutter)

3. Tests de performance :
   - Mesure de la latence (si applicable)
   - Test de charge (locust pour l'API)

Format : un fichier de tests par couche (unit, integration, performance).
Chaque test doit avoir un nom descriptif en anglais et un commentaire en français.
```

---

### Prompt Revue de fin de sprint

```
Le sprint [NUMÉRO] de "Blocker" vient de se terminer.

Tâches réalisées : [LISTE]
Tâches non terminées : [LISTE]
Bugs découverts : [LISTE]
Points de vélocité : réalisés [X] / planifiés [Y]

En tant que Tech Lead, rédige :
1. Un bilan du sprint (points positifs, points à améliorer)
2. La mise à jour du fichier Blocker_Iterations.md pour ce sprint (statuts, métriques)
3. La mise à jour du fichier Blocker_Progression.md (avancement global, phase en cours)
4. Les ajustements éventuels pour le sprint suivant (scope, priorités)
5. Les risques identifiés et les actions de mitigation

Format : Markdown structuré, prêt à copier-coller dans les fichiers de suivi.
```

---

## Index des skills utilisés

| Skill | Usage dans le projet | Phases concernées |
|---|---|---|
| `ui-ux-pro-max` | Design system Flutter, tous les composants UI, dark mode, animations | Toutes |
| `frontend-design` | Choix esthétiques, typographie, palette de couleurs, layout | Phase 0, 1 |
| `docx` | Génération de rapports parentaux, exports PDF | Phase 2, 3 |
| `pdf` | Export des données fitness, politique de confidentialité | Phase 3, 4 |

---

*Ce fichier est le guide d'implémentation opérationnel de Blocker. Il doit être consulté avant chaque session de développement et mis à jour si les décisions techniques évoluent.*
