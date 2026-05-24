#Requires -Version 5.1
# ============================================================================
#  Save-Sprint-C2.ps1  (version 2, encodage UTF-8 BOM strict)
#
#  Sauvegarde le travail du Sprint C2 Harmony :
#  - Copie les 3 fichiers de suivi depuis le sous-dossier tracking/
#  - Commit propre sur Git
#  - Push vers GitHub origin/main
#  - Cree un tag annote v0.5.0-sprint-c2
#
#  Auteur : Architecte projet Harmony
#  Date   : 24 mai 2026
#  Usage  : Ouvrir PowerShell, se placer dans le dossier racine du projet :
#           cd "C:\Users\bkabe\Desktop\Harmony -mobile"
#           .\Save-Sprint-C2.ps1
#  Prerequis :
#    - git installe et dans le PATH
#    - Le dossier tracking/ doit contenir Harmony_Progression.md,
#      Harmony_Iterations.md, Harmony_Instructions_Prompts.md
# ============================================================================

# Force PowerShell a utiliser UTF-8 pour l'affichage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ---------- Configuration ---------------------------------------------------
$ErrorActionPreference = 'Stop'
$ProjectRoot      = (Get-Location).Path
$TrackingDir      = Join-Path $ProjectRoot 'tracking'
$SprintTag        = 'v0.5.0-sprint-c2'
$SprintCommitHash = 'd34ce4f'
$Today            = Get-Date -Format 'yyyy-MM-dd'
$Timestamp        = Get-Date -Format 'yyyyMMdd_HHmmss'

$TrackingFiles = @(
    'Harmony_Progression.md',
    'Harmony_Iterations.md',
    'Harmony_Instructions_Prompts.md'
)

# ---------- Helpers ---------------------------------------------------------
function Write-Step {
    param([string]$Message)
    Write-Host ''
    Write-Host "==> $Message" -ForegroundColor Cyan
    Write-Host ('-' * 70) -ForegroundColor DarkGray
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  [!]  $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "  [X]  $Message" -ForegroundColor Red
}

function Assert-Cmd {
    param([string]$Cmd)
    if (-not (Get-Command $Cmd -ErrorAction SilentlyContinue)) {
        Write-Err "$Cmd n'est pas installe ou pas dans le PATH."
        exit 1
    }
}

# ============================================================================
#  PHASE 0 - VERIFICATIONS
# ============================================================================
Write-Step 'Phase 0 - Verifications prealables'

Assert-Cmd 'git'
Write-Ok 'git detecte'

if (-not (Test-Path $ProjectRoot)) {
    Write-Err "Le dossier $ProjectRoot n'existe pas."
    exit 1
}
Write-Ok "Dossier projet : $ProjectRoot"

if (-not (Test-Path $TrackingDir)) {
    Write-Err "Le sous-dossier 'tracking' est introuvable : $TrackingDir"
    Write-Err "Place les 3 fichiers Markdown dans ce sous-dossier puis relance."
    exit 1
}
Write-Ok "Dossier tracking : $TrackingDir"

foreach ($f in $TrackingFiles) {
    $src = Join-Path $TrackingDir $f
    if (-not (Test-Path $src)) {
        Write-Err "Fichier source absent : $src"
        exit 1
    }
}
Write-Ok 'Les 3 fichiers source sont presents'

# Branche actuelle
$currentBranch = & git rev-parse --abbrev-ref HEAD
if ($currentBranch -ne 'main') {
    Write-Warn "Branche actuelle : $currentBranch (different de main)"
    Write-Host '    Bascule automatique vers main...' -ForegroundColor Yellow
    & git checkout main
    if ($LASTEXITCODE -ne 0) {
        Write-Err 'Impossible de basculer vers main. Annulation.'
        exit 1
    }
}
Write-Ok 'Branche : main'

# Repo propre ?
$status = & git status --porcelain
if ($status) {
    Write-Warn 'Le repo a des modifications non commitees :'
    Write-Host $status -ForegroundColor DarkGray
    $confirm = Read-Host '    Continuer quand meme ? (o/N)'
    if ($confirm -ne 'o') {
        Write-Err 'Annule par l utilisateur.'
        exit 1
    }
}

# ============================================================================
#  PHASE 1 - BACKUP LOCAL
# ============================================================================
Write-Step 'Phase 1 - Backup local des fichiers de suivi existants'

$backupDir = Join-Path $ProjectRoot ("backup_" + $Timestamp)
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

foreach ($f in $TrackingFiles) {
    $existing = Join-Path $ProjectRoot $f
    if (Test-Path $existing) {
        Copy-Item -LiteralPath $existing -Destination $backupDir -Force
        Write-Ok "Sauvegarde : $f"
    } else {
        Write-Warn "Pas de fichier existant a sauvegarder : $f"
    }
}

# ============================================================================
#  PHASE 2 - COPIE DES FICHIERS MIS A JOUR
# ============================================================================
Write-Step 'Phase 2 - Copie des fichiers de suivi mis a jour'

foreach ($f in $TrackingFiles) {
    $src = Join-Path $TrackingDir $f
    $dst = Join-Path $ProjectRoot $f

    # Lire avec UTF-8 et reecrire avec UTF-8 (sans BOM) pour eviter tout souci
    $content = Get-Content -LiteralPath $src -Raw -Encoding UTF8
    [System.IO.File]::WriteAllText($dst, $content, [System.Text.UTF8Encoding]::new($false))

    $sizeKB = [math]::Round((Get-Item $dst).Length / 1KB, 1)
    Write-Ok "$f mis a jour ($sizeKB KB)"
}

# ============================================================================
#  PHASE 3 - COMMIT + PUSH
# ============================================================================
Write-Step 'Phase 3 - Commit Git + Push GitHub'

$pendingChanges = & git status --porcelain
if (-not $pendingChanges) {
    Write-Warn 'Aucun changement detecte. Les fichiers sont deja a jour.'
    Write-Host '    Sortie sans erreur.' -ForegroundColor Yellow
    exit 0
}
Write-Ok 'Changements detectes'

# Stager uniquement les 3 fichiers de suivi
foreach ($f in $TrackingFiles) {
    & git add $f
}
Write-Ok 'Fichiers stages'

# Construire le message de commit (variables echappees pour les guillemets)
$commitTitle = "docs(tracking): mise a jour suivi projet apres Sprint C2"
$commitBody = @"
Synchronisation des 3 fichiers de reference apres livraison Sprint C2 (commit $SprintCommitHash) :

- Harmony_Progression.md :
  * Version 0.5.0 enregistree
  * Bilan Phase 0+ (UI premium) complet
  * ADR-010 a ADR-013 ajoutes
  * KPIs techniques mis a jour (52 tests, 0 issue analyze)
  * Critiques UX utilisateur tracees et adressees

- Harmony_Iterations.md :
  * Sprint C2 marque termine avec bilan complet (US-C2-001 a US-C2-013)
  * Sprint C3 (Voicemail) ajoute au backlog
  * Velocite moyenne calculee sur 6 derniers sprints : 12.7 pts
  * Reference des commits sur main listee

- Harmony_Instructions_Prompts.md :
  * Etat actuel du projet documente (v0.5.0)
  * Prompt Sprint C3 (Voicemail mockups) redige et pret a lancer
  * Prompt Sprint 1 (Android natif) reference pour la suite
  * Workflow Git formalise

Tests : 52 verts
Analyze : 0 issues
Langues : FR/EN/ES/PT/IT
Themes : System/Light/Dark

Date : $Today
"@

# Sauvegarder le message dans un fichier temporaire (evite les soucis de quoting)
$commitMsgFile = Join-Path $env:TEMP "harmony_commit_msg_$Timestamp.txt"
$fullMessage = $commitTitle + "`r`n`r`n" + $commitBody
[System.IO.File]::WriteAllText($commitMsgFile, $fullMessage, [System.Text.UTF8Encoding]::new($false))

& git commit -F $commitMsgFile
if ($LASTEXITCODE -ne 0) {
    Write-Err "Echec du commit (code $LASTEXITCODE)"
    Remove-Item -LiteralPath $commitMsgFile -Force -ErrorAction SilentlyContinue
    exit 1
}
Remove-Item -LiteralPath $commitMsgFile -Force -ErrorAction SilentlyContinue
Write-Ok 'Commit cree'

# Push vers origin/main
Write-Host '    Push vers origin/main...' -ForegroundColor DarkGray
& git push origin main
if ($LASTEXITCODE -eq 0) {
    Write-Ok 'Push reussi'
} else {
    Write-Err "Le push a echoue (code $LASTEXITCODE). Verifie tes credentials GitHub."
    exit 1
}

# ============================================================================
#  PHASE 4 - TAG DE VERSION
# ============================================================================
Write-Step "Phase 4 - Creation du tag $SprintTag"

# Verifier si le tag existe deja
$existingTag = & git tag -l $SprintTag
if ($existingTag) {
    Write-Warn "Le tag $SprintTag existe deja localement, suppression..."
    & git tag -d $SprintTag | Out-Null
}

$tagTitle = "Sprint C2 - Premium Polish + Light Mode + Contacts"
$tagBody = @"
Livraisons :
- ThemeCubit (system/light/dark) + persistance
- Light theme anti-fatigue (ivoire #FAF8F5)
- 4 nouveaux widgets (MetricCard, ThemeToggle, AudioWaveform, SearchBar)
- Refonte 4 widgets existants (Card, Badge, StatusDot, Button)
- Ecran Contacts (/contacts) avec recherche
- 12 cles i18n x 5 langues
- 52 tests verts, 0 issue analyze
- Commit principal : $SprintCommitHash

Date : $Today
"@

$tagMsgFile = Join-Path $env:TEMP "harmony_tag_msg_$Timestamp.txt"
$tagFullMessage = $tagTitle + "`r`n`r`n" + $tagBody
[System.IO.File]::WriteAllText($tagMsgFile, $tagFullMessage, [System.Text.UTF8Encoding]::new($false))

& git tag -a $SprintTag -F $tagMsgFile
if ($LASTEXITCODE -ne 0) {
    Write-Warn 'Echec creation du tag - non bloquant'
} else {
    Write-Ok "Tag $SprintTag cree localement"
}
Remove-Item -LiteralPath $tagMsgFile -Force -ErrorAction SilentlyContinue

# Push tag sur GitHub
Write-Host '    Push du tag vers origin...' -ForegroundColor DarkGray
& git push origin $SprintTag --force
if ($LASTEXITCODE -eq 0) {
    Write-Ok "Tag $SprintTag pousse sur GitHub"
} else {
    Write-Warn 'Push du tag a echoue - non bloquant'
}

# ============================================================================
#  RECAPITULATIF FINAL
# ============================================================================
Write-Host ''
Write-Host '=======================================================================' -ForegroundColor Green
Write-Host '  SAUVEGARDE SPRINT C2 TERMINEE AVEC SUCCES' -ForegroundColor Green
Write-Host '=======================================================================' -ForegroundColor Green
Write-Host ''

$lastCommit = & git log -1 --format='%h %s' main
Write-Host '  Dernier commit  : ' -NoNewline -ForegroundColor Cyan
Write-Host $lastCommit -ForegroundColor White

Write-Host '  Tag de version  : ' -NoNewline -ForegroundColor Cyan
Write-Host $SprintTag -ForegroundColor White

Write-Host '  Backup local    : ' -NoNewline -ForegroundColor Cyan
Write-Host "backup_$Timestamp" -ForegroundColor White

$remoteUrl = & git config --get remote.origin.url
Write-Host '  Repo GitHub     : ' -NoNewline -ForegroundColor Cyan
Write-Host $remoteUrl -ForegroundColor White

Write-Host ''
Write-Host '  Fichiers mis a jour :' -ForegroundColor Cyan
foreach ($f in $TrackingFiles) {
    Write-Host "    - $f" -ForegroundColor White
}
Write-Host ''
Write-Host '  Prochaine etape suggeree : Sprint C3 (Messagerie vocale)' -ForegroundColor Yellow
Write-Host '  Voir prompt dans Harmony_Instructions_Prompts.md' -ForegroundColor DarkGray
Write-Host ''
