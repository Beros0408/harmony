# 🧭 Harmony — Instructions et Prompts par étape
> Guide d'implémentation complet · À utiliser avec Claude Code ou tout agent IA
> Référence : `CAHIER_DES_CHARGES_Harmony_Consolide.md` · Skills : `ui-ux-pro-max`, `frontend-design`
> Mise à jour : 24 mai 2026

---

## Comment utiliser ce fichier

1. **Suivre l'ordre des sprints** défini dans `Harmony_Iterations.md`
2. **Avant chaque étape**, lire la section correspondante ici
3. **Copier le prompt** associé et l'envoyer à Claude Code dans VS Code
4. **Valider les critères d'acceptation** avant de passer à l'étape suivante
5. **Mettre à jour** `Harmony_Progression.md` et `Harmony_Iterations.md` après chaque tâche (via script `Save-Sprint-CX.ps1`)

---

## État actuel du projet

| Élément | Valeur |
|---|---|
| Version | 0.5.0 — Sprint C2 livré |
| Dernier commit sur main | `d34ce4f` |
| Tests verts | 52 / 52 |
| Issues `flutter analyze` | 0 |
| Langues supportées | FR · EN · ES · PT · IT (5) |
| Thèmes supportés | System · Light · Dark |

---

## Stack technique (rappel)

```
Mobile      = Flutter 3.x (Dart) + bloc/cubit + go_router
Backend     = Python 3.12 + FastAPI + asyncpg + Redis
BDD         = PostgreSQL 16 + Redis 7
Sécurité    = SQLCipher (local), TLS 1.3 (réseau), AES-256
i18n        = flutter_localizations + intl 0.20.2 + ARB files
IA          = TensorFlow Lite (on-device) — à venir Phase 2
Design      = UI/UX Pro Max Skill (dark + light, tokens CSS)
CI/CD       = GitHub Actions (analyze, test, build Android, build iOS)
```

---

## Règles de qualité à respecter dans chaque prompt

- Dark mode + Light mode obligatoires (3 états : system/light/dark)
- Aucune couleur codée en dur — utiliser les tokens `AppColors`
- Chaque composant doit avoir un état chargement, vide et erreur
- Accessibilité WCAG 2.1 AAA visée (textes lisibles, contrastes 7:1+)
- Tests unitaires requis pour tout code métier (couverture supérieure à 70 %)
- Pas de type dynamique non contrôlé en Dart
- Commentaires en français, code en anglais
- Toutes les nouvelles chaînes UI traduites dans 5 langues (FR/EN/ES/PT/IT)
- Tout nouvel écran enfant doit utiliser `HarmonyAppBar` (back button auto)
- Tout sprint = nouvelle branche `feat/sprint-XX-description`, commit conventionnel, merge --no-ff sur main

---

## SPRINT C3 — Messagerie vocale + Transcriptions + Push (À LANCER) ⬜

**Objectif :** Implémenter l'écran Voicemail avec transcriptions mockées (anticipe Sprint 5 STT du cahier des charges) et simulation de push notification.

**Pré-requis :** Sprint C2 terminé (HarmonyAudioWaveform déjà créé).

**Prompt à coller dans Claude Code :**

```
SPRINT C3 — Écran Messagerie vocale + Transcriptions + Push (anticipation Sprint 5)

CONTEXTE :
Le cahier des charges Harmony section 3.1.1 décrit :
- Messagerie vocale intelligente : transcription automatique des messages vocaux (STT)
- Implémentation native du STT prévue au Sprint 5
- Mais l'utilisateur souhaite voir la maquette dès maintenant pour valider l'UX

OBJECTIF :
Créer la maquette complète et fonctionnelle de l'écran Messagerie vocale avec :
- 4 messages mockés avec transcriptions complètes
- Lecture audio simulée via HarmonyAudioWaveform (déjà créé au Sprint C2)
- Simulation de push notification au démarrage de l'écran
- Mention explicite que c'est un MOCKUP (vraie implémentation au Sprint 5)

PHASE 1 — STRUCTURE
- mobile/lib/features/voicemail/data/mock/voicemail_mocks.dart (modèle + 4 messages)
- mobile/lib/features/voicemail/presentation/screens/voicemail_screen.dart
- mobile/lib/features/voicemail/presentation/widgets/voicemail_item_card.dart
- Ajouter voicemail = '/voicemail' dans route_names.dart + app_router.dart

PHASE 2 — MODÈLE
enum VoicemailUrgency { low, normal, urgent }
class Voicemail { id, callerName, callerPhone, receivedAt, duration, transcription, shortPreview, isRead, urgency }

PHASE 3 — 4 MESSAGES MOCKÉS
1. Maman (-2h, normal, non lu) : "Salut mon chéri, c'est maman..."
2. Dr Dupont (hier 14:32, urgent, non lu) : "Bonjour, ici le cabinet du Dr Dupont. Nous confirmons votre rendez-vous..."
3. Numéro inconnu (-3j, low, lu) : "Bonjour, je vous appelle pour une offre exceptionnelle..."
4. Lucas (hier 17:45, normal, lu) : "Papa, c'est Lucas, je sors plus tard de l'école..."

NOTE : ajouter commentaire en tête de fichier indiquant que les transcriptions sont MOCKÉES (vraie STT au Sprint 5).

PHASE 4 — VoicemailItemCard
- HarmonyCard wrapper
- Header : Avatar 36x36 + nom + date relative + badge urgence si urgent
- Si non lu : dot bleu animate-ping
- Aperçu transcription : 2 lignes maxLines
- Footer : durée + 3 IconButtons (play, mark_read, delete)
- Au tap : AnimatedSize 300 ms pour expand vers transcription complète + HarmonyAudioWaveform + bouton Play 60x60 accentBlue

PHASE 5 — VoicemailScreen
- HarmonyAppBar "Messagerie vocale" + back button auto
- Header récap HarmonyMetricCard horizontal : "X nouveau(x)" + "Y au total" + icône Icons.notifications_active animée si non lus supérieurs à 0
- Liste verticale de VoicemailItemCard avec stagger 50 ms
- Info bar bottom : "Les nouveaux messages déclenchent une notification push (mockup)"

PHASE 6 — SIMULATION PUSH
Dans initState() : Timer 2 secondes vers AnimatedSnackBar custom EN HAUT :
- Background bgElevated + border accentBlue 1px
- Icon Icons.notifications_active rotation +5° -5° en boucle
- Title "Nouveau message vocal"
- Subtitle "Dr Dupont vient de laisser un message"
- Button "Voir" devient ferme et scroll vers le message
- Auto-dismiss 5 s
- Slide-in depuis le haut 300 ms easeOut
COMMENTAIRE : MOCKUP push. Vraie implémentation FCM/APNs au Sprint 5 (cahier section 4.1).

PHASE 7 — ACCÈS
- Depuis Sécurité : HarmonyListTile "Messagerie vocale" + HarmonyBadge "2 nouveaux" + chevron devient context.push('/voicemail')
- Depuis Dashboard : optionnel, carte module "Messagerie" (5e carte si layout le permet)

PHASE 8 — TRADUCTIONS (15 clés x 5 langues)
- voicemailScreenTitle, voicemailNewCount (ICU plural), voicemailTotal, voicemailPushInfo
- voicemailMarkRead, voicemailDelete, voicemailCallBack
- voicemailUrgent, voicemailNewMessageToastTitle, voicemailNewMessageToastBody (avec name placeholder)
- voicemailViewButton, voicemailTranscriptionLabel, voicemailExpandHint, voicemailMockNote

PHASE 9 — TESTS
- voicemail_mocks_test.dart (3 tests : count, urgency, isRead)
- voicemail_screen_test.dart (4 tests : affichage, expand, push toast, badge non lu)
- Objectif : 52 + 7 = 59 tests minimum

PHASE 10 — COMMIT
- Branche : feat/sprint-c3-voicemail-mockups
- Message conventionnel avec mention "anticipe Sprint 5 STT"
- Merge --no-ff sur main
- Push origin main

CONFIRMER chaque phase avec un check. Émettre à la fin un récap avec hash commit, tests, analyze, et notes éventuelles.
```

---

## SPRINT 1 — Filtrage appels Android natif (À LANCER ENSUITE) ⬜

**Objectif :** Implémenter le cœur métier — le filtrage natif des appels entrants/sortants sur Android via TelecomManager + Kotlin, avec latence inférieure à 200 ms.

**Pré-requis :**
- Device Android physique ou émulateur (Pixel 7 virtuel actif)
- Android Studio installé
- Kotlin connaissance basique
- Cahier des charges section 3.1.1 et 4 (architecture)

**Étapes principales :**
1. Configuration `AndroidManifest.xml` (permissions, services, broadcast receivers)
2. `CallScreeningService` en Kotlin (lecture blacklist locale via SQLCipher pont)
3. `MethodChannel` Flutter et Kotlin pour CRUD règles
4. UI Flutter pour gérer les règles (déjà ébauché Sprint B)
5. Tests latence sur 100 appels simulés (inférieur à 200 ms moyenne)
6. Audit batterie sur 24 h
7. Demande RoleManager pour devenir "Call Screening default app"

**Prompt complet à venir au moment du lancement.**

---

## SPRINT 2 — iOS CallKit + Listes avancées ⬜

Cf. cahier des charges. Adaptation iOS via CallKit (CXCallDirectoryProvider, asynchrone) + finitions blacklist/whitelist avancées avec plages horaires sophistiquées.

---

## SPRINTS 3 à 17 — Voir cahier des charges

Le détail est dans `Harmony_Iterations.md` et `CAHIER_DES_CHARGES_Harmony_Consolide.md`.

---

## PROMPTS TRANSVERSAUX

### Prompt fix rapide (1 bug)

```
FIX RAPIDE — [TITRE DU BUG]

CONTEXTE :
[Description du bug observé par l'utilisateur, fichier concerné, fonction concernée]

CORRECTION DEMANDÉE :
[Description précise de la solution attendue]

ÉTAPES :
1. Édite [fichier(s)]
2. Lance flutter analyze (doit rester 0 issues)
3. Lance flutter test (tous doivent passer)
4. Commit conventionnel :
   - git checkout -b fix/[nom-du-fix]
   - git add -A
   - git commit -m "fix([scope]): [description]"
   - git push -u origin fix/[nom-du-fix]
   - git checkout main et git merge --no-ff fix/[nom-du-fix]
   - git push origin main

CONFIRMER avec un check après chaque étape. Donner hash commit à la fin.
```

### Prompt design system — Nouveau composant

```
NOUVEAU WIDGET HARMONY — [NomDuWidget]

CONTRAINTES OBLIGATOIRES :
- Adaptatif dark + light (utiliser Theme.of(context).brightness)
- Aucune couleur hardcodée — utiliser AppColors
- Animation d'entrée 200 ms easeOut
- Accessibilité : Semantics + tooltip si interactif
- Tests unitaires (au moins 3)
- Code en anglais, commentaires en français
- Documentation du constructeur (paramètres, types, defaults)

À CRÉER :
- mobile/lib/shared/widgets/[snake_case_name].dart
- mobile/test/widgets/[snake_case_name]_test.dart
- Export depuis index si applicable
- Showcase dans Dashboard si pertinent
```

### Prompt revue de fin de sprint

```
REVUE FIN DE SPRINT — Sprint [LETTRE/NUMERO]

Le sprint vient de se terminer.

TÂCHES RÉALISÉES :
[Liste]

TÂCHES NON TERMINÉES (à reporter) :
[Liste]

BUGS DÉCOUVERTS :
[Liste]

MÉTRIQUES :
- Points planifiés : X
- Points réalisés : Y
- Tests verts : Z / Z
- Issues analyze : 0

RÉDIGE :
1. Un bilan honnête (positifs, points à améliorer)
2. La mise à jour de Harmony_Iterations.md (section sprint)
3. La mise à jour de Harmony_Progression.md (changelog + ADR si applicable)
4. Les ajustements pour le sprint suivant
5. Les risques identifiés et mitigations

Format : Markdown structuré, prêt à coller dans les fichiers.
```

---

## Skills utilisés

| Skill | Usage dans le projet | Phases concernées |
|---|---|---|
| `ui-ux-pro-max` | Design system Flutter, composants UI, dark + light mode, animations | Toutes |
| `frontend-design` | Choix esthétiques, typographie, palette couleurs, layout | Phase 0, UI premium |
| `docx` | Rapports parentaux, exports PDF | Phase 2, 3 |
| `pdf` | Export fitness, politique confidentialité | Phase 3, 4 |

---

## Workflow Git imposé

Chaque sprint :
1. Créer branche : `git checkout -b feat/sprint-XX-description`
2. Travailler sur la branche
3. Tests verts + 0 issues analyze
4. Commit conventionnel (feat/fix/chore + scope)
5. Push branche : `git push -u origin feat/sprint-XX-description`
6. Merge --no-ff sur main : `git checkout main` et `git merge --no-ff feat/sprint-XX-description`
7. Push main : `git push origin main`
8. Tag éventuel : `git tag -a vX.Y.Z -m "Sprint XX - Description"`
9. Mise à jour des fichiers de suivi via script `Save-Sprint-XX.ps1`

---

*Ce fichier est le guide d'implémentation opérationnel de Harmony. Il doit être consulté avant chaque session de développement et mis à jour si les décisions techniques évoluent. Dernière revue : 24 mai 2026 après livraison Sprint C2.*
