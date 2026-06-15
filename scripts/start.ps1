# OpenCode Daily Workflow (Master Control)
# Check repos, sync, test models, apply profile
# Usage: .\start.ps1 -Profile gratis|go [-ProjectPath "C:\path\to\project"]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("gratis", "go")]
    [string]$Profile,

    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$ECC_DIR = "$ROOT_DIR\ecc"
$ROUTER_DIR = "$ROOT_DIR\9router"
$SYNC_STATE = "$ROOT_DIR\.sync-state.json"
$OPENCODE_DIR = "$env:USERPROFILE\.config\opencode"
$OPENCODE_CONFIG = "$OPENCODE_DIR\opencode.jsonc"
$PROFILE_CONFIG = "$ROOT_DIR\profiles\$Profile\opencode.jsonc"
$API_URL = "http://localhost:20128"
$API_PASS = "123456"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve Project Path (Master Control)
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if ($ProjectPath) { Write-Host "  [SESSION] Project: $ProjectPath" -ForegroundColor Gray }

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

$profileLabel = if ($Profile -eq "gratis") { "100% Free" } else { "Go (Limited)" }
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         OpenCode Daily Workflow                  ║" -ForegroundColor Magenta
Write-Host "  ║         Profile: $profileLabel$( ' ' * (25 - $profileLabel.Length))║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Load Session State
# ============================================================

$session = $null
if (Test-Path $SESSION_FILE) {
    try {
        $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
        Write-Host "  [SESSION] Loaded previous session ($($session.last_action))" -ForegroundColor Gray
    } catch {
        Write-Host "  [SESSION] Corrupt, starting fresh" -ForegroundColor Yellow
    }
}

# ============================================================
# Self-Healing Checks
# ============================================================

Write-Host ""
Write-Host "  [HEAL] Checking system health..." -ForegroundColor Gray

# Check 9Router
$portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
if (-not $portInUse) {
    Write-Host "  [HEAL] 9Router not running. Auto-starting..." -ForegroundColor Yellow
    Start-Process -FilePath "9router" -WindowStyle Minimized
    Start-Sleep -Seconds 4
    $portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
    if ($portInUse) { Write-Host "  [HEAL] 9Router started" -ForegroundColor Green }
    else { Write-Host "  [HEAL] 9Router failed. Start manually: 9router --tray" -ForegroundColor Red }
} else {
    Write-Host "  [HEAL] 9Router: OK" -ForegroundColor Green
}

# Check ECC repo
if (-not (Test-Path "$ROOT_DIR\ecc\.git")) {
    Write-Host "  [HEAL] ECC not cloned. Cloning..." -ForegroundColor Yellow
    git clone --quiet https://github.com/fannndi/ECC.git "$ROOT_DIR\ecc"
    if (Test-Path "$ROOT_DIR\ecc\.git") { Write-Host "  [HEAL] ECC cloned" -ForegroundColor Green }
    else { Write-Host "  [HEAL] ECC clone failed" -ForegroundColor Red }
} else {
    Write-Host "  [HEAL] ECC: OK" -ForegroundColor Green
}

# Check 9Router repo
if (-not (Test-Path "$ROOT_DIR\9router\.git")) {
    Write-Host "  [HEAL] 9Router not cloned. Cloning..." -ForegroundColor Yellow
    git clone --quiet https://github.com/fannndi/9router.git "$ROOT_DIR\9router"
    if (Test-Path "$ROOT_DIR\9router\.git") { Write-Host "  [HEAL] 9Router cloned" -ForegroundColor Green }
    else { Write-Host "  [HEAL] 9Router clone failed" -ForegroundColor Red }
} else {
    Write-Host "  [HEAL] 9Router: OK" -ForegroundColor Green
}

# Check plugin
$pluginBuilt = Test-Path "$ROOT_DIR\ecc\.opencode\dist\index.js"
if (-not $pluginBuilt) {
    Write-Host "  [HEAL] Plugin not built. Building..." -ForegroundColor Yellow
    Push-Location "$ROOT_DIR\ecc"
    if (-not (Test-Path "node_modules")) { npm install --silent 2>$null }
    if (-not (Test-Path ".opencode\node_modules")) { Push-Location ".opencode"; npm install --silent 2>$null; Pop-Location }
    npm run build:opencode 2>$null
    Pop-Location
    if (Test-Path "$ROOT_DIR\ecc\.opencode\dist\index.js") { Write-Host "  [HEAL] Plugin built" -ForegroundColor Green }
    else { Write-Host "  [HEAL] Plugin build failed" -ForegroundColor Red }
} else {
    Write-Host "  [HEAL] Plugin: OK" -ForegroundColor Green
}

# Check session
if (Test-Path $SESSION_FILE) {
    try {
        $null = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
        Write-Host "  [HEAL] Session: OK" -ForegroundColor Green
    } catch {
        Write-Host "  [HEAL] Session corrupt. Resetting..." -ForegroundColor Yellow
        Remove-Item $SESSION_FILE -Force -ErrorAction SilentlyContinue
        Write-Host "  [HEAL] Session reset" -ForegroundColor Green
    }
} else {
    Write-Host "  [HEAL] Session: none (fresh start)" -ForegroundColor Gray
}

# Save healing result to memory
try { & "$ROOT_DIR\scripts\memory.ps1" -Action save -Value "Self-healing: all OK" -ProjectPath $ROOT_DIR } catch {}

# ============================================================
# Auto-Update Check
# ============================================================

Write-Host ""
Write-Host "  [UPDATE] Checking for updates..." -ForegroundColor Gray

$eccBefore = git -C "$ROOT_DIR\ecc" log -1 --format="%H" 2>$null
$routerBefore = git -C "$ROOT_DIR\9router" log -1 --format="%H" 2>$null

$hasEccUpdates = $false
$hasRouterUpdates = $false

# Pull ECC
if (Test-Path "$ROOT_DIR\ecc\.git") {
    git -C "$ROOT_DIR\ecc" pull --quiet 2>$null
    $eccAfter = git -C "$ROOT_DIR\ecc" log -1 --format="%H" 2>$null
    if ($eccBefore -ne $eccAfter) { $hasEccUpdates = $true }
}

# Pull 9Router
if (Test-Path "$ROOT_DIR\9router\.git") {
    git -C "$ROOT_DIR\9router" pull --quiet 2>$null
    $routerAfter = git -C "$ROOT_DIR\9router" log -1 --format="%H" 2>$null
    if ($routerBefore -ne $routerAfter) { $hasRouterUpdates = $true }
}

if ($hasEccUpdates -or $hasRouterUpdates) {
    Write-Host "  [UPDATE] ECC updates detected! Rebuilding plugin..." -ForegroundColor Yellow
    Push-Location "$ROOT_DIR\ecc"
    if (-not (Test-Path "node_modules")) { npm install --silent 2>$null }
    if (-not (Test-Path ".opencode\node_modules")) { Push-Location ".opencode"; npm install --silent 2>$null; Pop-Location }
    npm run build:opencode 2>$null
    Pop-Location
    Write-Host "  [UPDATE] Plugin rebuilt" -ForegroundColor Green
    
    # Update sync state
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    $eccVersion = if (Test-Path "$ROOT_DIR\ecc\VERSION") { Get-Content "$ROOT_DIR\ecc\VERSION" -ErrorAction SilentlyContinue } else { "unknown" }
    $syncState = @{
        ecc = @{ last_sha = $eccAfter; last_sync = $timestamp; repo = "fannndi/ECC"; version = $eccVersion }
        "9router" = @{ last_sha = $routerAfter; last_sync = $timestamp; repo = "fannndi/9router" }
    } | ConvertTo-Json -Depth 5
    Set-Content -Path "$ROOT_DIR\.sync-state.json" -Value $syncState -Encoding UTF8
    Write-Host "  [UPDATE] Sync state updated" -ForegroundColor Green
} else {
    Write-Host "  [UPDATE] No updates" -ForegroundColor Green
}

$totalSteps = 7

# ============================================================
# [1/7] Check repos
# ============================================================

Write-Step "1/$totalSteps" "Checking repositories..."

# ECC
if (-not (Test-Path "$ECC_DIR\.git")) {
    Write-Info "ECC not found, cloning..."
    git clone --quiet https://github.com/fannndi/ECC.git $ECC_DIR
    Write-OK "ECC cloned"
} else {
    $before = git -C $ECC_DIR log -1 --format="%H"
    git -C $ECC_DIR pull --quiet 2>$null
    $after = git -C $ECC_DIR log -1 --format="%H"
    if ($before -ne $after) {
        Write-OK "ECC: updated ($($before.Substring(0,7)) → $($after.Substring(0,7)))"
    } else {
        Write-OK "ECC: already up to date"
    }
}

# 9Router
if (-not (Test-Path "$ROUTER_DIR\.git")) {
    Write-Info "9Router not found, cloning..."
    git clone --quiet https://github.com/fannndi/9router.git $ROUTER_DIR
    Write-OK "9Router cloned"
} else {
    $before = git -C $ROUTER_DIR log -1 --format="%H"
    git -C $ROUTER_DIR pull --quiet 2>$null
    $after = git -C $ROUTER_DIR log -1 --format="%H"
    if ($before -ne $after) {
        Write-OK "9Router: updated ($($before.Substring(0,7)) → $($after.Substring(0,7)))"
    } else {
        Write-OK "9Router: already up to date"
    }
}

# ============================================================
# [2/7] Sync changelog
# ============================================================

Write-Step "2/$totalSteps" "Syncing changelog..."

$eccHasChanges = $false
$routerHasChanges = $false

if (Test-Path $SYNC_STATE) {
    $state = Get-Content $SYNC_STATE -Raw | ConvertFrom-Json
    $eccLastSHA = $state.ecc.last_sha
    $routerLastSHA = $state."9router".last_sha
    $eccCurrentSHA = git -C $ECC_DIR log -1 --format="%H"
    $routerCurrentSHA = git -C $ROUTER_DIR log -1 --format="%H"

    $eccHasChanges = ($eccLastSHA -ne $eccCurrentSHA)
    $routerHasChanges = ($routerLastSHA -ne $routerCurrentSHA)

    if ($eccHasChanges -or $routerHasChanges) {
        $eccCommits = 0
        $routerCommits = 0
        $opencodeChanges = 0

        if ($eccHasChanges) {
            $commits = git -C $ECC_DIR log "$eccLastSHA..$eccCurrentSHA" --oneline 2>$null
            $eccCommits = ($commits | Measure-Object).Count
            $opencodeKeywords = @("opencode", "plugin", ".opencode", "agent", "skill", "hook", "config")
            foreach ($c in $commits) {
                foreach ($kw in $opencodeKeywords) {
                    if ($c -match "(?i)$kw") { $opencodeChanges++; break }
                }
            }
        }

        if ($routerHasChanges) {
            $commits = git -C $ROUTER_DIR log "$routerLastSHA..$routerCurrentSHA" --oneline 2>$null
            $routerCommits = ($commits | Measure-Object).Count
        }

        Write-Host "  ECC: $eccCommits new commit(s)" -ForegroundColor White
        Write-Host "  9Router: $routerCommits new commit(s)" -ForegroundColor White
        if ($opencodeChanges -gt 0) {
            Write-Host "  ⚡ $opencodeChanges opencode-related change(s)" -ForegroundColor Yellow
        }
    } else {
        Write-OK "No changes since last sync"
    }
} else {
    Write-Skip "No sync state found (first run)"
}

# ============================================================
# [3/7] Analyze updates
# ============================================================

Write-Step "3/$totalSteps" "Analyzing updates..."

$needsRebuild = $false

if ($eccHasChanges) {
    $opencodeKeywords = @("opencode", "plugin", ".opencode", "build:opencode")
    $commits = git -C $ECC_DIR log "$($state.ecc.last_sha)..$(git -C $ECC_DIR log -1 --format='%H')" --oneline 2>$null
    foreach ($c in $commits) {
        foreach ($kw in $opencodeKeywords) {
            if ($c -match "(?i)$kw") { $needsRebuild = $true; break }
        }
        if ($needsRebuild) { break }
    }
}

if ($needsRebuild) {
    Write-Info "Opencode changes detected, rebuilding plugin..."
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
        Write-OK "Plugin rebuilt successfully"
    } else {
        Write-Fail "Plugin build failed"
    }

    Pop-Location
} else {
    Write-OK "No rebuild needed"
}

# Update sync state
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
$eccVersion = if (Test-Path "$ECC_DIR\VERSION") { Get-Content "$ECC_DIR\VERSION" -ErrorAction SilentlyContinue } else { "unknown" }
$syncState = @{
    ecc = @{
        last_sha = git -C $ECC_DIR log -1 --format="%H"
        last_sync = $timestamp
        repo = "fannndi/ECC"
        version = $eccVersion
    }
    "9router" = @{
        last_sha = git -C $ROUTER_DIR log -1 --format="%H"
        last_sync = $timestamp
        repo = "fannndi/9router"
    }
} | ConvertTo-Json -Depth 5
Set-Content -Path $SYNC_STATE -Value $syncState -Encoding UTF8

# ============================================================
# [4/7] Test 9Router
# ============================================================

Write-Step "4/$totalSteps" "Testing 9Router..."

$portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-OK "9Router already running on port 20128"
} else {
    Write-Info "9Router not running, auto-starting..."
    Start-Process -FilePath "9router" -WindowStyle Minimized
    Start-Sleep -Seconds 4

    $portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
    if ($portInUse) {
        Write-OK "9Router auto-started on port 20128"
    } else {
        Write-Fail "9Router failed to start"
    }
}

# Health check
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -TimeoutSec 5
    if ($health.ok) {
        Write-OK "Health check passed"
    }
} catch {
    Write-Fail "Health check failed"
}

# ============================================================
# [5/7] Test models
# ============================================================

Write-Step "5/$totalSteps" "Testing models..."

# Login
$httpSession = $null
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" `
        -Method POST `
        -Body "{`"password`":`"$API_PASS`"}" `
        -ContentType "application/json" `
        -SessionVariable httpSession | Out-Null
    Write-OK "API login successful"
} catch {
    Write-Fail "API login failed"
}

# Determine models to test
$modelsToTest = @()
if ($Profile -eq "gratis") {
    $modelsToTest = @("mmf/mimo-auto", "oc/deepseek-v4-flash-free", "oc/mimo-v2.5-free")
} else {
    $modelsToTest = @("ocg/kimi-k2.6", "ocg/qwen3.6-plus")
}

foreach ($model in $modelsToTest) {
    try {
        $response = Invoke-RestMethod -Uri "$API_URL/v1/chat/completions" `
            -Method POST `
            -Body "{`"model`":`"$model`",`"messages`":[{`"role`":`"user`",`"content`":`"hi`"}],`"max_tokens`":10}" `
            -ContentType "application/json" `
            -WebSession $httpSession `
            -TimeoutSec 15

        # Parse SSE response (9Router returns data: {json}\n\ndata: [DONE])
        $reply = ""
        if ($response -is [string]) {
            $lines = $response -split "`n"
            foreach ($line in $lines) {
                if ($line -match '^data: (.+)$' -and $Matches[1] -ne "[DONE]") {
                    try {
                        $json = $Matches[1] | ConvertFrom-Json
                        if ($json.choices[0].message.content) {
                            $reply = $json.choices[0].message.content
                        }
                    } catch {}
                }
            }
        } elseif ($response.choices) {
            $reply = $response.choices[0].message.content
        }

        if ($reply) {
            Write-OK "$model : responding ($($reply.Substring(0, [Math]::Min(30, $reply.Length)))...)"
        } else {
            Write-Fail "$model : empty response"
        }
    } catch {
        Write-Fail "$model : $($_.Exception.Message)"
    }
}

# ============================================================
# [6/7] Apply profile
# ============================================================

Write-Step "6/$totalSteps" "Applying profile: $Profile..."

# Backup existing config
if (Test-Path $OPENCODE_CONFIG) {
    $backup = "$OPENCODE_CONFIG.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $OPENCODE_CONFIG $backup
    Write-OK "Existing config backed up"
}

# Copy profile config
if (-not (Test-Path $PROFILE_CONFIG)) {
    Write-Fail "Profile config not found: $PROFILE_CONFIG"
} else {
    New-Item -ItemType Directory -Force -Path $OPENCODE_DIR | Out-Null
    Copy-Item $PROFILE_CONFIG $OPENCODE_CONFIG -Force
    Write-OK "Config: $Profile → $OPENCODE_CONFIG"
}

# Set env vars
[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'standard', 'User')
Write-OK "ECC_HOOK_PROFILE=standard"

# ============================================================
# [7/7] Ready
# ============================================================

Write-Step "7/$totalSteps" "Status summary"

# ============================================================
# Save Session
# ============================================================

# ============================================================
# Save Session (per-project)
# ============================================================

if ($ProjectPath) {
    $slug = Get-ProjectSlug -Path $ProjectPath
    $sessionDir = "$OPENCODE_DIR\projects\$slug"
    Ensure-ProjectDirs -ProjectDir $sessionDir
    $sessionFile = "$sessionDir\session.json"

    # Read existing session if present
    $oldSession = $null
    if (Test-Path $sessionFile) {
        try { $oldSession = Get-Content $sessionFile -Raw | ConvertFrom-Json } catch {}
    }

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    $sessionData = [PSCustomObject]@{
        version = "2.0"
        project_path = $ProjectPath
        project_name = $slug
        github_url = if ($oldSession -and $oldSession.github_url) { $oldSession.github_url } else { "" }
        last_profile = $Profile
        stack = if ($oldSession) { $oldSession.stack } else { "" }
        skills_loaded = if ($oldSession) { $oldSession.skills_loaded } else { @() }
        rules_applied = if ($oldSession) { $oldSession.rules_applied } else { @() }
        workflow_state = [PSCustomObject]@{
            prd_analyzed = if ($oldSession) { $oldSession.workflow_state.prd_analyzed } else { $false }
            ai_notes_generated = if ($oldSession) { $oldSession.workflow_state.ai_notes_generated } else { $false }
            analyze_project_done = if ($oldSession) { $oldSession.workflow_state.analyze_project_done } else { $false }
        }
        last_action = "/start-$Profile"
        created_at = if ($oldSession) { $oldSession.created_at } else { $timestamp }
        updated_at = $timestamp
    }
    $sessionData | ConvertTo-Json -Depth 10 | Set-Content -Path $sessionFile -Encoding UTF8
    Write-Host ""
    Write-Host "  [SESSION] Saved to .opencode/projects/$slug/session.json" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "  [SESSION] No project set, session not saved" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              All systems GO!                     ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Profile:     $Profile" -ForegroundColor White
Write-Host "  Config:      $OPENCODE_CONFIG" -ForegroundColor White
Write-Host "  9Router:     $API_URL" -ForegroundColor White
Write-Host "  Dashboard:   $API_URL/dashboard" -ForegroundColor White
Write-Host ""

if ($Profile -eq "gratis") {
    Write-Host "  Combo chain:" -ForegroundColor Yellow
    Write-Host "    mmf/mimo-auto → oc/deepseek-v4-flash-free → oc/mimo-v2.5-free" -ForegroundColor White
    Write-Host "    Emergency: nemotron-3-ultra-free → big-pickle → north-mini-code-free" -ForegroundColor Gray
    Write-Host "    Cost: FREE forever" -ForegroundColor Green
} else {
    Write-Host "  Profile go: (skipped)" -ForegroundColor Yellow
    Write-Host "    Gunakan profile gratis untuk sekarang" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""
