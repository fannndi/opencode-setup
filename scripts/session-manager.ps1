# Session Manager — Baca/tulis status workflow
# Usage: .\session-manager.ps1 -Action read|write|reset|status

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("read", "write", "reset", "status")]
    [string]$Action,
    
    [string]$Key,
    [string]$Value
)

$ErrorActionPreference = "Stop"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SESSION_FILE = "$ROOT_DIR\.opencode-session.json"

# ============================================================
# Read
# ============================================================

function Read-Session {
    if (-not (Test-Path $SESSION_FILE)) {
        Write-Host "  No session file found. Starting fresh." -ForegroundColor Yellow
        return $null
    }
    
    try {
        $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
        return $session
    } catch {
        Write-Host "  Session file corrupt. Starting fresh." -ForegroundColor Yellow
        return $null
    }
}

# ============================================================
# Write
# ============================================================

function Write-Session {
    param(
        [string]$Key,
        [string]$Value
    )
    
    $session = Read-Session
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    
    if ($null -eq $session) {
        # Create new session
        $session = [PSCustomObject]@{
            version = "1.0"
            last_profile = ""
            stack = ""
            skills_loaded = @()
            rules_applied = @()
            workflow_state = [PSCustomObject]@{
                prd_analyzed = $false
                ai_notes_generated = $false
                analyze_project_done = $false
            }
            last_action = ""
            created_at = $timestamp
            updated_at = $timestamp
        }
    }
    
    # Update the specific key
    switch ($Key) {
        "profile" { $session.last_profile = $Value }
        "stack" { $session.stack = $Value }
        "skills" { $session.skills_loaded = $Value -split "," }
        "rules" { $session.rules_applied = $Value -split "," }
        "prd_analyzed" { $session.workflow_state.prd_analyzed = [bool]$Value }
        "ai_notes_generated" { $session.workflow_state.ai_notes_generated = [bool]$Value }
        "analyze_project_done" { $session.workflow_state.analyze_project_done = [bool]$Value }
        "last_action" { $session.last_action = $Value }
        "current_project" { $session.current_project = $Value }
    }
    
    $session.updated_at = $timestamp
    
    # Save
    $session | ConvertTo-Json -Depth 10 | Set-Content -Path $SESSION_FILE -Encoding UTF8
    Write-Host "  Session updated: $Key = $Value" -ForegroundColor Green
}

# ============================================================
# Reset
# ============================================================

function Reset-Session {
    if (Test-Path $SESSION_FILE) {
        Remove-Item $SESSION_FILE -Force
        Write-Host "  Session reset. Starting fresh." -ForegroundColor Yellow
    } else {
        Write-Host "  No session to reset." -ForegroundColor Gray
    }
}

# ============================================================
# Status
# ============================================================

function Show-Status {
    $session = Read-Session
    
    if ($null -eq $session) {
        Write-Host "  Status: No session (fresh start)" -ForegroundColor Yellow
        return
    }
    
    Write-Host ""
    Write-Host "  Session Status:" -ForegroundColor Cyan
    Write-Host "    Profile:        $($session.last_profile)" -ForegroundColor White
    Write-Host "    Stack:          $($session.stack)" -ForegroundColor White
    Write-Host "    Skills loaded:  $($session.skills_loaded.Count)" -ForegroundColor White
    Write-Host "    Current project: $($session.current_project)" -ForegroundColor White
    Write-Host "    Last action:    $($session.last_action)" -ForegroundColor White
    Write-Host "    Created:        $($session.created_at)" -ForegroundColor Gray
    Write-Host "    Updated:        $($session.updated_at)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Workflow State:" -ForegroundColor Cyan
    Write-Host "    PRD analyzed:       $($session.workflow_state.prd_analyzed)" -ForegroundColor $(if ($session.workflow_state.prd_analyzed) { "Green" } else { "Yellow" })
    Write-Host "    AI Notes generated: $($session.workflow_state.ai_notes_generated)" -ForegroundColor $(if ($session.workflow_state.ai_notes_generated) { "Green" } else { "Yellow" })
    Write-Host "    Analyze project:    $($session.workflow_state.analyze_project_done)" -ForegroundColor $(if ($session.workflow_state.analyze_project_done) { "Green" } else { "Yellow" })
    Write-Host ""
}

# ============================================================
# Execute
# ============================================================

switch ($Action) {
    "read" {
        $session = Read-Session
        if ($null -ne $session) {
            $session | ConvertTo-Json -Depth 10
        }
    }
    "write" {
        if (-not $Key) { Write-Host "Error: -Key required for write" -ForegroundColor Red; exit 1 }
        Write-Session -Key $Key -Value $Value
    }
    "reset" { Reset-Session }
    "status" { Show-Status }
}
