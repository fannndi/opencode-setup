# LLM Adapter — Wrapper for local Ollama API with auto-fallback
# Usage: .\llm-adapter.ps1 -Prompt "your text" [-Model "qwen3:1.7b"] [-System "system prompt"]

param(
    [Parameter(Mandatory=$true)]
    [string]$Prompt,

    [string]$Model,
    [string]$System,
    [int]$MaxTokens = 512,
    [double]$Temperature = 0.3,
    [int]$TimeoutSec = 30
)

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$MODE_FILE = "$ROOT_DIR\.opencode\llm-mode.json"
$OLLAMA_URL = "http://localhost:11434"

# ============================================================
# Check mode
# ============================================================

function Get-LLMMode {
    if (-not (Test-Path $MODE_FILE)) { return "off" }
    try {
        $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
        return $state.mode
    } catch { return "off" }
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

# ============================================================
# Invoke LLM
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

    $mode = Get-LLMMode
    if ($mode -ne "on") {
        Write-Warning "LLM mode is OFF. Enable with: .\llm-mode.ps1 on"
        return $null
    }

    if (-not $Model) { $Model = Get-LLMModel }

    # Build request body
    $body = @{
        model = $Model
        prompt = $Prompt
        stream = $false
        options = @{
            num_predict = $MaxTokens
            temperature = $Temperature
        }
    }
    if ($System) {
        $body.prompt = "$System`n`n$Prompt"
    }

    try {
        $response = Invoke-RestMethod -Uri "$OLLAMA_URL/api/generate" `
            -Method POST `
            -Body ($body | ConvertTo-Json -Depth 5) `
            -ContentType "application/json" `
            -TimeoutSec $TimeoutSec `
            -ErrorAction Stop

        return [PSCustomObject]@{
            response = $response.response
            model = $response.model
            total_duration = $response.total_duration
            tokens_per_second = if ($response.total_duration -and $response.total_duration -gt 0) {
                [math]::Round($response.eval_count / ($response.total_duration / 1e9), 2)
            } else { 0 }
            eval_count = $response.eval_count
        }
    } catch {
        Write-Warning "LLM call failed: $($_.Exception.Message)"
        # Auto-disable mode on connection error
        if ($_.Exception.Message -match "ConnectFailure|connection refused|No connection") {
            Write-Warning "Ollama not reachable. Auto-disabling LLM mode."
            $null = & "$SETUP_DIR\llm-mode.ps1" off
        }
        return $null
    }
}

# ============================================================
# Execute
# ============================================================

$result = Invoke-LLM -Prompt $Prompt -Model $Model -System $System -MaxTokens $MaxTokens -Temperature $Temperature -TimeoutSec $TimeoutSec

if ($result) {
    $result | ConvertTo-Json -Depth 3
} else {
    # Silent exit — caller handles null
}
