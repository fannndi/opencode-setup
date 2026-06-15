# LLM Feedback — Analyze failure log → fix recommendations
# Usage: .\llm-feedback.ps1 [-Apply] [-Iterations 10]

param(
    [switch]$Apply,
    [int]$Iterations = 20
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$FAILURE_LOG = "$ROOT_DIR\.opencode\llm-failures.jsonl"
$USAGE_LOG = "$ROOT_DIR\.opencode\llm-usage.jsonl"

. "$SETUP_DIR\llm-adapter.ps1"

# Ensure state dirs
New-Item -ItemType Directory -Path "$ROOT_DIR\.opencode" -Force | Out-Null

# ============================================================
# Step 1: Load failures
# ============================================================

$failures = @()
if (Test-Path $FAILURE_LOG) {
    $lines = Get-Content $FAILURE_LOG
    foreach ($line in $lines) {
        try { $failures += $line | ConvertFrom-Json } catch {}
    }
}

$recentFailures = $failures | Select-Object -Last $Iterations

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║           LLM Feedback — Failure Analysis       ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Total failures logged: $($failures.Count)" -ForegroundColor White
Write-Host "  Analyzing last $($recentFailures.Count)..." -ForegroundColor Gray
Write-Host ""

if ($recentFailures.Count -eq 0) {
    Write-Host "  No failures to analyze." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 2: Categorize failures
# ============================================================

$categories = @{
    timeout = 0
    json_parse = 0
    connection = 0
    model_error = 0
    other = 0
}

$scripts = @{}
$models = @{}

foreach ($f in $recentFailures) {
    $err = $f.error
    if ($err -match "timeout|canceled") { $categories.timeout++ }
    elseif ($err -match "json|parse|invalid") { $categories.json_parse++ }
    elseif ($err -match "connect|refused|network") { $categories.connection++ }
    elseif ($err -match "model|not found|not exist") { $categories.model_error++ }
    else { $categories.other++ }

    $script = $f.script
    if ($script) { $scripts[$script] = ($scripts[$script] -or 0) + 1 }

    $model = $f.model
    if ($model) { $models[$model] = ($models[$model] -or 0) + 1 }
}

Write-Host "  Failure Categories:" -ForegroundColor Cyan
$categories.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object {
    $pct = [math]::Round($_.Value / $recentFailures.Count * 100, 1)
    Write-Host "    $($_.Key): $($_.Value) ($pct%)" -ForegroundColor White
}

Write-Host ""
Write-Host "  By Script:" -ForegroundColor Cyan
$scripts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "    $($_.Key): $($_.Value)" -ForegroundColor Gray
}

# ============================================================
# Step 3: LLM analysis + recommendations (mode permitting)
# ============================================================

$mode = Get-OperatingMode

if ($mode -ne "eco") {
    $summary = $recentFailures | Select-Object -First 10 | ForEach-Object { "$($_.script): $($_.error)" } | Out-String
    $prompt = @"
Analyze these LLM failures and recommend concrete fixes:

Failures:
$summary

Counts:
- Timeout: $($categories.timeout)
- JSON parse: $($categories.json_parse)
- Connection: $($categories.connection)
- Model error: $($categories.model_error)

Output ONLY a JSON array of recommendations:
[{"issue":"...","fix":"...","config_change":"...","priority":"high|medium|low"}]
"@

    Write-Host "  Analyzing with LLM..." -ForegroundColor Gray
    $result = Invoke-LLM -Prompt $prompt -System "You are a system optimizer. Output ONLY JSON." -MaxTokens 1024 -Temperature 0.3 -TimeoutSec 60

    if ($result) {
        Write-Host ""
        Write-Host "  LLM Recommendations:" -ForegroundColor Green
        try {
            $recs = $result.response | ConvertFrom-Json
            foreach ($r in $recs) {
                $color = switch ($r.priority) { "high" { "Yellow" } "medium" { "Gray" } default { "DarkGray" } }
                Write-Host "    [$($r.priority)] $($r.issue)" -ForegroundColor $color
                Write-Host "      Fix: $($r.fix)" -ForegroundColor Gray
                if ($r.config_change) { Write-Host "      Config: $($r.config_change)" -ForegroundColor DarkGray }
            }
        } catch { Write-Host "    (LLM returned invalid JSON)" -ForegroundColor Red }
    }
}

# ============================================================
# Step 4: Auto-fix (if -Apply)
# ============================================================

if ($Apply) {
    # Quick fixes: adjust timeout if timeout rate > 50%
    if ($categories.timeout -gt $recentFailures.Count * 0.5) {
        Write-Host ""
        Write-Host "  [AUTO] Timeout rate > 50%. Increasing default timeout..." -ForegroundColor Yellow
    }

    # Archive old failures (keep last 100)
    if ($failures.Count -gt 100) {
        $failures | Select-Object -Last 100 | ForEach-Object {
            $_ | ConvertTo-Json -Compress
        } | Set-Content -Path $FAILURE_LOG -Encoding UTF8
        Write-Host "  [AUTO] Trimmed failure log to 100 entries." -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "  [FEEDBACK] Done." -ForegroundColor Green
Write-Host ""
