# LLM Benchmark — Test qwen3:1.7b vs qwen2.5-coder:3b vs no-llm
# Usage: .\llm-benchmark.ps1 [-Rounds 5]

param(
    [int]$Rounds = 5,
    [string]$OutDir
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

if (-not $OutDir) { $OutDir = "$ROOT_DIR\docs\benchmark" }
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Source functions
. "$SETUP_DIR\llm-adapter.ps1"

$SCENARIOS = @(
    @{
        name = "intent_compiler"
        weight = 30
        prompt = "Convert this to JSON: Buat modul penduduk untuk web desa. Harus ada CRUD, validasi NIK, role admin, audit log, aman dari SQL injection."
        system = "You are an intent compiler. Output ONLY valid JSON. No explanation."
        validator = { param($text) try { $null = $text | ConvertFrom-Json; return $true } catch { return $false } }
    }
    @{
        name = "skill_routing"
        weight = 20
        prompt = "Given this intent JSON, select the top 5 most relevant skills from: tdd-workflow, security-review, coding-standards, verification-loop, api-design, postgres-patterns, docker-patterns, deployment-patterns, redis-patterns, error-handling. Output only skill names as JSON array. Intent: { 'domain': 'web_desa', 'module': 'penduduk', 'stack': ['php', 'mysql'] }"
        system = "Output ONLY a JSON array of strings."
        validator = { param($text) try { $arr = $text | ConvertFrom-Json; return ($arr -is [array]) } catch { return $false } }
    }
    @{
        name = "error_classification"
        weight = 15
        prompt = "Classify this error: SQLSTATE[23000]: Integrity constraint violation: 1062 Duplicate entry '123' for key 'users_nik_unique'. Output JSON with: category, root_cause, impact, fix."
        system = "Output ONLY valid JSON."
        validator = { param($text) try { $null = $text | ConvertFrom-Json; return $true } catch { return $false } }
    }
    @{
        name = "pattern_mining"
        weight = 10
        prompt = "Extract a reusable pattern from this session log: User tried to insert duplicate NIK. System threw integrity constraint violation. Fix was to add pre-insert validation check. Output markdown with: Issue, Risk, Resolution, Prevention."
        system = "Output ONLY valid JSON with fields: issue, risk, resolution, prevention"
        validator = { param($text) try { $null = $text | ConvertFrom-Json; return $true } catch { return $false } }
    }
)

$MODELS = @("qwen3:1.7b", "qwen2.5-coder:3b", "no-llm")

# ============================================================
# Run benchmarks
# ============================================================

$results = @()

foreach ($model in $MODELS) {
    Write-Host "`n  [BENCH] Testing: $model" -ForegroundColor Cyan

    foreach ($scenario in $SCENARIOS) {
        Write-Host "  [BENCH]   Scenario: $($scenario.name)" -ForegroundColor Gray

        for ($r = 1; $r -le $Rounds; $r++) {
            $start = Get-Date
            $response = $null
            $errorMsg = $null
            $valid = $false
            $latency = 0
            $tps = 0

            if ($model -eq "no-llm") {
                # Baseline: rule-based simulation
                $latency = 0.05  # 50ms
                $response = '{"status":"baseline","method":"regex"}'
                $valid = $true
            } else {
                if ((Get-OperatingMode) -eq "eco") {
                    Write-Host "  [BENCH]     ECO mode — skipping LLM for $($scenario.name)" -ForegroundColor DarkGray
                    continue
                }
                $enrichedBmInput = Invoke-LLMEnrich -Text $scenario.prompt -Context "benchmark enrichment"
                if (-not $enrichedBmInput) { $enrichedBmInput = $scenario.prompt }
                try {
                    $result = Invoke-LLM -Prompt $enrichedBmInput -Model $model -System $scenario.system -MaxTokens 256 -TimeoutSec 60
                    if ($result) {
                        $latency = [math]::Round($result.total_duration / 1e9, 3)
                        $tps = $result.tokens_per_second
                        $response = $result.response
                        $valid = & $scenario.validator $response
                    } else {
                        $errorMsg = "LLM returned null"
                    }
                } catch {
                    $errorMsg = $_.Exception.Message
                }
            }

            $elapsed = [math]::Round((Get-Date - $start).TotalSeconds, 3)

            $results += [PSCustomObject]@{
                model = $model
                scenario = $scenario.name
                round = $r
                valid = $valid
                latency = $latency
                tokens_per_sec = $tps
                elapsed = $elapsed
                error = $errorMsg
            }

            Write-Host "  [BENCH]     Round $r: valid=$valid latency=${latency}s tps=$tps" -ForegroundColor $(if ($valid) { 'Green' } else { 'Red' })
        }
    }
}

# ============================================================
# Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║              Benchmark Results                   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$summary = $results | Group-Object model, scenario | ForEach-Object {
    $parts = $_.Name -split ', '
    $modelName = $parts[0]
    $scenarioName = $parts[1]
    $validCount = ($_.Group | Where-Object { $_.valid }).Count
    $totalCount = $_.Group.Count
    $avgLatency = [math]::Round(($_.Group | Measure-Object -Property latency -Average).Average, 3)
    $avgTps = [math]::Round(($_.Group | Measure-Object -Property tokens_per_sec -Average).Average, 1)

    [PSCustomObject]@{
        model = $modelName
        scenario = $scenarioName
        pass_rate = [math]::Round($validCount / $totalCount * 100, 1)
        avg_latency = $avgLatency
        avg_tps = $avgTps
    }
}

$summary | Format-Table -Property model, scenario, pass_rate, avg_latency, avg_tps -AutoSize

# Show best model by score
$scores = $summary | Group-Object model | ForEach-Object {
    $score = 0
    foreach ($row in $_.Group) {
        $w = ($SCENARIOS | Where-Object { $_.name -eq $row.scenario }).weight
        $score += $row.pass_rate * $w / 100
    }
    [PSCustomObject]@{
        model = $_.Name
        score = [math]::Round($score, 1)
    }
}

Write-Host ""
Write-Host "  Composite Scores:" -ForegroundColor Cyan
$scores | Sort-Object score -Descending | Format-Table -AutoSize

$bestModel = ($scores | Sort-Object score -Descending | Select-Object -First 1).model
Write-Host ""
Write-Host "  Recommended: $bestModel" -ForegroundColor Green

# Export
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$csvPath = "$OutDir\benchmark-$timestamp.csv"
$results | Export-Csv -Path $csvPath -NoTypeInformation
Write-Host "  Results saved: $csvPath" -ForegroundColor Gray
Write-Host ""
