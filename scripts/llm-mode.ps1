# LLM Mode — System operating mode toggle
# Usage: .\llm-mode.ps1 eco|balanced|performance|status
#        .\llm-mode.ps1 off  (alias for eco)

param(
    [ValidateSet("eco", "balanced", "performance", "off", "on", "status")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$MODE_DIR = "$ROOT_DIR\.opencode"
$MODE_FILE = "$MODE_DIR\llm-mode.json"
$OLLAMA_URL = "http://localhost:11434"

$MODEL_MAP = @{
    "eco"         = $null
    "balanced"    = "qwen2.5:1.5b-s"
    "performance" = "qwen2.5:1.5b-s"
}

function Get-Mode {
    if (Test-Path $MODE_FILE) {
        try {
            $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
            return $state.mode
        } catch {}
    }
    return "balanced"
}

function Get-ModeModel {
    if (Test-Path $MODE_FILE) {
        try {
            $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
            if ($state.model) { return $state.model }
        } catch {}
    }
    return "qwen3:1.7b"
}

function Set-Mode {
    param([string]$Mode, [string]$Model)
    New-Item -ItemType Directory -Path $MODE_DIR -Force | Out-Null
    $state = [PSCustomObject]@{
        mode = $Mode
        model = if ($Model) { $Model } else { "" }
        updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    }
    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $MODE_FILE -Encoding UTF8
}

function Test-OllamaRunning {
    try {
        $null = Invoke-RestMethod -Uri "$OLLAMA_URL/api/tags" -TimeoutSec 3 -ErrorAction Stop
        return $true
    } catch { return $false }
}

function Invoke-Warmup {
    param([string]$ModelName)
    try {
        $body = @{
            model = $ModelName
            messages = @(@{ role = "user"; content = "ok" })
            stream = $false
            keep_alive = "5m"
            options = @{ num_predict = 2; num_gpu = 99 }
        } | ConvertTo-Json -Depth 5 -Compress
        $null = Invoke-RestMethod -Uri "$OLLAMA_URL/api/chat" -Method POST -Body $body -ContentType "application/json" -TimeoutSec 120 -ErrorAction SilentlyContinue
    } catch {}
}

# Resolve alias
if ($Action -eq "on") { $Action = "balanced" }
if ($Action -eq "off") { $Action = "eco" }

switch ($Action) {
    "eco" {
        Set-Mode -Mode "eco" -Model $null
        # Unload models from VRAM — free GPU memory
        ollama stop qwen2.5:1.5b-s 2>$null
        Write-Host "  [MODE] ECO — no LLM, regex fallback only" -ForegroundColor Green
        Write-Host "  [MODE] VRAM freed. Battery optimized, zero GPU usage" -ForegroundColor Gray
    }

    "balanced" {
        $model = $MODEL_MAP["balanced"]
        $running = Test-OllamaRunning
        if (-not $running) {
            Write-Host "  [MODE] Ollama not running. Starting..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
                Start-Sleep -Seconds 3
            } catch {}
        }
        Set-Mode -Mode "balanced" -Model $model
        Write-Host "  [MODE] Loading $model to GPU..." -ForegroundColor Gray
        Invoke-Warmup -ModelName $model
        Write-Host "  [MODE] BALANCED — $model" -ForegroundColor Cyan
        Write-Host "  [MODE] qwen2.5:1.5b-s GPU ~1GB, enrich 100 tok" -ForegroundColor Gray
    }

    "performance" {
        $model = $MODEL_MAP["performance"]
        $running = Test-OllamaRunning
        if (-not $running) {
            Write-Host "  [MODE] Ollama not running. Starting..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
                Start-Sleep -Seconds 3
            } catch {}
        }
        Set-Mode -Mode "performance" -Model $model
        Write-Host "  [MODE] Loading $model to GPU..." -ForegroundColor Gray
        Invoke-Warmup -ModelName $model
        Write-Host "  [MODE] PERFORMANCE — $model" -ForegroundColor Magenta
        Write-Host "  [MODE] qwen2.5:1.5b-s GPU ~1GB, enrich 200 tok" -ForegroundColor Gray
    }

    "status" {
        $mode = Get-Mode
        $model = Get-ModeModel
        $running = Test-OllamaRunning
        $labels = @{ "eco" = "ECO"; "balanced" = "BALANCED"; "performance" = "PERFORMANCE" }
        $label = if ($labels.ContainsKey($mode)) { $labels[$mode] } else { "UNKNOWN" }

        Write-Host ""
        Write-Host "  Operating Mode:" -ForegroundColor Cyan
        Write-Host "    Mode:        $label" -ForegroundColor $(switch ($mode) { "eco" { "Green" } "balanced" { "Yellow" } "performance" { "Magenta" } default { "Red" } })
        if ($model) { Write-Host "    Model:       $model" -ForegroundColor White }
        Write-Host "    Ollama:      $(if ($running) { '✅ Running' } else { '❌ Stopped' })" -ForegroundColor $(if ($running) { 'Green' } else { 'Red' })

        if ($running) {
            try {
                $tags = Invoke-RestMethod -Uri "$OLLAMA_URL/api/tags" -TimeoutSec 5
                if ($tags.models) {
                    Write-Host "    Available:" -ForegroundColor Gray
                    foreach ($m in $tags.models) {
                        $size = [math]::Round($m.size / 1GB, 2)
                        Write-Host "      $($m.name) ($size GB)" -ForegroundColor Gray
                    }
                }
            } catch {}
        }
        Write-Host ""
        Write-Host "  Mode behaviors:" -ForegroundColor Cyan
        Write-Host "    ECO:         regex fallback, no LLM calls" -ForegroundColor Gray
        Write-Host "    BALANCED:    qwen2.5:1.5b-s (GPU), enrich 100 tok, ~1GB VRAM" -ForegroundColor Gray
        Write-Host "    PERFORMANCE: qwen2.5:1.5b-s (GPU), enrich 200 tok, deep analysis" -ForegroundColor Gray
        Write-Host ""
    }
}
