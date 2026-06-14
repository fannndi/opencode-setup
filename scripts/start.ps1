# OpenCode Daily Workflow
# Check repos, sync, test models, apply profile
# Usage: .\start.ps1 -Profile gratis|go

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("gratis", "go")]
    [string]$Profile
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
$session = $null
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" `
        -Method POST `
        -Body "{`"password`":`"$API_PASS`"}" `
        -ContentType "application/json" `
        -SessionVariable session | Out-Null
    Write-OK "API login successful"
} catch {
    Write-Fail "API login failed"
}

# Determine models to test
$modelsToTest = @()
if ($Profile -eq "gratis") {
    $modelsToTest = @("oc/mimo-v2.5-free", "oc/deepseek-v4-flash-free")
} else {
    $modelsToTest = @("ocg/kimi-k2.6", "ocg/qwen3.6-plus")
}

foreach ($model in $modelsToTest) {
    try {
        $body = @{
            model = $model
            messages = @(@{ role = "user"; content = "hi" })
            max_tokens = 10
        } | ConvertTo-Json -Depth 5

        $response = Invoke-RestMethod -Uri "$API_URL/v1/chat/completions" `
            -Method POST `
            -Body $body `
            -ContentType "application/json" `
            -WebSession $session `
            -TimeoutSec 15

        $reply = $response.choices[0].message.content
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
    Write-Host "    oc/mimo-v2.5-free → oc/deepseek-v4-flash-free → kr/claude-sonnet-4.5" -ForegroundColor White
    Write-Host "    Cost: FREE forever" -ForegroundColor Green
} else {
    Write-Host "  Combo chain:" -ForegroundColor Yellow
    Write-Host "    ocg/kimi-k2.6 → ocg/qwen3.6-plus → ocg/glm-5.1" -ForegroundColor White
    Write-Host "    Cost: Limited quota" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""
