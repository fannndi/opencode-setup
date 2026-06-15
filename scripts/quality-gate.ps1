# Quality Gate — Verify fixes after code-review, track iterations
# Usage: .\quality-gate.ps1 [-ProjectPath "C:\path\to\project"]

param([string]$ProjectPath)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# Resolve Project
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
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

    $llmAnalysis = Invoke-LLMEnrich -Text "Git status: $modifiedFiles modified, $stagedFiles staged files in $ProjectPath" -Context "Quality gate"
    if ($llmAnalysis) {
        Write-Host "  [LLM] $llmAnalysis" -ForegroundColor Magenta
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
$buildResult = ""

if (Test-Path $pubspec) {
    $result = flutter analyze --no-pub --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] flutter analyze: clean ✅" -ForegroundColor Green
        $buildResult = "Flutter analyze passed"
    } else {
        Write-Host "  [WARN] flutter analyze: issues found" -ForegroundColor Yellow
        $remainingIssues++
        $buildResult = "Flutter analyze found issues"
    }
} elseif (Test-Path $package) {
    $hasTsc = (Get-Command "tsc" -ErrorAction SilentlyContinue) -ne $null
    if ($hasTsc) {
        $result = & npx --yes tsc --noEmit 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] tsc --noEmit: clean ✅" -ForegroundColor Green
            $buildResult = "TypeScript type check passed"
        } else {
            Write-Host "  [WARN] TypeScript errors found" -ForegroundColor Yellow
            $remainingIssues++
            $buildResult = "TypeScript type check found errors"
        }
    } else {
        Write-Host "  [SKIP] No TypeScript config found" -ForegroundColor Gray
        $buildResult = "No TS config, skipped"
    }
} else {
    Write-Host "  [SKIP] No known project type detected" -ForegroundColor Gray
    $buildResult = "No known project type, skipped"
}

$llmAnalysis = Invoke-LLMEnrich -Text "Build check result: $buildResult in $ProjectPath" -Context "Quality gate"
if ($llmAnalysis) {
    Write-Host "  [LLM] $llmAnalysis" -ForegroundColor Magenta
}

# ============================================================
# [3/5] Test check
# ============================================================

Write-Host "[3/5] Test check..." -ForegroundColor Cyan
$testResult = ""
if (Test-Path $pubspec) {
    $result = flutter test --no-pub --quiet 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Tests passed ✅" -ForegroundColor Green
        $fixedIssues++
        $testResult = "Flutter tests passed"
    } else {
        Write-Host "  [WARN] Tests failed" -ForegroundColor Yellow
        $remainingIssues++
        $testResult = "Flutter tests failed"
    }
} elseif (Test-Path $package) {
    $npmTest = npm test 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Tests passed ✅" -ForegroundColor Green
        $testResult = "npm tests passed"
    } else {
        Write-Host "  [WARN] Tests failed" -ForegroundColor Yellow
        $remainingIssues++
        $testResult = "npm tests failed"
    }
} else {
    Write-Host "  [SKIP] No test framework detected" -ForegroundColor Gray
    $testResult = "No test framework, skipped"
}

$llmAnalysis = Invoke-LLMEnrich -Text "Test check result: $testResult in $ProjectPath" -Context "Quality gate"
if ($llmAnalysis) {
    Write-Host "  [LLM] $llmAnalysis" -ForegroundColor Magenta
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
