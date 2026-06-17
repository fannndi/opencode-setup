# OpenCode Setup - Smart installer with detection
# Usage:
#   .\setup.ps1              # First run: install everything, stop at api-key
#   .\setup.ps1 --apply      # Second run: apply api-key, verify, done
#   .\setup.ps1 --profile go # Use go profile instead of gratis

param(
    [switch]$Apply,
    [ValidateSet("gratis", "go")]
    [string]$Profile = "gratis"
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$ECC_DIR = "$ROOT_DIR\ecc"
$OPENCODE_CONFIG_DIR = "$env:USERPROFILE\.config\opencode"
$OPENCODE_CONFIG = "$OPENCODE_CONFIG_DIR\opencode.jsonc"
$API_KEY_FILE = "$ROOT_DIR\api-key.txt"

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

function Test-Command {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

function Test-PortOpen {
    param([int]$Port)
    return [bool](Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue)
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   OpenCode Setup" -ForegroundColor Cyan
Write-Host "   ECC + 9Router + Free Models" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# MODE: --apply (second run after filling api-key.txt)
# ============================================================

if ($Apply) {
    Write-Host "  Mode: APPLY (reading api-key.txt)" -ForegroundColor Yellow
    Write-Host ""

    # Step A: Read api-key.txt
    Write-Step "A" "Reading api-key.txt..."

    if (-not (Test-Path $API_KEY_FILE)) {
        Write-Fail "api-key.txt not found at: $API_KEY_FILE"
        Write-Host "  Run .\setup.ps1 first to generate it." -ForegroundColor Yellow
        exit 1
    }

    $keyContent = Get-Content $API_KEY_FILE -ErrorAction SilentlyContinue
    if (-not $keyContent) { $keyContent = @() }
    $keyLines = @($keyContent | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' })

    if ($keyLines.Count -eq 0) {
        Write-Fail "api-key.txt is empty or all lines are comments"
        Write-Host "  Edit $API_KEY_FILE and add your API key." -ForegroundColor Yellow
        exit 1
    }

    $apiKey = [string]$keyLines[0].Trim()
    if ($apiKey -match '=') {
        $apiKey = ($apiKey -split '=', 2)[1].Trim()
    }

    if ([string]::IsNullOrWhiteSpace($apiKey) -or $apiKey -eq 'YOUR-API-KEY-HERE') {
        Write-Fail "API key not filled in api-key.txt"
        Write-Host "  Edit $API_KEY_FILE and replace placeholder with real key." -ForegroundColor Yellow
        exit 1
    }

    Write-OK "API key loaded ($($apiKey.Substring(0, [Math]::Min(8, $apiKey.Length)))...)"

    # Set env var
    [Environment]::SetEnvironmentVariable('NINEROUTER_API_KEY', $apiKey, 'User')
    $env:NINEROUTER_API_KEY = $apiKey
    Write-OK "NINEROUTER_API_KEY set"

    # Step B: Start 9Router if not running
    Write-Step "B" "Check 9Router..."

    if (Test-PortOpen 20128) {
        Write-OK "9Router already running on port 20128"
    } else {
        if (Test-Command "9router") {
            Write-Info "Starting 9Router..."
            Start-Process -FilePath "9router" -WindowStyle Minimized
            Start-Sleep -Seconds 3

            if (Test-PortOpen 20128) {
                Write-OK "9Router started"
            } else {
                Write-Skip "9Router may need manual start: run '9router' in terminal"
            }
        } else {
            Write-Fail "9Router not installed. Run: npm install -g 9router"
            exit 1
        }
    }

    # Step C: Verify
    Write-Step "C" "Verify setup..."

    try {
        $health = Invoke-RestMethod -Uri "http://localhost:20128/api/health" -TimeoutSec 5
        if ($health.ok) {
            Write-OK "9Router health: OK"
        }
    } catch {
        Write-Skip "9Router health check failed"
    }

    if (Test-Path $OPENCODE_CONFIG) {
        Write-OK "Config exists: $OPENCODE_CONFIG"
    } else {
        Write-Fail "Config not found: $OPENCODE_CONFIG"
    }

    # Summary
    Write-Host ""
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host "   Setup Complete!" -ForegroundColor Green
    Write-Host "  ========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next:" -ForegroundColor Yellow
    Write-Host "    1. Open terminal" -ForegroundColor White
    Write-Host "    2. Type: opencode" -ForegroundColor White
    Write-Host "    3. Start coding!" -ForegroundColor White
    Write-Host ""

    # Create llm-status.json so AI knows setup is done
    $statusFile = "$ROOT_DIR\.opencode\llm-status.json"
    New-Item -ItemType Directory -Path (Split-Path $statusFile -Parent) -Force | Out-Null
    $status = @{
        mode = "PERFORMANCE"
        user_mode = "Admin"
        enrich = "On"
        enrich_time = 0
        profile = $Profile
        cloud = $Profile
        last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
    } | ConvertTo-Json -Depth 3
    Set-Content -Path $statusFile -Value $status -Encoding UTF8
    Write-Host "  [OK] llm-status.json created" -ForegroundColor Green

    exit 0
}

# ============================================================
# MODE: First run (default)
# ============================================================

Write-Host "  Mode: INSTALL" -ForegroundColor Green
Write-Host ""

# ============================================================
# Step 1: Pre-flight checks
# ============================================================

Write-Step "1" "Pre-flight checks..."

# Node.js
if (-not (Test-Command "node")) {
    Write-Fail "Node.js not found"
    Write-Host "  Install from: https://nodejs.org (v20+ LTS)" -ForegroundColor Yellow
    exit 1
}
Write-OK "Node.js $(node --version)"

# npm
if (-not (Test-Command "npm")) {
    Write-Fail "npm not found"
    exit 1
}
Write-OK "npm $(npm --version)"

# Git
if (-not (Test-Command "git")) {
    Write-Fail "Git not found"
    Write-Host "  Install from: https://git-scm.com" -ForegroundColor Yellow
    exit 1
}
Write-OK "Git $(git --version)"

# OpenCode
if (-not (Test-Command "opencode")) {
    Write-Info "OpenCode not found. Installing..."
    npm install -g opencode
    if (-not (Test-Command "opencode")) {
        Write-Fail "OpenCode install failed. Run manually: npm install -g opencode"
        exit 1
    }
}
Write-OK "OpenCode installed"

# ============================================================
# Step 2: Detect 9Router
# ============================================================

Write-Step "2" "Detect 9Router..."

$routerInstalled = Test-Command "9router"
$routerRunning = Test-PortOpen 20128

if ($routerInstalled -and $routerRunning) {
    Write-OK "9Router installed + running on port 20128"
} elseif ($routerInstalled) {
    Write-OK "9Router installed (not running)"
    Write-Info "Will start after api-key is configured"
} else {
    Write-Info "9Router not found. Installing..."
    npm install -g 9router
    if (Test-Command "9router") {
        Write-OK "9Router installed"
    } else {
        Write-Skip "9Router install failed. Run manually later: npm install -g 9router"
    }
}

# ============================================================
# Step 3: Clone/Pull ECC
# ============================================================

Write-Step "3" "Clone/Pull ECC..."

if (Test-Path "$ECC_DIR\.git") {
    Write-Info "ECC exists, pulling latest..."
    Push-Location $ECC_DIR
    git pull --quiet
    Pop-Location
    Write-OK "ECC updated"
} else {
    Write-Info "Cloning fannndi/ECC..."
    git clone --quiet https://github.com/fannndi/ECC.git $ECC_DIR
    if (Test-Path "$ECC_DIR\.git") {
        Write-OK "ECC cloned"
    } else {
        Write-Fail "ECC clone failed. Check internet connection."
        exit 1
    }
}

# ============================================================
# Step 4: Install ECC dependencies + build plugin
# ============================================================

Write-Step "4" "Install ECC dependencies..."

Push-Location $ECC_DIR

if (-not (Test-Path "node_modules")) {
    Write-Info "Installing root dependencies..."
    npm install --silent 2>$null
}
Write-OK "Root dependencies"

if (-not (Test-Path ".opencode\node_modules")) {
    Write-Info "Installing .opencode dependencies..."
    Push-Location ".opencode"
    npm install --silent 2>$null
    Pop-Location
}
Write-OK ".opencode dependencies"

Pop-Location

# Build plugin
Write-Step "4b" "Build ECC plugin..."

Push-Location $ECC_DIR
npm run build:opencode 2>$null
if (Test-Path ".opencode\dist\index.js") {
    Write-OK "Plugin built"
} else {
    Write-Skip "Plugin build failed (non-critical)"
}
Pop-Location

# ============================================================
# Step 5: Apply profile config
# ============================================================

Write-Step "5" "Apply profile: $Profile..."

# Backup existing config
if (Test-Path $OPENCODE_CONFIG) {
    $backup = "$OPENCODE_CONFIG.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $OPENCODE_CONFIG $backup
    Write-OK "Config backed up"
}

# Copy profile
$profileConfig = "$ROOT_DIR\profiles\$Profile\opencode.jsonc"
if (Test-Path $profileConfig) {
    New-Item -ItemType Directory -Force -Path $OPENCODE_CONFIG_DIR | Out-Null
    Copy-Item $profileConfig $OPENCODE_CONFIG -Force

    # Fix hardcoded paths
    $configContent = Get-Content $OPENCODE_CONFIG -Raw
    $configContent = $configContent.Replace("C:/Users/FANNNDI/Documents/opencode-setup", $ROOT_DIR.ToString().Replace('\', '/'))
    Set-Content -Path $OPENCODE_CONFIG -Value $configContent -Encoding UTF8

    Write-OK "Profile '$Profile' applied"
} else {
    Write-Fail "Profile not found: $profileConfig"
    exit 1
}

# ============================================================
# Step 6: Set environment variables
# ============================================================

Write-Step "6" "Set environment variables..."

[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'standard', 'User')
Write-OK "ECC_HOOK_PROFILE=standard"

# Check existing NINEROUTER_API_KEY
$existingKey = [Environment]::GetEnvironmentVariable('NINEROUTER_API_KEY', 'User')
if ($existingKey -and $existingKey -ne 'SET-YOUR-KEY-FROM-DASHBOARD' -and $existingKey -ne '') {
    Write-OK "NINEROUTER_API_KEY already set"
} else {
    Write-Skip "NINEROUTER_API_KEY not set (waiting for api-key.txt)"
}

# ============================================================
# Step 7: Generate api-key.txt
# ============================================================

Write-Step "7" "Generate api-key.txt..."

if (Test-Path $API_KEY_FILE) {
    Write-Skip "api-key.txt already exists"
} else {
    $apiTemplate = @"
# OpenCode API Key
# =================
# Get your API key from 9Router dashboard:
#   1. Open http://localhost:20128/dashboard
#   2. Login (password: 123456)
#   3. Go to Endpoint page
#   4. Create a new API key
#   5. Paste the key below (replace this line)
#
# Format: just paste the key, or KEY=value
# Lines starting with # are ignored

YOUR-API-KEY-HERE
"@
    Set-Content -Path $API_KEY_FILE -Value $apiTemplate -Encoding UTF8
    Write-OK "api-key.txt created"
}

# ============================================================
# STOP: User needs to fill api-key.txt
# ============================================================

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Yellow
Write-Host "   SETUP PAUSED" -ForegroundColor Yellow
Write-Host "  ========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host "  1. Open: $API_KEY_FILE" -ForegroundColor Cyan
Write-Host "  2. Replace YOUR-API-KEY-HERE with your real key" -ForegroundColor White
Write-Host "  3. Run: .\setup.ps1 --apply" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Get API key from:" -ForegroundColor Yellow
Write-Host "    http://localhost:20128/dashboard" -ForegroundColor White
Write-Host "    Login: password 123456" -ForegroundColor White
Write-Host ""
