# Profile Optimizer — Track skill usage, recommend load/unload
# Usage: .\profile-optimizer.ps1 [-Analyze] [-Apply]

param(
    [switch]$Analyze,
    [switch]$Apply
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$USAGE_LOG = "$ROOT_DIR\.opencode\skill-usage.jsonl"
$PROFILE_FILE = "$ROOT_DIR\profiles\gratis\opencode.jsonc"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║         Profile Optimizer — Skill Usage Audit    ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -Write-Host ""

# Load usage log
$skillUsage = @{}
if (Test-Path $USAGE_LOG) {
    Get-Content $USAGE_LOG | ForEach-Object {
        try {
            $entry = $_ | ConvertFrom-Json
            foreach ($skill in $entry.skills) {
                $skillUsage[$skill] = ($skillUsage[$skill] -or 0) + 1
            }
        } catch {}
    }
}

# Load skill index
$skillFile = "$ROOT_DIR\Skill\skill-list.md"
$allSkills = @()
if (Test-Path $skillFile) {
    Get-Content $skillFile | ForEach-Object {
        if ($_ -match '^\| `([\w-]+)` \|') {
            $allSkills += $Matches[1]
        }
    }
}

# Load current profile
$loadedSkills = @()
if (Test-Path $PROFILE_FILE) {
    $config = Get-Content $PROFILE_FILE -Raw
    $loadedSkills = [regex]::Matches($config, 'ecc/skills/([\w-]+)/SKILL\.md') | ForEach-Object { $_.Groups[1].Value }
}

Write-Host "  Current profile loads $($loadedSkills.Count) skills" -ForegroundColor White
Write-Host "  Total ECC skills: $($allSkills.Count)" -ForegroundColor Gray
Write-Host "  Skills with usage data: $($skillUsage.Count)" -ForegroundColor Gray
Write-Host ""

# Get top skills by usage
$topSkills = $skillUsage.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10
$bottomSkills = $skillUsage.GetEnumerator() | Sort-Object Value | Select-Object -First 5

Write-Host "  Most used skills:" -ForegroundColor Yellow
foreach ($s in $topSkills) {
    $loaded = if ($s.Key -in $loadedSkills) { "✅ loaded" } else { "⬜ not loaded" }
    Write-Host "    • $($s.Key) ($($s.Value) uses) — $loaded" -ForegroundColor White
}

Write-Host ""
Write-Host "  Least used (loaded):" -ForegroundColor Yellow
$lowUsageLoaded = $loadedSkills | Where-Object { -not $skillUsage.ContainsKey($_) -or $skillUsage[$_] -lt 2 }
if ($lowUsageLoaded) {
    foreach ($s in $lowUsageLoaded | Select-Object -First 5) {
        Write-Host "    • $s — 0-1 uses" -ForegroundColor DarkGray
    }
} else {
    Write-Host "    (no low-usage loaded skills detected)" -ForegroundColor Gray
}

# Recommendations
Write-Host ""
Write-Host "  Recommendations:" -ForegroundColor Cyan

$RECOMMEND_FILE = "$ROOT_DIR\.opencode\recommended-skills.json"
$highUsageNotLoaded = $topSkills | Where-Object { $_.Key -notin $loadedSkills }
if ($highUsageNotLoaded) {
    foreach ($s in $highUsageNotLoaded) {
        Write-Host "    • LOAD: $($s.Key) ($($s.Value) uses)" -ForegroundColor Green
    }
}
if ($lowUsageLoaded) {
    foreach ($s in $lowUsageLoaded | Select-Object -First 3) {
        Write-Host "    • UNLOAD: $s (0-1 uses, wasting context)" -ForegroundColor Yellow
    }
}
if (-not $highUsageNotLoaded -and -not $lowUsageLoaded) {
    Write-Host "    • Profile is optimal. No changes needed." -ForegroundColor Gray
}

# Save recommendations if there's data
if ($skillUsage.Count -gt 0) {
    New-Item -ItemType Directory -Path "$ROOT_DIR\.opencode" -Force | Out-Null
    $recs = [PSCustomObject]@{
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        skill_usage_total = $skillUsage.Count
        current_loaded = $loadedSkills.Count
        recommended_load = @($highUsageNotLoaded | ForEach-Object { $_.Key })
        recommended_unload = @($lowUsageLoaded | Select-Object -First 5 | ForEach-Object { $_ })
    }
    $recs | ConvertTo-Json -Depth 3 | Set-Content -Path $RECOMMEND_FILE -Encoding UTF8
    Write-Host ""
    Write-Host "  [OPTIMIZER] Recommendations saved" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  [OPTIMIZER] Done." -ForegroundColor Green
Write-Host ""
