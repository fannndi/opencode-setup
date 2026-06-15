# LLM Mode — Toggle local LLM on/off
# Usage: .\llm-mode.ps1 on|off|status

param(
    [ValidateSet("on", "off", "status")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$MODE_FILE = "$ROOT_DIR\.opencode\llm-mode.json"
$OLLAMA_URL = "http://localhost:11434"

# ============================================================
# Mode State
# ============================================================

function Get-Mode {
    if (Test-Path $MODE_FILE) {
        try {
            $state = Get-Content $MODE_FILE -Raw | ConvertFrom-Json
            return $state.mode
        } catch {}
    }
    return "off"
}

function Set-Mode {
    param([string]$Mode, [string]$Model)
    New-Item -ItemType Directory -Path (Split-Path $MODE_FILE -Parent) -Force | Out-Null
    $state = [PSCustomObject]@{
        mode = $Mode
        model = if ($Model) { $Model } else { "qwen3:1.7b" }
        updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    }
    $state | ConvertTo-Json -Depth 5 | Set-Content -Path $MODE_FILE -Encoding UTF8
}

function Test-OllamaRunning {
    try {
        $null = Invoke-RestMethod -Uri "$OLLAMA_URL/api/tags" -TimeoutSec 3 -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============================================================
# Actions
# ============================================================

switch ($Action) {
    "on" {
        $running = Test-OllamaRunning
        if (-not $running) {
            Write-Host "  [LLM] Starting Ollama..." -ForegroundColor Yellow
            try {
                Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Minimized
                Start-Sleep -Seconds 3
                $running = Test-OllamaRunning
            } catch {}
        }

        if ($running) {
            Set-Mode -Mode "on"
            Write-Host "  [LLM] Mode: ON" -ForegroundColor Green

            # Show available models
            try {
                $tags = Invoke-RestMethod -Uri "$OLLAMA_URL/api/tags" -TimeoutSec 5
                $models = $tags.models | Select-Object -ExpandProperty name
                if ($models) {
                    Write-Host "  [LLM] Models available:" -ForegroundColor Gray
                    foreach ($m in $models) { Write-Host "    • $m" -ForegroundColor Gray }
                }
            } catch {}
        } else {
            Write-Host "  [LLM] Ollama not found. Install: winget install Ollama.Ollama" -ForegroundColor Red
        }
    }

    "off" {
        Set-Mode -Mode "off"
        Write-Host "  [LLM] Mode: OFF" -ForegroundColor Yellow
    }

    "status" {
        $mode = Get-Mode
        $running = Test-OllamaRunning
        Write-Host ""
        Write-Host "  LLM Status:" -ForegroundColor Cyan
        Write-Host "    Mode:        $(if ($mode -eq 'on') { '🟢 ON' } else { '🔴 OFF' })" -ForegroundColor $(if ($mode -eq 'on') { 'Green' } else { 'Yellow' })
        Write-Host "    Ollama:      $(if ($running) { '✅ Running' } else { '❌ Stopped' })" -ForegroundColor $(if ($running) { 'Green' } else { 'Red' })

        if ($running) {
            try {
                $tags = Invoke-RestMethod -Uri "$OLLAMA_URL/api/tags" -TimeoutSec 5
                if ($tags.models) {
                    Write-Host "    Models:" -ForegroundColor White
                    foreach ($m in $tags.models) {
                        $size = [math]::Round($m.size / 1GB, 2)
                        Write-Host "      $($m.name) ($size GB)" -ForegroundColor Gray
                    }
                }
            } catch {}
        }
        Write-Host ""
    }
}
