# Instinct Extract — StopHook: auto-extract patterns from session
# Trigger: session end (Stop hook)
# Extracts: error-solutions, code-patterns, user-preferences

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\agent-core.ps1"

$activeProject = Get-ActiveProject
if (-not $activeProject) { exit 0 }

$memDir = Get-MemoryDir -ProjectPath $activeProject
$slug = Get-ProjectSlug -Path $activeProject

# ============================================================
# Extract 1: Error solutions from session history
# ============================================================
$sessionLog = "$memDir\sessions\$(Get-Date -Format 'yyyy-MM-dd').md"
if (Test-Path $sessionLog) {
    $content = Get-Content $sessionLog -Raw

    # Look for error→solution patterns
    $errorPatterns = [regex]::Matches($content, '(?:error|bug|fail|gagal|salah)[^:]*:\s*([^\n]+)', 'IgnoreCase')
    $solutionPatterns = [regex]::Matches($content, '(?:fix|solusi|resolve|fixed|fixed by)\s*:?\s*([^\n]+)', 'IgnoreCase')

    if ($errorPatterns.Count -gt 0 -and $solutionPatterns.Count -gt 0) {
        $min = [Math]::Min($errorPatterns.Count, $solutionPatterns.Count)
        for ($i = 0; $i -lt $min; $i++) {
            $errName = $errorPatterns[$i].Groups[1].Value.Trim()
            $solDesc = $solutionPatterns[$i].Groups[1].Value.Trim()
            $safeName = $errName -replace '[^\w\-]', '_'

            $patternFile = "$memDir\errors\$safeName.md"
            if (-not (Test-Path $patternFile)) {
@" 
# $errName
- Solution: $solDesc
- Date: $(Get-Date -Format "yyyy-MM-dd")
- Auto-extracted from session
"@ | Set-Content -Path $patternFile -Encoding UTF8
                Write-Host "  [INSTINCT] Extracted error fix: $errName" -ForegroundColor Green
            }
        }
    }
}

# ============================================================
# Extract 2: Framework patterns from error files
# ============================================================
$contextLog = "$memDir\sessions\context.md"
$patternsDir = "$memDir\patterns"
New-Item -ItemType Directory -Path $patternsDir -Force | Out-Null

# Detect patterns from project structure
$projectPath = $activeProject
if (Test-Path "$projectPath\package.json") {
    try {
        $pkg = Get-Content "$projectPath\package.json" -Raw | ConvertFrom-Json
        $allDeps = @()
        if ($pkg.dependencies) { $allDeps += $pkg.dependencies.PSObject.Properties.Name }
        if ($pkg.devDependencies) { $allDeps += $pkg.devDependencies.PSObject.Properties.Name }

        # Save framework pattern
        $frameworkFile = "$patternsDir\project-framework.md"
        if (-not (Test-Path $frameworkFile)) {
            $coreDeps = $allDeps | Select-Object -First 20
@" 
# Project Framework Dependencies
- Stack: $( -join $allDeps)
- Auto-detected: $(Get-Date -Format "yyyy-MM-dd")
"@ | Set-Content -Path $frameworkFile -Encoding UTF8
        }
    } catch {}
}

# ============================================================
# Update session with pattern count
# ============================================================
$sf = Get-SessionFile -ProjectPath $activeProject
if (Test-Path $sf) {
    try {
        $session = Get-Content $sf -Raw | ConvertFrom-Json
        $errorCount = (Get-ChildItem "$memDir\errors\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
        $patternCount = (Get-ChildItem "$memDir\patterns\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
        $session.updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        $session | Add-Member -NotePropertyName "error_count" -NotePropertyValue $errorCount -Force -ErrorAction SilentlyContinue
        $session | Add-Member -NotePropertyName "pattern_count" -NotePropertyValue $patternCount -Force -ErrorAction SilentlyContinue
        $session | ConvertTo-Json -Depth 10 | Set-Content -Path $sf -Encoding UTF8
    } catch {}
}

exit 0
