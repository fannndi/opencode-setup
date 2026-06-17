# OpenCode Morning Routine - Auto-heal daily startup
# Usage:
#   .\start.ps1 -Profile gratis    # Free models
#   .\start.ps1 -Profile go         # Go models

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("gratis", "go")]
    [string]$Profile
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$ECC_DIR = "$ROOT_DIR\ecc"
$OPENCODE_CONFIG_DIR = "$env:USERPROFILE\.config\opencode"
$OPENCODE_CONFIG = "$OPENCODE_CONFIG_DIR\opencode.jsonc"
$PROFILE_CONFIG = "$ROOT_DIR\profiles\$Profile\opencode.jsonc"
$API_URL = "http://localhost:20128"
$ROUTER_ENV = "$ROOT_DIR\9router\.env"
$API_PASS = if ($env:NINEROUTER_PASSWORD) { $env:NINEROUTER_PASSWORD } elseif (Test-Path $ROUTER_ENV) { $envContent = Get-Content $ROUTER_ENV -Raw; if ($envContent -match 'INITIAL_PASSWORD=(.+)') { $Matches[1].Trim() } else { "123456" } } else { "123456" }

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

function Write-Fix {
    param([string]$Message)
    Write-Host "  [FIX] $Message" -ForegroundColor Yellow
}

# ============================================================
# Banner
# ============================================================

$profileLabel = if ($Profile -eq "gratis") { "Free" } else { "Go" }
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   Morning Routine - $profileLabel" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

$totalSteps = 7
$allGood = $true

# ============================================================
# [1/7] LLM CHECK (first - core dependency)
# ============================================================

Write-Step "1/$totalSteps" "LLM check (9Router)..."

# 1a: 9Router installed?
$routerInstalled = [bool](Get-Command "9router" -ErrorAction SilentlyContinue)
if (-not $routerInstalled) {
    Write-Fix "9Router not found. Installing..."
    npm install -g 9router 2>$null
    $routerInstalled = [bool](Get-Command "9router" -ErrorAction SilentlyContinue)
    if ($routerInstalled) { Write-OK "9Router installed" }
    else { Write-Fail "9Router install failed"; $allGood = $false }
} else {
    Write-OK "9Router installed"
}

# 1b: 9Router running?
$portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
if (-not $portInUse) {
    Write-Fix "9Router not running. Starting..."
    Start-Process -FilePath "9router" -WindowStyle Minimized
    Start-Sleep -Seconds 4
    $portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
    if ($portInUse) { Write-OK "9Router started on port 20128" }
    else { Write-Fail "9Router failed to start"; $allGood = $false }
} else {
    Write-OK "9Router running on port 20128"
}

# 1c: Health check
try {
    $health = Invoke-RestMethod -Uri "$API_URL/api/health" -TimeoutSec 5
    if ($health.ok) { Write-OK "Health check passed" }
    else { Write-Fail "Health check failed"; $allGood = $false }
} catch {
    Write-Fail "Health check failed"; $allGood = $false
}

# 1d: Combos check
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

# 1e: API key check
$envKey = [Environment]::GetEnvironmentVariable('NINEROUTER_API_KEY', 'User')
if ($envKey -and $envKey -ne 'SET-YOUR-KEY-FROM-DASHBOARD' -and $envKey -ne '') {
    Write-OK "NINEROUTER_API_KEY: set"
} else {
    Write-Fail "NINEROUTER_API_KEY: not set"
    Write-Info "Run: .\scripts\setup.ps1 --apply"
    $allGood = $false
}

# ============================================================
# [2/7] PRE-FLIGHT
# ============================================================

Write-Step "2/$totalSteps" "Pre-flight..."

# Node.js
$node = Get-Command "node" -ErrorAction SilentlyContinue
if ($node) { Write-OK "Node.js $(node --version)" }
else { Write-Fail "Node.js not found"; $allGood = $false }

# Git
$git = Get-Command "git" -ErrorAction SilentlyContinue
if ($git) { Write-OK "Git $(git --version)" }
else { Write-Fail "Git not found"; $allGood = $false }

# OpenCode
$oc = Get-Command "opencode" -ErrorAction SilentlyContinue
if ($oc) { Write-OK "OpenCode installed" }
else { Write-Fail "OpenCode not found"; $allGood = $false }

# ============================================================
# [3/7] ECC
# ============================================================

Write-Step "3/$totalSteps" "ECC..."

if (Test-Path "$ECC_DIR\.git") {
    $before = git -C $ECC_DIR log -1 --format="%H" 2>$null
    git -C $ECC_DIR pull --quiet 2>$null
    $after = git -C $ECC_DIR log -1 --format="%H" 2>$null
    if ($before -ne $after) {
        Write-OK "ECC updated: $($before.Substring(0,7)) -> $($after.Substring(0,7))"
    } else {
        Write-OK "ECC up to date"
    }
} else {
    Write-Fix "ECC not cloned. Cloning..."
    git clone --quiet https://github.com/fannndi/ECC.git $ECC_DIR 2>$null
    if (Test-Path "$ECC_DIR\.git") { Write-OK "ECC cloned" }
    else { Write-Fail "ECC clone failed"; $allGood = $false }
}

# ============================================================
# [4/7] PLUGIN
# ============================================================

Write-Step "4/$totalSteps" "Plugin..."

$pluginBuilt = Test-Path "$ECC_DIR\.opencode\dist\index.js"
if ($pluginBuilt) {
    Write-OK "Plugin already built"
} else {
    Write-Fix "Plugin not built. Building..."
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
        Write-OK "Plugin built"
    } else {
        Write-Fail "Plugin build failed"
        $allGood = $false
    }

    Pop-Location
}

# ============================================================
# [5/7] CONFIG
# ============================================================

Write-Step "5/$totalSteps" "Config..."

# Check if config exists and matches profile
$configExists = Test-Path $OPENCODE_CONFIG
$profileExists = Test-Path $PROFILE_CONFIG

if ($configExists -and $profileExists) {
    $configContent = Get-Content $OPENCODE_CONFIG -Raw
    $profileContent = Get-Content $PROFILE_CONFIG -Raw
    if ($configContent -eq $profileContent) {
        Write-OK "Config matches profile '$Profile'"
    } else {
        Write-Fix "Config outdated. Applying profile '$Profile'..."
        $backup = "$OPENCODE_CONFIG.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $OPENCODE_CONFIG $backup
        Copy-Item $PROFILE_CONFIG $OPENCODE_CONFIG -Force
        # Fix paths
        $newContent = Get-Content $OPENCODE_CONFIG -Raw
        $newContent = $newContent.Replace("C:/Users/FANNNDI/Documents/opencode-setup", $ROOT_DIR.ToString().Replace('\', '/'))
        Set-Content -Path $OPENCODE_CONFIG -Value $newContent -Encoding UTF8
        Write-OK "Config applied (backup: $backup)"
    }
} elseif ($profileExists) {
    Write-Fix "No config found. Applying profile '$Profile'..."
    New-Item -ItemType Directory -Force -Path $OPENCODE_CONFIG_DIR | Out-Null
    Copy-Item $PROFILE_CONFIG $OPENCODE_CONFIG -Force
    $newContent = Get-Content $OPENCODE_CONFIG -Raw
    $newContent = $newContent.Replace("C:/Users/FANNNDI/Documents/opencode-setup", $ROOT_DIR.ToString().Replace('\', '/'))
    Set-Content -Path $OPENCODE_CONFIG -Value $newContent -Encoding UTF8
    Write-OK "Config created"
} else {
    Write-Fail "Profile not found: $PROFILE_CONFIG"
    $allGood = $false
}

# ============================================================
# [6/7] MODEL TEST
# ============================================================

Write-Step "6/$totalSteps" "Model test..."

# Use API key for model test (not session cookies)
$modelHeaders = @{ "X-API-Key" = $env:NINEROUTER_API_KEY }

# Test models
if ($env:NINEROUTER_API_KEY) {
    $modelsToTest = if ($Profile -eq "gratis") {
        @("mmf/mimo-auto", "oc/deepseek-v4-flash-free", "oc/mimo-v2.5-free")
    } else {
        @("ocg/kimi-k2.6", "ocg/qwen3.6-plus")
    }

    foreach ($model in $modelsToTest) {
        try {
            $response = Invoke-WebRequest -Uri "$API_URL/v1/chat/completions" `
                -Method POST `
                -Body "{`"model`":`"$model`",`"messages`":[{`"role`":`"user`",`"content`":`"hi`"}],`"max_tokens`":10}" `
                -ContentType "application/json" `
                -Headers $modelHeaders `
                -UseBasicParsing `
                -TimeoutSec 15

            $reply = ""
            $raw = if ($response -is [string]) { $response } else { $response.Content }
            if ($raw) {
                $lines = $raw -split "`n"
                foreach ($line in $lines) {
                    if ($line -match '^data: (.+)$' -and $Matches[1] -ne "[DONE]") {
                        try {
                            $json = $Matches[1] | ConvertFrom-Json
                            if ($json.choices[0].message.content) {
                                $reply = $json.choices[0].message.content
                            } elseif ($json.choices[0].message.reasoning_content) {
                                $reply = $json.choices[0].message.reasoning_content
                            }
                        } catch {}
                    }
                }
            }

            if ($reply) {
                Write-OK "$model : responding"
            } else {
                Write-Skip "$model : empty response"
            }
        } catch {
            Write-Skip "$model : $($_.Exception.Message)"
        }
    }
} else {
    Write-Skip "API key not set, skipping model test"
}

# ============================================================
# [7/7] SUMMARY
# ============================================================

Write-Step "7/$totalSteps" "Summary"

Write-Host ""
if ($allGood) {
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "   All systems GO!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
} else {
    Write-Host "  ========================================" -ForegroundColor Yellow
    Write-Host "   Some issues detected" -ForegroundColor Yellow
    Write-Host "  ========================================" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Profile:   $Profile" -ForegroundColor White
Write-Host "  Config:    $OPENCODE_CONFIG" -ForegroundColor White
Write-Host "  9Router:   $API_URL" -ForegroundColor White
Write-Host "  Dashboard: $API_URL/dashboard" -ForegroundColor White
Write-Host ""

if ($Profile -eq "gratis") {
    Write-Host "  Models:" -ForegroundColor Yellow
    Write-Host "    Primary:   mmf/mimo-auto -> oc/deepseek-v4-flash-free -> oc/mimo-v2.5-free" -ForegroundColor White
    Write-Host "    Emergency: oc/nemotron-3-ultra-free -> oc/big-pickle -> oc/north-mini-code-free" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""

# Create llm-status.json so AI knows setup is done
$statusFile = "$ROOT_DIR\.opencode\llm-status.json"
New-Item -ItemType Directory -Path (Split-Path $statusFile -Parent) -Force | Out-Null
$status = @{
    mode = "PERFORMANCE"
    user_mode = "User"
    enrich = "On"
    enrich_time = 0
    profile = $Profile
    cloud = $Profile
    last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json -Depth 3
Set-Content -Path $statusFile -Value $status -Encoding UTF8
Write-Host "  [OK] llm-status.json created" -ForegroundColor Green

