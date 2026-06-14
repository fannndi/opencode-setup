# Auto Start — 1 command = chain semua workflow
# Usage: .\auto-start.ps1 [-Profile gratis|go] [-Mode existing|new] [-ProjectPath "C:\path"]

param(
    [ValidateSet("gratis", "go")]
    [string]$Profile = "gratis",
    
    [ValidateSet("existing", "new")]
    [string]$Mode = "existing",
    
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SESSION_FILE = "$ROOT_DIR\.opencode-session.json"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Auto Start — Full Workflow Chain        ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Step 1: Resolve project path
# ============================================================

if (-not $ProjectPath) {
    try {
        if (Test-Path $SESSION_FILE) {
            $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
            if ($session.PSObject.Properties.Name -contains "current_project") {
                $ProjectPath = $session.current_project
            }
        }
    } catch {}
}

if (-not $ProjectPath) {
    $ProjectPath = Read-Host "  Masukkan path project"
    if (-not (Test-Path $ProjectPath)) {
        Write-Host "  [ERROR] Path not found" -ForegroundColor Red; exit 1
    }
}

Write-Host "  [INFO] Profile: $Profile" -ForegroundColor White
Write-Host "  [INFO] Mode:    $Mode" -ForegroundColor White
Write-Host "  [INFO] Project: $ProjectPath" -ForegroundColor White
Write-Host ""

# ============================================================
# Step 2: Start workflow
# ============================================================

Write-Host "  [1/4] Starting workflow..." -ForegroundColor Cyan
& "$SETUP_DIR\start.ps1" -Profile $Profile -ProjectPath $ProjectPath
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Host "  [FAIL] Start failed. Check 9Router." -ForegroundColor Red
    exit 1
}

# ============================================================
# Step 3: Analyze code
# ============================================================

$hasPRD = Test-Path "$ProjectPath\prd.md"

if ($Mode -eq "existing" -or -not $hasPRD) {
    Write-Host ""
    Write-Host "  [2/4] Analyzing source code..." -ForegroundColor Cyan
    & "$SETUP_DIR\code-analyze.ps1" -ProjectPath $ProjectPath
} else {
    Write-Host ""
    Write-Host "  [2/4] Analyzing PRD..." -ForegroundColor Cyan
    & "$SETUP_DIR\project-analyze.ps1" -ProjectPath $ProjectPath
}

# ============================================================
# Step 4: Detect stack
# ============================================================

Write-Host ""
Write-Host "  [3/4] Detecting stack..." -ForegroundColor Cyan
& "$SETUP_DIR\analyze-project.ps1" -ProjectPath $ProjectPath

# ============================================================
# Step 5: Save memory
# ============================================================

Write-Host ""
Write-Host "  [4/4] Saving memory..." -ForegroundColor Cyan
$modeLabel = if ($Mode -eq "existing") { "Code analyze" } else { "PRD analyze" }
& "$SETUP_DIR\memory.ps1" -Action save -Value "Completed: $modeLabel on $(Split-Path $ProjectPath -Leaf)" -ProjectPath $ProjectPath

# ============================================================
# Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║         Auto Start — Complete!                  ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Project: $ProjectPath" -ForegroundColor White
Write-Host "  Mode:    $Mode" -ForegroundColor White
Write-Host "  Profile: $Profile" -ForegroundColor White
Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host "  Commands: /code-review, /security, /tdd, /verify" -ForegroundColor Cyan
Write-Host ""
