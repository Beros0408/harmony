# ============================================================================
# HARMONY — Sauvegarde fin de journee 26 mai 2026
# Sprints livres : 3.3 (hotfix dark mode) + 5 (APIs reelles)
# ============================================================================

$env:Path += ";C:\src\flutter\bin;C:\Users\bkabe\AppData\Local\Android\Sdk\platform-tools"

Set-Location "C:\Users\bkabe\Desktop\Harmony -mobile"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  HARMONY — Sauvegarde Sprint 3.3 + Sprint 5" -ForegroundColor Cyan
Write-Host "  Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/6] Etat Git actuel" -ForegroundColor Yellow
git branch --show-current
git log --oneline -5
Write-Host ""

Write-Host "[2/6] Verification branche main" -ForegroundColor Yellow
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "  Pas sur main, switch en cours..." -ForegroundColor Yellow
    git checkout main
} else {
    Write-Host "  OK - Deja sur main" -ForegroundColor Green
}
Write-Host ""

Write-Host "[3/6] Verification des tags" -ForegroundColor Yellow
git fetch --tags 2>&1 | Out-Null
$localTags = git tag --list | Sort-Object -Descending | Select-Object -First 5
Write-Host "  Tags locaux (5 derniers) :" -ForegroundColor Cyan
$localTags | ForEach-Object { Write-Host "    $_" -ForegroundColor White }
Write-Host ""

Write-Host "[4/6] Push de securite vers origin" -ForegroundColor Yellow
git push origin main --tags 2>&1
Write-Host ""

Write-Host "[5/6] Verification des fichiers de suivi" -ForegroundColor Yellow
Copy-Item "Harmony_Iterations.md" "Harmony_Iterations.md.bak" -Force -ErrorAction SilentlyContinue
Copy-Item "Harmony_Progression.md" "Harmony_Progression.md.bak" -Force -ErrorAction SilentlyContinue
Write-Host "  OK - Backups crees (.bak)" -ForegroundColor Green

$progressionContent = Get-Content "Harmony_Progression.md" -Raw
if ($progressionContent -notmatch "v1\.4\.0-real-apis") {
    Write-Host "  ATTENTION - Sprint 5 pas encore documente" -ForegroundColor Yellow
} else {
    Write-Host "  OK - Harmony_Progression.md mentionne v1.4.0-real-apis" -ForegroundColor Green
}
Write-Host ""

Write-Host "[6/6] Rapport final" -ForegroundColor Yellow
Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "  SAUVEGARDE TERMINEE" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""

Write-Host "  Resume de la journee :" -ForegroundColor Cyan
Write-Host "    - Sprint 3.3 : Hotfix dark mode AppBar" -ForegroundColor White
Write-Host "    - Sprint 5   : JWT + Google Calendar + Contacts natifs" -ForegroundColor White
Write-Host ""

Write-Host "  Tags de la journee :" -ForegroundColor Cyan
Write-Host "    - v1.3.2-dark-mode-fix" -ForegroundColor White
Write-Host "    - v1.4.0-real-apis" -ForegroundColor White
Write-Host ""

Write-Host "  Commits recents :" -ForegroundColor Cyan
git log --oneline -5

Write-Host ""
Write-Host "  Repo GitHub : https://github.com/Beros0408/harmony" -ForegroundColor Cyan
Write-Host ""

$status = git status --short
if ([string]::IsNullOrEmpty($status)) {
    Write-Host "  OK - Working tree propre, tout est commite et pushe" -ForegroundColor Green
} else {
    Write-Host "  ATTENTION - Fichiers non commites detectes :" -ForegroundColor Yellow
    Write-Host $status -ForegroundColor White
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host "  Bonne nuit ! Repose-toi bien." -ForegroundColor Magenta
Write-Host "  Demain : tests contacts + Sprint 6 (WhatsApp)" -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Green
