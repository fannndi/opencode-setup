# LLM Preprocess — Universal input preprocessor
# Pipeline: stack detect → skill index → feature index → memory → knowledge → intent → route
# Usage: .\llm-preprocess.ps1 -Query "bikin CRUD penduduk"

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [string]$ProjectPath
)

$ErrorActionPreference = "Continue"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# SKILL INDEX — parse Skill/skill-list.md
# ============================================================

function Get-SkillIndex {
    $skillFile = "$ROOT_DIR\Skill\skill-list.md"
    $index = @()
    if (Test-Path $skillFile) {
        $lines = Get-Content $skillFile
        foreach ($line in $lines) {
            if ($line -match '^\| `([\w-]+)` \|') {
                $name = $Matches[1]
                $parts = $line -split '\|'
                $cat = if ($parts.Count -ge 5) { $parts[2].Trim().Trim('`') } else { "" }
                $stack = if ($parts.Count -ge 5) { $parts[3].Trim().Trim('`') } else { "" }
                $purpose = if ($parts.Count -ge 4) { $parts[-2].Trim().Trim('`') } else { "" }
                $index += [PSCustomObject]@{ name = $name; category = $cat; stack = $stack; purpose = $purpose }
            }
        }
    }
    return $index
}

# ============================================================
# FEATURE INDEX — parse Feature/list.md
# ============================================================

function Get-FeatureIndex {
    $featureFile = "$ROOT_DIR\Feature\list.md"
    $index = @()
    if (Test-Path $featureFile) {
        $lines = Get-Content $featureFile
        foreach ($line in $lines) {
            if ($line -match '^\| `([\w-]+)`') {
                $name = $Matches[1]
                $parts = $line -split '\|'
                $cat = if ($parts.Count -ge 3) { $parts[2].Trim().Trim('`') } else { "" }
                $desc = if ($parts.Count -ge 4) { $parts[3].Trim().Trim('`') } else { "" }
                $index += [PSCustomObject]@{ name = $name; category = $cat; description = $desc }
            }
        }
    }
    return $index
}

# ============================================================
# Preprocess Pipeline
# ============================================================

$operatingMode = Get-ModeForLLM
$spec = $null
$matchedSkills = @()
$matchedFeatures = @()
$memoryResults = @()
$knowledgeResults = @()

# ── Resolve project ──
if (-not $ProjectPath) { $ProjectPath = Get-ActiveProject }

# ── Step 1: Intent compiler (LLM or regex) ──
$spec = & "$SETUP_DIR\intent-compiler.ps1" -Query $Query -Mode auto

$stackHint = if ($spec) { $spec.stack_hint -join ', ' } else { "" }
$domain = if ($spec) { $spec.domain } else { "unknown" }
$module = if ($spec) { $spec.module } else { "general" }

# ── Step 2: Skill index match ──
$allSkills = Get-SkillIndex
if ($allSkills.Count -gt 0) {
    # Match by stack keyword
    $stackWords = @()
    if ($stackHint) { $stackWords = $stackHint -split ',\s*' }
    $stackWords += $domain, $module

    foreach ($word in $stackWords) {
        $matches = $allSkills | Where-Object {
            $_.stack -match $word -or $_.category -match $word -or $_.purpose -match $word
        }
        $matchedSkills += $matches
    }
    $matchedSkills = $matchedSkills | Sort-Object name -Unique | Select-Object -First 10
}

# ── Step 3: Feature index match ──
$allFeatures = Get-FeatureIndex
if ($allFeatures.Count -gt 0) {
    $searchTerms = @($domain, $module) + ($spec.features)
    foreach ($term in $searchTerms) {
        $matches = $allFeatures | Where-Object {
            $_.name -match $term -or $_.category -match $term -or $_.description -match $term
        }
        $matchedFeatures += $matches
    }
    $matchedFeatures = $matchedFeatures | Sort-Object name -Unique | Select-Object -First 5
}

# ── Step 4: Memory search ──
if ($ProjectPath) {
    try {
        $memDir = Get-MemoryDir -ProjectPath $ProjectPath
        $searchTerms = @($domain, $module) + $spec.features
        foreach ($term in $searchTerms) {
            if (-not $term) { continue }
            $found = Get-ChildItem -Path $memDir -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
                Where-Object { (Get-Content $_.FullName -Raw) -match $term }
            $memoryResults += $found
            if ($found.Count -gt 0) { break }
        }
        $memoryResults = $memoryResults | Select-Object -Unique -First 5
    } catch {}
}

# ── Step 5: Knowledge search ──
if ($ProjectPath) {
    try {
        $slug = Get-ProjectSlug -Path $ProjectPath
        $knowDir = "$ROOT_DIR\Project\Knowledge\$slug"
        if (Test-Path $knowDir) {
            $searchTerms = @($domain, $module) + $spec.features
        foreach ($term in $searchTerms) {
                if (-not $term) { continue }
                $found = Get-ChildItem -Path $knowDir -Filter "*.md" -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { (Get-Content $_.FullName -Raw) -match $term }
                $knowledgeResults += $found
                if ($found.Count -gt 0) { break }
            }
            $knowledgeResults = $knowledgeResults | Select-Object -Unique -First 5
        }
    } catch {}
}

# ── Step 6: Skill routing ──
$routed = & "$SETUP_DIR\skill-router.ps1" -Query $Query -Mode auto

# ============================================================
# Build enriched context
# ============================================================

Write-Host ""
Write-Host "  ────── PREPROCESSED CONTEXT ──────" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Request: $Query" -ForegroundColor White
Write-Host "  Domain:  $domain" -ForegroundColor Gray
Write-Host "  Module:  $module" -ForegroundColor Gray
if ($stackHint) { Write-Host "  Stack:   $stackHint" -ForegroundColor Gray }
if ($spec) { Write-Host "  Features: $($spec.features -join ', ')" -ForegroundColor Gray }
Write-Host "  Mode:    $operatingMode" -ForegroundColor Gray
Write-Host ""

# Skills
if ($matchedSkills) {
    Write-Host "  [SKILLS] Relevant ($($matchedSkills.Count) of 270):" -ForegroundColor Yellow
    foreach ($s in $matchedSkills) {
        Write-Host "    • $($s.name) — $($s.purpose)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [SKILLS] No skill matches found." -ForegroundColor DarkGray
}
Write-Host ""

# Features
if ($matchedFeatures) {
    Write-Host "  [FEATURES] Matching ($($matchedFeatures.Count) of 600+):" -ForegroundColor Yellow
    foreach ($f in $matchedFeatures) {
        Write-Host "    • $($f.name) — $($f.description)" -ForegroundColor Gray
    }
} else {
    Write-Host "  [FEATURES] No feature matches found." -ForegroundColor DarkGray
}
Write-Host ""

# Memory
if ($memoryResults) {
    Write-Host "  [MEMORY] Related sessions ($($memoryResults.Count)):" -ForegroundColor Yellow
    foreach ($m in $memoryResults) {
        $relPath = $m.FullName.Substring($memDir.Length + 1)
        Write-Host "    • $relPath" -ForegroundColor Gray
    }
} else {
    Write-Host "  [MEMORY] No previous sessions found." -ForegroundColor DarkGray
}
Write-Host ""

# Knowledge
if ($knowledgeResults) {
    Write-Host "  [KNOWLEDGE] Patterns ($($knowledgeResults.Count)):" -ForegroundColor Yellow
    foreach ($k in $knowledgeResults) {
        $title = (Get-Content $k.FullName -TotalCount 5 | Where-Object { $_ -match "^# " } | Select-Object -First 1)
        Write-Host "    • $($k.BaseName) — $title" -ForegroundColor Gray
    }
} else {
    Write-Host "  [KNOWLEDGE] No matching patterns found." -ForegroundColor DarkGray
}
Write-Host ""

if ($routed -and $routed.skills) {
    Write-Host "  [RECOMMENDED] Load skills:" -ForegroundColor Green
    foreach ($s in $routed.skills) { Write-Host "    • $s" -ForegroundColor Gray }
}
Write-Host ""
Write-Host "  ────── END CONTEXT ──────" -ForegroundColor Cyan
Write-Host ""

# Return structured object
return [PSCustomObject]@{
    query = $Query
    spec = $spec
    domain = $domain
    module = $module
    stack = $stackHint
    mode = $operatingMode
    skills_matched = $matchedSkills.Count
    features_matched = $matchedFeatures.Count
    memory_count = $memoryResults.Count
    knowledge_count = $knowledgeResults.Count
}
