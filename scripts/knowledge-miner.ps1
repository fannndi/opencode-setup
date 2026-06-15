# Knowledge Miner — Scan memory sessions → LLM extract → save to knowledge
# Usage: .\knowledge-miner.ps1 [-ProjectPath "C:\path"] [-Days 7]

param(
    [string]$ProjectPath,
    [int]$Days = 7
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"
. "$SETUP_DIR\project-resolve.ps1"

if (-not $ProjectPath) { $ProjectPath = Get-ActiveProject }
if (-not $ProjectPath) { Write-Host "  No active project." -ForegroundColor Yellow; exit 0 }

$slug = Get-ProjectSlug -Path $ProjectPath
$memDir = Get-MemoryDir -ProjectPath $ProjectPath
$knowDir = "$ROOT_DIR\Project\Knowledge\$slug"

# Find recent sessions
$cutoff = (Get-Date).AddDays(-$Days)
$sessionFiles = Get-ChildItem -Path "$memDir\sessions\*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt $cutoff } |
    Sort-Object LastWriteTime -Descending

if ($sessionFiles.Count -eq 0) {
    Write-Host "  [MINER] No sessions in last $Days days." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║           Knowledge Miner — Session Mining       ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -Write-Host ""
Write-Host "  Found $($sessionFiles.Count) session(s)" -ForegroundColor White
Write-Host ""

$mode = Get-OperatingMode
$extracted = 0

foreach ($sf in $sessionFiles) {
    $content = Get-Content $sf.FullName -Raw
    if ($content.Length -lt 100) { continue }  # skip empty logs

    # Check if we already mined this
    $minedFile = "$knowDir\auto-mined\$($sf.BaseName).md"
    if (Test-Path $minedFile) { continue }

    Write-Host "  Processing: $($sf.Name)" -ForegroundColor Gray

    if ($mode -ne "eco") {
        $prompt = @"
Extract reusable patterns from this dev session log.

Focus on:
1. Problems solved
2. Solutions found
3. Code patterns discovered
4. Mistakes to avoid

Output ONLY a JSON array:
[{"pattern":"...","context":"...","solution":"...","tags":["...",]}]"

Session:
$content
"@
        $result = Invoke-LLM -Prompt $prompt -System "Extract patterns. Output ONLY JSON array." -MaxTokens 1024 -Temperature 0.2 -TimeoutSec 60

        if ($result) {
            try {
                $patterns = $result.response | ConvertFrom-Json
                if ($patterns -is [array]) {
                    New-Item -ItemType Directory -Path "$knowDir\auto-mined" -Force | Out-Null
    
                    $minedContent = @()
                    $minedContent += "---"
                    $minedContent += "title: Auto-mined $($sf.BaseName)"
                    $minedContent += "source: $($sf.Name)"
                    $minedContent += "mined: $(Get-Date -Format 'yyyy-MM-dd')"
                    $minedContent += "---"
                    $minedContent += ""

                    foreach ($p in $patterns) {
                        if ($p.pattern -and $p.solution) {
                            $minedContent += "## $($p.pattern)"
                            $minedContent += ""
                            $minedContent += "**Context:** $($p.context)"
                            $minedContent += ""
                            $minedContent += "**Solution:** $($p.solution)"
                            if ($p.tags) { $minedContent += "**Tags:** $($p.tags -join ', ')" }
                            $minedContent += "---"
                            $minedContent += ""
                        }
                    }

                    $minedContent | Set-Content -Path $minedFile -Encoding UTF8
                    $extracted++
                    Write-Host "    ✅ Saved $($patterns.Count) pattern(s)" -ForegroundColor Green
                }
            } catch { Write-Host "    ⚠️ LLM output parse failed" -ForegroundColor Yellow }
        }
    } else {
        # ECO mode: basic keyword extraction
        $errors = [regex]::Matches($content, '(?:error|bug|fail|gagal)[^:]*:\s*([^\n]+)', 'IgnoreCase')
        if ($errors.Count -gt 0) {
            New-Item -ItemType Directory -Path "$knowDir\auto-mined" -Force | Out-Null
            $minedContent = @("---", "title: Auto-mined $($sf.BaseName)", "source: $($sf.Name)", "mined: $(Get-Date -Format 'yyyy-MM-dd')", "---", "")
            foreach ($e in $errors | Select-Object -First 5) {
                $minedContent += "- Pattern: Found error: $($e.Groups[1].Value.Trim())"
            }
            $minedContent | Set-Content -Path $minedFile -Encoding UTF8
            $extracted++
            Write-Host "    ✅ Saved $($errors.Count) error patterns(s)" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  [MINER] Extracted $extracted new knowledge entries." -ForegroundColor Green
Write-Host ""
