# Quality Gate — Verify fixes after code-review, track iterations
# Usage: .\quality-gate.ps1 [-ProjectPath "C:\path\to\project"]

param([string]$ProjectPath)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SESSION_FILE = "$ROOT_DIR\.opencode-session.json"

# ============================================================
# Resolve Project
# ============================================================

if (-not $ProjectPath) {
    try {
        if (Test-Path $SESSION_FILE) {
            $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
            if ($session.PSObject.Properties.Name -contains "current_project") { $ProjectPath = $session.current_project }
        }
    } catch {}
}

if (-not $ProjectPath) {
    Write-Host "[ERROR] No project path" -ForegroundColor Red; exit 1
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║         Quality Gate — $([System.IO.Path]::GetFileName($ProjectPath))$( ' ' * (28 - $([System.IO.Path]::GetFileName($ProjectPath)).Length))║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$totalIssues = 0
$fixedIssues = 0
$remainingIssues = 0

# ============================================================
# [1/5] Git status — check uncommitted changes
# ============================================================

Write-Host "[1/5] Git status..." -ForegroundColor Cyan
$gitDir = "$ProjectPath\.git"
if (Test-Path $gitDir) {
    $status = git -C $ProjectPath status --short 2>$null
    $modifiedFiles = ($status | Measure-Object).Count
    $stagedFiles = (git -C $ProjectPath diff --cached --name-only 2>$null | Measure-Object).Count

    if ($modifiedFiles -gt 0 -or $stagedFiles -gt 0) {
        Write-Host "  [OK] $modifiedFiles modified, $stagedFiles staged" -ForegroundColor Green
        $totalIssues += $modifiedFiles
    } else {
        Write-Host "  [INFO] No uncommitted changes" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [SKIP] Not a git repo" -ForegroundColor Yellow
}

# ============================================================
# [2/5] Flutter check
# ============================================================

Write-Host "[2/5] Build check..." -ForegroundColor Cyan
$pubspec = "$ProjectPath\pubspec.yaml"
$package = "$ProjectPath\package.json"

if (Test-Path $pubspec) {
    # Flutter
    $result = flutter analyze --no-pub --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] flutter analyze: clean ✅" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] flutter analyze: issues found" -ForegroundColor Yellow
        $remainingIssues++
    }
} elseif (Test-Path $package) {
    # JS/TS
    $hasTsc = (Get-Command "tsc" -ErrorAction SilentlyContinue) -ne $null
    if ($hasTsc) {
        $result = & npx --yes tsc --noEmit 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] tsc --noEmit: clean ✅" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] TypeScript errors found" -ForegroundColor Yellow
            $remainingIssues++
        }
    } else {
        Write-Host "  [SKIP] No TypeScript config found" -ForegroundColor Gray
    }
} else {
    Write-Host "  [SKIP] No known project type detected" -ForegroundColor Gray
}

# ============================================================
# [3/5] Test check
# ============================================================

Write-Host "[3/5] Test check..." -ForegroundColor Cyan
if (Test-Path $pubspec) {
    $result = flutter test --no-pub --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Tests passed ✅" -ForegroundColor Green
        $fixedIssues++
    } else {
        Write-Host "  [WARN] Tests failed" -ForegroundColor Yellow
        $remainingIssues++
    }
} elseif (Test-Path $package) {
    $npmTest = npm test 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Tests passed ✅" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Tests failed" -ForegroundColor Yellow
        $remainingIssues++
    }
} else {
    Write-Host "  [SKIP] No test framework detected" -ForegroundColor Gray
}

# ============================================================
# [4/5] Iteration tracking
# ============================================================

Write-Host "[4/5] Iteration tracking..." -ForegroundColor Cyan
$iterationFile = "$ROOT_DIR\.iteration.json"
$iteration = 1
if (Test-Path $iterationFile) {
    try {
        $iteration = (Get-Content $iterationFile -Raw | ConvertFrom-Json).count + 1
    } catch {}
}
@{ count = $iteration } | ConvertTo-Json | Set-Content -Path $iterationFile -Encoding UTF8

Write-Host "  [INFO] Attempt #$iteration" -ForegroundColor White

# ============================================================
# [5/5] Verdict
# ============================================================

Write-Host "[5/5] Verdict..." -ForegroundColor Cyan
Write-Host ""

if ($remainingIssues -eq 0) {
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║              QUALITY GATE PASSED ✅             ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  All checks passed after $iteration attempt(s)" -ForegroundColor White
    Write-Host "  Next: git add -A && git commit" -ForegroundColor Cyan
} else {
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "  ║           QUALITY GATE: $remainingIssues issue(s) ║" -ForegroundColor Yellow
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  $remainingIssues issue(s) remaining after $iteration attempt(s)" -ForegroundColor White
    Write-Host "  Iteration: attempt #$iteration" -ForegroundColor White
    Write-Host "  Next: fix issues then run /quality-gate again" -ForegroundColor Cyan
}

Write-Host ""
