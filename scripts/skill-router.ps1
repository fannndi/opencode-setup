# Skill Router — Select relevant skills from intent
# Usage: .\skill-router.ps1 -IntentJSON '{...}'
#        .\skill-router.ps1 -Query "PHP MySQL web desa"

param(
    [string]$IntentJSON,
    [string]$Query,
    [ValidateSet("auto", "on", "off")]
    [string]$Mode = "auto"
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# Skill Index — parsed from Skill/skill-list.md
# ============================================================

$SKILL_INDEX = @()
$skillFile = "$ROOT_DIR\Skill\skill-list.md"
if (Test-Path $skillFile) {
    $lines = Get-Content $skillFile
    foreach ($line in $lines) {
        if ($line -match '^\| `([\w-]+)` \|') {
            $name = $Matches[1]
            # Split remaining columns by |
            $parts = $line -split '\|'
            $category = ""
            $stack = ""
            $purpose = ""
            if ($parts.Count -ge 5) {
                # 4-column format: skill, category, stack, purpose
                $category = $parts[2].Trim().Trim('`')
                $stack = $parts[3].Trim().Trim('`')
                $purpose = $parts[4].Trim().Trim('`')
            } elseif ($parts.Count -ge 4) {
                # 3-column format: skill, category, description
                $category = $parts[2].Trim().Trim('`')
                $purpose = $parts[3].Trim().Trim('`')
            } elseif ($parts.Count -ge 3) {
                # 2-column format: skill, description
                $purpose = $parts[2].Trim().Trim('`')
            }
            $SKILL_INDEX += [PSCustomObject]@{
                name = $name
                category = $category
                stack = $stack
                purpose = $purpose
            }
        }
    }
}

$SKILL_NAMES = $SKILL_INDEX | ForEach-Object { $_.name }
$SKILL_CATEGORIES = $SKILL_INDEX | Group-Object category | ForEach-Object { $_.Name }

# ============================================================
# Parse Intent
# ============================================================

function Get-Intent {
    if ($IntentJSON) {
        try { return $IntentJSON | ConvertFrom-Json } catch {}
    }
    if ($Query) {
        $compiled = & "$SETUP_DIR\intent-compiler.ps1" -Query $Query -Mode $Mode
        return $compiled
    }
    return $null
}

# ============================================================
# LLM-based routing
# ============================================================

function RouteWithLLM {
    param($Intent)

    $prompt = @"
Select the top 10 most relevant skills for this project from the list below.

Project:
- Domain: $($Intent.domain)
- Module: $($Intent.module)
- Features: $($Intent.features -join ', ')
- Security: $($Intent.security -join ', ')
- Stack: $($Intent.stack_hint -join ', ')

Available skills (270 total). Select only the most relevant ones:

$($SKILL_NAMES -join ', ')

Output ONLY a JSON array of skill names. Example: ["tdd-workflow", "security-review", ...]
"@

    $result = Invoke-LLM -Prompt $prompt -System "Output ONLY a JSON array of skill names. No explanation." -MaxTokens 1024 -Temperature 0.2 -TimeoutSec 60

    if (-not $result) { return $null }

    $text = $result.response.Trim()
    if ($text -match '\[([\s\S]*)\]') {
        try {
            $selected = $text | ConvertFrom-Json
            return @($selected) | Where-Object { $_ -in $SKILL_NAMES }
        } catch {}
    }
    return $null
}

# ============================================================
# Regex-based routing (fallback)
# ============================================================

function RouteWithRegex {
    param($Intent)

    $stack = $Intent.stack_hint
    $domain = $Intent.domain
    $features = $Intent.features
    $security = $Intent.security

    $selected = @()

    # Core skills — always include
    $core = @("coding-standards", "tdd-workflow", "error-handling")
    $selected += $core

    # Security skills
    if ($security -contains "prepared_statement" -or $domain -eq "auth") {
        $selected += "security-review"
    }

    # Stack-specific skills
    foreach ($s in $stack) {
        switch -Wildcard ($s) {
            "php*"       { $selected += "laravel-patterns"; $selected += "laravel-security" }
            "mysql"      { $selected += "mysql-patterns" }
            "postgres*"  { $selected += "postgres-patterns" }
            "nodejs"     { $selected += "backend-patterns"; $selected += "api-design" }
            "react"      { $selected += "react-patterns"; $selected += "frontend-patterns" }
            "flutter*"   { $selected += "dart-flutter-patterns" }
            "python"     { $selected += "python-patterns" }
            "go*"        { $selected += "golang-patterns" }
            "laravel*"   { $selected += "laravel-patterns"; $selected += "laravel-security" }
            "django"     { $selected += "django-patterns"; $selected += "django-security" }
            "nestjs"     { $selected += "nestjs-patterns"; $selected += "backend-patterns" }
        }
    }

    # Feature-specific
    if ($features -contains "api" -or $domain -ne "web_desa") {
        $selected += "api-design"
    }

    # Deduplicate + validate against actual skill index
    $selected = $selected | Select-Object -Unique
    $valid = $selected | Where-Object { $_ -in $SKILL_NAMES }
    if (-not $valid) { $valid = $core }  # fallback: at least core skills
    return @($valid)
}

# ============================================================
# Main
# ============================================================

Write-Host ""
$intent = Get-Intent
if (-not $intent) { Write-Host "  [ROUTER] No intent provided" -ForegroundColor Red; exit 1 }

Write-Host "  [ROUTER] Intent: $($intent.domain)/$($intent.module)" -ForegroundColor Cyan
Write-Host "  [ROUTER] Stack: $($intent.stack_hint -join ', ')" -ForegroundColor Gray

# Determine mode
$effectiveMode = $Mode
if ($effectiveMode -eq "auto") {
    $modeState = Get-LLMMode
    $effectiveMode = if ($modeState -eq "on") { "on" } else { "off" }
}

$skills = @()

if ($effectiveMode -eq "on") {
    $skills = RouteWithLLM -Intent $intent
}

if (-not $skills -or $skills.Count -eq 0) {
    $skills = RouteWithRegex -Intent $intent
}

Write-Host ""
Write-Host "  [ROUTER] Selected $($skills.Count) skills:" -ForegroundColor Green
foreach ($s in $skills) {
    $info = $SKILL_INDEX | Where-Object { $_.name -eq $s } | Select-Object -First 1
    if ($info) {
        Write-Host "    • $s ($($info.purpose))" -ForegroundColor Gray
    } else {
        Write-Host "    • $s" -ForegroundColor Gray
    }
}
Write-Host ""

# Output
return [PSCustomObject]@{
    skills = $skills
    count = $skills.Count
    mode = $effectiveMode
}
