# Create Function — Generate modular function boilerplate
# Usage: .\create-function.ps1 -Name "Login-Attempt" -Module "auth"
#        .\create-function.ps1 -Name "Validate-Email" -Module "user" -Requires "shared/validation.ps1"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [string]$Module,

    [string]$Description,

    [string]$Requires,

    [string]$Exports,

    [ValidateSet("ps1", "ts", "py", "go")]
    [string]$Lang = "ps1",

    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"

if (-not $ProjectPath) { $ProjectPath = Get-ActiveProject }
if (-not $ProjectPath) { $ProjectPath = $ROOT_DIR }

$moduleDir = if ($Module) { "$ProjectPath\modules\$Module" } else { "$ProjectPath\modules" }
New-Item -ItemType Directory -Path $moduleDir -Force | Out-Null

$safeName = $Name -replace '[^\w-]', ''
$filePath = "$moduleDir\$safeName.$Lang"
if (Test-Path $filePath) {
    Write-Host "  [ERROR] File exists: $filePath" -ForegroundColor Red
    exit 1
}

$desc = if ($Description) { $Description } else { "$safeName function" }
$reqComment = if ($Requires) { "# Requires: $Requires" } else { "" }
$expComment = if ($Exports) { "# Exports: $Exports" } else { "# Exports: $safeName" }
$timestamp = Get-Date -Format "yyyy-MM-dd"

$content = switch ($Lang) {
    "ps1" {
@"
# $desc
# Usage: $safeName -Param "value"
$reqComment
$expComment
# Created: $timestamp

param(
    [Parameter(Mandatory=`$true)]
    [string]`$Input
)

`$ErrorActionPreference = "Stop"

try {
    # --- logic start ---

    # --- logic end ---
} catch {
    Write-Error "FATAL: `$(`$_.Exception.Message)"
    return `$null
}
"@
    }
    "ts" {
@"
// $desc
// $reqComment
// $expComment
// Created: $timestamp

export interface ${safeName}Input {
  input: string;
}

export interface ${safeName}Result {
  success: boolean;
  data?: unknown;
  error?: string;
}

export async function $safeName(input: ${safeName}Input): Promise<${safeName}Result> {
  try {
    // --- logic start ---

    // --- logic end ---
    return { success: true, data: null };
  } catch (error) {
    return { success: false, error: (error as Error).message };
  }
}
"@
    }
    "py" {
@"
"""$desc
Usage: result = $safe_name(param)
$reqComment
$expComment
Created: $timestamp
"""

from typing import Optional


def $safe_name(input_data: str) -> Optional[dict]:
    try:
        # --- logic start ---

        # --- logic end ---
        return {"success": True}
    except Exception as e:
        print(f"FATAL: {e}")
        return None
"@
    }
    "go" {
@"
// $desc
// $reqComment
// $expComment
// Created: $timestamp

package module

import "fmt"

type ${safeName}Input struct {
	Input string
}

type ${safeName}Result struct {
	Success bool
	Data    interface{}
	Error   string
}

func $safeName(input ${safeName}Input) ${safeName}Result {
	// --- logic start ---

	// --- logic end ---
	return ${safeName}Result{Success: true}
}
"@
    }
}

# Check 1500 char hard limit
if ($content.Length -gt 1500) {
    Write-Host "  [WARN] Generated content exceeds 1500 chars ($($content.Length))" -ForegroundColor Yellow
    Write-Host "  Consider simplifying the function signature" -ForegroundColor Yellow
}

Set-Content -Path $filePath -Value $content -Encoding UTF8
Write-Host "  [OK] Created: $filePath ($($content.Length) chars)" -ForegroundColor Green

# If module dir has >=5 files, suggest sub-directory
$fileCount = (Get-ChildItem -Path $moduleDir -Filter "*.$Lang" -ErrorAction SilentlyContinue).Count
if ($fileCount -ge 5) {
    Write-Host "  [HINT] Module '$Module' has $fileCount files — consider grouping to sub-dir" -ForegroundColor Yellow
}

# Check if index.ps1 exists, if not suggest creating
$indexFile = "$moduleDir\index.ps1"
if (-not (Test-Path $indexFile) -and $Lang -eq "ps1") {
    $indexContent = "# $Module module — auto-generated index`n`n"
    $indexContent += Get-ChildItem -Path $moduleDir -Filter "*.ps1" -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -ne "index.ps1" } |
        ForEach-Object { ". `$PSScriptRoot\$($_.Name)" } |
        Join-String -Separator "`n"
    Set-Content -Path $indexFile -Value $indexContent -Encoding UTF8
    Write-Host "  [OK] Created index: $indexFile" -ForegroundColor Green
}
