# Knowledge Manager — Structured reusable knowledge
# Usage: .\knowledge.ps1 -Action save|search|list
# Knowledge is distinct from Memory: curated, deduplicated, searchable.

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("save", "search", "list")]
    [string]$Action,

    [string]$Key,
    [string]$Value,
    [string]$Category,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"

$activeProject = Get-ActiveProject
if (-not $activeProject -and -not $ProjectPath) {
    Write-Host "  No active project. Use /set-project first." -ForegroundColor Yellow
    exit 0
}

$targetPath = if ($ProjectPath) { $ProjectPath } else { $activeProject }
$slug = Get-ProjectSlug -Path $targetPath
$knowledgeDir = "$ROOT_DIR\Project\Knowledge\$slug"
New-Item -ItemType Directory -Path $knowledgeDir -Force | Out-Null

# ============================================================
# Save knowledge entry
# ============================================================

function Save-Knowledge {
    param([string]$Title, [string]$Content, [string]$Category)

    $date = Get-Date -Format "yyyy-MM-dd"
    $safeName = $Title -replace '[^\w\-]', '_'
    $catDir = if ($Category) { "$knowledgeDir\$Category" } else { "$knowledgeDir\general" }
    New-Item -ItemType Directory -Path $catDir -Force | Out-Null
    $file = "$catDir\$safeName.md"

    $header = @"
---
title: $Title
category: $(if ($Category) { $Category } else { "general" })
created: $date
---
"@

    "$header`n$Content" | Set-Content -Path $file -Encoding UTF8
    Write-Host "  [KNOWLEDGE] Saved: $Title" -ForegroundColor Green
    return $file
}

# ============================================================
# Search knowledge
# ============================================================

function Search-Knowledge {
    param([string]$Query)

    $results = @()
    $files = Get-ChildItem -Path $knowledgeDir -Filter "*.md" -Recurse -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $content = Get-Content $f.FullName -Raw
        if ($content -match $Query) {
            $relPath = $f.FullName.Substring($knowledgeDir.Length + 1)
            $title = if ($content -match "^title: (.+)") { $Matches[1] } else { $relPath }
            $lines = ($content -split "`n").Count
            $results += [PSCustomObject]@{ Path = $relPath; Title = $title; Lines = $lines }
        }
    }
    return $results
}

# ============================================================
# List knowledge
# ============================================================

function List-Knowledge {
    Write-Host ""
    Write-Host "  ─── Knowledge: $slug ───" -ForegroundColor Cyan

    $categories = Get-ChildItem -Path $knowledgeDir -Directory -ErrorAction SilentlyContinue
    if (-not $categories) {
        Write-Host "  No knowledge entries yet." -ForegroundColor Yellow
        Write-Host "  Use: .\knowledge.ps1 -Action save -Key 'title' -Value 'content'" -ForegroundColor Gray
        return
    }

    foreach ($cat in $categories) {
        $items = Get-ChildItem -Path $cat.FullName -Filter "*.md" -ErrorAction SilentlyContinue
        if ($items) {
            Write-Host ""
            Write-Host "  [$($cat.Name)]" -ForegroundColor Yellow
            foreach ($item in $items) {
                $lines = (Get-Content $item.FullName | Measure-Object).Count
                Write-Host "    • $($item.BaseName) ($lines lines)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
}

# ============================================================
# Execute
# ============================================================

switch ($Action) {
    "save" {
        if (-not $Key) { Write-Host "[ERROR] -Key (title) required" -ForegroundColor Red; exit 1 }
        Save-Knowledge -Title $Key -Content $Value -Category $Category
    }
    "search" {
        if (-not $Key) { Write-Host "[ERROR] -Key (search term) required" -ForegroundColor Red; exit 1 }
        $results = Search-Knowledge -Query $Key
        Write-Host ""
        if ($results.Count -eq 0) {
            Write-Host "  [KNOWLEDGE] No matches for '$Key'" -ForegroundColor Yellow
        } else {
            Write-Host "  [KNOWLEDGE] $($results.Count) result(s):" -ForegroundColor Cyan
            foreach ($r in $results) {
                Write-Host "    • $($r.Title) — $($r.Path)" -ForegroundColor Gray
            }
        }
        Write-Host ""
    }
    "list" { List-Knowledge }
}
