# Research — Web search + AI ringkasan via 9Router
# Usage: .\research.ps1 -Query "topik yang mau dicari"

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [int]$MaxResults = 5
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$API_URL = "http://localhost:20128"
$API_PASS = "123456"
. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# Helpers
# ============================================================

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host ""
    Write-Host "[$Step] $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Gray
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║         Research — $($Query.Substring(0, [Math]::Min(40, $Query.Length)))" -ForegroundColor Cyan
if ($Query.Length -gt 40) { Write-Host "  ║         $( ' ' * 10)$($Query.Substring(40, [Math]::Min(40, $Query.Length - 40)))" -ForegroundColor Cyan }
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$enrichedQuery = Invoke-LLMEnrich -Text $Query -Context "research query enrichment"
if (-not $enrichedQuery) { $enrichedQuery = $Query }

$totalSteps = 3
$sourceUrls = @()
$allText = ""

# ============================================================
# [1/3] Login + Search via 9Router
# ============================================================

Write-Step "1/$totalSteps" "Mencari informasi..."

$httpSession = $null
try {
    Invoke-RestMethod -Uri "$API_URL/api/auth/login" -Method POST `
        -Body "{`"password`":`"$API_PASS`"}" -ContentType "application/json" `
        -SessionVariable httpSession -ErrorAction Stop | Out-Null
    Write-Info "9Router: connected"
} catch {
    Write-Info "9Router: login failed"
}

# Try search via /v1/search
$searchResults = $null
try {
    $searchBody = @{
        query = $enrichedQuery
        max_results = $MaxResults
    } | ConvertTo-Json -Depth 5

    $searchResp = Invoke-RestMethod -Uri "$API_URL/v1/search" -Method POST `
        -Body $searchBody -ContentType "application/json" `
        -WebSession $httpSession -TimeoutSec 15 -ErrorAction SilentlyContinue

    if ($searchResp.results -and $searchResp.results.Count -gt 0) {
        $searchResults = $searchResp.results
        Write-OK "Search: $($searchResults.Count) results"
        foreach ($r in $searchResults) { $sourceUrls += $r.url }
    }
} catch {
    Write-Info "Search API: unavailable (connect Tavily/Exa di Dashboard 9Router)"
}

# Try web fetch if search failed
if (-not $searchResults) {
    try {
        $fetchBody = @{
            model = "jina-reader"
            url = "https://s.jina.ai/$($enrichedQuery -replace ' ', '+')"
            max_characters = 3000
        } | ConvertTo-Json -Depth 5

        $fetchResp = Invoke-RestMethod -Uri "$API_URL/v1/web/fetch" -Method POST `
            -Body $fetchBody -ContentType "application/json" `
            -WebSession $httpSession -TimeoutSec 15 -ErrorAction SilentlyContinue

        if ($fetchResp.content -and $fetchResp.content.text) {
            $allText = $fetchResp.content.text
            Write-OK "Web fetch: $($allText.Length) chars loaded"
            if ($fetchResp.url) { $sourceUrls += $fetchResp.url }
        }
    } catch {
        Write-Info "Web fetch: unavailable (connect Jina/Firecrawl di Dashboard 9Router)"
    }
}

# ============================================================
# [2/3] Research via Chat Model
# ============================================================

Write-Step "2/$totalSteps" "Merangkum informasi..."

$systemPrompt = "Kamu adalah asisten riset. Jawab pertanyaan dengan informasi akurat dan terkini."
if ($searchResults) {
    # Use search results as context
    $searchContext = ""
    foreach ($r in $searchResults) {
        $searchContext += "Source: $($r.title)`nURL: $($r.url)`nContent: $($r.snippet)`n`n"
    }
    $systemPrompt += "`n`nGunakan informasi ini sebagai referensi:`n$searchContext"
    $systemPrompt += "`nSertakan source URL dalam jawaban."
} elseif ($allText) {
    $systemPrompt += "`n`nReferensi:`n$allText"
    $systemPrompt += "`nSertakan source URL dalam jawaban."
} else {
    $systemPrompt += "`nCari informasi terbaru tentang topik yang ditanyakan."
    $systemPrompt += "`nSertakan source URL jika ada."
    Write-Info "Chat model akan menjawab berdasarkan pengetahuannya"
}

# Determine best model
$model = "mmf/mimo-auto"
$fallbackModels = @("oc/deepseek-v4-flash-free", "oc/mimo-v2.5-free")

$responseText = $null
$usedModel = $model
$promptTokens = 0
$completionTokens = 0

foreach ($m in @($model) + $fallbackModels) {
    try {
        $chatBody = @{
            model = $m
            messages = @(
                @{ role = "system"; content = $systemPrompt }
                @{ role = "user"; content = $enrichedQuery }
            )
            max_tokens = 500
        } | ConvertTo-Json -Depth 5

        $raw = Invoke-RestMethod -Uri "$API_URL/v1/chat/completions" -Method POST `
            -Body $chatBody -ContentType "application/json" `
            -WebSession $httpSession -TimeoutSec 60 -ErrorAction SilentlyContinue

        # Parse SSE if needed
        if ($raw -is [string]) {
            foreach ($line in $raw -split "`n") {
                if ($line -match '^data: (.+)$' -and $Matches[1] -ne "[DONE]") {
                    try {
                        $json = $Matches[1] | ConvertFrom-Json
                        if ($json.choices[0].message.content) {
                            $responseText = $json.choices[0].message.content
                            $promptTokens = $json.usage.prompt_tokens
                            $completionTokens = $json.usage.completion_tokens
                        }
                    } catch {}
                }
            }
        } elseif ($raw.choices) {
            $responseText = $raw.choices[0].message.content
            $promptTokens = $raw.usage.prompt_tokens
            $completionTokens = $raw.usage.completion_tokens
        }

        if ($responseText) {
            $usedModel = $m
            Write-OK "$m responded ($promptTokens in / $completionTokens out)"
            break
        }
    } catch {
        Write-Info "${m}: $($_.Exception.Message)"
    }
}

# ============================================================
# [3/3] Display Results
# ============================================================

Write-Step "3/$totalSteps" "Hasil riset"

Write-Host ""
Write-Host "  ─── Ringkasan ───" -ForegroundColor Yellow
Write-Host ""
if ($responseText) {
    # Format response text
    $responseText -split "`n" | ForEach-Object {
        if ($_.Trim() -ne "") {
            Write-Host "  $_" -ForegroundColor White
        }
    }
} else {
    Write-Host "  [FAIL] Tidak ada response dari model" -ForegroundColor Red
}
Write-Host ""
Write-Host "  ─── Sumber ───" -ForegroundColor Yellow
Write-Host ""

if ($sourceUrls.Count -gt 0) {
    $sourceUrls | Get-Unique | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
} else {
    Write-Host "  • Tidak ada source URL (chat model tanpa web search)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "  ─── Info ───" -ForegroundColor Yellow
Write-Host "  Model:     $usedModel" -ForegroundColor Gray
if ($promptTokens) { Write-Host "  Token in:  $promptTokens" -ForegroundColor Gray }
if ($completionTokens) { Write-Host "  Token out: $completionTokens" -ForegroundColor Gray }
Write-Host ""
Write-Host "  💡 Untuk hasil riset real-time, connect search provider" -ForegroundColor Yellow
Write-Host "     di 9Router Dashboard → Providers → Add Tavily/Exa" -ForegroundColor Yellow
Write-Host ""
