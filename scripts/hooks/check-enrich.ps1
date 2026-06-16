# Self-Check Enrichment — Verify AI compliance post-response
# Usage: .\scripts\hooks\check-enrich.ps1 -Input "<user_input>"
# Returns: structured compliance report

param(
    [string]$Input,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"

$mode = Get-OperatingMode
$report = @{
    timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    input_length = if ($Input) { $Input.Length } else { 0 }
    mode = $mode
    enrichment_expected = ($mode -ne "eco")
    enrichment_success = $false
    issues = @()
}

# Check 1: Mode file exists
if (-not (Test-Path "$ROOT_DIR\.opencode\llm-mode.json")) {
    $report.issues += "MISSING: .opencode/llm-mode.json"
}

# Check 2: Model loaded
$modelLoaded = $false
$ollamaPs = & ollama ps 2>$null
if ($ollamaPs -match "qwen2.5") { $modelLoaded = $true }

if ($report.enrichment_expected -and -not $modelLoaded) {
    $report.issues += "WARNING: Model not loaded in VRAM despite PERFORMANCE mode"
}

# Check 3: Status file exists and has correct mode
if (Test-Path "$ROOT_DIR\.opencode\llm-status.json") {
    try {
        $status = Get-Content "$ROOT_DIR\.opencode\llm-status.json" -Raw | ConvertFrom-Json
        if ($status.enrich -eq "On") { $report.enrichment_success = $true }
    } catch {}
}

# Check 4: Context file exists
if (-not (Test-Path "$ROOT_DIR\.opencode\context.md")) {
    $report.issues += "MISSING: .opencode/context.md"
}

if (-not $Quiet) {
    Write-Host ""
    Write-Host "  ────── ENRICHMENT CHECK ──────" -ForegroundColor Cyan
    Write-Host "  Mode:       $($report.mode)" -ForegroundColor White
    Write-Host "  Expected:   $($report.enrichment_expected)" -ForegroundColor $(if ($report.enrichment_expected) { "Green" } else { "Gray" })
    Write-Host "  Success:    $($report.enrichment_success)" -ForegroundColor $(if ($report.enrichment_success) { "Green" } else { "Red" })
    Write-Host "  Model:      $($report.enrichment_expected -and $modelLoaded)" -ForegroundColor $(if ($modelLoaded) { "Green" } else { "Gray" })
    if ($report.issues.Count -gt 0) {
        Write-Host "  Issues:     $($report.issues.Count)" -ForegroundColor Red
        foreach ($issue in $report.issues) { Write-Host "    • $issue" -ForegroundColor Red }
    }
    Write-Host "  ─────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
}

return $report
