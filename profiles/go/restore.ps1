# Restore Go Profile (Limited Quota Models)
# Switch global OpenCode config to Go models with auto-fallback combos

$ErrorActionPreference = "Stop"

$CONFIG_DIR = "$env:USERPROFILE\.config\opencode"
$CONFIG_FILE = "$CONFIG_DIR\opencode.jsonc"
$BACKUP_DIR = "$CONFIG_DIR\backups"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$SOURCE_CONFIG = "$SCRIPT_DIR\opencode.jsonc"

Write-Host "=== Restore Go Profile ===" -ForegroundColor Cyan
Write-Host "Models: ocg/kimi-k2.6 -> ocg/qwen3.6-plus -> ocg/glm-5.1" -ForegroundColor Gray
Write-Host "WARNING: Go models have limited quota!" -ForegroundColor Yellow

# Backup current config
if (Test-Path $CONFIG_FILE) {
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = "$BACKUP_DIR\opencode.jsonc.$timestamp.bak"
    Copy-Item $CONFIG_FILE $backupFile
    Write-Host "Backup: $backupFile" -ForegroundColor Green
}

# Copy config
if (-not (Test-Path $SOURCE_CONFIG)) {
    Write-Host "ERROR: opencode.jsonc not found in $SCRIPT_DIR" -ForegroundColor Red
    exit 1
}

Copy-Item $SOURCE_CONFIG $CONFIG_FILE -Force

# Fix hardcoded paths → dynamic
$ROOT_DIR = Resolve-Path "$SCRIPT_DIR\..\.."
$oldPath = "C:/Users/FANNNDI/Documents/opencode-setup"
$configContent = Get-Content $CONFIG_FILE -Raw
$configContent = $configContent.Replace($oldPath, $ROOT_DIR.ToString().Replace('\', '/'))
Set-Content -Path $CONFIG_FILE -Value $configContent -Encoding UTF8
Write-Host "Restored: $CONFIG_FILE" -ForegroundColor Green

# Verify 9Router
try {
    $health = Invoke-RestMethod -Uri "http://localhost:20128/api/health" -TimeoutSec 5
    if ($health.ok) {
        Write-Host "9Router: OK" -ForegroundColor Green
    }
} catch {
    Write-Host "9Router: NOT RUNNING - Run: 9router --tray" -ForegroundColor Red
}

# Verify combos
try {
    Invoke-RestMethod -Uri "http://localhost:20128/api/auth/login" -Method POST -Body '{"password":"123456"}' -ContentType "application/json" -SessionVariable session | Out-Null
    $combos = Invoke-RestMethod -Uri "http://localhost:20128/api/combos" -WebSession $session
    $names = $combos.combos | ForEach-Object { $_.name }
    Write-Host "Combos: $($names -join ', ')" -ForegroundColor Green
} catch {
    Write-Host "Combos: unable to verify" -ForegroundColor Yellow
}

# Verify env var
if ($env:NINEROUTER_API_KEY) {
    Write-Host "NINEROUTER_API_KEY: SET" -ForegroundColor Green
} else {
    Write-Host "NINEROUTER_API_KEY: NOT SET" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done! Restart OpenCode to apply." -ForegroundColor Cyan
