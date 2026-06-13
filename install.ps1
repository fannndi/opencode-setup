# ECC Setup Installer for OpenCode
# Usage: .\install.ps1 -Profile gratis|go [-ECCRoot <path>]

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("gratis", "go")]
    [string]$Profile,

    [string]$ECCRoot
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- Detect ECC Root ---
if ($ECCRoot) {
    $ECCRoot = Resolve-Path $ECCRoot
} elseif (Test-Path "$ScriptDir\..\rules") {
    $ECCRoot = Resolve-Path "$ScriptDir\.."
} elseif (Test-Path "$ScriptDir\..\..\rules") {
    $ECCRoot = Resolve-Path "$ScriptDir\..\.."
} else {
    Write-Host "[!] ECC repo not found. cloning to temp directory..." -ForegroundColor Yellow
    $ECCRoot = "$env:TEMP\ecc"
    git clone https://github.com/fannndi/ECC.git $ECCRoot
}

$OpenCodeDir = "$env:USERPROFILE\.config\opencode"
$RulesTarget = "$OpenCodeDir\rules\ecc"
$ConfigFile = "$OpenCodeDir\opencode.jsonc"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " ECC OpenCode Setup - Profile: $Profile" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Backup existing config ---
if (Test-Path $ConfigFile) {
    $BackupFile = "$ConfigFile.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $ConfigFile $BackupFile
    Write-Host "[*] Existing config backed up to: $BackupFile" -ForegroundColor Gray
}

# --- Step 2: Copy opencode.jsonc ---
$SourceConfig = "$ScriptDir\$Profile\opencode.jsonc"
if (!(Test-Path $SourceConfig)) {
    Write-Host "[ERROR] Config not found: $SourceConfig" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $OpenCodeDir | Out-Null
Copy-Item $SourceConfig $ConfigFile
Write-Host "[OK] Config copied: $Profile -> $ConfigFile" -ForegroundColor Green

# --- Step 3: Copy rules ---
Write-Host "[*] Installing rules (common + typescript + python + golang)..." -ForegroundColor Gray

New-Item -ItemType Directory -Force -Path $RulesTarget | Out-Null

$RuleDirs = @("common", "typescript", "python", "golang")
foreach ($dir in $RuleDirs) {
    $Src = "$ECCRoot\rules\$dir"
    $Dst = "$RulesTarget\$dir"
    if (Test-Path $Src) {
        if (Test-Path $Dst) { Remove-Item -Recurse -Force $Dst }
        Copy-Item -Recurse $Src $Dst
        Write-Host "  [OK] rules/$dir" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] rules/$dir not found" -ForegroundColor Yellow
    }
}

# --- Step 4: Build plugin ---
Write-Host ""
Write-Host "[*] Building OpenCode plugin..." -ForegroundColor Gray

Push-Location $ECCRoot

if (!(Test-Path "node_modules")) {
    Write-Host "  [*] Installing root dependencies..." -ForegroundColor Gray
    npm install --silent
}

if (!(Test-Path ".opencode\node_modules")) {
    Write-Host "  [*] Installing .opencode dependencies..." -ForegroundColor Gray
    Push-Location ".opencode"
    npm install --silent
    Pop-Location
}

npm run build:opencode
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Plugin build failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "[OK] Plugin built successfully" -ForegroundColor Green

Pop-Location

# --- Step 5: Set environment variables ---
Write-Host "[*] Setting environment variables..." -ForegroundColor Gray

[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'standard', 'User')
[Environment]::SetEnvironmentVariable('ECC_AGENT_DATA_HOME', "$env:USERPROFILE\.opencode\ecc", 'User')

Write-Host "  [OK] ECC_HOOK_PROFILE=standard" -ForegroundColor Green
Write-Host "  [OK] ECC_AGENT_DATA_HOME=$env:USERPROFILE\.opencode\ecc" -ForegroundColor Green

# --- Step 6: Summary ---
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host " Profile:      $Profile" -ForegroundColor White
Write-Host " Config:       $ConfigFile" -ForegroundColor White
Write-Host " Rules:        $RulesTarget" -ForegroundColor White
Write-Host " ECC Root:     $ECCRoot" -ForegroundColor White
Write-Host ""
Write-Host "Model mapping:" -ForegroundColor Yellow

if ($Profile -eq "gratis") {
    Write-Host "  Primary:    opencode/mimo-v2.5-free" -ForegroundColor White
    Write-Host "  Subagent:   opencode/deepseek-v4-flash-free" -ForegroundColor White
    Write-Host "  Cost:       FREE (rate limited)" -ForegroundColor Green
} else {
    Write-Host "  Primary:    opencode-go/kimi-k2.7" -ForegroundColor White
    Write-Host "  Reasoning:  opencode-go/qwen3.7-max" -ForegroundColor White
    Write-Host "  Review:     opencode-go/deepseek-v4-pro" -ForegroundColor White
    Write-Host "  Cost:       $5/first month, $10/mo" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Login OpenCode:  opencode /connect" -ForegroundColor White
Write-Host "  2. Start OpenCode:  opencode" -ForegroundColor White
Write-Host "  3. Test:            /plan 'add auth feature'" -ForegroundColor White
Write-Host ""
