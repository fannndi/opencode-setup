# Project Analyze — Analisa PRD dan buat ai-notes.md
# Usage: .\project-analyze.ps1 [-ProjectPath "C:\path\to\project"]

param(
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$ECC_DIR = "$ROOT_DIR\ecc"
$SKILL_LIST = "$ROOT_DIR\Skill\skill-list.md"
$FEATURE_LIST = "$ROOT_DIR\Feature\list.md"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve Project Path
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if (-not $ProjectPath) {
    $ProjectPath = Split-Path -Parent $ROOT_DIR
}

$PROJECT_DIR = $ProjectPath
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Host "  [ERROR] Path not found: $PROJECT_DIR" -ForegroundColor Red
    Write-Host "  Usage: .\project-analyze.ps1 -ProjectPath 'C:\path\to\project'" -ForegroundColor Yellow
    exit 1
}

# Ensure session exists for this project
Resolve-Project -Path $PROJECT_DIR | Out-Null

$PRD_FILE = "$PROJECT_DIR\prd.md"
$AI_NOTES = "$PROJECT_DIR\ai-notes.md"

# ============================================================
# Helpers
# ============================================================

function Write-Step {
    param([string]$Step, [string]$Message)
    Write-Host ""
    Write-Host "[$Step] $Message" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  [SKIP] $Message" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Message)
    Write-Host "  [FAIL] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "  [INFO] $Message" -ForegroundColor Gray
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Project Analyze — PRD → ai-notes.md     ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$totalSteps = 5

# ============================================================
# [1/5] Locate project root
# ============================================================

Write-Step "1/$totalSteps" "Locating project root..."

$PROJECT_DIR = Split-Path -Parent $ROOT_DIR
$PRD_FILE = "$PROJECT_DIR\prd.md"
$AI_NOTES = "$PROJECT_DIR\ai-notes.md"

Write-Host "  Project: $PROJECT_DIR" -ForegroundColor White

if (-not (Test-Path $PRD_FILE)) {
    Write-Fail "prd.md not found in $PROJECT_DIR"
    Write-Info "Buat prd.md terlebih dahulu di project root"
    exit 1
}

Write-OK "prd.md found"

# ============================================================
# [2/5] Read PRD
# ============================================================

Write-Step "2/$totalSteps" "Reading PRD..."

$prdContent = Get-Content $PRD_FILE -Raw
$prdLength = $prdContent.Length
$prdLines = ($prdContent -split "`n").Count

Write-OK "PRD loaded ($prdLines lines, $prdLength chars)"

# ============================================================
# [3/5] Detect stack from PRD
# ============================================================

Write-Step "3/$totalSteps" "Detecting stack from PRD..."

$detectedStack = @()
$detectedFeatures = @()

# Detect keywords in PRD
$keywords = @{
    "flutter" = "dart-flutter"
    "dart" = "dart-flutter"
    "react" = "react"
    "next.js" = "nextjs"
    "nextjs" = "nextjs"
    "vue" = "vue"
    "angular" = "angular"
    "svelte" = "svelte"
    "python" = "python"
    "django" = "django"
    "fastapi" = "python"
    "flask" = "python"
    "golang" = "golang"
    "go" = "golang"
    "rust" = "rust"
    "java" = "java"
    "spring" = "springboot"
    "kotlin" = "kotlin"
    "swift" = "swift"
    "ios" = "swift"
    "android" = "android"
    "php" = "php"
    "laravel" = "php-laravel"
    "ruby" = "ruby"
    "rails" = "ruby"
    "c++" = "cpp"
    "docker" = "docker"
    "kubernetes" = "kubernetes"
    "postgresql" = "postgres"
    "mysql" = "mysql"
    "redis" = "redis"
    "mongodb" = "mongodb"
    "supabase" = "supabase"
    "firebase" = "firebase"
    "rest api" = "api"
    "graphql" = "graphql"
    "websocket" = "websocket"
    "jwt" = "authentication"
    "auth" = "authentication"
    "payment" = "payment"
    "stripe" = "payment"
    "ml" = "machine-learning"
    "machine learning" = "machine-learning"
    "ai" = "ai"
    "llm" = "ai"
}

$prdLower = $prdContent.ToLower()

foreach ($kw in $keywords.Keys) {
    if ($prdLower -match [regex]::Escape($kw)) {
        $stack = $keywords[$kw]
        if ($stack -notin $detectedStack) {
            $detectedStack += $stack
        }
    }
}

if ($detectedStack.Count -gt 0) {
    Write-OK "Detected: $($detectedStack -join ', ')"
} else {
    Write-Skip "No specific stack detected from PRD"
    $detectedStack = @("general")
}

# ============================================================
# [4/5] Match skills from Skill/skill-list.md
# ============================================================

Write-Step "4/$totalSteps" "Matching skills..."

$matchedSkills = @()
$matchedRules = @()

# Core skills (always)
$coreSkills = @("tdd-workflow", "security-review", "coding-standards", "verification-loop")
$matchedSkills += $coreSkills

# Stack-specific skills
$stackSkills = @{
    "dart-flutter" = @("dart-flutter-patterns")
    "react" = @("frontend-patterns", "react-patterns", "react-performance", "react-testing", "accessibility")
    "nextjs" = @("frontend-patterns", "backend-patterns", "nextjs-turbopack")
    "vue" = @("frontend-patterns")
    "angular" = @("angular-developer")
    "python" = @("python-patterns", "python-testing")
    "django" = @("django-patterns", "django-tdd", "django-verification", "django-security")
    "golang" = @("golang-patterns", "golang-testing")
    "rust" = @("rust-patterns", "rust-testing")
    "java" = @("java-coding-standards", "jpa-patterns")
    "springboot" = @("springboot-patterns", "springboot-tdd", "springboot-verification", "springboot-security")
    "kotlin" = @("kotlin-patterns", "kotlin-testing", "kotlin-coroutines-flows")
    "swift" = @("swiftui-patterns", "swift-concurrency-6-2")
    "php-laravel" = @("laravel-patterns", "laravel-tdd", "laravel-verification", "laravel-security")
    "cpp" = @("cpp-coding-standards", "cpp-testing")
    "docker" = @("docker-patterns", "deployment-patterns")
    "postgres" = @("postgres-patterns", "database-migrations")
    "redis" = @("redis-patterns")
    "api" = @("api-design", "backend-patterns")
    "authentication" = @("security-review")
    "payment" = @("security-review")
    "machine-learning" = @("pytorch-patterns", "mle-workflow")
}

$stackRules = @{
    "dart-flutter" = @("common", "dart")
    "react" = @("common", "typescript", "web", "react")
    "nextjs" = @("common", "typescript", "web", "react")
    "vue" = @("common", "typescript")
    "angular" = @("common", "typescript", "angular")
    "python" = @("common", "python")
    "django" = @("common", "python")
    "golang" = @("common", "golang")
    "rust" = @("common", "rust")
    "java" = @("common", "java")
    "springboot" = @("common", "java")
    "kotlin" = @("common", "kotlin")
    "swift" = @("common", "swift")
    "php-laravel" = @("common", "php")
    "cpp" = @("common", "cpp")
}

foreach ($stack in $detectedStack) {
    if ($stackSkills.ContainsKey($stack)) {
        foreach ($skill in $stackSkills[$stack]) {
            if ($skill -notin $matchedSkills) {
                $matchedSkills += $skill
            }
        }
    }
    if ($stackRules.ContainsKey($stack)) {
        foreach ($rule in $stackRules[$stack]) {
            if ($rule -notin $matchedRules) {
                $matchedRules += $rule
            }
        }
    }
}

Write-OK "Matched $($matchedSkills.Count) skills, $($matchedRules.Count) rules"

# ============================================================
# [5/5] Generate ai-notes.md
# ============================================================

Write-Step "5/$totalSteps" "Generating ai-notes.md..."

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$aiNotes = @"
# AI Notes — Project Analysis

**Generated:** $timestamp
**PRD Source:** prd.md

---

## Project Overview

Project ini dianalisa dari prd.md. Berikut rekomendasi stack, skills, dan architecture.

## Detected Stack

| Komponen | Pilihan | Alasan |
|----------|---------|--------|
$(foreach ($s in $detectedStack) { "| Stack | $s | Terdeteksi dari PRD |" })

## Recommended Skills

### Core (always)
$(foreach ($s in $coreSkills) { "- $s" })

### Project-Specific
$(foreach ($s in $matchedSkills | Where-Object { $_ -notin $coreSkills }) { "- $s" })

## Recommended Rules

$(foreach ($r in $matchedRules) { "- $r" })

## Recommended Commands

| Command | Kapan Dipakai |
|---------|---------------|
| /plan | Perencanaan implementasi |
| /tdd | Test-driven development |
| /code-review | Review kode |
| /security | Security review |
| /build-fix | Fix build errors |
| /verify | Verification loop |

## Recommended Agents

| Agent | Kapan Dipakai |
|-------|---------------|
| planner | Perencanaan fitur |
| code-reviewer | Review kode |
| security-reviewer | Security audit |
| tdd-guide | TDD workflow |
| build-error-resolver | Fix build errors |

## Implementation Notes

### Skills to Load
```json
"instructions": [
$(foreach ($s in $matchedSkills) { "    `"$($ROOT_DIR.Replace('\', '/'))/ecc/skills/$s/SKILL.md`"," })
]
```

### Rules to Apply
```
Rules: $($matchedRules -join ', ')
```

## Next Steps

1. Review ai-notes.md ini
2. Sesuaikan rekomendasi jika perlu
3. Jalankan: ``/make-docs``
4. Review docs/ yang dihasilkan
5. Jalankan: ``/implement``

---

*File ini di-generate otomatis oleh /project-analyze*
*Untuk rekomendasi manual, edit file ini langsung*
"@

Set-Content -Path $AI_NOTES -Value $aiNotes -Encoding UTF8
Write-OK "ai-notes.md generated: $AI_NOTES"

# ============================================================
# Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Analysis Complete!                  ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  PRD:       $PRD_FILE" -ForegroundColor White
Write-Host "  AI Notes:  $AI_NOTES" -ForegroundColor White
Write-Host "  Stack:     $($detectedStack -join ', ')" -ForegroundColor White
Write-Host "  Skills:    $($matchedSkills.Count) matched" -ForegroundColor White
Write-Host "  Rules:     $($matchedRules -join ', ')" -ForegroundColor White
Write-Host ""
Write-Host "  Next: review ai-notes.md, lalu /make-docs" -ForegroundColor Cyan
Write-Host ""
