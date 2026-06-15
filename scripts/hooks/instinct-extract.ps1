# Instinct Extract — StopHook: auto-extract patterns from session
# Extracts: error-solutions, code-patterns, preferences
# LLM mode: richer extraction. Regex mode: basic line pairing.

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\agent-core.ps1"
. "$SETUP_DIR\llm-adapter.ps1"

$activeProject = Get-ActiveProject
if (-not $activeProject) { exit 0 }

$memDir = Get-MemoryDir -ProjectPath $activeProject
$slug = Get-ProjectSlug -Path $activeProject
$sessionLog = "$memDir\sessions\$(Get-Date -Format 'yyyy-MM-dd').md"
$patternsDir = "$memDir\patterns"
$errorsDir = "$memDir\errors"
New-Item -ItemType Directory -Path $patternsDir -Force | Out-Null
New-Item -ItemType Directory -Path $errorsDir -Force | Out-Null

# ============================================================
# Auto-save session log entry (so memory is never empty)
# ============================================================
$timestamp = Get-Date -Format "HH:mm:ss"
$autoEntry = "`n### $timestamp — Session end (auto)`n- Mode: $(Get-OperatingMode)`n- Action: /stop"
if (Test-Path $sessionLog) {
    Add-Content -Path $sessionLog -Value $autoEntry -Encoding UTF8
} else {
    $header = "# Session Log — $(Get-Date -Format 'yyyy-MM-dd')`n$autoEntry"
    Set-Content -Path $sessionLog -Value $header -Encoding UTF8
}

$operatingMode = Get-ModeForLLM

# ============================================================
# Extract 1: Session Summary + Error Patterns
# ECO → regex only. BALANCED → LLM summary. PERFORMANCE → LLM depth.
# ============================================================
if (Test-Path $sessionLog) {
    $content = Get-Content $sessionLog -Raw

    if ($operatingMode -ne "eco" -and $content.Length -gt 50) {
        # LLM extraction
        $depthLevel = if ($operatingMode -eq "performance") { "deep analysis" } else { "brief summary" }
        $prompt = @"
Analyze this development session log and extract $depthLevel:
1. What problems occurred (max 3)
2. What solutions were found
3. Any reusable patterns or lessons

Output ONLY JSON array:
[{"problem": "...", "solution": "...", "pattern": "..."}]

Session log:
$content
"@

        $timeout = if ($operatingMode -eq "performance") { 60 } else { 30 }
        $result = Invoke-LLM -Prompt $prompt -System "Output ONLY a JSON array. No explanation." -MaxTokens 1024 -Temperature 0.2 -TimeoutSec $timeout

        if ($result) {
            try {
                $patterns = $result.response | ConvertFrom-Json
                $i = 0
                foreach ($p in $patterns) {
                    $i++
                    if ($p.problem -and $p.solution) {
                        $safeName = ($p.problem -replace '[^\w\-]', '_').Substring(0, [Math]::Min(40, $p.problem.Length))
                        $pf = "$errorsDir\$safeName.md"
                        if (-not (Test-Path $pf)) {
@" 
# $($p.problem)
- Solution: $($p.solution)
- Pattern: $($p.pattern)
- Date: $(Get-Date -Format "yyyy-MM-dd")
- Extracted by: LLM ($operatingMode)
"@ | Set-Content -Path $pf -Encoding UTF8
                            Write-Host "  [INSTINCT] LLM extracted: $($p.problem)" -ForegroundColor Green
                        }
                        # Also save to knowledge base for reusable patterns
                        if ($p.solution.Length -gt 50 -and $operatingMode -eq "performance") {
                            try {
                                & "$SETUP_DIR\knowledge.ps1" -Action save -Key $safeName -Value "$($p.solution)`n---`n$($p.pattern)" -Category "auto-extracted" -ProjectPath $activeProject
                            } catch {}
                        }
                    }
                }
            } catch {}
        }
    }

    # Regex fallback — always runs for coverage
    $errorPatterns = [regex]::Matches($content, '(?:error|bug|fail|gagal|salah)[^:]*:\s*([^\n]+)', 'IgnoreCase')
    $solutionPatterns = [regex]::Matches($content, '(?:fix|solusi|resolve|fixed|fixed by)\s*:?\s*([^\n]+)', 'IgnoreCase')

    if ($errorPatterns.Count -gt 0 -and $solutionPatterns.Count -gt 0) {
        $min = [Math]::Min($errorPatterns.Count, $solutionPatterns.Count)
        for ($i = 0; $i -lt $min; $i++) {
            $errName = $errorPatterns[$i].Groups[1].Value.Trim()
            $solDesc = $solutionPatterns[$i].Groups[1].Value.Trim()
            $safeName = $errName -replace '[^\w\-]', '_'

            $pf = "$errorsDir\$safeName.md"
            if (-not (Test-Path $pf)) {
@"
# $errName
- Solution: $solDesc
- Date: $(Get-Date -Format "yyyy-MM-dd")
- Extracted by: regex
"@ | Set-Content -Path $pf -Encoding UTF8
                Write-Host "  [INSTINCT] Regex extracted: $errName" -ForegroundColor Gray
            }
        }
    }
}

# ============================================================
# Extract 2: Project framework detection
# ============================================================
$projectPath = $activeProject
if (Test-Path "$projectPath\package.json") {
    try {
        $pkg = Get-Content "$projectPath\package.json" -Raw | ConvertFrom-Json
        $allDeps = @()
        if ($pkg.dependencies) { $allDeps += $pkg.dependencies.PSObject.Properties.Name }
        if ($pkg.devDependencies) { $allDeps += $pkg.devDependencies.PSObject.Properties.Name }

        $ff = "$patternsDir\project-framework.md"
        if (-not (Test-Path $ff)) {
            $coreDeps = $allDeps | Select-Object -First 20
@"
# Project Framework Dependencies
- Stack: $($allDeps -join ', ')
- Auto-detected: $(Get-Date -Format "yyyy-MM-dd")
"@ | Set-Content -Path $ff -Encoding UTF8
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
        $errorCount = (Get-ChildItem "$errorsDir\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
        $patternCount = (Get-ChildItem "$patternsDir\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
        $session.updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        $session | Add-Member -NotePropertyName "error_count" -NotePropertyValue $errorCount -Force -ErrorAction SilentlyContinue
        $session | Add-Member -NotePropertyName "pattern_count" -NotePropertyValue $patternCount -Force -ErrorAction SilentlyContinue
        $session | ConvertTo-Json -Depth 10 | Set-Content -Path $sf -Encoding UTF8
    } catch {}
}

# Auto-mine knowledge in PERFORMANCE mode
if ($operatingMode -eq "performance") {
    try {
        & "$SETUP_DIR\knowledge-miner.ps1" -ProjectPath $activeProject -Days 1 2>&1 | Out-Null
    } catch {}
}

exit 0
