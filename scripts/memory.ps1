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
$PROJECT_ROOT = "$ROOT_DIR\Project"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve Memory Directory
# ============================================================

function Get-CurrentMemoryDir {
    if ($ProjectPath) {
        $normalized = $ProjectPath.TrimEnd('\', '/')
        $md = Get-MemoryDir -ProjectPath $normalized
        if (Test-Path $md) { return $md }
        $slug = Get-ProjectSlug -Path $normalized
        Ensure-ProjectDirs -Slug $slug
        return $md
    }

    $active = Get-ActiveProject
    if ($active) {
        $md = Get-MemoryDir -ProjectPath $active
        if (Test-Path $md) { return $md }
        $slug = Get-ProjectSlug -Path $active
        Ensure-ProjectDirs -Slug $slug
        return $md
    }

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
    Write-Host "  [MEMORY] Saved to Memory/$((Split-Path $memDir -Leaf))/sessions/$today.md" -ForegroundColor Green
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

    $slug = Split-Path $memDir -Leaf
    Write-Host ""
    Write-Host "  ─── Project Memory: $slug ───" -ForegroundColor Cyan

    $sessionFiles = Get-ChildItem "$memDir\sessions\*.md" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 5
    if ($sessionFiles) {
        Write-Host ""
        Write-Host "  Recent sessions:" -ForegroundColor Yellow
        foreach ($f in $sessionFiles) {
            $firstLine = Get-Content $f.FullName -TotalCount 3 | Where-Object { $_ -match "Project:" } | Select-Object -First 1
            Write-Host "  • $($f.BaseName) — $firstLine" -ForegroundColor Gray
        }
    }

    $patternFiles = Get-ChildItem "$memDir\patterns\*.md" -ErrorAction SilentlyContinue
    if ($patternFiles) {
        Write-Host ""
        Write-Host "  Patterns learned:" -ForegroundColor Yellow
        foreach ($f in $patternFiles) {
            $desc = Get-Content $f.FullName -TotalCount 2 | Select-Object -Last 1
            Write-Host "  • $($f.BaseName): $desc" -ForegroundColor Gray
        }
    }

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
    if (-not $memDir) { Write-Host "  No project active." -ForegroundColor Yellow; return }
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
    if (-not $memDir) { Write-Host "  No project active." -ForegroundColor Yellow; return }
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
        $projName = if ($ProjectPath) { Split-Path $ProjectPath -Leaf } else { "general" }
        Save-Session -Project $projName
    }
    "read" { Read-Memory }
    "status" { Read-Memory }
    "add-pattern" {
        if (-not $Key -or -not $Value) { Write-Host "[ERROR] -Key and -Value required" -ForegroundColor Red; exit 1 }
        Add-Pattern -Name $Key -Description $Value
    }
    "add-error" {
        if (-not $Key -or -not $Value) { Write-Host "[ERROR] -Key and -Value required" -ForegroundColor Red; exit 1 }
        Add-Error -Name $Key -Solution $Value
    }
}
