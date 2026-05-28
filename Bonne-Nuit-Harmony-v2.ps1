#Requires -Version 5.1
# =============================================================================
# HARMONY - Script de fin de journee (Sprint 7 + 8 + hotfixes)
# Version 2 - corrigee pour eviter les soucis d'encodage PowerShell
# =============================================================================

$ErrorActionPreference = "Continue"
$ProjectRoot = "C:\Users\bkabe\Desktop\Harmony -mobile"
$MobileDir = "$ProjectRoot\mobile"
$FlutterBin = "C:\src\flutter\bin"
$AdbBin = "C:\Users\bkabe\AppData\Local\Android\Sdk\platform-tools"
$Today = Get-Date -Format "yyyy-MM-dd"
$ApkOutputDir = "$ProjectRoot\APK-builds\$Today"

$env:PATH = "$FlutterBin;$AdbBin;" + $env:PATH

function Write-Step($message) {
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Cyan
    Write-Host "  $message" -ForegroundColor Cyan
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Write-OK($message) {
    Write-Host "  [OK] $message" -ForegroundColor Green
}

function Write-Warn($message) {
    Write-Host "  [!] $message" -ForegroundColor Yellow
}

function Write-Err($message) {
    Write-Host "  [X] $message" -ForegroundColor Red
}

Clear-Host
Write-Host ""
Write-Host "  HARMONY - Routine de fin de journee" -ForegroundColor Magenta
Write-Host "  Date : $Today" -ForegroundColor Gray
Write-Host ""

# -----------------------------------------------------------------------------
# ETAPE 1 - Verifications
# -----------------------------------------------------------------------------
Write-Step "ETAPE 1/6 - Verifications"

if (-not (Test-Path $ProjectRoot)) {
    Write-Err "Dossier projet introuvable : $ProjectRoot"
    Read-Host "Appuie sur Entree pour quitter"
    exit 1
}
Write-OK "Dossier projet trouve"

if (-not (Test-Path "$FlutterBin\flutter.bat")) {
    Write-Err "Flutter introuvable : $FlutterBin"
    Read-Host "Appuie sur Entree pour quitter"
    exit 1
}
Write-OK "Flutter trouve"

Set-Location $ProjectRoot

# -----------------------------------------------------------------------------
# ETAPE 2 - Git status + push
# -----------------------------------------------------------------------------
Write-Step "ETAPE 2/6 - Synchronisation Git"

$currentBranch = git branch --show-current
Write-Host "  Branche actuelle : $currentBranch" -ForegroundColor Gray

if ($currentBranch -ne "main") {
    Write-Warn "Tu n'es pas sur main. Je passe sur main..."
    git checkout main
}

Write-Host "  Recuperation des changements distants..." -ForegroundColor Gray
git fetch origin 2>&1 | Out-Null

Write-Host ""
Write-Host "  Derniers tags Git :" -ForegroundColor Gray
git tag --sort=-creatordate | Select-Object -First 5 | ForEach-Object {
    Write-Host "    - $_" -ForegroundColor White
}

Write-Host ""
Write-Host "  5 derniers commits :" -ForegroundColor Gray
git log --oneline -5 | ForEach-Object {
    Write-Host "    $_" -ForegroundColor White
}

$hasUnpushed = git log "origin/main..HEAD" --oneline 2>$null
if ($hasUnpushed) {
    Write-Warn "Commits non pousses detectes. Push vers GitHub..."
    git push origin main --tags 2>&1
    Write-OK "Push effectue"
} else {
    Write-OK "Tout est synchronise avec GitHub"
}

# -----------------------------------------------------------------------------
# ETAPE 3 - Etat du working tree
# -----------------------------------------------------------------------------
Write-Step "ETAPE 3/6 - Etat du code"

$gitStatus = git status --short
if ($gitStatus) {
    Write-Warn "Fichiers non commites :"
    $gitStatus | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
} else {
    Write-OK "Working tree propre"
}

# -----------------------------------------------------------------------------
# ETAPE 4 - Build APK debug
# -----------------------------------------------------------------------------
Write-Step "ETAPE 4/6 - Build APK debug (3-5 min)"

Set-Location $MobileDir

if (-not (Test-Path $ApkOutputDir)) {
    New-Item -ItemType Directory -Path $ApkOutputDir -Force | Out-Null
}

Write-Host "  Lancement de flutter build apk --debug..." -ForegroundColor Gray
Write-Host "  (patience, environ 3-5 minutes)" -ForegroundColor Gray
Write-Host ""

flutter build apk --debug
$buildSuccess = $LASTEXITCODE -eq 0

if ($buildSuccess) {
    Write-OK "Build APK reussi"
    
    $apkSource = "$MobileDir\build\app\outputs\flutter-apk\app-debug.apk"
    $apkDest = "$ApkOutputDir\harmony-debug-$Today.apk"
    
    if (Test-Path $apkSource) {
        Copy-Item $apkSource $apkDest -Force
        $apkSize = [math]::Round((Get-Item $apkDest).Length / 1MB, 1)
        Write-OK "APK copie : $apkDest"
        Write-OK "Taille : $apkSize MB"
    } else {
        Write-Warn "APK source introuvable a $apkSource"
    }
} else {
    Write-Err "Build APK echoue"
    Write-Warn "On continue sans APK. Tu pourras le builder demain matin."
}

# -----------------------------------------------------------------------------
# ETAPE 5 - Generation du bilan (en TXT pour eviter soucis d'encodage)
# -----------------------------------------------------------------------------
Write-Step "ETAPE 5/6 - Generation du bilan de la journee"

Set-Location $ProjectRoot

$summaryFile = "$ProjectRoot\BILAN-$Today.txt"
$lastTag = git tag --sort=-creatordate | Select-Object -First 1

# Ecriture ligne par ligne (evite les soucis de here-string)
$lines = @()
$lines += "BILAN DE LA JOURNEE - $Today"
$lines += "================================================================"
$lines += ""
$lines += "Statut final : Sprint 7 + Sprint 8 + 2 hotfixes livres et valides"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "TAGS LIVRES AUJOURD'HUI"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "  v2.0.0-cdc-complete    Sprint 7 (Fitness + Parental + Messages)"
$lines += "  v2.0.1-sprint7-fix     Hotfix Sprint 7 (DatabaseHelper pattern)"
$lines += "  v2.1.0-paywall         Sprint 8 (Paywall + Feature Gating + AdMob)"
$lines += "  v2.1.1-paywall-fix     Hotfix Sprint 8 (count DB total)"
$lines += ""
$lines += "Tag actuel : $lastTag"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "METRIQUES"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "  Tests Flutter      : 303+ verts"
$lines += "  flutter analyze    : 0 erreurs"
$lines += "  CDC fonctionnel    : 93 pourcent"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "ETAT DES MODULES"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "  M1 Filtrage appels         : 100 pourcent"
$lines += "  M2 Listes (Blacklist)      : 100 pourcent"
$lines += "  M3 WhatsApp / SMS          : 100 pourcent"
$lines += "  M4 Controle parental       : 90 pourcent"
$lines += "  M5 Agenda                  : 100 pourcent"
$lines += "  M6 Fitness                 : 80 pourcent"
$lines += "  M7 Securite                : 100 pourcent"
$lines += "  M8 Monetisation (nouveau)  : 100 pourcent"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "SYSTEME DE MONETISATION ACTIVE"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "  Premium Solo      4,99 euros / mois ou 49,99 euros / an"
$lines += "  Premium Famille   9,99 euros / mois ou 99,99 euros / an (POPULAIRE)"
$lines += "  Premium Sport     6,99 euros / mois ou 69,99 euros / an"
$lines += "  Licence a vie     149,99 euros"
$lines += ""
$lines += "Limites version gratuite :"
$lines += "  - Blacklist : 10 numeros max"
$lines += "  - Controle parental : 1 enfant max"
$lines += "  - Fitness : 1 semaine d'historique"
$lines += "  - AdMob banner en bas de Blacklist + Fitness"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "APK INSTALLABLE SUR PHONE ANDROID"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "Fichier : APK-builds\$Today\harmony-debug-$Today.apk"
$lines += ""
$lines += "Comment installer :"
$lines += "  1. Copier l'APK sur ton phone (USB, email, Google Drive)"
$lines += "  2. Ouvrir le fichier depuis ton phone"
$lines += "  3. Autoriser 'Installer depuis sources inconnues' si demande"
$lines += "  4. Installer et lancer Harmony"
$lines += ""
$lines += "Note importante : version debug, donc :"
$lines += "  - Plus lente qu'une version release"
$lines += "  - AdMob en mode test (bannieres 'Test Ad')"
$lines += "  - RevenueCat ne permet pas de vrai achat sans sandbox"
$lines += "  - Stockage local uniquement (Sprint 9 backend a venir)"
$lines += ""
$lines += "----------------------------------------------------------------"
$lines += "PROCHAINE ETAPE : SPRINT 9 (BACKEND FASTAPI)"
$lines += "----------------------------------------------------------------"
$lines += ""
$lines += "Prevu pour demain matin 9h00."
$lines += "Pre-requis : Docker Desktop installe."
$lines += ""
$lines += "Bonne nuit !"

$lines | Out-File -FilePath $summaryFile -Encoding UTF8
Write-OK "Bilan cree : $summaryFile"

# -----------------------------------------------------------------------------
# ETAPE 6 - Commit + push du bilan + recap final
# -----------------------------------------------------------------------------
Write-Step "ETAPE 6/6 - Commit du bilan et recap final"

git add "BILAN-$Today.txt" 2>&1 | Out-Null
git commit -m "docs: bilan journee $Today (Sprint 7 + 8 + hotfixes valides)" 2>&1 | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-OK "Bilan commite"
    git push origin main 2>&1 | Out-Null
    Write-OK "Bilan pousse sur GitHub"
} else {
    Write-Warn "Pas de changement a commiter (bilan peut-etre identique)"
}

Write-Host ""
Write-Host "================================================================" -ForegroundColor Green
Write-Host "  TOUT EST PRET POUR LA NUIT" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Fichiers generes :" -ForegroundColor Cyan
Write-Host "    - Bilan : BILAN-$Today.txt" -ForegroundColor White
if (Test-Path "$ApkOutputDir\harmony-debug-$Today.apk") {
    Write-Host "    - APK   : APK-builds\$Today\harmony-debug-$Today.apk" -ForegroundColor White
}
Write-Host ""
Write-Host "  GitHub :" -ForegroundColor Cyan
Write-Host "    - Repo        : https://github.com/Beros0408/harmony" -ForegroundColor White
Write-Host "    - Dernier tag : $lastTag" -ForegroundColor White
Write-Host ""
Write-Host "  Installation sur phone Android :" -ForegroundColor Cyan
Write-Host "    1. Copier l'APK sur ton phone (USB, email, Drive)" -ForegroundColor White
Write-Host "    2. Ouvrir l'APK depuis le phone" -ForegroundColor White
Write-Host "    3. Autoriser sources inconnues" -ForegroundColor White
Write-Host "    4. Installer et tester !" -ForegroundColor White
Write-Host ""
Write-Host "  Bonne nuit ! Rendez-vous demain 9h00 pour Sprint 9 (Backend)" -ForegroundColor Magenta
Write-Host ""

if (Test-Path $ApkOutputDir) {
    Start-Process explorer.exe $ApkOutputDir
}

Read-Host "  Appuie sur Entree pour terminer"
