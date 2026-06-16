# Token Tracker — Track token usage from 9Router
# Usage: .\token-tracker.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$API_URL = "http://localhost:20128"
$ROUTER_ENV = "$ROOT_DIR\9router\.env"
$API_PASS = if ($env:NINEROUTER_PASSWORD) { $env:NINEROUTER_PASSWORD } elseif (Test-Path $ROUTER_ENV) { (Select-String 'INITIAL_PASSWORD=(.+)' (Get-Content $ROUTER_ENV)).Matches.Groups[1].Value } else { "admin" }

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║         Token Tracker — Usage Overview          ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$totalTokens = 0
$totalCalls = 0

# Try to get observability data from 9Router
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" -Method POST -Body "{`"password`":`"$API_PASS`"}" -ContentType "application/json" -SessionVariable httpSession | Out-Null

    # Check if 9Router has observability endpoint
    $obs = Invoke-RestMethod -Uri "$API_URL/api/settings" -WebSession $httpSession -ErrorAction SilentlyContinue
    $observabilityEnabled = $obs.enableObservability

    if ($observabilityEnabled) {
        Write-Host "  [OK] Observability enabled in 9Router" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Observability disabled in 9Router" -ForegroundColor Yellow
    }

    # Check models list to see available providers
    $models = Invoke-RestMethod -Uri "$API_URL/v1/models" -WebSession $httpSession -ErrorAction SilentlyContinue
    $allModels = ($models | Select-Object -ExpandProperty data).Count
    Write-Host "  Models available: $allModels" -ForegroundColor White

    # Get combo info
    $combos = Invoke-RestMethod -Uri "$API_URL/api/combos" -WebSession $httpSession
    foreach ($combo in $combos.combos) {
        Write-Host "  Combo '$($combo.name)': $($combo.models.Count) models" -ForegroundColor Gray
    }

} catch {
    Write-Host "  [WARN] 9Router API unavailable: $($_.Exception.Message)" -ForegroundColor Yellow
}

# ============================================================
# Session stats
# ============================================================

Write-Host ""
Write-Host "  ─── Session Stats ───" -ForegroundColor Cyan

$activeProject = Get-ActiveProject
if ($activeProject) {
    $sessionFile = Get-SessionFile -ProjectPath $activeProject
    if (Test-Path $sessionFile) {
        try {
            $session = Get-Content $sessionFile -Raw | ConvertFrom-Json
            Write-Host "  Profile:     $($session.last_profile)" -ForegroundColor White
            Write-Host "  Project:     $($session.project_name)" -ForegroundColor White
            Write-Host "  Path:        $($session.project_path)" -ForegroundColor White
            Write-Host "  Stack:       $($session.stack)" -ForegroundColor White
            Write-Host "  Last action: $($session.last_action)" -ForegroundColor White

            if ($session.PSObject.Properties.Name -contains "total_tokens" -and $session.total_tokens -gt 0) {
                $totalTokens = $session.total_tokens
                $totalCalls = $session.total_calls
            }
        } catch {
            Write-Host "  No session data" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No session data" -ForegroundColor Gray
    }
} else {
    Write-Host "  No active project" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  ─── Estimated Usage ───" -ForegroundColor Cyan
Write-Host "  Total tokens: $totalTokens" -ForegroundColor White
Write-Host "  API calls:    $totalCalls" -ForegroundColor White

if ($activeProject) {
    $sessionFile = Get-SessionFile -ProjectPath $activeProject
    if (Test-Path $sessionFile) {
        try {
            $session = Get-Content $sessionFile -Raw | ConvertFrom-Json
            if ($session.last_profile -eq "gratis") {
                Write-Host "  Cost:        FREE" -ForegroundColor Green
            } else {
                $estCost = [math]::Round(($totalTokens / 1000000) * 5, 2)
                Write-Host "  Est. cost:   `$$estCost (Go rate)" -ForegroundColor Yellow
            }
        } catch {}
    }
}

if ($totalTokens -gt 100000) {
    Write-Host ""
    Write-Host "  ⚠️  High token usage ($totalTokens). Consider /compact" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "  Next: /quality-gate — verify code quality" -ForegroundColor Cyan
Write-Host ""
