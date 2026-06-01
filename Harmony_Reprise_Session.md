# 🌿 Harmony — Résumé de reprise de session

> **À coller au début de chaque nouvelle conversation avec Claude.**
> Mettre à jour la section « État actuel » à la fin de chaque sprint.

---

## Le projet en bref

**Harmony** : application mobile **Flutter** (Android 10+ / iOS 16+) — filtrage appels/messages + contrôle parental + bien-être. Direction artistique « bien-être » douce et apaisante (style Calm / Headspace / Petit BamBou). 9 modules (M1 appels, M2 listes, M3 messages, M4 parental, M5 agenda, M6 fitness, M7 sécurité, M8 monétisation, M9 méditation).

> NB : les fichiers du cahier des charges portent l'ancien nom « Blocker », mais le projet s'appelle **Harmony** (nom de travail). Nom public à décider plus tard (candidats : « Kimia », « Harmony » — session branding dédiée à prévoir).

## Rôles

- **Moi (Beros)** : porteur du projet. Je teste sur émulateurs et lance les prompts dans Claude Code.
- **Toi (Claude, cette conversation)** : architecte. Tu prépares les prompts prêts à copier-coller pour Claude Code, tu me guides pas à pas, tu vérifies via mes captures d'écran.
- **Claude Code** : agent qui code dans les fichiers, fait commit + tag + push automatiquement à chaque sprint.

## Mes règles de travail

1. Tests **toujours sur émulateur** (vérification visuelle obligatoire).
2. Prompts Claude Code **prêts à copier-coller**. Messages de commit **courts, une seule ligne**.
3. Français irréprochable.
4. Distinguer la **Fenêtre A (backend uvicorn)** de la fenêtre `flutter run` — les erreurs backend sont dans la Fenêtre A.
5. Backend lancé **sans `--reload`** → **redémarrage manuel obligatoire** après chaque modif backend (Ctrl+C puis `uvicorn app.main:app --host 0.0.0.0`).
6. APK uniquement sur demande explicite.
7. **Économie de tokens** : nouvelle session Claude Code (`/clear`) à chaque sprint ; ne coller que les extraits utiles des logs (pas tout le déroulé) ; une seule capture par étape.

## Environnement technique

- Projet : `C:\Users\bkabe\Desktop\Harmony -mobile` (sous-dossiers `mobile/` Flutter, `backend/` FastAPI)
- Repo GitHub : `Beros0408/harmony` (PUBLIC — protéger les secrets)
- Flutter : `C:\src\flutter\bin`
- PATH à recoller dans chaque fenêtre PowerShell :
  `$env:Path += ";C:\src\flutter\bin;C:\Users\bkabe\AppData\Local\Android\Sdk\platform-tools;C:\Users\bkabe\AppData\Local\Android\Sdk\emulator"`
- **Deux émulateurs (réglés Android 14 API 34, fuseau Europe/Paris)** :
  - `Pixel_7` = `emulator-5554` → app PARENT (`lib/main.dart`)
  - `Pixel_6` = `emulator-5556` → app ENFANT (`lib/main_kids.dart`)
- Lancer un émulateur : `Start-Process emulator -ArgumentList "-avd Pixel_7"`
- Skill design : `/mnt/skills/user/ui-ux-pro-max/SKILL.md`

## Backend / Supabase

- Backend FastAPI ↔ **Supabase** (projet harmony-backend) + Vercel envisagé pour la prod.
- Connexion via **pooler** ; secrets dans `backend/.env` (gitignoré) et `INFORMATION HARMONY - SUPABASE.txt` (gitignoré).
- **Config DB critique** (`backend/app/core/database.py`) : `poolclass=NullPool` + `connect_args={"statement_cache_size":0, ...}` — résout le conflit « prepared statements » du pooler Supabase. NE PAS retirer.
- Tables : profiles, family_links, locations, call_rules, pairing_codes, device_commands, lock_schedules, (content_filter à venir Sprint C).
- Parent de test codé en dur : `dff545af-49e3-4250-b214-fe29e8bfa18f` (TODO : vraie auth).
- Enfants de test : Bjunior, Boubou, **Nora (`ee8625cd-3ae6-4afe-bff6-c2ce7df1f140`)**. **Le Pixel_6 est appairé à Nora.**

## Leçon technique clé (asyncpg)

asyncpg exige les **vrais types Python** comme paramètres, PAS des chaînes :
liste Python `[1,2,3]` (pas `'{1,2,3}'`), objet `datetime.time(19,59)` (pas `'19:59'`), UUID via `CAST(:x AS uuid)`. Pour les INSERT, laisser PostgreSQL inférer le type depuis la colonne (pas de CAST explicite pour time/array).

---

## ✅ État actuel (mis à jour le 31 mai 2026)

**Tag courant : v2.7.3-fix-pooler · 358 tests Flutter verts · ~78 issues analyze (baseline)**

### Terminé et testé visuellement
- **Sprint A — Appairage parent↔enfant** ✅ (code 6 chiffres, profil enfant + lien créés)
- **Sprint B1 — Verrouillage local** ✅ (mode admin Android DevicePolicyManager)
- **Sprint B2 — Verrouillage à distance** ✅ (parent → enfant, polling 15 s, table device_commands)
- **v2.6.2 — Vrais enfants Supabase** ✅ (fin des enfants fictifs Emma/Lucas)
- **Sprint B3 — Coucher automatique** ✅ (horaires planifiés, table lock_schedules, plages traversant minuit ; testé : le Pixel_6 se verrouille seul à l'heure programmée)

→ **TOUT LE SPRINT B EST BOUCLÉ.**

### Prochaine étape : Sprint C — Filtrage de contenu
- **Approche décidée** : DNS filtrant familial (via un `VpnService` local minimaliste qui ne redirige QUE le DNS, sans inspecter le trafic ni maintenir de blocklist maison) + SafeSearch forcé.
- **Contrôle** : le parent active/désactive depuis l'écran Détail de l'enfant (toggle).
- **Backend** : table/état `content_filter` (enabled on/off) ; mêmes conventions SQL ; même `get_db`/engine que les autres routeurs.
- **Enfant** : `VpnService` Kotlin (consentement VPN au 1er lancement) ; le polling existant lit l'état et démarre/arrête le filtrage.
- Tag prévu : v2.8.0-sprint-C-content-filter.
- *(Le prompt complet du Sprint C a été préparé dans la conversation précédente — le redemander à Claude si besoin.)*

### Dette technique à traiter (non urgent)
- Auth réelle (remplacer le parent codé en dur `dff545af-...`).
- Ménage des profils enfants de test en double.
- 3 écrans encore en mode sombre : child_detail, trip_history, sos_active.
- Session branding dédiée (choix du nom public).

### Roadmap après Sprint C
Sprint C+1 (VPN/filtrage avancé si besoin) → S10 sécurité → S11 IA → S12 fitness → S13 temps d'écran → S14 wearables → S15 RGPD → S16 onboarding → S17 publication stores.
