# Memory Manager — Per-project memory
# Usage: .\memory.ps1 -Action save|read|status|add-pattern|add-error

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("save", "read", "status", "add-pattern", "add-error")]
    [string]$Action,

    [string]$Key,
    [string]$Value,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$OPENCODE_DIR = "$ROOT_DIR\.opencode"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve Memory Directory
# ============================================================

function Get-CurrentMemoryDir {
    # If ProjectPath given, use it
    if ($ProjectPath) {
        $normalized = $ProjectPath.TrimEnd('\', '/')
        $slug = Get-ProjectSlug -Path $normalized
        $md = "$OPENCODE_DIR\projects\$slug\memory"
        if (Test-Path $md) { return $md }
        # Create if not exists
        $dir = "$OPENCODE_DIR\projects\$slug"
        Ensure-ProjectDirs -ProjectDir $dir
        return $md
    }

    # Try active project from registry
    $active = Get-ActiveProject
    if ($active) {
        $slug = Get-ProjectSlug -Path $active
        $md = "$OPENCODE_DIR\projects\$slug\memory"
        if (Test-Path $md) { return $md }
        $dir = "$OPENCODE_DIR\projects\$slug"
        Ensure-ProjectDirs -ProjectDir $dir
        return $md
    }

    # Fallback
    return $null
}

# ============================================================
# Save session note
# ============================================================

function Save-Session {
    param([string]$Project)
    $memDir = Get-CurrentMemoryDir
    if (-not $memDir) {
        Write-Host "  No project active. Use /set-project first." -ForegroundColor Yellow
        return
    }

    $today = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"
    $sessionFile = "$memDir\sessions\$today.md"
    $entry = "`n### $time - Project: $Project`n$Value`n"

    if (Test-Path $sessionFile) { Add-Content -Path $sessionFile -Value $entry -Encoding UTF8 }
    else {
        $header = "# Session Log — $today`n`n$entry"
        Set-Content -Path $sessionFile -Value $header -Encoding UTF8
    }
    Write-Host "  [MEMORY] Saved to sessions/$today.md" -ForegroundColor Green
}

# ============================================================
# Read memory
# ============================================================

function Read-Memory {
    $memDir = Get-CurrentMemoryDir
    if (-not $memDir) {
        Write-Host "  No project active. Use /set-project first." -ForegroundColor Yellow
        return
    }

    $slug = Split-Path (Split-Path $memDir -Parent) -Leaf
    Write-Host ""
    Write-Host "  ─── Project Memory: $slug ───" -ForegroundColor Cyan

    # Sessions
    $sessionFiles = Get-ChildItem "$memDir\sessions\*.md" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 5
    if ($sessionFiles) {
        Write-Host ""
        Write-Host "  Recent sessions:" -ForegroundColor Yellow
        foreach ($f in $sessionFiles) {
            $firstLine = Get-Content $f.FullName -TotalCount 3 | Where-Object { $_ -match "Project:" } | Select-Object -First 1
            Write-Host "  • $($f.BaseName) — $firstLine" -ForegroundColor Gray
        }
    }

    # Patterns
    $patternFiles = Get-ChildItem "$memDir\patterns\*.md" -ErrorAction SilentlyContinue
    if ($patternFiles) {
        Write-Host ""
        Write-Host "  Patterns learned:" -ForegroundColor Yellow
        foreach ($f in $patternFiles) {
            $desc = Get-Content $f.FullName -TotalCount 2 | Select-Object -Last 1
            Write-Host "  • $($f.BaseName): $desc" -ForegroundColor Gray
        }
    }

    # Errors
    $errorFiles = Get-ChildItem "$memDir\errors\*.md" -ErrorAction SilentlyContinue
    if ($errorFiles) {
        Write-Host ""
        Write-Host "  Error history:" -ForegroundColor Yellow
        foreach ($f in $errorFiles) {
            $solution = Get-Content $f.FullName -TotalCount 2 | Where-Object { $_ -match "Solution:" } | Select-Object -First 1
            Write-Host "  • $($f.BaseName) — $solution" -ForegroundColor Gray
        }
    }

    Write-Host ""
}

# ============================================================
# Add pattern
# ============================================================

function Add-Pattern {
    param([string]$Name, [string]$Description)
    $memDir = Get-CurrentMemoryDir
    if (-not $memDir) {
        Write-Host "  No project active." -ForegroundColor Yellow
        return
    }
    $safeName = $Name -replace '[^\w\-]', '_'
    $file = "$memDir\patterns\$safeName.md"
@"
# $Name
$Description
"@ | Set-Content -Path $file -Encoding UTF8
    Write-Host "  [MEMORY] Pattern saved: $Name" -ForegroundColor Green
}

# ============================================================
# Add error
# ============================================================

function Add-Error {
    param([string]$Name, [string]$Solution)
    $memDir = Get-CurrentMemoryDir
    if (-not $memDir) {
        Write-Host "  No project active." -ForegroundColor Yellow
        return
    }
    $safeName = $Name -replace '[^\w\-]', '_'
    $file = "$memDir\errors\$safeName.md"
@"
# $Name
- Solution: $Solution
- Date: $(Get-Date -Format "yyyy-MM-dd")
"@ | Set-Content -Path $file -Encoding UTF8
    Write-Host "  [MEMORY] Error fix saved: $Name" -ForegroundColor Green
}

# ============================================================
# Execute
# ============================================================

switch ($Action) {
    "save" {
        if (-not $Value) { Write-Host "[ERROR] -Value required" -ForegroundColor Red; exit 1 }
        $projectPath = if ($ProjectPath) { $ProjectPath } else { "opencode-setup" }
        Save-Session -Project $projectPath
    }
    "read" { Read-Memory }
    "status" { Read-Memory }
    "add-pattern" {
        if (-not $Key -or -not $Value) { Write-Host "[ERROR] -Key (pattern name) and -Value (description) required" -ForegroundColor Red; exit 1 }
        Add-Pattern -Name $Key -Description $Value
    }
    "add-error" {
        if (-not $Key -or -not $Value) { Write-Host "[ERROR] -Key (error name) and -Value (solution) required" -ForegroundColor Red; exit 1 }
        Add-Error -Name $Key -Solution $Value
    }
}
