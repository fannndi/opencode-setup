# Session Manager — Per-project session management
# Usage: .\session-manager.ps1 -Action read|write|reset|status|list|switch

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("read", "write", "reset", "status", "list", "switch")]
    [string]$Action,

    [string]$Key,
    [string]$Value,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$PROJECT_ROOT = "$ROOT_DIR\Project"
$REGISTRY_FILE = "$PROJECT_ROOT\registry.json"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve Session File for Current Project
# ============================================================

function Get-CurrentSessionFile {
    if ($ProjectPath) {
        $normalized = $ProjectPath.TrimEnd('\', '/')
        $sf = Get-SessionFile -ProjectPath $normalized
        if (Test-Path $sf) { return $sf }
        return $null
    }

    $active = Get-ActiveProject
    if ($active) {
        $sf = Get-SessionFile -ProjectPath $active
        if (Test-Path $sf) { return $sf }
    }

    return $null
}

# ============================================================
# Read
# ============================================================

function Read-Session {
    $sf = Get-CurrentSessionFile
    if (-not $sf) {
        Write-Host "  No session found. Use /set-project first." -ForegroundColor Yellow
        return $null
    }
    try {
        return Get-Content $sf -Raw | ConvertFrom-Json
    } catch {
        Write-Host "  Session file corrupt." -ForegroundColor Yellow
        return $null
    }
}

# ============================================================
# Write
# ============================================================

function Write-Session {
    param([string]$Key, [string]$Value)

    $active = Get-ActiveProject
    if (-not $active) {
        Write-Host "  No active project. Use /set-project first." -ForegroundColor Yellow
        return
    }

    $sf = Get-SessionFile -ProjectPath $active
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"

    $session = $null
    if (Test-Path $sf) {
        try { $session = Get-Content $sf -Raw | ConvertFrom-Json } catch {}
    }

    if ($null -eq $session) {
        $slug = Get-ProjectSlug -Path $active
        $session = [PSCustomObject]@{
            version = "2.0"
            project_path = $active
            project_name = $slug
            github_url = ""
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

    switch ($Key) {
        "profile" { $session.last_profile = $Value }
        "stack" { $session.stack = $Value }
        "skills" { $session.skills_loaded = $Value -split "," }
        "rules" { $session.rules_applied = $Value -split "," }
        "prd_analyzed" { $session.workflow_state.prd_analyzed = [bool]$Value }
        "ai_notes_generated" { $session.workflow_state.ai_notes_generated = [bool]$Value }
        "analyze_project_done" { $session.workflow_state.analyze_project_done = [bool]$Value }
        "last_action" { $session.last_action = $Value }
        "github_url" { $session.github_url = $Value }
    }

    $session.updated_at = $timestamp
    $session | ConvertTo-Json -Depth 10 | Set-Content -Path $sf -Encoding UTF8
    Write-Host "  Session updated: $Key = $Value" -ForegroundColor Green
}

# ============================================================
# Reset
# ============================================================

function Reset-Session {
    $sf = Get-CurrentSessionFile
    if ($sf -and (Test-Path $sf)) {
        Remove-Item $sf -Force
        Write-Host "  Session reset." -ForegroundColor Yellow
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
    Write-Host "    Project:        $($session.project_name)" -ForegroundColor White
    Write-Host "    Path:           $($session.project_path)" -ForegroundColor White
    if ($session.github_url) {
        Write-Host "    GitHub:         $($session.github_url)" -ForegroundColor White
    }
    Write-Host "    Profile:        $($session.last_profile)" -ForegroundColor White
    Write-Host "    Stack:          $($session.stack)" -ForegroundColor White
    Write-Host "    Skills loaded:  $($session.skills_loaded.Count)" -ForegroundColor White
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
        if ($null -ne $session) { $session | ConvertTo-Json -Depth 10 }
    }
    "write" {
        if (-not $Key) { Write-Host "Error: -Key required" -ForegroundColor Red; exit 1 }
        Write-Session -Key $Key -Value $Value
    }
    "reset" { Reset-Session }
    "status" { Show-Status }
    "list" { List-Projects }
    "switch" {
        if (-not $ProjectPath) { Write-Host "Error: -ProjectPath required" -ForegroundColor Red; exit 1 }
        Set-ActiveProject -Path $ProjectPath
        $slug = Get-ProjectSlug -Path $ProjectPath
        Write-Host "  Switched to: $slug" -ForegroundColor Green
    }
}
