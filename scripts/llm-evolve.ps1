# LLM Evolve — Auto-adjust config from usage stats
# Usage: .\llm-evolve.ps1 [-Analyze] [-Apply]

param(
    [switch]$Analyze,
    [switch]$Apply
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$FAILURE_LOG = "$ROOT_DIR\.opencode\llm-failures.jsonl"
$USAGE_LOG = "$ROOT_DIR\.opencode\llm-usage.jsonl"

. "$SETUP_DIR\llm-adapter.ps1"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║           LLM Evolve — Self-Optimization        ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -Write-Host ""

# ============================================================
# Step 1: Load stats
# ============================================================

$failures = @()
if (Test-Path $FAILURE_LOG) {
    Get-Content $FAILURE_LOG | ForEach-Object {
        try { $failures += $_ | ConvertFrom-Json } catch {}
    }
}

$usage = @()
if (Test-Path $USAGE_LOG) {
    Get-Content $USAGE_LOG | ForEach-Object {
        try { $usage += $_ | ConvertFrom-Json } catch {}
    }
}

# ============================================================
# Step 2: Calculate stats
# ============================================================

$totalCalls = $usage.Count
$totalFailures = $failures.Count
$failureRate = if ($totalCalls -gt 0) { [math]::Round($totalFailures / $totalCalls * 100, 1) } else { 0 }

$timeoutCount = ($failures | Where-Object { $_.error -match "timeout|canceled" }).Count
$jsonFailCount = ($failures | Where-Object { $_.error -match "json|parse|invalid" }).Count

$avgLatency = if ($usage.Count -gt 0) {
    $times = $usage | ForEach-Object { $_.total_duration } | Where-Object { $_ -gt 0 }
    if ($times.Count -gt 0) { [math]::Round(($times | Measure-Object -Average).Average / 1e9, 2) } else { 0 }
} else { 0 }

Write-Host "  Stats:" -ForegroundColor Cyan
Write-Host "    Total calls:    $totalCalls" -ForegroundColor White
Write-Host "    Failures:       $totalFailures ($failureRate%)" -ForegroundColor $(if ($failureRate -gt 20) { "Red" } else { "Green" })
Write-Host "    Avg latency:    ${avgLatency}s" -ForegroundColor White
Write-Host "    Timeout rate:   $([math]::Round($timeoutCount / [math]::Max(1, $totalFailures) * 100, 1))%" -ForegroundColor Gray
Write-Host "    JSON fail rate: $([math]::Round($jsonFailCount / [math]::Max(1, $totalFailures) * 100, 1))%" -ForegroundColor Gray
Write-Host ""

# ============================================================
# Step 3: Determine optimal config
# ============================================================

$recommendations = @()

# Timeout: increase if timeout rate > 30%
if ($timeoutCount -gt $totalFailures * 0.3 -and $totalFailures -gt 2) {
    $recommendations += "Increase default TimeoutSec (current 60 -> 120)"
}

# Temperature: decrease if JSON parse errors > 30%
if ($jsonFailCount -gt $totalFailures * 0.3 -and $totalFailures -gt 2) {
    $recommendations += "Decrease default Temperature from 0.3 to 0.1 (stricter output)"
}

# Model: if failure rate > 50%, suggest switching
if ($failureRate -gt 50 -and $totalCalls -gt 10) {
    $recommendations += "High failure rate. Consider switching model or reducing chunk size"
}

if ($recommendations.Count -eq 0) {
    $recommendations += "System is healthy. No config changes needed."
}

Write-Host "  Recommendations:" -ForegroundColor Yellow
foreach ($r in $recommendations) {
    Write-Host "    • $r" -ForegroundColor White
}
Write-Host ""

# ============================================================
# Step 4: Log current state
# ============================================================

$state = [PSCustomObject]@{
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    total_calls = $totalCalls
    total_failures = $totalFailures
    failure_rate = $failureRate
    avg_latency_seconds = $avgLatency
    timeout_count = $timeoutCount
    json_fail_count = $jsonFailCount
    recommendations = $recommendations
}

$evolveLog = "$ROOT_DIR\.opencode\llm-evolve.jsonl"
Add-Content -Path $evolveLog -Value ($state | ConvertTo-Json -Compress) -Encoding UTF8
Write-Host "  [EVOLVE] State logged." -ForegroundColor Gray

# ============================================================
# Step 5: Apply fixes (if -Apply)
# ============================================================

if ($Apply) {
    $applied = @()
    
    # Auto-fix 1: Timeout rate > 30% → naikin default (set env var)
    if ($timeoutCount -gt $totalFailures * 0.3 -and $totalFailures -gt 2) {
        [Environment]::SetEnvironmentVariable("LLM_DEFAULT_TIMEOUT", "180", "User")
        $applied += "TimeoutSec default 60->180 (env: LLM_DEFAULT_TIMEOUT)"
    }
    
    # Auto-fix 2: JSON fail rate > 30% → turunin temperature
    if ($jsonFailCount -gt $totalFailures * 0.3 -and $totalFailures -gt 2) {
        [Environment]::SetEnvironmentVariable("LLM_DEFAULT_TEMPERATURE", "0.1", "User")
        $applied += "Temperature default 0.3->0.1 (env: LLM_DEFAULT_TEMPERATURE)"
    }
    
    # Auto-fix 3: Failure rate > 50% → switch ke balanced mode (smaller model)
    if ($failureRate -gt 50 -and $totalCalls -gt 10) {
        & "$SETUP_DIR\llm-mode.ps1" eco 2>$null
        $applied += "Switched to ECO mode (failure rate $failureRate%)"
    }
    
    # Auto-fix 4: Trim failure log kalo > 100 entries
    if ((Get-Content "$ROOT_DIR\.opencode\llm-failures.jsonl" -ErrorAction SilentlyContinue | Measure-Object).Count -gt 100) {
        $trimmed = Get-Content "$ROOT_DIR\.opencode\llm-failures.jsonl" -ErrorAction SilentlyContinue | Select-Object -Last 100
        $trimmed | Set-Content "$ROOT_DIR\.opencode\llm-failures.jsonl" -Encoding UTF8
        $applied += "Trimmed failure log to 100 entries"
    }
    
    if ($applied.Count -gt 0) {
        Write-Host ""
        Write-Host "  [EVOLVE] Applied $($applied.Count) fixes:" -ForegroundColor Green
        foreach ($a in $applied) { Write-Host "    • $a" -ForegroundColor Gray }
    } else {
        Write-Host "  [EVOLVE] No fixes needed." -ForegroundColor Gray
    }
}

Write-Host "  [EVOLVE] Done." -ForegroundColor Green
Write-Host ""
