# Token Tracker — Track token usage from 9Router
# Usage: .\token-tracker.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SESSION_FILE = "$ROOT_DIR\.opencode-session.json"
$API_URL = "http://localhost:20128"
$API_PASS = "123456"

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

if (Test-Path $SESSION_FILE) {
    try {
        $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
        Write-Host "  Profile:     $($session.last_profile)" -ForegroundColor White
        Write-Host "  Project:     $($session.current_project)" -ForegroundColor White
        Write-Host "  Stack:       $($session.stack)" -ForegroundColor White
        Write-Host "  Last action: $($session.last_action)" -ForegroundColor White
        Write-Host "  Iteration:   $($session.iteration)" -ForegroundColor White

        # Token tracking from session
        if ($session.PSObject.Properties.Name -contains "total_tokens" -and $session.total_tokens -gt 0) {
            $totalTokens = $session.total_tokens
            $totalCalls = $session.total_calls
        }

        Write-Host ""
        Write-Host "  ─── Estimated Usage ───" -ForegroundColor Cyan
        Write-Host "  Total tokens: $totalTokens" -ForegroundColor White
        Write-Host "  API calls:    $totalCalls" -ForegroundColor White

        # Estimate cost (free = $0)
        if ($session.last_profile -eq "gratis") {
            Write-Host "  Cost:        FREE" -ForegroundColor Green
        } else {
            $estCost = [math]::Round(($totalTokens / 1000000) * 5, 2)
            Write-Host "  Est. cost:   `$$estCost (Go rate)" -ForegroundColor Yellow
        }

        # Context warning
        if ($totalTokens -gt 100000) {
            Write-Host ""
            Write-Host "  ⚠️  High token usage ($totalTokens). Consider /compact" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  No session data" -ForegroundColor Gray
    }
} else {
    Write-Host "  No session data" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  Next: /quality-gate — verify code quality" -ForegroundColor Cyan
Write-Host ""
