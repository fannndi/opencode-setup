# File Index — Content hash cache for scripts and configs
# Usage: .\file-index.ps1 [-Update] [-Check <path>]
# Auto-updates .opencode/file-index.json

param(
    [switch]$Update,
    [string]$Check
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$INDEX_FILE = "$ROOT_DIR\.opencode\file-index.json"

$WATCH_DIRS = @(
    "$ROOT_DIR\scripts\*.ps1",
    "$ROOT_DIR\profiles\*\opencode.jsonc",
    "$ROOT_DIR\commands\*.md",
    "$ROOT_DIR\instructions\*.md",
    "$ROOT_DIR\.opencode\*.md"
)

function Get-FileHashSimple {
    param([string]$Path)
    try {
        $content = Get-Content $Path -Raw -ErrorAction Stop
        return [System.Convert]::ToBase64String(
            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes($content)
            )
        ).Substring(0, 12)
    } catch { return "error" }
}

# Check single file
if ($Check) {
    $hash = Get-FileHashSimple -Path $Check
    if (Test-Path $INDEX_FILE) {
        $index = Get-Content $INDEX_FILE -Raw | ConvertFrom-Json
        $cached = $index.files.$Check
        if ($cached -and $cached.hash -eq $hash) { return $true }
    }
    return $false
}

# Update index
if ($Update) {
    $index = @{ files = @{}; updated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss") }

    foreach ($pattern in $WATCH_DIRS) {
        Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue | ForEach-Object {
            $relPath = $_.FullName.Substring($ROOT_DIR.Length + 1)
            $index.files[$relPath] = @{
                hash = Get-FileHashSimple -Path $_.FullName
                size = $_.Length
                last_write = $_.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ss")
            }
        }
    }

    New-Item -ItemType Directory -Path (Split-Path $INDEX_FILE -Parent) -Force | Out-Null
    $index | ConvertTo-Json -Depth 5 | Set-Content -Path $INDEX_FILE -Encoding UTF8
    Write-Host "  [INDEX] Updated: $($index.files.Keys.Count) files" -ForegroundColor Gray
}

return (Get-Content $INDEX_FILE -Raw | ConvertFrom-Json)
