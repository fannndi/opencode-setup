# Admin Update — Pull repos, changelog, rebuild, doctor check
# Usage:
#   .\admin-update.ps1              # Full: pull + changelog + rebuild + doctor
#   .\admin-update.ps1 --doctor     # Doctor check only

param(
    [switch]$Doctor
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$ECC_DIR = "$ROOT_DIR\ecc"
$ROUTER_DIR = "$ROOT_DIR\9router"
$SYNC_STATE = "$ROOT_DIR\.sync-state.json"
$ADMIN_LOG = "$ROOT_DIR\log-admin.md"
$API_URL = "http://localhost:20128"
$API_PASS = "123456"

# Source LLM adapter (optional, graceful fallback)
try { . "$PSScriptRoot\llm-adapter.ps1" } catch {}

# ============================================================
# Helpers
# ============================================================

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host ""
    Write-Host "[$Step] $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  [SKIP] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Gray
}

function Write-Changelog {
    param([string]$Repo, [string]$BeforeSHA, [string]$AfterSHA, [string]$Dir)

    if ($BeforeSHA -eq $AfterSHA) {
        Write-OK "${Repo}: up to date"
        return @{ commits = 0; opencode = 0; breaking = 0; setup = 0 }
    }

    Write-OK "${Repo} updated: $($BeforeSHA.Substring(0,7)) -> $($AfterSHA.Substring(0,7))"

    $allCommits = git -C $Dir log "$BeforeSHA..$AfterSHA" --format="%H|%ai|%an|%s" 2>$null
    $commitList = @()
    $opencodeCount = 0
    $breakingCount = 0
    $setupCount = 0

    foreach ($line in $allCommits) {
        $parts = $line -split '\|', 4
        if ($parts.Length -ge 4) {
            $sha = $parts[0].Substring(0,7)
            $date = $parts[1].Split(' ')[0]
            $author = $parts[2]
            $msg = $parts[3]

            # Categorize
            $tag = ""
            if ($msg -match "(?i)(opencode|plugin|\.opencode|build:opencode)") {
                $tag = "[plugin]"
                $opencodeCount++
            }
            elseif ($msg -match "(?i)(setup|install|profile)") {
                $tag = "[setup]"
                $setupCount++
            }
            elseif ($msg -match "(?i)(breaking|deprecat|remove)") {
                $tag = "[breaking]"
                $breakingCount++
            }
            elseif ($msg -match "(?i)(skill|SKILL\.md|agent)") {
                $tag = "[skill]"
            }
            elseif ($msg -match "(?i)(config|opencode\.json|settings)") {
                $tag = "[config]"
            }
            else {
                $tag = "[info]"
            }

            $color = switch ($tag) {
                "[plugin]"   { "Yellow" }
                "[setup]"    { "Yellow" }
                "[breaking]" { "Red" }
                "[skill]"    { "Green" }
                "[config]"   { "Yellow" }
                default      { "Gray" }
            }

            Write-Host "    $sha $author $msg " -NoNewline -ForegroundColor Gray
            Write-Host $tag -ForegroundColor $color

            $commitList += @{ sha = $sha; date = $date; author = $author; msg = $msg; tag = $tag }
        }
    }

    $count = ($allCommits | Measure-Object).Count
    Write-Host ""

    return @{ commits = $count; opencode = $opencodeCount; breaking = $breakingCount; setup = $setupCount; list = $commitList }
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host "   Admin Update" -ForegroundColor Magenta
Write-Host "  ========================================" -ForegroundColor Magenta
Write-Host ""

if ($Doctor) {
    Write-Host "  Mode: DOCTOR ONLY" -ForegroundColor Yellow
} else {
    Write-Host "  Mode: FULL (pull + changelog + rebuild + doctor)" -ForegroundColor Yellow
}
Write-Host ""

# ============================================================
# [1/9] LLM CHECK
# ============================================================

Write-Step "1/9" "LLM check (9Router)..."

try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -TimeoutSec 5
    if ($health.ok) { Write-OK "9Router: running" }
    else { Write-Fail "9Router: health check failed" }
} catch {
    Write-Fail "9Router: not running"
}

try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" `
        -Method POST `
        -Body "{`"password`":`"$API_PASS`"}" `
        -ContentType "application/json" `
        -SessionVariable httpSession | Out-Null
    $combos = Invoke-RestMethod -Uri "$API_URL/api/combos" -WebSession $httpSession
    $comboNames = $combos.combos | ForEach-Object { $_.name }
    Write-OK "Combos: $($comboNames -join ', ')"
} catch {
    Write-Fail "Combos: unable to verify"
}

if ($Doctor) { Write-Info "Skipping pull (doctor mode)"; Write-Host "" }

# ============================================================
# [2/9] PULL ECC
# ============================================================

$eccBefore = ""
$eccAfter = ""
$eccStats = @{ commits = 0; opencode = 0; breaking = 0; setup = 0 }

if (-not $Doctor) {
    Write-Step "2/9" "Pull ECC..."

    if (Test-Path "$ECC_DIR\.git") {
        $eccBefore = git -C $ECC_DIR log -1 --format="%H" 2>$null
        git -C $ECC_DIR pull --quiet 2>$null
        $eccAfter = git -C $ECC_DIR log -1 --format="%H" 2>$null
        $eccStats = Write-Changelog "ECC" $eccBefore $eccAfter $ECC_DIR
    } else {
        Write-Skip "ECC not cloned. Run setup.ps1 first"
    }
} else {
    $eccAfter = git -C $ECC_DIR log -1 --format="%H" 2>$null
}

# ============================================================
# [3/9] PULL 9ROUTER
# ============================================================

$routerBefore = ""
$routerAfter = ""
$routerStats = @{ commits = 0; opencode = 0; breaking = 0; setup = 0 }

if (-not $Doctor) {
    Write-Step "3/9" "Pull 9Router..."

    if (Test-Path "$ROUTER_DIR\.git") {
        $routerBefore = git -C $ROUTER_DIR log -1 --format="%H" 2>$null
        git -C $ROUTER_DIR pull --quiet 2>$null
        $routerAfter = git -C $ROUTER_DIR log -1 --format="%H" 2>$null
        $routerStats = Write-Changelog "9Router" $routerBefore $routerAfter $ROUTER_DIR
    } else {
        Write-Skip "9Router not cloned. Run setup.ps1 first"
    }
} else {
    $routerAfter = git -C $ROUTER_DIR log -1 --format="%H" 2>$null
}

# ============================================================
# [4/9] ANALYZE CHANGES
# ============================================================

Write-Step "4/9" "Analyze changes..."

$needsRework = $false
$needsRebuild = $false

# ECC analysis
if ($eccStats.commits -gt 0) {
    if ($eccStats.setup -gt 0) {
        Write-Host "    ECC:      [!] SETUP changes detected - re-run /setup recommended" -ForegroundColor Yellow
        $needsRework = $true
    }
    if ($eccStats.opencode -gt 0) {
        Write-Host "    ECC:      [PLUGIN] PLUGIN changes detected - rebuild needed" -ForegroundColor Yellow
        $needsRebuild = $true
    }
    if ($eccStats.breaking -gt 0) {
        Write-Host "    ECC:      [BREAKING] BREAKING changes detected - manual review needed" -ForegroundColor Red
        $needsRework = $true
    }
    if ($eccStats.setup -eq 0 -and $eccStats.opencode -eq 0 -and $eccStats.breaking -eq 0) {
        Write-OK "ECC: no action needed"
    }
} else {
    Write-OK "ECC: no changes"
}

# 9Router analysis
if ($routerStats.commits -gt 0) {
    if ($routerStats.setup -gt 0) {
        Write-Host "    9Router: [!] SETUP changes detected" -ForegroundColor Yellow
        $needsRework = $true
    }
    if ($routerStats.breaking -gt 0) {
        Write-Host "    9Router: [BREAKING]  BREAKING changes detected" -ForegroundColor Red
        $needsRework = $true
    }
    if ($routerStats.setup -eq 0 -and $routerStats.breaking -eq 0) {
        Write-OK "9Router: no action needed"
    }
} else {
    Write-OK "9Router: no changes"
}

# ============================================================
# [5/9] REBUILD PLUGIN
# ============================================================

Write-Step "5/9" "Rebuild plugin..."

$pluginRebuilt = $false

if ($needsRebuild -and (Test-Path "$ECC_DIR\.git")) {
    Write-Info "Opencode changes detected, rebuilding..."
    Push-Location $ECC_DIR

    if (-not (Test-Path "node_modules")) {
        Write-Info "Installing root dependencies..."
        npm install --silent 2>$null
    }
    if (-not (Test-Path ".opencode\node_modules")) {
        Write-Info "Installing .opencode dependencies..."
        Push-Location ".opencode"
        npm install --silent 2>$null
        Pop-Location
    }

    npm run build:opencode 2>$null
    if (Test-Path ".opencode\dist\index.js") {
        Write-OK "Plugin rebuilt"
        $pluginRebuilt = $true
    } else {
        Write-Fail "Plugin build failed"
    }

    Pop-Location
} else {
    Write-OK "No rebuild needed"
}

# ============================================================
# [6/9] DOCTOR CHECK
# ============================================================

Write-Step "6/9" "Doctor check..."

$doctorIssues = 0

# ECC structure
$eccSkills = Get-ChildItem "$ECC_DIR\skills" -Directory -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
$eccAgents = Get-ChildItem "$ECC_DIR\.opencode\prompts\agents" -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
if ($eccSkills -gt 0) { Write-OK "ECC: $eccSkills skills, $eccAgents agents" }
else { Write-Fail "ECC: skills missing!"; $doctorIssues++ }

# ECC commands
$eccCommands = Get-ChildItem "$ECC_DIR\.opencode\commands" -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
Write-OK "ECC commands: $eccCommands"

# 9Router health
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -TimeoutSec 5
    if ($health.ok) { Write-OK "9Router: running" }
    else { Write-Fail "9Router: health check failed"; $doctorIssues++ }
} catch {
    Write-Fail "9Router: not running"; $doctorIssues++
}

# Combos
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" `
        -Method POST `
        -Body "{`"password`":`"$API_PASS`"}" `
        -ContentType "application/json" `
        -SessionVariable httpSession | Out-Null
    $combos = Invoke-RestMethod -Uri "$API_URL/api/combos" -WebSession $httpSession
    Write-OK "Combos: $($combos.combos.Count) active"
} catch {
    Write-Fail "Combos: unable to verify"; $doctorIssues++
}

# Config
$configExists = Test-Path "$env:USERPROFILE\.config\opencode\opencode.jsonc"
if ($configExists) { Write-OK "Config: exists" }
else { Write-Fail "Config: missing"; $doctorIssues++ }

# API key
$envKey = [Environment]::GetEnvironmentVariable('NINEROUTER_API_KEY', 'User')
if ($envKey -and $envKey -ne 'SET-YOUR-KEY-FROM-DASHBOARD' -and $envKey -ne '') {
    Write-OK "NINEROUTER_API_KEY: set"
} else {
    Write-Fail "NINEROUTER_API_KEY: not set"; $doctorIssues++
}

# Plugin
$pluginExists = Test-Path "$ECC_DIR\.opencode\dist\index.js"
if ($pluginExists) { Write-OK "Plugin: built" }
else { Write-Fail "Plugin: not built"; $doctorIssues++ }

$doctorStatus = if ($doctorIssues -eq 0) { "PASS" } else { "FAIL ($doctorIssues issues)" }

# ============================================================
# [7/9] UPDATE SYNC STATE
# ============================================================

if (-not $Doctor) {
    Write-Step "7/9" "Update sync state..."

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    $eccVersion = if (Test-Path "$ECC_DIR\VERSION") { Get-Content "$ECC_DIR\VERSION" -ErrorAction SilentlyContinue } else { "unknown" }

    $syncData = @{
        ecc = @{
            last_sha = if ($eccAfter) { $eccAfter } else { git -C $ECC_DIR log -1 --format="%H" 2>$null }
            last_sync = $timestamp
            repo = "fannndi/ECC"
            version = $eccVersion
        }
        "9router" = @{
            last_sha = if ($routerAfter) { $routerAfter } else { git -C $ROUTER_DIR log -1 --format="%H" 2>$null }
            last_sync = $timestamp
            repo = "fannndi/9router"
        }
    } | ConvertTo-Json -Depth 5

    Set-Content -Path $SYNC_STATE -Value $syncData -Encoding UTF8
    Write-OK "Sync state updated"
} else {
    Write-Step "7/9" "Sync state..."
    Write-Skip "Skipped (doctor mode)"
}

# ============================================================
# [8/9] SAVE ADMIN LOG
# ============================================================

Write-Step "8/9" "Save admin log..."

$today = Get-Date -Format "yyyy-MM-dd"
$now = Get-Date -Format "HH:mm:ss"

$eccSummary = if ($eccStats.commits -gt 0) { "$($eccStats.commits) commits" } else { "up to date" }
$routerSummary = if ($routerStats.commits -gt 0) { "$($routerStats.commits) commits" } else { "up to date" }
$pluginSummary = if ($pluginRebuilt) { "rebuilt" } else { "no change" }

$logEntry = @"
## $today $now

| Component | Status |
|-----------|--------|
| ECC | $eccSummary |
| 9Router | $routerSummary |
| Plugin | $pluginSummary |
| Doctor | $doctorStatus |

"@

if (Test-Path $ADMIN_LOG) {
    $existing = Get-Content $ADMIN_LOG -Raw
    $insertPoint = $existing.IndexOf("---")
    if ($insertPoint -ge 0) {
        $updated = $existing.Substring(0, $insertPoint + 3) + "`n" + $logEntry + $existing.Substring($insertPoint + 3)
        Set-Content -Path $ADMIN_LOG -Value $updated -Encoding UTF8
    } else {
        Add-Content -Path $ADMIN_LOG -Value $logEntry -Encoding UTF8
    }
} else {
    $header = "# Admin Log`n`nHistory update admin untuk opencode-setup.`n`n---`n`n$logEntry"
    Set-Content -Path $ADMIN_LOG -Value $header -Encoding UTF8
}

Write-OK "log-admin.md updated"

# ============================================================
# [9/9] SUMMARY
# ============================================================

Write-Step "9/9" "Summary"

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "   Admin Update Complete" -ForegroundColor Green
Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""

$eccShortBefore = if ($eccBefore) { $eccBefore.Substring(0,7) } else { "n/a" }
$eccShortAfter = if ($eccAfter) { $eccAfter.Substring(0,7) } else { "n/a" }
$routerShortBefore = if ($routerBefore) { $routerBefore.Substring(0,7) } else { "n/a" }
$routerShortAfter = if ($routerAfter) { $routerAfter.Substring(0,7) } else { "n/a" }

Write-Host "  ECC:      $eccShortBefore -> $eccShortAfter ($($eccStats.commits) commits)" -ForegroundColor White
Write-Host "  9Router:  $routerShortBefore -> $routerShortAfter ($($routerStats.commits) commits)" -ForegroundColor White
Write-Host "  Plugin:   $(if ($pluginRebuilt) { 'Rebuilt' } else { 'No change' })" -ForegroundColor White
Write-Host "  Doctor:   $doctorStatus" -ForegroundColor $(if ($doctorIssues -eq 0) { "Green" } else { "Red" })
Write-Host "  Log:      log-admin.md" -ForegroundColor White
Write-Host ""

# Recommendations
$recommendations = @()
if ($eccStats.setup -gt 0 -or $routerStats.setup -gt 0) {
    $recommendations += "[!] Setup changes detected - run /setup to apply"
}
if ($eccStats.breaking -gt 0 -or $routerStats.breaking -gt 0) {
    $recommendations += "[BREAKING] Breaking changes - review changelog manually"
}
if ($needsRebuild -and -not $pluginRebuilt) {
    $recommendations += "[PLUGIN] Plugin rebuild failed - run manually: cd ecc && npm run build:opencode"
}
if ($doctorIssues -gt 0) {
    $recommendations += "[DOCTOR] Doctor found $doctorIssues issue(s) - fix before coding"
}

if ($recommendations.Count -gt 0) {
    Write-Host "  Recommendations:" -ForegroundColor Yellow
    foreach ($r in $recommendations) {
        Write-Host "    $r" -ForegroundColor White
    }
} else {
    Write-Host "  No action needed. Ready to code!" -ForegroundColor Green
}

Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""
