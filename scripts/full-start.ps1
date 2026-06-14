# Full Start — Auto-deploy workflow: start → set-project → code-analyze → analyze-project
# Usage: .\full-start.ps1 -Profile gratis|go [-ProjectPath "C:\path\to\project"]

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

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Full Start — Master Control              ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Step 1: Start
Write-Host "  [1/3] Start workflow ($Profile)..." -ForegroundColor Cyan
& "$SETUP_DIR\start.ps1" -Profile $Profile -ProjectPath $ProjectPath
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { Write-Host "  [FAIL] Start failed" -ForegroundColor Red; exit 1 }

# Step 2: Code Analyze (if project has no PRD)
if (-not $ProjectPath) {
    try {
        $session = Get-Content "$ROOT_DIR\.opencode-session.json" -Raw | ConvertFrom-Json
        if ($session.PSObject.Properties.Name -contains "current_project") { $ProjectPath = $session.current_project }
    } catch {}
}

if ($ProjectPath -and -not (Test-Path "$ProjectPath\prd.md")) {
    Write-Host ""
    Write-Host "  [2/3] Code Analyze..." -ForegroundColor Cyan
    & "$SETUP_DIR\code-analyze.ps1" -ProjectPath $ProjectPath
    Write-Host ""
    Write-Host "  [3/3] Done!" -ForegroundColor Cyan
} elseif ($ProjectPath -and (Test-Path "$ProjectPath\prd.md")) {
    Write-Host ""
    Write-Host "  [SKIP] PRD found. Use /project-analyze instead" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Ready! Buka OpenCode               ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host "  Commands: /code-review, /security, /tdd, /verify" -ForegroundColor Cyan
Write-Host ""
