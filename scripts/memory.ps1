# Memory Manager — Simpan & baca memori session
# Usage: .\memory.ps1 -Action save|read|status

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
$MEMORY_DIR = "$ROOT_DIR\project-memory"

# ============================================================
# Save session note
# ============================================================

function Save-Session {
    param([string]$Project)
    $today = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"
    $sessionFile = "$MEMORY_DIR\sessions\$today.md"
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
    Write-Host ""
    Write-Host "  ─── Project Memory ───" -ForegroundColor Cyan
    
    # Sessions
    $sessionFiles = Get-ChildItem "$MEMORY_DIR\sessions\*.md" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 5
    if ($sessionFiles) {
        Write-Host ""
        Write-Host "  Recent sessions:" -ForegroundColor Yellow
        foreach ($f in $sessionFiles) {
            $firstLine = Get-Content $f.FullName -TotalCount 3 | Where-Object { $_ -match "Project:" } | Select-Object -First 1
            Write-Host "  • $($f.BaseName) — $firstLine" -ForegroundColor Gray
        }
    }
    
    # Patterns
    $patternFiles = Get-ChildItem "$MEMORY_DIR\patterns\*.md" -ErrorAction SilentlyContinue
    if ($patternFiles) {
        Write-Host ""
        Write-Host "  Patterns learned:" -ForegroundColor Yellow
        foreach ($f in $patternFiles) {
            $desc = Get-Content $f.FullName -TotalCount 2 | Select-Object -Last 1
            Write-Host "  • $($f.BaseName): $desc" -ForegroundColor Gray
        }
    }
    
    # Errors
    $errorFiles = Get-ChildItem "$MEMORY_DIR\errors\*.md" -ErrorAction SilentlyContinue
    if ($errorFiles) {
        Write-Host ""
        Write-Host "  Error history:" -ForegroundColor Yellow
        foreach ($f in $errorFiles) {
            $solution = Get-Content $f.FullName -TotalCount 2 | Where-Object { $_ -match "Solution:" } | Select-Object -First 1
            Write-Host "  • $($f.BaseName) — $solution" -ForegroundColor Gray
        }
    }
    
    # Preferences
    $prefFile = "$MEMORY_DIR\preferences\current.md"
    if (Test-Path $prefFile) {
        Write-Host ""
        Write-Host "  Preferences:" -ForegroundColor Yellow
        Get-Content $prefFile | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }
    }
    
    Write-Host ""
}

# ============================================================
# Add pattern
# ============================================================

function Add-Pattern {
    param([string]$Name, [string]$Description)
    $safeName = $Name -replace '[^\w\-]', '_'
    $file = "$MEMORY_DIR\patterns\$safeName.md"
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
    $safeName = $Name -replace '[^\w\-]', '_'
    $file = "$MEMORY_DIR\errors\$safeName.md"
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
