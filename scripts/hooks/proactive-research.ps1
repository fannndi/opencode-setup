# Proactive Research Hook — PreToolUse: research unknown libraries
# Trigger: before Edit/Write if file references unknown dependencies

param(
    [string]$FilePath,
    [string]$ProjectPath
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"

if (-not $ProjectPath -and $env:ECC_PROJECT_PATH) {
    $ProjectPath = $env:ECC_PROJECT_PATH
}
if (-not $ProjectPath) { exit 0 }

$memDir = Get-MemoryDir -ProjectPath $ProjectPath
$knownLibsFile = "$memDir\patterns\known-libraries.md"

# Track known libraries
$knownLibs = @{}
if (Test-Path $knownLibsFile) {
    try {
        $lines = Get-Content $knownLibsFile
        foreach ($line in $lines) {
            if ($line -match '^- (.+?):') {
                $knownLibs[$Matches[1]] = $true
            }
        }
    } catch {}
}

# Check file content for unknown imports
if ($FilePath -and (Test-Path $FilePath)) {
    try {
        $content = Get-Content $FilePath -Raw
        $imports = [regex]::Matches($content, "(?:import|from|require|using)\s+['""]([^'""]+)['""]", 'IgnoreCase')

        foreach ($m in $imports) {
            $libName = $m.Groups[1].Value
            # Extract base package name
            $pkgName = ""
            if ($libName -match "^@?([\w-]+)") {
                $pkgName = $Matches[1]
            }
            if ($pkgName -and -not $knownLibs.ContainsKey($pkgName)) {
                # New library — log it
                $knownLibs[$pkgName] = $true
                $entry = "- $pkgName: first seen $(Get-Date -Format 'yyyy-MM-dd')"
                Add-Content -Path $knownLibsFile -Value $entry -Encoding UTF8 -ErrorAction SilentlyContinue
                Write-Host "  [RESEARCH] New library detected: $pkgName" -ForegroundColor Yellow
            }
        }
    } catch {}
}

exit 0
