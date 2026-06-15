# LLM Adapter — Wrapper for local Ollama API with auto-fallback
# Usage: . .\llm-adapter.ps1  (source for functions)
#        .\llm-adapter.ps1 -Prompt "your text" [-Model "qwen3:1.7b"] (direct execution)

param(
    [string]$Prompt,
    [string]$Model,
    [string]$System,
    [int]$MaxTokens = 1024,
    [double]$Temperature = 0.3,
    [int]$TimeoutSec = 60
)

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$MODE_FILE = "$ROOT_DIR\.opencode\llm-mode.json"
$OLLAMA_URL = "http://localhost:11434"

# ============================================================
# Mode helpers (compatible with eco/balanced/performance)
# ============================================================

function Get-OperatingMode {
    if (-not (Test-Path $MODE_FILE)) { return "eco" }
    try {
        $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
        return $state.mode
    } catch { return "eco" }
}

function Get-LLMMode {
    # Returns "on" if LLM available, "off" if eco
    $mode = Get-OperatingMode
    if ($mode -eq "eco") { return "off" }
    return "on"
}

function Get-LLMModel {
    if (Test-Path $MODE_FILE) {
        try {
            $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
            if ($state.model) { return $state.model }
        } catch {}
    }
    return "qwen3:1.7b"
}

function Get-ModeForLLM {
    return Get-OperatingMode
}

# ============================================================
# Universal enrichment — single entry for all scripts
# Even "Hi" passes through LLM in balanced/performance mode.
# ECO mode: pass-through. Force: bypass ECO check.
# ============================================================

function Invoke-LLMEnrich {
    param(
        [string]$Text,
        [string]$Context,
        [string]$System,
        [int]$MaxTokens = 256,
        [switch]$Force
    )

    $mode = Get-OperatingMode
    if ($mode -eq "eco" -and -not $Force) { return $Text }

    if (-not $System) {
        if ($Context) { $System = "You are a universal input preprocessor. Given input and context, return enriched output." }
        else { $System = "You are a universal input preprocessor. Return enriched version of the input." }
    }

    $prompt = if ($Context) { "Context: $Context`n`nInput: $Text" } else { $Text }
    $callerInfo = Get-PSCallStack | Select-Object -Skip 1 -First 1
    $callerScript = if ($callerInfo) { Split-Path $callerInfo.ScriptName -Leaf } else { "unknown" }
    $tokens = if ($mode -eq "performance") { 512 } else { $MaxTokens }
    $timeout = if ($mode -eq "performance") { 60 } else { 30 }

    $result = Invoke-LLM -Prompt $prompt -System $System -MaxTokens $tokens -Temperature 0.3 -TimeoutSec $timeout
    if (-not $result) { return $Text }

    $text = $result.response.Trim()
    return $text
}

# ============================================================
# Chunk sizes per mode — GPU-aware (MX150 2GB)
# Balanced: 1000 chars = ~250 tokens (16.7% of 1500 context)
# Performance: 600 chars = ~150 tokens (18.7% of 800 context)
# ============================================================

# ============================================================
# Chunk sizes per mode — GPU-aware (MX150 2GB)
# Balanced: 1000 chars = ~250 tokens (16.7% of 1500 context)
# Performance: 600 chars = ~150 tokens (18.7% of 800 context)
# ============================================================

$OVERLAP_CHARS = 200

function Get-ChunkSize {
    $mode = Get-OperatingMode
    $sizes = @{ eco = 0; balanced = 1000; performance = 600 }
    return $sizes[$mode]
}

function Invoke-LLMChunk {
    param(
        [string]$Text,
        [string]$System,
        [string]$SystemMerge,
        [int]$MaxTokens = 256,
        [double]$Temperature = 0.2,
        [int]$TimeoutSec = 120,
        [scriptblock]$ProcessResult,
        [int]$CustomChunkSize
    )

    $mode = Get-OperatingMode
    if ($mode -eq "eco") { return @() }

    $chunkSize = if ($CustomChunkSize) { $CustomChunkSize } else { Get-ChunkSize }
    if ($chunkSize -le 0) { return @() }

    $allResults = @()
    $pos = 0
    $chunkNum = 0
    $totalChunks = [math]::Max(1, [math]::Ceiling($Text.Length / $chunkSize))

    while ($pos -lt $Text.Length) {
        $chunkNum++
        $endPos = [math]::Min($pos + $chunkSize, $Text.Length)
        $overlapPos = [math]::Max(0, $pos - $OVERLAP_CHARS)
        $chunkText = $Text.Substring($overlapPos, $endPos - $overlapPos)

        $prompt = if ($totalChunks -gt 1) {
            "Part $chunkNum/$totalChunks.`n`n$chunkText"
        } else { $chunkText }

        $result = Invoke-LLM -Prompt $prompt -System $System -MaxTokens $MaxTokens -Temperature $Temperature -TimeoutSec $TimeoutSec
        if (-not $result) { continue }

        if ($ProcessResult) {
            $parsed = & $ProcessResult $result.response
            if ($parsed) { $allResults += $parsed }
        } else {
            $allResults += $result.response
        }

        $pos = $endPos
    }

    if ($totalChunks -gt 1 -and $SystemMerge -and $allResults.Count -gt 1) {
        $merged = Invoke-LLM -Prompt ($allResults -join "`n---`n") -System $SystemMerge -MaxTokens $MaxTokens -Temperature $Temperature -TimeoutSec $TimeoutSec
        if ($merged) { return $merged.response }
    }

    return $allResults
}

# ============================================================
# Failure logging
# ============================================================

function Write-LLMFailure {
    param(
        [string]$Script,
        [string]$Model,
        [string]$Prompt,
        [string]$RawOutput,
        [string]$Error
    )
    try {
        New-Item -ItemType Directory -Path (Split-Path $FAILURE_LOG -Parent) -Force | Out-Null
        $entry = @{
            timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
            script = $Script
            model = $Model
            prompt_hash = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Prompt.Substring(0, [Math]::Min(100, $Prompt.Length))))
            raw_output = $RawOutput
            error = $Error
        }
        Add-Content -Path $FAILURE_LOG -Value ($entry | ConvertTo-Json -Compress) -Encoding UTF8
    } catch {}
}

# ============================================================
# Invoke LLM — uses /api/chat for instruction-tuned models
# ============================================================

function Invoke-LLM {
    param(
        [string]$Prompt,
        [string]$Model,
        [string]$System,
        [int]$MaxTokens,
        [double]$Temperature,
        [int]$TimeoutSec
    )

    $mode = Get-OperatingMode
    if ($mode -eq "eco") {
        Write-Warning "ECO mode — LLM calls disabled. Enable with: .\llm-mode.ps1 balanced"
        return $null
    }

    if (-not $Model) { $Model = Get-LLMModel }

    # Build messages array (chat format)
    $messages = @()
    if ($System) {
        $messages += @{ role = "system"; content = $System }
    }
    $messages += @{ role = "user"; content = $Prompt }

    $body = @{
        model = $Model
        messages = $messages
        stream = $false
        options = @{
            num_predict = $MaxTokens
            temperature = $Temperature
        }
    }

    try {
        $response = Invoke-RestMethod -Uri "$OLLAMA_URL/api/chat" `
            -Method POST `
            -Body ($body | ConvertTo-Json -Depth 5) `
            -ContentType "application/json" `
            -TimeoutSec $TimeoutSec `
            -ErrorAction Stop

        # Log usage
        try {
            $callerInfo = Get-PSCallStack | Select-Object -Skip 2 -First 1
            $callerScript = if ($callerInfo) { Split-Path $callerInfo.ScriptName -Leaf } else { "unknown" }
            $usageEntry = @{
                timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
                script = $callerScript
                model = $response.model
                prompt_hash = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Prompt.Substring(0, [Math]::Min(100, $Prompt.Length))))
                total_duration = $response.total_duration
                eval_count = $response.eval_count
                tokens_per_second = [math]::Round($response.eval_count / ($response.total_duration / 1e9), 2)
                success = $true
            }
            $usageFile = "$ROOT_DIR\.opencode\llm-usage.jsonl"
            New-Item -ItemType Directory -Path (Split-Path $usageFile -Parent) -Force | Out-Null
            Add-Content -Path $usageFile -Value ($usageEntry | ConvertTo-Json -Compress) -Encoding UTF8
        } catch {}

        return [PSCustomObject]@{
            response = $response.message.content
            model = $response.model
            total_duration = $response.total_duration
            tokens_per_second = if ($response.total_duration -and $response.total_duration -gt 0) {
                [math]::Round($response.eval_count / ($response.total_duration / 1e9), 2)
            } else { 0 }
            eval_count = $response.eval_count
        }
    } catch {
        $errMsg = $_.Exception.Message
        Write-LLMFailure -Script "llm-adapter" -Model $Model -Prompt $Prompt -RawOutput "" -Error $errMsg
        Write-Warning "LLM call failed: $errMsg"
        if ($errMsg -match "ConnectFailure|connection refused|No connection") {
            Write-Warning "Ollama not reachable. Auto-disabling LLM mode."
            $null = & "$SETUP_DIR\llm-mode.ps1" eco 2>$null
        }
        return $null
    }
}

# ============================================================
# Execute (only when run directly, not sourced)
# ============================================================

if ($MyInvocation.InvocationName -ne '.' -and $Prompt) {
    $result = Invoke-LLM -Prompt $Prompt -Model $Model -System $System -MaxTokens $MaxTokens -Temperature $Temperature -TimeoutSec $TimeoutSec

    if ($result) {
        $result | ConvertTo-Json -Depth 3
    }
}
