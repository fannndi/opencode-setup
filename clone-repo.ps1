# Clone ECC + 9Router repos and record SHA
# Usage: .\clone-repo.ps1 [-Force]

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = "$SETUP_DIR\ecc"
$ROUTER_DIR = "$SETUP_DIR\9router"
$SYNC_STATE = "$SETUP_DIR\.sync-state.json"

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

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Clone Repos - ECC + 9Router             ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Step 1: Clone ECC
# ============================================================

Write-Step "1/2" "Clone ECC (fannndi/ECC)..."

if (Test-Path "$ECC_DIR\.git") {
    if ($Force) {
        Write-Host "  Force mode: removing existing clone..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $ECC_DIR
        git clone --quiet https://github.com/fannndi/ECC.git $ECC_DIR
    } else {
        Write-Skip "ECC already cloned, pulling latest..."
        Push-Location $ECC_DIR
        git pull --quiet
        Pop-Location
    }
} else {
    Write-Host "  Cloning fannndi/ECC..." -ForegroundColor Gray
    git clone --quiet https://github.com/fannndi/ECC.git $ECC_DIR
}

$eccSHA = (git -C $ECC_DIR log -1 --format="%H")
$eccDate = (git -C $ECC_DIR log -1 --format="%ai")
$eccVersion = (Get-Content "$ECC_DIR\VERSION" -ErrorAction SilentlyContinue)
if (-not $eccVersion) { $eccVersion = "unknown" }
Write-OK "ECC cloned (SHA: $($eccSHA.Substring(0,7)), Version: $eccVersion, Date: $eccDate)"

# ============================================================
# Step 2: Clone 9Router
# ============================================================

Write-Step "2/2" "Clone 9Router (fannndi/9router)..."

if (Test-Path "$ROUTER_DIR\.git") {
    if ($Force) {
        Write-Host "  Force mode: removing existing clone..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $ROUTER_DIR
        git clone --quiet https://github.com/fannndi/9router.git $ROUTER_DIR
    } else {
        Write-Skip "9Router already cloned, pulling latest..."
        Push-Location $ROUTER_DIR
        git pull --quiet
        Pop-Location
    }
} else {
    Write-Host "  Cloning fannndi/9router..." -ForegroundColor Gray
    git clone --quiet https://github.com/fannndi/9router.git $ROUTER_DIR
}

$routerSHA = (git -C $ROUTER_DIR log -1 --format="%H")
$routerDate = (git -C $ROUTER_DIR log -1 --format="%ai")
Write-OK "9Router cloned (SHA: $($routerSHA.Substring(0,7)), Date: $routerDate)"

# ============================================================
# Update .sync-state.json
# ============================================================

$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"

$syncState = @{
    ecc = @{
        last_sha = $eccSHA
        last_sync = $timestamp
        repo = "fannndi/ECC"
        version = $eccVersion
    }
    "9router" = @{
        last_sha = $routerSHA
        last_sync = $timestamp
        repo = "fannndi/9router"
    }
} | ConvertTo-Json -Depth 5

Set-Content -Path $SYNC_STATE -Value $syncState -Encoding UTF8
Write-OK "SHA recorded to .sync-state.json"

# ============================================================
# Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Clone Complete!                     ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  ECC:     $ECC_DIR" -ForegroundColor White
Write-Host "  9Router: $ROUTER_DIR" -ForegroundColor White
Write-Host ""
Write-Host "  SHA:" -ForegroundColor Yellow
Write-Host "    ECC:     $($eccSHA.Substring(0,7)) ($eccVersion)" -ForegroundColor White
Write-Host "    9Router: $($routerSHA.Substring(0,7))" -ForegroundColor White
Write-Host ""
