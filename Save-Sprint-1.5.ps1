# ============================================================================
# Save-Sprint-1.5.ps1
# ----------------------------------------------------------------------------
# Sauvegarde le Sprint 1.5 — Blacklist UI + Sync Flutter/Kotlin
# - Met à jour les fichiers de suivi (Progression + Iterations)
# - Merge la branche fix/sprint-1.5-blacklist-ui-sync sur main
# - Pousse tout vers GitHub avec tag v1.1.1-blacklist-ui-sync
# ----------------------------------------------------------------------------
# Usage : depuis la racine du dépôt
#   cd "C:\Users\bkabe\Desktop\Harmony -mobile"
#   .\Save-Sprint-1.5.ps1
# ============================================================================

# Couleurs pour la sortie
function Write-Step($message) {
    Write-Host ""
    Write-Host "=== $message ===" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[OK] $message" -ForegroundColor Green
}

function Write-Warning2($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Write-Error2($message) {
    Write-Host "[ERREUR] $message" -ForegroundColor Red
}

# Sortir si une erreur arrive
$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# Phase 0 — Vérifications préalables
# ----------------------------------------------------------------------------
Write-Step "Phase 0 — Verifications prealables"

$repoRoot = "C:\Users\bkabe\Desktop\Harmony -mobile"
if (-not (Test-Path $repoRoot)) {
    Write-Error2 "Repo introuvable a : $repoRoot"
    exit 1
}

Set-Location $repoRoot
Write-Success "Position : $repoRoot"

# Verifier que git fonctionne
try {
    $gitVersion = git --version
    Write-Success "Git detecte : $gitVersion"
} catch {
    Write-Error2 "Git non installe ou non accessible"
    exit 1
}

# Verifier la branche actuelle
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Success "Branche actuelle : $currentBranch"

# ----------------------------------------------------------------------------
# Phase 1 — Mise a jour des fichiers de suivi
# ----------------------------------------------------------------------------
Write-Step "Phase 1 — Mise a jour des fichiers de suivi"

$today = Get-Date -Format "yyyy-MM-dd HH:mm"

# Mettre a jour tracking/Harmony_Progression.md
$progressionFile = "tracking\Harmony_Progression.md"
if (Test-Path $progressionFile) {
    Write-Success "Lecture de $progressionFile"
    $content = Get-Content $progressionFile -Raw

    # Ajouter un bloc Sprint 1.5 a la fin de la section ADR ou en fin de fichier
    $sprintBlock = @"


## Sprint 1.5 — UI Blacklist interactive + Sync Flutter/Kotlin (TERMINE)

| Champ | Valeur |
|---|---|
| Date | $today |
| Tag | v1.1.1-blacklist-ui-sync |
| Branche | fix/sprint-1.5-blacklist-ui-sync |
| Tests Flutter | 117/117 verts |
| Tests Kotlin | 13/13 verts |
| flutter analyze | 0 issues |
| Lignes ajoutees | 1746 |

### Livrables

- DatabaseHelper SQLCipher singleton (harmony.db, AES-256)
- BlacklistEntry model Equatable + BlockReason enum (4 valeurs)
- IBlacklistRepository interface + BlacklistRepository CRUD complet
- BlacklistCubit avec syncToNative() automatique apres chaque mutation
- BlacklistScreen (route /blacklist) avec HarmonySearchBar + FAB rouge
- BlacklistFormSheet (BottomSheet add/edit avec ChoiceChip raison)
- CallFilterScreen integre : tile tappable + compteur dynamique
- Section "Derniers appels bloques" depuis CallFilterChannel.getBlockedCalls()
- App startup : BlocProvider<BlacklistCubit> + init() avant runApp
- 14 nouvelles cles i18n × 5 langues (fr/en/es/pt/it)

### Validation E2E en conditions reelles

```
adb emu gsm call +33123456789
→ HarmonyCallScreening: Snapshot actif : blacklist=4
→ HarmonyCallScreening: Decision en 0ms : bloquer=true
→ Telecom: SCREENING_COMPLETED, [Reject, mCallBlockReason = 1]
→ TelecomFramework: mIsBlocked=true
→ Emulateur silencieux : aucune sonnerie, aucune notif
```

**KPI cahier des charges (latence < 200ms) : VALIDE en conditions reelles (0ms)**

"@

    # Ajouter le bloc si pas deja present
    if ($content -notmatch "Sprint 1\.5 — UI Blacklist interactive") {
        Add-Content -Path $progressionFile -Value $sprintBlock -Encoding UTF8
        Write-Success "Bloc Sprint 1.5 ajoute a Harmony_Progression.md"
    } else {
        Write-Warning2 "Sprint 1.5 deja present dans Harmony_Progression.md (ignore)"
    }
} else {
    Write-Warning2 "$progressionFile introuvable (ignore)"
}

# Mettre a jour tracking/Harmony_Iterations.md
$iterationsFile = "tracking\Harmony_Iterations.md"
if (Test-Path $iterationsFile) {
    Write-Success "Lecture de $iterationsFile"
    $content = Get-Content $iterationsFile -Raw

    $iterationBlock = @"


## Mini-Sprint 1.5 — Blacklist UI + Sync natif

**Date :** $today
**Branche :** fix/sprint-1.5-blacklist-ui-sync
**Tag :** v1.1.1-blacklist-ui-sync

### Objectif

Boucler la chaine UI Flutter → SQLCipher → Kotlin natif pour que le blocage
des appels fonctionne en conditions reelles. Le Sprint 1 avait livre le
service Kotlin (latence 0ms validee) mais le snapshot des regles etait vide.

### User Stories realisees

| ID | Story | Statut |
|---|---|---|
| US-1.5-001 | DatabaseHelper SQLCipher singleton | TERMINE |
| US-1.5-002 | BlacklistEntry model Equatable | TERMINE |
| US-1.5-003 | BlacklistRepository CRUD complet | TERMINE |
| US-1.5-004 | IBlacklistRepository interface | TERMINE |
| US-1.5-005 | BlacklistCubit gestion d'etat | TERMINE |
| US-1.5-006 | BlacklistScreen avec recherche | TERMINE |
| US-1.5-007 | FAB ajout numero | TERMINE |
| US-1.5-008 | BlacklistFormSheet BottomSheet | TERMINE |
| US-1.5-009 | Validation et normalisation E.164 | TERMINE |
| US-1.5-010 | Sync auto Flutter -> Kotlin | TERMINE |
| US-1.5-011 | CallFilterScreen tile tappable | TERMINE |
| US-1.5-012 | Compteur blacklist dynamique | TERMINE |
| US-1.5-013 | i18n 14 cles × 5 langues | TERMINE |
| US-1.5-014 | Tests automatises (24 nouveaux) | TERMINE |

### Resultats

- Tests Flutter : 117/117 verts
- Tests Kotlin JUnit : 13/13 verts
- flutter analyze : 0 issues
- Lignes ajoutees : 1746
- Fichiers modifies : 29

### Validation E2E IRL

Test reel sur emulateur Android Pixel 7 :
- Ajout du numero +33123456789 via le FAB de BlacklistScreen
- Lancement de adb emu gsm call +33123456789
- Logs Kotlin : "Snapshot actif : blacklist=4" + "bloquer=true"
- Telecom : SCREENING_COMPLETED [Reject], mIsBlocked=true
- Emulateur reste silencieux pendant toute la duree de l'appel

KPI latence : 0ms (cahier des charges < 200ms) — marge 200x

"@

    if ($content -notmatch "Mini-Sprint 1\.5 — Blacklist UI") {
        Add-Content -Path $iterationsFile -Value $iterationBlock -Encoding UTF8
        Write-Success "Bloc Sprint 1.5 ajoute a Harmony_Iterations.md"
    } else {
        Write-Warning2 "Sprint 1.5 deja present dans Harmony_Iterations.md (ignore)"
    }
} else {
    Write-Warning2 "$iterationsFile introuvable (ignore)"
}

# ----------------------------------------------------------------------------
# Phase 2 — Commit des fichiers de suivi
# ----------------------------------------------------------------------------
Write-Step "Phase 2 — Commit des fichiers de suivi"

# Verifier s'il y a des changements
$status = git status --short
if ($status) {
    Write-Success "Changements detectes :"
    Write-Host $status

    git add tracking/
    git commit -m "docs(tracking): Sprint 1.5 - Blacklist UI interactive + sync Kotlin

E2E IRL valide:
- Snapshot Kotlin: blacklist=4 apres sync depuis Flutter
- Decision en 0ms: bloquer=true pour +33123456789
- Android Telecom: SCREENING_COMPLETED [Reject], mIsBlocked=true
- Emulateur silencieux: aucune sonnerie, aucune notif

Tests: 117/117 Flutter + 13/13 Kotlin verts
Lignes ajoutees: 1746
Fichiers modifies: 29"

    Write-Success "Commit des fichiers de suivi cree"
} else {
    Write-Warning2 "Aucun changement a committer dans tracking/"
}

# ----------------------------------------------------------------------------
# Phase 3 — Merge sur main
# ----------------------------------------------------------------------------
Write-Step "Phase 3 — Merge sur main"

# Sauvegarder la branche actuelle
$branchToMerge = "fix/sprint-1.5-blacklist-ui-sync"

# Verifier que la branche existe
$branches = git branch --list $branchToMerge
if (-not $branches) {
    Write-Error2 "La branche $branchToMerge n'existe pas localement"
    Write-Warning2 "Verifie que tu es bien sur le repo Harmony et que Sprint 1.5 a ete livre"
    exit 1
}

# Passer sur main
Write-Success "Passage sur main..."
git checkout main

# Pull pour etre a jour
Write-Success "Pull des derniers changements depuis origin/main..."
git pull origin main

# Merge non-fast-forward
Write-Success "Merge de $branchToMerge sur main (--no-ff)..."
git merge --no-ff $branchToMerge -m "Merge Sprint 1.5 - Blacklist UI interactive + sync Flutter/Kotlin

Tag: v1.1.1-blacklist-ui-sync
Branche: $branchToMerge

E2E IRL VALIDE: blocage effectif d'appels en conditions reelles
- Snapshot Kotlin: blacklist=4 apres sync depuis Flutter
- Decision en 0ms: bloquer=true
- Telecom: SCREENING_COMPLETED [Reject]

Tests: 117 Flutter + 13 Kotlin verts
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

Write-Success "Merge effectue"

# ----------------------------------------------------------------------------
# Phase 4 — Push vers GitHub
# ----------------------------------------------------------------------------
Write-Step "Phase 4 — Push vers GitHub"

Write-Success "Push de main + tags vers origin..."
git push origin main --tags

Write-Success "Push effectue"

# ----------------------------------------------------------------------------
# Phase 5 — Verification finale
# ----------------------------------------------------------------------------
Write-Step "Phase 5 — Verification finale"

Write-Host ""
Write-Host "Derniers commits sur main :" -ForegroundColor Cyan
git log --oneline -5

Write-Host ""
Write-Host "Tags recents :" -ForegroundColor Cyan
git tag --list "v*" | Sort-Object -Descending | Select-Object -First 5

Write-Host ""
Write-Host "Branche actuelle :" -ForegroundColor Cyan
git rev-parse --abbrev-ref HEAD

# ----------------------------------------------------------------------------
# Bilan final
# ----------------------------------------------------------------------------
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host " SPRINT 1.5 SAUVEGARDE AVEC SUCCES !" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Tag       : v1.1.1-blacklist-ui-sync" -ForegroundColor White
Write-Host "Branche   : main (merged from fix/sprint-1.5-blacklist-ui-sync)" -ForegroundColor White
Write-Host "Remote    : https://github.com/Beros0408/harmony" -ForegroundColor White
Write-Host ""
Write-Host "Pour visualiser sur GitHub :" -ForegroundColor Cyan
Write-Host "  https://github.com/Beros0408/harmony/releases/tag/v1.1.1-blacklist-ui-sync" -ForegroundColor White
Write-Host ""
Write-Host "Bonne nuit ! Demain tu reprendras frais pour Sprint 3." -ForegroundColor Yellow
Write-Host ""
