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
    # Returns "eco", "balanced", or "performance"
    return Get-OperatingMode
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
        Write-Warning "LLM call failed: $($_.Exception.Message)"
        if ($_.Exception.Message -match "ConnectFailure|connection refused|No connection") {
            Write-Warning "Ollama not reachable. Auto-disabling LLM mode."
            $null = & "$SETUP_DIR\llm-mode.ps1" off
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
