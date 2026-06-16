# Session Summary — Auto-generate end-of-session report
# Usage: .\scripts\session-summary.ps1 -Changes "file1, file2" -Mode "PERFORMANCE"
# Output: .opencode/session-summary.md

param(
    [string]$Changes = "(none)",
    [string]$Mode = "unknown",
    [string]$Task = "(not set)",
    [int]$Tokens = 0,
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SUMMARY_FILE = "$ROOT_DIR\.opencode\session-summary.md"

# Gather enrichment stats
$enrichStats = @{ total = 0; success = 0; fail = 0 }
$usageLog = "$ROOT_DIR\.opencode\llm-usage.jsonl"
if (Test-Path $usageLog) {
    Get-Content $usageLog -Tail 100 -ErrorAction SilentlyContinue | ForEach-Object {
        $enrichStats.total++
        $entry = $_ | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($entry.success) { $enrichStats.success++ } else { $enrichStats.fail++ }
    }
}

$summary = @"
# Session Summary — $(Get-Date -Format "yyyy-MM-dd HH:mm")

## Metadata
- **Mode:** $Mode
- **Task:** $Task
- **Files Changed:** $Changes
- **Tokens Generated:** $Tokens

## Enrichment Stats
- **Total Calls:** $($enrichStats.total)
- **Successful:** $($enrichStats.success)
- **Failed:** $($enrichStats.fail)
- **Success Rate:** $(if ($enrichStats.total -gt 0) { "{0:P1}" -f ($enrichStats.success / $enrichStats.total) } else { "N/A" })

## LLMEnrich Status
- **Last Mode:** $Mode
- **Compliant:** $(if ($enrichStats.success -gt 0) { "✅ Yes" } else { "❌ No — enrichment may have been skipped" })

## Recommendations
$(if ($enrichStats.fail -gt $enrichStats.total * 0.5) { "- ⚠️ High failure rate. Check timeout settings." } else { "- ✅ Enrichment pipeline healthy." })
- Review `session-summary.md` before next session for context.
"@

$summary | Set-Content -Path $SUMMARY_FILE -Encoding UTF8

if (-not $Quiet) {
    Write-Host ""
    Write-Host "  ────── SESSION SUMMARY ──────" -ForegroundColor Cyan
    Write-Host "  Mode:     $Mode" -ForegroundColor White
    Write-Host "  Changed:  $Changes" -ForegroundColor White
    Write-Host "  Enrich:   $($enrichStats.success)/$($enrichStats.total) successful" -ForegroundColor $(if ($enrichStats.success -gt 0) { "Green" } else { "Red" })
    Write-Host "  Saved to: $SUMMARY_FILE" -ForegroundColor Gray
    Write-Host "  ─────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
}

return $summary
