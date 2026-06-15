# Project Resolve — Per-project session & memory management
# Usage: Source this file in other scripts, or run directly for testing
#
# Functions:
#   Get-Registry              — Read registry.json
#   Set-Registry              — Write registry.json
#   Resolve-Project           — Path → project dir (create if needed)
#   Get-ActiveProject         — Get current active project path
#   Set-ActiveProject         — Set active project
#   List-Projects             — List all projects
#   Get-SessionFile           — Get session.json path for project
#   Get-MemoryDir             — Get memory/ dir for project
#   Clone-Project             — Clone GitHub repo to path
#   Ensure-ProjectDirs        — Create session + memory dirs
#
# Direct execution:
#   .\project-resolve.ps1 resolve "C:\path" "https://github.com/user/repo"
#   .\project-resolve.ps1 active
#   .\project-resolve.ps1 list
#   .\project-resolve.ps1 switch "C:\path"

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$OPENCODE_DIR = "$ROOT_DIR\.opencode"
$REGISTRY_FILE = "$OPENCODE_DIR\registry.json"

# ============================================================
# Registry CRUD
# ============================================================

function Get-Registry {
    if (-not (Test-Path $REGISTRY_FILE)) {
        return [PSCustomObject]@{
            version = "1.0"
            active_project = ""
            projects = [PSCustomObject]@{}
        }
    }
    try {
        $raw = Get-Content $REGISTRY_FILE -Raw | ConvertFrom-Json
        # Ensure projects is PSCustomObject (not corrupted)
        if ($raw.projects -is [PSCustomObject]) {
            return $raw
        }
        # Rebuild if corrupted
        $clean = [PSCustomObject]@{
            version = "1.0"
            active_project = $raw.active_project
            projects = [PSCustomObject]@{}
        }
        return $clean
    } catch {
        Write-Host "  [WARN] Registry corrupt, rebuilding..." -ForegroundColor Yellow
        return [PSCustomObject]@{
            version = "1.0"
            active_project = ""
            projects = [PSCustomObject]@{}
        }
    }
}

function Set-Registry {
    param([PSCustomObject]$Registry)
    New-Item -ItemType Directory -Path $OPENCODE_DIR -Force | Out-Null

    # Clean up projects — convert to PSCustomObject to avoid PowerShell internal properties
    $cleanProjects = [PSCustomObject]@{}
    if ($Registry.projects.PSObject.Properties) {
        foreach ($prop in $Registry.projects.PSObject.Properties) {
            $cleanProjects | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
        }
    }
    $Registry.projects = $cleanProjects

    $Registry | ConvertTo-Json -Depth 10 | Set-Content -Path $REGISTRY_FILE -Encoding UTF8
}

# ============================================================
# Project Directory Helpers
# ============================================================

function Get-ProjectSlug {
    param([string]$Path)
    $leaf = Split-Path $Path -Leaf
    $safe = $leaf -replace '[^\w\-]', '_'
    return $safe
}

function Ensure-ProjectDirs {
    param([string]$ProjectDir)
    $dirs = @(
        "$ProjectDir",
        "$ProjectDir\memory",
        "$ProjectDir\memory\sessions",
        "$ProjectDir\memory\patterns",
        "$ProjectDir\memory\errors"
    )
    foreach ($d in $dirs) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

function Get-SessionFile {
    param([string]$ProjectPath)
    $slug = Get-ProjectSlug -Path $ProjectPath
    return "$OPENCODE_DIR\projects\$slug\session.json"
}

function Get-MemoryDir {
    param([string]$ProjectPath)
    $slug = Get-ProjectSlug -Path $ProjectPath
    return "$OPENCODE_DIR\projects\$slug\memory"
}

# ============================================================
# Core: Resolve Project
# ============================================================

function Resolve-Project {
    param(
        [string]$Path,
        [string]$GitHubUrl
    )

    $normalized = $Path.TrimEnd('\', '/')
    $slug = Get-ProjectSlug -Path $normalized
    $projectDir = "$OPENCODE_DIR\projects\$slug"
    $sessionFile = "$projectDir\session.json"

    # Ensure dirs exist
    Ensure-ProjectDirs -ProjectDir $projectDir

    # Check registry
    $registry = Get-Registry
    $exists = $registry.projects.PSObject.Properties.Name -contains $normalized

    if ($exists) {
        # Update last_seen
        $registry.projects.$normalized.last_seen = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        if ($GitHubUrl) { $registry.projects.$normalized.github_url = $GitHubUrl }
        Set-Registry -Registry $registry
        Write-Host "  [PROJECT] Loaded existing: $slug" -ForegroundColor Green
    } else {
        # Register new project
        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        $newProject = [PSCustomObject]@{
            dir = $slug
            github_url = if ($GitHubUrl) { $GitHubUrl } else { "" }
            stack = ""
            profile = ""
            first_seen = $timestamp
            last_seen = $timestamp
        }

        # Add to registry (use PSCustomObject to avoid PowerShell internal properties)
        $newProjects = [PSCustomObject]@{}
        foreach ($prop in $registry.projects.PSObject.Properties) {
            $newProjects | Add-Member -NotePropertyName $prop.Name -NotePropertyValue $prop.Value -Force
        }
        $newProjects | Add-Member -NotePropertyName $normalized -NotePropertyValue $newProject -Force

        $registry.projects = $newProjects
        $registry.active_project = $normalized
        Set-Registry -Registry $registry
        Write-Host "  [PROJECT] Created new: $slug" -ForegroundColor Green
    }

    # Create session.json if not exists
    if (-not (Test-Path $sessionFile)) {
        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        $session = [PSCustomObject]@{
            version = "2.0"
            project_path = $normalized
            project_name = $slug
            github_url = if ($GitHubUrl) { $GitHubUrl } else { "" }
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
        $session | ConvertTo-Json -Depth 10 | Set-Content -Path $sessionFile -Encoding UTF8
        Write-Host "  [SESSION] Created: $slug/session.json" -ForegroundColor Gray
    }

    return $normalized
}

# ============================================================
# Clone Project
# ============================================================

function Clone-Project {
    param(
        [string]$Url,
        [string]$Destination
    )

    if (Test-Path $Destination) {
        Write-Host "  [CLONE] Path already exists: $Destination" -ForegroundColor Yellow
        # Check if it's a git repo
        if (Test-Path "$Destination\.git") {
            Write-Host "  [CLONE] Git repo detected, pulling latest..." -ForegroundColor Gray
            git -C $Destination pull --quiet 2>$null
            return $true
        }
        Write-Host "  [CLONE] Not a git repo" -ForegroundColor Yellow
        return $false
    }

    Write-Host "  [CLONE] Cloning $Url → $Destination" -ForegroundColor Cyan
    $parentDir = Split-Path $Destination -Parent
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null

    git clone --quiet $Url $Destination 2>&1 | ForEach-Object {
        Write-Host "  [CLONE] $_" -ForegroundColor Gray
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [CLONE] Success" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  [CLONE] Failed" -ForegroundColor Red
        return $false
    }
}

# ============================================================
# Get/Set Active Project
# ============================================================

function Get-ActiveProject {
    $registry = Get-Registry
    if ($registry.active_project) {
        return $registry.active_project
    }
    return $null
}

function Set-ActiveProject {
    param([string]$Path)
    $normalized = $Path.TrimEnd('\', '/')
    $registry = Get-Registry
    $registry.active_project = $normalized
    if ($registry.projects.PSObject.Properties.Name -contains $normalized) {
        $registry.projects.$normalized.last_seen = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
    }
    Set-Registry -Registry $registry
}

# ============================================================
# List Projects
# ============================================================

function List-Projects {
    $registry = Get-Registry
    $active = $registry.active_project

    if (-not $registry.projects.PSObject.Properties -or $registry.projects.PSObject.Properties.Count -eq 0) {
        Write-Host "  No projects registered." -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "  Registered Projects:" -ForegroundColor Cyan
    Write-Host "  ─────────────────────────────────────────" -ForegroundColor DarkGray

    foreach ($prop in $registry.projects.PSObject.Properties) {
        $path = $prop.Name
        $info = $prop.Value
        $isActive = ($path -eq $active)
        $marker = if ($isActive) { " * " } else { "   " }
        $color = if ($isActive) { "Green" } else { "White" }

        Write-Host "  $marker$($info.dir)" -ForegroundColor $color
        Write-Host "      Path:   $path" -ForegroundColor Gray
        if ($info.github_url) {
            Write-Host "      GitHub: $($info.github_url)" -ForegroundColor Gray
        }
        if ($info.stack) {
            Write-Host "      Stack:  $($info.stack)" -ForegroundColor Gray
        }
        Write-Host "      Last:   $($info.last_seen)" -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "  (* = active)" -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# Direct execution (when run, not sourced)
# ============================================================

if ($MyInvocation.InvocationName -ne '.') {
    $action = $args[0]
    $projectPathArg = $args[1]
    $githubUrlArg = $args[2]

    switch ($action) {
        "resolve" {
            if (-not $projectPathArg) { Write-Host "Error: project path required" -ForegroundColor Red; exit 1 }
            $result = Resolve-Project -Path $projectPathArg -GitHubUrl $githubUrlArg
            Write-Host "  Resolved: $result" -ForegroundColor Cyan
        }
        "active" {
            $active = Get-ActiveProject
            if ($active) { Write-Host $active }
            else { Write-Host "No active project" -ForegroundColor Yellow }
        }
        "list" { List-Projects }
        "switch" {
            if (-not $projectPathArg) { Write-Host "Error: project path required" -ForegroundColor Red; exit 1 }
            Set-ActiveProject -Path $projectPathArg
            Write-Host "  Switched to: $projectPathArg" -ForegroundColor Green
        }
        "ensure" {
            if (-not $projectPathArg) { Write-Host "Error: project path required" -ForegroundColor Red; exit 1 }
            $slug = Get-ProjectSlug -Path $projectPathArg
            $dir = "$OPENCODE_DIR\projects\$slug"
            Ensure-ProjectDirs -ProjectDir $dir
            Write-Host "  Ensured: $dir" -ForegroundColor Green
        }
        default {
            Write-Host "Usage: .\project-resolve.ps1 <action> [projectPath] [githubUrl]" -ForegroundColor Yellow
            Write-Host "Actions: resolve, active, list, switch, ensure" -ForegroundColor Gray
        }
    }
}
