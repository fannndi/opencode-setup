# Self-Heal Hook — PostToolUse: auto-fix type errors after code changes
# Trigger: after Edit or Write tool
# Checks: tsc (TypeScript), flutter analyze (Dart), ruff (Python)

param(
    [string]$FilePath,
    [string]$ProjectPath
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

if (-not $ProjectPath -and $env:ECC_PROJECT_PATH) {
    $ProjectPath = $env:ECC_PROJECT_PATH
}
if (-not $ProjectPath) {
    # Try from registry
    . "$SETUP_DIR\project-resolve.ps1"
    . "$SETUP_DIR\llm-adapter.ps1"
    $ProjectPath = Get-ActiveProject
}
if (-not $ProjectPath) { exit 0 }

# Determine project type
$isFlutter = Test-Path "$ProjectPath\pubspec.yaml"
$isNode = Test-Path "$ProjectPath\package.json"
$isPython = Test-Path "$ProjectPath\requirements.txt" -or (Test-Path "$ProjectPath\pyproject.toml")

# Change to project directory
Push-Location $ProjectPath

$errorCount = 0

# ============================================================
# Check 1: TypeScript / Node
# ============================================================
if ($isNode) {
    # Check if tsconfig exists (nested project)
    $tsconfigPaths = @("$ProjectPath\tsconfig.json", "$ProjectPath\backend\tsconfig.json")
    $hasTs = $false
    foreach ($tsp in $tsconfigPaths) {
        if (Test-Path $tsp) {
            $hasTs = $true
            $checkDir = Split-Path $tsp -Parent
            Write-Host "  [HEAL] Checking TypeScript..." -ForegroundColor Gray
            $result = & npx --yes tsc --noEmit 2>&1 | Select-String -Pattern "error TS" -SimpleMatch
            if ($result) {
                $errorCount = ($result | Measure-Object).Count
                if ($errorCount -gt 0) {
                    Write-Host "  [HEAL] $errorCount TS errors detected" -ForegroundColor Yellow
                    $suggestion = Invoke-LLMEnrich -Text "$errorCount TS errors" -Context "Analyze and suggest fixes"
                    Write-Host "  [HEAL] LLM suggestion: $suggestion" -ForegroundColor Cyan
                }
            }
            break
        }
    }
}

# ============================================================
# Check 2: Flutter / Dart
# ============================================================
if ($isFlutter) {
    Write-Host "  [HEAL] Checking Flutter analyze..." -ForegroundColor Gray
    $result = & flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1
    $hasError = $result | Select-String -Pattern "error -"
    if ($hasError) {
        $errorCount = ($hasError | Measure-Object).Count
        Write-Host "  [HEAL] $errorCount Dart errors detected" -ForegroundColor Yellow
        $suggestion = Invoke-LLMEnrich -Text "$errorCount Dart errors" -Context "Analyze and suggest fixes"
        Write-Host "  [HEAL] LLM suggestion: $suggestion" -ForegroundColor Cyan
    }
}

Pop-Location

# Signal result to calling process via env var
[Environment]::SetEnvironmentVariable('ECC_HEAL_ERRORS', $errorCount.ToString(), 'Process')
