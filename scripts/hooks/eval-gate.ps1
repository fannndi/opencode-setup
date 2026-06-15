# Eval Gate Hook — PostToolUse: auto-run tests after changes
# Trigger: after Edit/Write on test files (*.spec.ts, *_test.dart, *_test.py)

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
    . "$SETUP_DIR\project-resolve.ps1"
    . "$ROOT_DIR\scripts\llm-adapter.ps1"
    $ProjectPath = Get-ActiveProject
}
if (-not $ProjectPath) { exit 0 }

# Only trigger on test files
$fileName = Split-Path $FilePath -Leaf
$isTestFile = $fileName -match '\.(spec|test)\.(ts|js|dart|py)$'
if (-not $isTestFile) { exit 0 }

Push-Location $ProjectPath

$isFlutter = Test-Path "pubspec.yaml"
$isNode = Test-Path "package.json"

$result = ""
$passed = $false

if ($isFlutter) {
    Write-Host "  [GATE] Running flutter test: $fileName" -ForegroundColor Gray
    $result = & flutter test --reporter compact 2>&1 | Out-String
    $passed = ($result -match "All tests passed" -or $result -match "PASS")
}
elseif ($isNode) {
    Write-Host "  [GATE] Running test: $fileName" -ForegroundColor Gray
    $result = & npx jest --testPathPattern="$fileName" --no-coverage 2>&1 | Out-String
    $passed = ($result -match "Tests:\s+\d+ passed" -or $result -match "PASS")
}

Pop-Location

if ($passed) {
    Write-Host "  [GATE] ✅ Tests passed" -ForegroundColor Green
    $analysis = Invoke-LLMEnrich -Text "Test $result" -Context "Test gate result"
    Write-Host "  [GATE] LLM analysis: $analysis" -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable('ECC_GATE_RESULT', 'PASS', 'Process')
} else {
    Write-Host "  [GATE] ❌ Tests failed" -ForegroundColor Red
    Write-Host "  $result" -ForegroundColor Gray
    $analysis = Invoke-LLMEnrich -Text "Test $result" -Context "Test gate result"
    Write-Host "  [GATE] LLM analysis: $analysis" -ForegroundColor Cyan
    [Environment]::SetEnvironmentVariable('ECC_GATE_RESULT', 'FAIL', 'Process')
}

exit 0
