# ============================================================================
# Save-Sprint-1.5-v2.ps1
# ----------------------------------------------------------------------------
# Version simplifiee et robuste du script de sauvegarde Sprint 1.5
# Pas de heredoc complexe, pas de table markdown dans le script
# ============================================================================

function Write-Step($message) {
    Write-Host ""
    Write-Host "=== $message ===" -ForegroundColor Cyan
}

function Write-OK($message) {
    Write-Host "[OK] $message" -ForegroundColor Green
}

function Write-Warn($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Write-Err($message) {
    Write-Host "[ERREUR] $message" -ForegroundColor Red
}

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# Phase 0 - Verifications
# ----------------------------------------------------------------------------
Write-Step "Phase 0 - Verifications"

$repoRoot = "C:\Users\bkabe\Desktop\Harmony -mobile"
Set-Location $repoRoot
Write-OK "Position : $repoRoot"

$currentBranch = git rev-parse --abbrev-ref HEAD
Write-OK "Branche actuelle : $currentBranch"

# ----------------------------------------------------------------------------
# Phase 1 - Mise a jour fichiers de suivi
# ----------------------------------------------------------------------------
Write-Step "Phase 1 - Mise a jour fichiers de suivi"

$today = Get-Date -Format "yyyy-MM-dd HH:mm"

# Bloc Progression - construit ligne par ligne pour eviter heredoc
$progressionLines = @()
$progressionLines += ""
$progressionLines += ""
$progressionLines += "## Sprint 1.5 - UI Blacklist interactive + Sync Flutter/Kotlin (TERMINE)"
$progressionLines += ""
$progressionLines += "- Date : $today"
$progressionLines += "- Tag : v1.1.1-blacklist-ui-sync"
$progressionLines += "- Branche : fix/sprint-1.5-blacklist-ui-sync"
$progressionLines += "- Tests Flutter : 117/117 verts"
$progressionLines += "- Tests Kotlin : 13/13 verts"
$progressionLines += "- flutter analyze : 0 issues"
$progressionLines += "- Lignes ajoutees : 1746"
$progressionLines += ""
$progressionLines += "### Livrables"
$progressionLines += ""
$progressionLines += "- DatabaseHelper SQLCipher singleton (harmony.db, AES-256)"
$progressionLines += "- BlacklistEntry model Equatable + BlockReason enum"
$progressionLines += "- BlacklistRepository CRUD complet + normalisation E.164"
$progressionLines += "- BlacklistCubit avec syncToNative automatique"
$progressionLines += "- BlacklistScreen route /blacklist + HarmonySearchBar + FAB"
$progressionLines += "- BlacklistFormSheet BottomSheet add/edit"
$progressionLines += "- CallFilterScreen tile tappable + compteur dynamique"
$progressionLines += "- 14 cles i18n x 5 langues (fr/en/es/pt/it)"
$progressionLines += ""
$progressionLines += "### Validation E2E en conditions reelles"
$progressionLines += ""
$progressionLines += "adb emu gsm call +33123456789"
$progressionLines += "  -> HarmonyCallScreening: Snapshot actif : blacklist=4"
$progressionLines += "  -> HarmonyCallScreening: Decision en 0ms : bloquer=true"
$progressionLines += "  -> Telecom: SCREENING_COMPLETED [Reject], mIsBlocked=true"
$progressionLines += "  -> Emulateur silencieux : aucune sonnerie, aucune notif"
$progressionLines += ""
$progressionLines += "KPI cahier des charges (latence < 200ms) : VALIDE a 0ms IRL (marge 200x)"
$progressionLines += ""

$progressionFile = "tracking\Harmony_Progression.md"
if (Test-Path $progressionFile) {
    $existing = Get-Content $progressionFile -Raw
    if ($existing -notmatch "Sprint 1\.5 - UI Blacklist interactive") {
        Add-Content -Path $progressionFile -Value ($progressionLines -join "`r`n") -Encoding UTF8
        Write-OK "Bloc Sprint 1.5 ajoute a $progressionFile"
    } else {
        Write-Warn "Sprint 1.5 deja present dans $progressionFile (ignore)"
    }
} else {
    Write-Warn "$progressionFile introuvable (ignore)"
}

# Bloc Iterations
$iterationLines = @()
$iterationLines += ""
$iterationLines += ""
$iterationLines += "## Mini-Sprint 1.5 - Blacklist UI + Sync natif"
$iterationLines += ""
$iterationLines += "- Date : $today"
$iterationLines += "- Branche : fix/sprint-1.5-blacklist-ui-sync"
$iterationLines += "- Tag : v1.1.1-blacklist-ui-sync"
$iterationLines += ""
$iterationLines += "### Objectif"
$iterationLines += ""
$iterationLines += "Boucler la chaine UI Flutter -> SQLCipher -> Kotlin natif pour blocage IRL."
$iterationLines += "Sprint 1 avait livre le natif (0ms latence) mais snapshot etait vide."
$iterationLines += ""
$iterationLines += "### Resultats"
$iterationLines += ""
$iterationLines += "- Tests Flutter : 117/117 verts"
$iterationLines += "- Tests Kotlin JUnit : 13/13 verts"
$iterationLines += "- flutter analyze : 0 issues"
$iterationLines += "- Lignes ajoutees : 1746"
$iterationLines += "- Fichiers modifies : 29"
$iterationLines += ""
$iterationLines += "### Validation E2E IRL"
$iterationLines += ""
$iterationLines += "Test reel sur emulateur Android Pixel 7 :"
$iterationLines += "- Ajout du numero +33123456789 via FAB BlacklistScreen"
$iterationLines += "- adb emu gsm call +33123456789"
$iterationLines += "- Logs Kotlin : Snapshot actif blacklist=4 + bloquer=true"
$iterationLines += "- Telecom : SCREENING_COMPLETED [Reject], mIsBlocked=true"
$iterationLines += "- Emulateur silencieux pendant toute la duree de l'appel"
$iterationLines += ""
$iterationLines += "KPI latence : 0ms (cahier des charges < 200ms) - marge 200x"
$iterationLines += ""

$iterationsFile = "tracking\Harmony_Iterations.md"
if (Test-Path $iterationsFile) {
    $existing = Get-Content $iterationsFile -Raw
    if ($existing -notmatch "Mini-Sprint 1\.5 - Blacklist UI") {
        Add-Content -Path $iterationsFile -Value ($iterationLines -join "`r`n") -Encoding UTF8
        Write-OK "Bloc Sprint 1.5 ajoute a $iterationsFile"
    } else {
        Write-Warn "Sprint 1.5 deja present dans $iterationsFile (ignore)"
    }
} else {
    Write-Warn "$iterationsFile introuvable (ignore)"
}

# ----------------------------------------------------------------------------
# Phase 2 - Commit des fichiers de suivi
# ----------------------------------------------------------------------------
Write-Step "Phase 2 - Commit des fichiers de suivi"

$status = git status --short
if ($status) {
    Write-OK "Changements detectes"
    git add tracking/

    $msg = "docs(tracking): Sprint 1.5 - Blacklist UI interactive + sync Kotlin`n`nE2E IRL valide: blocage effectif en conditions reelles`n- Snapshot Kotlin: blacklist=4 apres sync depuis Flutter`n- Decision en 0ms: bloquer=true pour +33123456789`n- Android Telecom: SCREENING_COMPLETED [Reject], mIsBlocked=true`n- Emulateur silencieux: aucune sonnerie, aucune notif`n`nTests: 117 Flutter + 13 Kotlin verts`nLignes ajoutees: 1746"

    git commit -m $msg
    Write-OK "Commit tracking cree"
} else {
    Write-Warn "Aucun changement a committer dans tracking/"
}

# ----------------------------------------------------------------------------
# Phase 3 - Merge sur main
# ----------------------------------------------------------------------------
Write-Step "Phase 3 - Merge sur main"

$branchToMerge = "fix/sprint-1.5-blacklist-ui-sync"

$branchExists = git branch --list $branchToMerge
if (-not $branchExists) {
    Write-Err "Branche $branchToMerge introuvable localement"
    exit 1
}

Write-OK "Bascule sur main"
git checkout main

Write-OK "Pull origin main"
git pull origin main

Write-OK "Merge --no-ff de $branchToMerge"
$mergeMsg = "Merge Sprint 1.5 - Blacklist UI interactive + sync Flutter/Kotlin`n`nTag: v1.1.1-blacklist-ui-sync`nBranche: $branchToMerge`n`nE2E IRL VALIDE: blocage effectif en conditions reelles`n- Snapshot Kotlin: blacklist=4 apres sync`n- Decision en 0ms: bloquer=true`n- Telecom: [Reject], mIsBlocked=true`n`nTests: 117 Flutter + 13 Kotlin verts"

git merge --no-ff $branchToMerge -m $mergeMsg
Write-OK "Merge effectue"

# ----------------------------------------------------------------------------
# Phase 4 - Push vers GitHub
# ----------------------------------------------------------------------------
Write-Step "Phase 4 - Push vers GitHub"

Write-OK "Push main + tags vers origin"
git push origin main --tags

Write-OK "Push effectue"

# ----------------------------------------------------------------------------
# Phase 5 - Verification
# ----------------------------------------------------------------------------
Write-Step "Phase 5 - Verification finale"

Write-Host ""
Write-Host "Derniers commits :" -ForegroundColor Cyan
git log --oneline -5

Write-Host ""
Write-Host "Tags recents :" -ForegroundColor Cyan
git tag --list "v*" | Sort-Object -Descending | Select-Object -First 5

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
Write-Host "Bonne nuit ! A demain pour Sprint 3." -ForegroundColor Yellow
Write-Host ""
