# OpenCode Free Config Restore Script
# Restore konfigurasi 100% free models via 9Router

$ErrorActionPreference = "Stop"

$CONFIG_DIR = "$env:USERPROFILE\.config\opencode"
$CONFIG_FILE = "$CONFIG_DIR\opencode.jsonc"
$BACKUP_DIR = "$CONFIG_DIR\backups"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=== OpenCode Free Config Restore ===" -ForegroundColor Cyan

# Backup current config
if (Test-Path $CONFIG_FILE) {
    if (-not (Test-Path $BACKUP_DIR)) {
        New-Item -ItemType Directory -Path $BACKUP_DIR -Force | Out-Null
    }
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = "$BACKUP_DIR\opencode.jsonc.$timestamp.bak"
    Copy-Item $CONFIG_FILE $backupFile
    Write-Host "Backed up current config to: $backupFile" -ForegroundColor Green
}

# Copy free config
$sourceConfig = "$SCRIPT_DIR\opencode-free-config.jsonc"
if (-not (Test-Path $sourceConfig)) {
    Write-Host "ERROR: opencode-free-config.jsonc not found in $SCRIPT_DIR" -ForegroundColor Red
    exit 1
}

Copy-Item $sourceConfig $CONFIG_FILE -Force
Write-Host "Restored free config to: $CONFIG_FILE" -ForegroundColor Green

# Verify 9Router is running
try {
    $health = Invoke-RestMethod -Uri "http://localhost:20128/api/health" -TimeoutSec 5
    if ($health.ok) {
        Write-Host "9Router: OK (running)" -ForegroundColor Green
    }
} catch {
    Write-Host "9Router: NOT RUNNING - Start it first!" -ForegroundColor Red
    Write-Host "  Run: 9router --tray" -ForegroundColor Yellow
}

# Verify env var
if ($env:NINEROUTER_API_KEY) {
    Write-Host "NINEROUTER_API_KEY: SET" -ForegroundColor Green
} else {
    Write-Host "NINEROUTER_API_KEY: NOT SET" -ForegroundColor Red
    Write-Host "  Set it: `$env:NINEROUTER_API_KEY = 'sk-...'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done! Restart OpenCode to apply." -ForegroundColor Cyan
Write-Host "Free models: oc/mimo-v2.5-free, oc/deepseek-v4-flash-free" -ForegroundColor Gray
