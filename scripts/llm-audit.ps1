# LLM Audit — Autonomous code audit using Local LLM
# GPU stress test in Loop mode — maksimalin VRAM MX150 2GB
# Usage: .\llm-audit.ps1 -Path .\scripts\ [-Mode all] [-Loop] [-Iterations 5]

param(
    [string]$Path,
    [ValidateSet("quality", "security", "perf", "all")]
    [string]$Mode = "all",
    [int]$Iterations = 0,
    [switch]$Loop,
    [switch]$Report
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve target files
# ============================================================

if (-not $Path) { $Path = $ROOT_DIR }
$Path = [System.IO.Path]::GetFullPath($Path)

$files = @()
if (Test-Path -Path $Path -PathType Container) {
    $extensions = @("*.ps1", "*.py", "*.ts", "*.dart", "*.sh", "*.js", "*.go", "*.rs", "*.php")
    foreach ($ext in $extensions) {
        $files += Get-ChildItem -Path $Path -Filter $ext -Recurse -ErrorAction SilentlyContinue
    }
} elseif (Test-Path $Path) {
    $files += Get-Item $Path
} else {
    Write-Host "  [AUDIT] Path not found: $Path" -ForegroundColor Red; exit 1
}

if ($files.Count -eq 0) { Write-Host "  [AUDIT] No matching files found" -ForegroundColor Yellow; exit 0 }

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║           LLM Audit — Self Improvement          ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Path:   $Path" -ForegroundColor Cyan
Write-Host "  Files:  $($files.Count) found" -ForegroundColor White
Write-Host "  Mode:   $Mode $(if ($Loop) { '(LOOP)' })" -ForegroundColor Gray
if ($Iterations -gt 0) { Write-Host "  Iters:  $Iterations" -ForegroundColor Gray }
Write-Host ""

# ============================================================
# Audit Prompts per Mode
# ============================================================

$PROMPTS = @{
    "quality" = @"
You are auditing PowerShell script quality. Analyze this code for:
1. Error handling — missing try/catch, empty catch blocks
2. Code style — inconsistent naming, magic numbers, deep nesting (>4 levels)
3. Duplication — repeated patterns that could be functions
4. Maintainability — long functions (>50 lines), missing comments for complex logic

Output ONLY JSON array:
[{"severity":"critical|high|medium|low","line":N,"issue":"...","fix":"..."}]
"@
    "security" = @"
You are auditing code security. Analyze this code for:
1. Hardcoded secrets — API keys, passwords, tokens
2. Injection risks — command injection, eval, SQL injection
3. Unsafe file ops — path traversal, temp file races
4. Input validation — missing validation on external input

Output ONLY JSON array:
[{"severity":"critical|high|medium|low","line":N,"issue":"...","fix":"..."}]
"@
    "perf" = @"
You are auditing code performance. Analyze this code for:
1. Inefficient loops — nested loops, redundant iterations
2. Memory — large allocations, unnecessary copies
3. I/O — blocking calls, missing async, redundant file reads
4. Startup — heavy imports, slow initialization

Output ONLY JSON array:
[{"severity":"critical|high|medium|low","line":N,"issue":"...","fix":"..."}]
"@
}

$ACTIVE_MODES = if ($Mode -eq "all") { @("quality", "security", "perf") } else { @($Mode) }

# ============================================================
# Audit Single File
# ============================================================

function Audit-File {
    param([string]$FilePath, [string]$Mode, [int]$FileIndex, [int]$TotalFiles)

    $relPath = if ($FilePath.StartsWith($ROOT_DIR)) { $FilePath.Substring($ROOT_DIR.Length + 1) } else { $FilePath }
    $content = Get-Content $FilePath -Raw -ErrorAction SilentlyContinue
    if (-not $content -or $content.Length -eq 0) { return $null }

    # Truncate if too long (32K context window - overhead)
    if ($content.Length -gt 28000) { $content = $content.Substring(0, 28000) + "`n... [TRUNCATED]" }

    $prompt = $PROMPTS[$Mode]
    $fullPrompt = "File: $relPath ($($content.Length) chars)`n`n$content`n`n$prompt"

    Write-Host "    [AUDIT] Mode=$Mode file=$relPath ($($content.Length) chars)" -ForegroundColor Gray

    $result = Invoke-LLM -Prompt $fullPrompt -System "Output ONLY a JSON array of findings. No explanation." -MaxTokens 2048 -Temperature 0.2 -TimeoutSec 90

    if (-not $result) { return @() }

    try {
        $findings = $result.response | ConvertFrom-Json
        if ($findings -is [array]) {
            return $findings
        }
    } catch {}
    return @()
}

# ============================================================
# Main Loop
# ============================================================

$iteration = 0
$allReports = @()

while ($true) {
    $iteration++

    Write-Host "  ── Iteration $iteration — $($files.Count) files ──" -ForegroundColor Cyan
    Write-Host ""

    $iterationFindings = @()

    for ($i = 0; $i -lt $files.Count; $i++) {
        $f = $files[$i]
        $relPath = if ($f.FullName.StartsWith($ROOT_DIR)) { $f.FullName.Substring($ROOT_DIR.Length + 1) } else { $f.FullName }

        Write-Host "  [$($i+1)/$($files.Count)] $relPath" -ForegroundColor White

        foreach ($m in $ACTIVE_MODES) {
            $findings = Audit-File -FilePath $f.FullName -Mode $m -FileIndex $i -TotalFiles $files.Count
            foreach ($finding in $findings) {
                $finding | Add-Member -NotePropertyName "file" -NotePropertyValue $relPath -Force
                $finding | Add-Member -NotePropertyName "audit_mode" -NotePropertyValue $m -Force
                $finding | Add-Member -NotePropertyName "iteration" -NotePropertyValue $iteration -Force
                $iterationFindings += $finding

                $sevColor = switch ($finding.severity) {
                    "critical" { "Red" }; "high" { "Yellow" }; "medium" { "Gray" }; default { "DarkGray" }
                }
                Write-Host "    [$($finding.severity)] $($finding.issue)" -ForegroundColor $sevColor
            }
        }
    }

    # Summary per iteration
    $critCount = ($iterationFindings | Where-Object { $_.severity -eq "critical" }).Count
    $highCount = ($iterationFindings | Where-Object { $_.severity -eq "high" }).Count
    Write-Host ""
    Write-Host "  Iteration $iteration summary:" -ForegroundColor Cyan
    Write-Host "    Total findings: $($iterationFindings.Count)" -ForegroundColor White
    Write-Host "    Critical: $critCount | High: $highCount | Medium/Low: $(($iterationFindings.Count - $critCount - $highCount))" -ForegroundColor Gray

    $allReports += @{
        iteration = $iteration
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        findings = $iterationFindings
    }

    # Loop termination
    if ($Iterations -gt 0 -and $iteration -ge $Iterations) { break }
    if (-not $Loop) { break }

    Write-Host ""
    Write-Host "  [AUDIT] Press Ctrl+C to stop, or wait for next pass..." -ForegroundColor DarkGray
    Write-Host ""
}

# ============================================================
# Report
# ============================================================

$activeProject = Get-ActiveProject
if ($activeProject -and $Report) {
    $slug = Get-ProjectSlug -Path $activeProject
    $reportDir = "$ROOT_DIR\Project\Knowledge\$slug\audits"
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $reportFile = "$reportDir\audit-$timestamp.json"

    $report = @{
        mode = $Mode
        path = $Path
        files_scanned = $files.Count
        iterations = $iteration
        total_findings = ($allReports | ForEach-Object { $_.findings }).Count
        timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        reports = $allReports
    }
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $reportFile -Encoding UTF8
    Write-Host ""
    Write-Host "  [AUDIT] Report saved: $reportFile" -ForegroundColor Green
}

Write-Host ""
Write-Host "  [AUDIT] Done. $iteration iteration(s), $($files.Count) file(s)" -ForegroundColor Green
Write-Host ""
