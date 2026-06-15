# Admin Update — Update ECC + 9Router, rebuild plugin, doctor check
# Usage: .\admin-update.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$ECC_DIR = "$ROOT_DIR\ecc"
$ROUTER_DIR = "$ROOT_DIR\9router"
$SYNC_STATE = "$ROOT_DIR\.sync-state.json"
$ADMIN_LOG = "$ROOT_DIR\log-admin.md"
$CHANGELOG_ECC = "$ROOT_DIR\changelog-ecc.md"
$CHANGELOG_9R = "$ROOT_DIR\changelog-9router.md"
$API_URL = "http://localhost:20128"
$API_PASS = "123456"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# Source LLM adapter
. "$SETUP_DIR\llm-adapter.ps1"

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

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Admin Update — ECC + 9Router            ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$totalSteps = 6
$eccNewCommits = 0
$routerNewCommits = 0
$eccOpencodeCommits = 0
$eccBeforeSHA = ""
$eccAfterSHA = ""
$routerBeforeSHA = ""
$routerAfterSHA = ""
$pluginRebuilt = $false
$doctorStatus = "OK"

# ============================================================
# [1/6] Update ECC
# ============================================================

Write-Step "1/$totalSteps" "Update ECC..."

if (Test-Path "$ECC_DIR\.git") {
    $eccBeforeSHA = git -C $ECC_DIR log -1 --format="%H"
    Write-Info "Current: $($eccBeforeSHA.Substring(0,7))"

    git -C $ECC_DIR pull --quiet 2>$null
    $eccAfterSHA = git -C $ECC_DIR log -1 --format="%H"

    if ($eccBeforeSHA -ne $eccAfterSHA) {
        Write-OK "Updated: $($eccBeforeSHA.Substring(0,7)) → $($eccAfterSHA.Substring(0,7))"
        $allCommits = git -C $ECC_DIR log "$eccBeforeSHA..$eccAfterSHA" --format="%H|%ai|%an|%s" 2>$null
        $eccNewCommits = ($allCommits | Measure-Object).Count

        $opencodeChanges = 0
        $commitLines = ""
        foreach ($line in $allCommits) {
            $parts = $line -split '\|', 4
            if ($parts.Length -ge 4) {
                $sha = $parts[0].Substring(0,7)
                $date = $parts[1].Split(' ')[0]
                $author = $parts[2]
                $msg = $parts[3]
                $isOpencode = if ($msg -match "(?i)(opencode|plugin|\.opencode|build:opencode)") { "⚠" } else { "" }
                if ($isOpencode) { $opencodeChanges++ }
                $commitLines += "| \`$sha\` | $author | $msg | $isOpencode |`n"
            }
        }
        $eccOpencodeCommits = $opencodeChanges

        # Update changelog-ecc.md
        $timestamp = Get-Date -Format "yyyy-MM-dd"
        $newEntry = "`n`n### $timestamp`n| SHA | Author | Message | Opencode? |`n|-----|--------|---------|-----------|`n$commitLines"

        if (Test-Path $CHANGELOG_ECC) {
            $existing = Get-Content $CHANGELOG_ECC -Raw
            # Insert after the --- section before "## Commits"
            $insertPoint = $existing.IndexOf("## Commits")
            $updated = $existing.Substring(0, $insertPoint) + "## Commits$newEntry`n`n" + $existing.Substring($insertPoint + 10)
            Set-Content -Path $CHANGELOG_ECC -Value $updated -Encoding UTF8
        }

        Write-OK "$eccNewCommits new commits ($opencodeChanges opencode-related)"

        # LLM changelog summary
        if ($commitLines) {
            $eccLlmSummary = Invoke-LLMEnrich -Text $commitLines -Context "Summarize changelog" -System "You are a changelog summarizer. Given commit data, produce a concise bullet-point summary of key changes."
            if ($eccLlmSummary -and $eccLlmSummary -ne $commitLines) {
                Write-Host "  [LLM] ECC Changelog summary:" -ForegroundColor Cyan
                $eccLlmSummary -split "`n" | ForEach-Object { if ($_.Trim()) { Write-Host "    $_" -ForegroundColor Gray } }
            }
        }
    } else {
        Write-OK "Already up to date"
    }
} else {
    Write-Skip "ECC not cloned. Run setup.ps1 first"
}

# ============================================================
# [2/6] Update 9Router
# ============================================================

Write-Step "2/$totalSteps" "Update 9Router..."

if (Test-Path "$ROUTER_DIR\.git") {
    $routerBeforeSHA = git -C $ROUTER_DIR log -1 --format="%H"
    Write-Info "Current: $($routerBeforeSHA.Substring(0,7))"

    git -C $ROUTER_DIR pull --quiet 2>$null
    $routerAfterSHA = git -C $ROUTER_DIR log -1 --format="%H"

    if ($routerBeforeSHA -ne $routerAfterSHA) {
        Write-OK "Updated: $($routerBeforeSHA.Substring(0,7)) → $($routerAfterSHA.Substring(0,7))"
        $allCommits = git -C $ROUTER_DIR log "$routerBeforeSHA..$routerAfterSHA" --format="%H|%ai|%an|%s" 2>$null
        $routerNewCommits = ($allCommits | Measure-Object).Count

        $commitLines = ""
        foreach ($line in $allCommits) {
            $parts = $line -split '\|', 4
            if ($parts.Length -ge 4) {
                $sha = $parts[0].Substring(0,7)
                $date = $parts[1].Split(' ')[0]
                $author = $parts[2]
                $msg = $parts[3]
                $commitLines += "| \`$sha\` | $author | $msg | |`n"
            }
        }

        # Update changelog-9router.md
        $timestamp = Get-Date -Format "yyyy-MM-dd"
        $newEntry = "`n`n### $timestamp`n| SHA | Author | Message | Opencode? |`n|-----|--------|---------|-----------|`n$commitLines"

        if (Test-Path $CHANGELOG_9R) {
            $existing = Get-Content $CHANGELOG_9R -Raw
            $insertPoint = $existing.IndexOf("## Commits")
            $updated = $existing.Substring(0, $insertPoint) + "## Commits$newEntry`n`n" + $existing.Substring($insertPoint + 10)
            Set-Content -Path $CHANGELOG_9R -Value $updated -Encoding UTF8
        }

        Write-OK "$routerNewCommits new commits"

        # LLM changelog summary
        if ($commitLines) {
            $routerLlmSummary = Invoke-LLMEnrich -Text $commitLines -Context "Summarize changelog" -System "You are a changelog summarizer. Given commit data, produce a concise bullet-point summary of key changes."
            if ($routerLlmSummary -and $routerLlmSummary -ne $commitLines) {
                Write-Host "  [LLM] 9Router Changelog summary:" -ForegroundColor Cyan
                $routerLlmSummary -split "`n" | ForEach-Object { if ($_.Trim()) { Write-Host "    $_" -ForegroundColor Gray } }
            }
        }
    } else {
        Write-OK "Already up to date"
    }
} else {
    Write-Skip "9Router not cloned. Run setup.ps1 first"
}

# ============================================================
# [3/6] Rebuild Plugin
# ============================================================

Write-Step "3/$totalSteps" "Rebuild plugin..."

if ($eccOpencodeCommits -gt 0) {
    Write-Info "Opencode changes detected, rebuilding..."
    Push-Location $ECC_DIR

    if (-not (Test-Path "node_modules")) {
        Write-Info "Installing dependencies..."
        npm install --silent 2>$null
    }
    if (-not (Test-Path ".opencode\node_modules")) {
        Push-Location ".opencode"
        npm install --silent 2>$null
        Pop-Location
    }

    npm run build:opencode 2>$null
    if (Test-Path ".opencode\dist\index.js") {
        Write-OK "Plugin rebuilt successfully"
        $pluginRebuilt = $true
    } else {
        Write-Fail "Plugin build failed"
        $doctorStatus = "PLUGIN_FAIL"
    }

    Pop-Location
} else {
    Write-OK "No rebuild needed"
}

# ============================================================
# [4/6] Doctor Check
# ============================================================

Write-Step "4/$totalSteps" "Doctor check..."

$allChecksPassed = $true

# Check ECC structure
$eccSkills = Get-ChildItem "$ECC_DIR\skills" -Directory -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
$eccAgents = Get-ChildItem "$ECC_DIR\agents" -File -ErrorAction SilentlyContinue | Measure-Object | Select-Object -ExpandProperty Count
if ($eccSkills -gt 0) { Write-OK "ECC: $eccSkills skills, $eccAgents agents" }
else { Write-Fail "ECC: skills missing!"; $allChecksPassed = $false }

# Check 9Router running
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -TimeoutSec 5
    if ($health.ok) { Write-OK "9Router: Running" }
    else { Write-Fail "9Router: Health check failed"; $allChecksPassed = $false }
} catch {
    Write-Fail "9Router: Not running"
    $allChecksPassed = $false
}

# Check combos
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" -Method POST -Body "{`"password`":`"$API_PASS`"}" -ContentType "application/json" -SessionVariable httpSession | Out-Null
    $combos = Invoke-RestMethod -Uri "$API_URL/api/combos" -WebSession $httpSession
    $comboCount = $combos.combos.Count
    Write-OK "Combos: $comboCount active"
} catch {
    Write-Fail "Combos: Unable to verify"
}

# Check session
$activeProject = Get-ActiveProject
if ($activeProject) {
    Write-OK "Session: Active ($activeProject)"
} else {
    Write-Info "Session: None"
}

if ($allChecksPassed) { $doctorStatus = "PASS" }
else { $doctorStatus = "FAIL" }

# ============================================================
# [5/6] Save Admin Log
# ============================================================

Write-Step "5/$totalSteps" "Save admin log..."

$today = Get-Date -Format "yyyy-MM-dd"
$now = Get-Date -Format "HH:mm:ss"
$eccChanges = if ($eccNewCommits -gt 0) { "$eccNewCommits commits" } else { "up to date" }
$routerChanges = if ($routerNewCommits -gt 0) { "$routerNewCommits commits" } else { "up to date" }
$pluginStatus = if ($pluginRebuilt) { "rebuilt" } else { "no change" }

$logEntry = @"
## $today $now

| Komponen | Status |
|----------|--------|
| ECC | $eccChanges$($eccOpencodeCommits | ForEach-Object { if ($_ -gt 0) { " ($_ ⚡)" } }) |
| 9Router | $routerChanges |
| Plugin | $pluginStatus |
| Doctor | $doctorStatus |

"@

if (Test-Path $ADMIN_LOG) {
    $existingLog = Get-Content $ADMIN_LOG -Raw
    # Insert after the header
    $insertPoint = $existingLog.IndexOf("---")
    if ($insertPoint -ge 0) {
        $updatedLog = $existingLog.Substring(0, $insertPoint + 3) + "`n" + $logEntry + $existingLog.Substring($insertPoint + 3)
        Set-Content -Path $ADMIN_LOG -Value $updatedLog -Encoding UTF8
    } else {
        Add-Content -Path $ADMIN_LOG -Value $logEntry -Encoding UTF8
    }
} else {
    $header = "# Admin Log`n`nHistory update admin untuk opencode-setup.`nTerakhir diperbarui: $today`n`n---`n`n$logEntry"
    Set-Content -Path $ADMIN_LOG -Value $header -Encoding UTF8
}

Write-OK "log-admin.md updated"

# ============================================================
# [6/6] Summary
# ============================================================

Write-Step "6/$totalSteps" "Summary"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║         Admin Update — Complete!                ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  ECC:      $($eccBeforeSHA.Substring(0, [Math]::Min(7, $eccBeforeSHA.Length))) → $($eccAfterSHA.Substring(0, [Math]::Min(7, $eccAfterSHA.Length)))" -ForegroundColor White
Write-Host "            $eccNewCommits new commits ($eccOpencodeCommits opencode-related)" -ForegroundColor Gray
Write-Host "  9Router:  $($routerBeforeSHA.Substring(0, [Math]::Min(7, $routerBeforeSHA.Length))) → $($routerAfterSHA.Substring(0, [Math]::Min(7, $routerAfterSHA.Length)))" -ForegroundColor White
Write-Host "            $routerNewCommits new commits" -ForegroundColor Gray
Write-Host "  Plugin:   $(if ($pluginRebuilt) { 'Rebuilt ✅' } else { 'No change' })" -ForegroundColor Green
Write-Host "  Doctor:   $doctorStatus" -ForegroundColor $(if ($doctorStatus -eq "PASS") { "Green" } else { "Red" })
Write-Host "  Log:      log-admin.md" -ForegroundColor White
Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""
