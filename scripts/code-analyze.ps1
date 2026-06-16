
# Usage: .\code-analyze.ps1 [-ProjectPath "C:\path\to\project"]

param(
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SKILL_LIST = "$ROOT_DIR\Skill\skill-list.md"
$ECC_DIR = "$ROOT_DIR\ecc"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# Source llm-adapter
. "$SETUP_DIR\llm-adapter.ps1"

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
    Write-Host "  Usage: .\code-analyze.ps1 -ProjectPath 'C:\path\to\project'" -ForegroundColor Yellow
    exit 1
}

# Ensure session exists for this project
Resolve-Project -Path $PROJECT_DIR | Out-Null

$AI_NOTES = "$PROJECT_DIR\ai-notes.md"

# Ignore folders
$ignoreDirs = @(
    "node_modules", ".git", "build", "dist", "target", ".dart_tool",
    ".next", "coverage", "__pycache__", ".venv", "venv", "vendor",
    ".opencode", "assets", ".github", "pub-cache", ".packages",
    ".pub-preload-cache", ".idea", ".vscode", ".vs", "bin", "obj",
    ".flutter-plugins", ".flutter", "android", "ios", "macos", "windows", "linux", "web",
    "ecc", "9router"
)

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

function Get-FilesRecursive {
    param([string]$Path, [string]$Pattern)
    $files = Get-ChildItem -Path $Path -Filter $Pattern -Recurse -ErrorAction SilentlyContinue |
        Where-Object { -not ($ignoreDirs | Where-Object { $_.FullName -match "\\$_\$|\\$_\\" }) }
    return $files
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta

Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$totalSteps = 7

# ============================================================
# [1/7] Read project documentation
# ============================================================

Write-Step "1/$totalSteps" "Reading project documentation..."

$projectName = Split-Path -Leaf $PROJECT_DIR
$docContent = @{}
$docFiles = @()

# Scan .md files in project root
$mdFiles = Get-ChildItem -Path $PROJECT_DIR -Filter "*.md" -Depth 0 -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin $ignoreDirs }

$readmeFiles = Get-ChildItem -Path $PROJECT_DIR -Filter "README*" -ErrorAction SilentlyContinue
$changelogFiles = Get-ChildItem -Path $PROJECT_DIR -Filter "CHANGELOG*" -ErrorAction SilentlyContinue

$targetDocs = @()
if ($readmeFiles) { $targetDocs += $readmeFiles }
if ($changelogFiles) { $targetDocs += $changelogFiles }
$targetDocs += $mdFiles | Where-Object { $_.Name -like "*.md" -and $_.Name -notlike "README*" -and $_.Name -notlike "CHANGELOG*" }

# Also check for LICENSE, CONTRIBUTING, SECURITY
foreach ($file in $allReadableDocs) {
    $found = Get-ChildItem -Path $PROJECT_DIR -Filter $extra -ErrorAction SilentlyContinue
    if ($found) { $targetDocs += $found }
}

$allReadableDocs = $targetDocs | Sort-Object Name -Unique

$allText = ""
foreach ($doc in $allReadableDocs) {
    try {
        $content = Get-Content $doc.FullName -Raw -ErrorAction SilentlyContinue
        if ($content) {
            $short = $content.Substring(0, [Math]::Min(1000, $content.Length))
            $allText += " " + $short
            $docFiles += $doc.Name
            Write-Info "Read: $($doc.Name) ($($content.Length) chars)"
        }
    } catch {}
}

# Extract keywords — LLM semantic analysis with regex fallback
$foundKeywords = @{}
$semanticResult = Invoke-LLMEnrich -Text $allText -Context "Extract tech stack from project docs" -System "Extract technology and framework keywords from project documentation. Return comma-separated list of relevant tech stack tags: e.g. react, postgres, docker, redis, python, flutter." -MaxTokens 256

if ($semanticResult -and $semanticResult -ne $allText) {
    $semanticKeywords = ($semanticResult -split '[,;\s]+') | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    foreach ($kw in $semanticKeywords) {
        if (-not $foundKeywords.ContainsKey($kw)) {
            $foundKeywords[$kw.ToLower()] = $true
        }
    }
} else {
    # Fallback to regex keyword matching
    $keywordMap = @{
        "rest api" = "rest-api"; "graphql" = "graphql"; "grpc" = "grpc"
        "microservice" = "microservice"; "monolith" = "monolith"
        "postgres" = "postgres"; "mysql" = "mysql"; "mongodb" = "mongodb"
        "redis" = "redis"; "firebase" = "firebase"; "supabase" = "supabase"
        "docker" = "docker"; "kubernetes" = "kubernetes"; "aws" = "aws"
        "react" = "react"; "vue" = "vue"; "angular" = "angular"
        "flutter" = "flutter"; "dart" = "dart"; "swift" = "swift"
        "go" = "golang"; "golang" = "golang"; "rust" = "rust"
        "python" = "python"; "java" = "java"; "kotlin" = "kotlin"
        "ci/cd" = "ci-cd"; "github actions" = "github-actions"
        "unit test" = "testing"; "integration test" = "testing"
        "tdd" = "tdd"; "jwt" = "jwt"; "oauth" = "oauth"
        "next.js" = "nextjs"; "nextjs" = "nextjs"
        "django" = "django"; "fastapi" = "fastapi"; "laravel" = "laravel"
        "express" = "express"; "nestjs" = "nestjs"
        "prisma" = "prisma"; "typeorm" = "typeorm"
        "sqlite" = "sqlite"; "sql server" = "mssql"
        "rabbitmq" = "rabbitmq"; "kafka" = "kafka"
        "serverless" = "serverless"; "lambda" = "aws-lambda"
    }
    $docLower = $allText.ToLower()
    foreach ($kw in $keywordMap.Keys) {
        if ($docLower -match [regex]::Escape($kw)) {
            $foundKeywords[$keywordMap[$kw]] = $true
        }
    }
}

if ($docFiles.Count -gt 0) {
    Write-OK "Read $($docFiles.Count) documentation files"
    if ($foundKeywords.Count -gt 0) {
        $keywordsList = ($foundKeywords.Keys | ForEach-Object { "$_" }) -join ", "
        Write-OK "Found context: $keywordsList"
    }
} else {
    Write-Skip "No documentation files found"
}

# ============================================================
# [2/7] Scan project structure
# ============================================================

Write-Step "2/$totalSteps" "Scanning project structure..."

$projectDirs = Get-ChildItem -Path $PROJECT_DIR -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin $ignoreDirs } |
    Select-Object Name, FullName

$dirSummary = @()
foreach ($dir in $projectDirs) {
    $files = Get-ChildItem -Path $dir.FullName -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { -not ($ignoreDirs | Where-Object { $_.FullName -match "\\$_\$|\\$_\\" }) }
    $lines = 0
    foreach ($f in $files) {
        try { $lines += (Get-Content $f.FullName -ErrorAction SilentlyContinue | Measure-Object).Count } catch {}
    }
    $dirSummary += [PSCustomObject]@{
        Name = $dir.Name
        Files = $files.Count
        Lines = $lines
    }
    Write-Host "  $($dir.Name) — $($files.Count) files, $lines lines" -ForegroundColor Gray
}

$totalFiles = ($dirSummary | Measure-Object -Property Files -Sum).Sum
$totalLines = ($dirSummary | Measure-Object -Property Lines -Sum).Sum
Write-OK "Found $totalFiles files, $totalLines lines across $($projectDirs.Count) directories"

# ============================================================
# [3/7] Read dependencies
# ============================================================

Write-Step "3/$totalSteps" "Reading dependencies..."

$deps = @{}
$depFiles = @()

# Search for dep files in project root and subdirs (1 level deep)
$depPatterns = @("package.json", "pubspec.yaml", "go.mod", "Cargo.toml", "composer.json", "Gemfile", "requirements.txt", "pyproject.toml", "build.gradle.kts", "*.csproj")
foreach ($pattern in @("package.json", "pubspec.yaml", "go.mod", "Cargo.toml", "composer.json", "Gemfile", "requirements.txt", "pyproject.toml", "build.gradle.kts")) {
    $found = Get-ChildItem -Path $PROJECT_DIR -Filter $pattern -Depth 1 -ErrorAction SilentlyContinue | Where-Object { $_.Name -notin $ignoreDirs }
    foreach ($f in $found) {
        $depFiles += $f.FullName
        try {
            $content = Get-Content $f.FullName -Raw -ErrorAction SilentlyContinue
            $deps[$f.Name] = $content.Substring(0, [Math]::Min(500, $content.Length))
        } catch {}
    }
}

foreach ($f in $depFiles) { Write-Info "Found: $f" }

if ($depFiles.Count -gt 0) {
    Write-OK "$($depFiles.Count) dependency files found"
} else {
    Write-Skip "No dependency files found"
}

# ============================================================
# [3/6] Deep code scan (imports & patterns)
# ============================================================

Write-Step "4/$totalSteps" "Deep code scan (imports & patterns)..."

$foundFeatures = @{}
$foundImports = @{}
$detectedStacks = @()

# Language-specific import patterns
$importPatterns = @(
    @{ Pattern = "react"; Lang = "JavaScript"; Framework = "React" }
    @{ Pattern = "vue"; Lang = "JavaScript"; Framework = "Vue" }
    @{ Pattern = "next"; Lang = "JavaScript"; Framework = "Next.js" }
    @{ Pattern = "express"; Lang = "JavaScript"; Framework = "Express" }
    @{ Pattern = "redux"; Lang = "JavaScript"; Framework = "Redux" }
    @{ Pattern = "zustand"; Lang = "JavaScript"; Framework = "Zustand" }
    @{ Pattern = "@angular"; Lang = "JavaScript"; Framework = "Angular" }
    @{ Pattern = "@nestjs"; Lang = "JavaScript"; Framework = "NestJS" }
    @{ Pattern = "prisma"; Lang = "JavaScript"; Framework = "Prisma" }
    @{ Pattern = "supabase"; Lang = "JavaScript"; Framework = "Supabase" }
    @{ Pattern = "fastify"; Lang = "JavaScript"; Framework = "Fastify" }
    @{ Pattern = "django"; Lang = "Python"; Framework = "Django" }
    @{ Pattern = "fastapi"; Lang = "Python"; Framework = "FastAPI" }
    @{ Pattern = "flask"; Lang = "Python"; Framework = "Flask" }
    @{ Pattern = "sqlalchemy"; Lang = "Python"; Framework = "SQLAlchemy" }
    @{ Pattern = "pytest"; Lang = "Python"; Framework = "pytest" }
    @{ Pattern = "tensorflow"; Lang = "Python"; Framework = "TensorFlow" }
    @{ Pattern = "torch"; Lang = "Python"; Framework = "PyTorch" }
    @{ Pattern = "gin"; Lang = "Go"; Framework = "Gin" }
    @{ Pattern = "echo"; Lang = "Go"; Framework = "Echo" }
    @{ Pattern = "fiber"; Lang = "Go"; Framework = "Fiber" }
    @{ Pattern = "gorilla"; Lang = "Go"; Framework = "Gorilla Mux" }
    @{ Pattern = "gorm"; Lang = "Go"; Framework = "GORM" }
    @{ Pattern = "golang-jwt"; Lang = "Go"; Framework = "JWT" }
    @{ Pattern = "flutter"; Lang = "Dart"; Framework = "Flutter" }
    @{ Pattern = "riverpod"; Lang = "Dart"; Framework = "Riverpod" }
    @{ Pattern = "bloc"; Lang = "Dart"; Framework = "BLoC" }
    @{ Pattern = "go_router"; Lang = "Dart"; Framework = "GoRouter" }
    @{ Pattern = "dio"; Lang = "Dart"; Framework = "Dio" }
    @{ Pattern = "axum"; Lang = "Rust"; Framework = "Axum" }
    @{ Pattern = "actix"; Lang = "Rust"; Framework = "Actix" }
    @{ Pattern = "tokio"; Lang = "Rust"; Framework = "Tokio" }
    @{ Pattern = "serde"; Lang = "Rust"; Framework = "Serde" }
    @{ Pattern = "diesel"; Lang = "Rust"; Framework = "Diesel" }
    @{ Pattern = "sqlx"; Lang = "Rust"; Framework = "SQLx" }
    @{ Pattern = "laravel"; Lang = "PHP"; Framework = "Laravel" }
    @{ Pattern = "symfony"; Lang = "PHP"; Framework = "Symfony" }
    @{ Pattern = "jwt"; Lang = "General"; Framework = "JWT Auth" }
    @{ Pattern = "jsonwebtoken"; Lang = "General"; Framework = "JWT" }
    @{ Pattern = "firebase"; Lang = "General"; Framework = "Firebase" }
    @{ Pattern = "stripe"; Lang = "General"; Framework = "Stripe" }
)

# Scan a subset of files for imports (limit to avoid timeout)
$codeFiles = Get-ChildItem -Path $PROJECT_DIR -Include @("*.js", "*.ts", "*.tsx", "*.jsx", "*.py", "*.go", "*.dart", "*.rs", "*.php", "*.rb") -Recurse -ErrorAction SilentlyContinue |
    Where-Object { 
        $fullName = $_.FullName
        -not ($ignoreDirs | Where-Object { $fullName -match "\\$_\$|\\$_\\" })
    }

# Limit scan to first 200 relevant files
if ($codeFiles.Count -gt 200) {
    Write-Info "Project has $($codeFiles.Count) source files, scanning first 200..."
    $codeFiles = $codeFiles | Select-Object -First 200
}

Write-Info "Scanning $($codeFiles.Count) source files for imports..."

$matchedFrameworks = @()
$importCount = 0

foreach ($file in $codeFiles) {
    try {
        $content = Get-Content $file.FullName -ErrorAction SilentlyContinue -TotalCount 50
        foreach ($line in $content) {
            foreach ($ip in $importPatterns) {
                if ($line -match [regex]::Escape($ip.Pattern) -and $line -match "(import|from|require|use)") {
                    $key = $ip.Pattern
                    if (-not $matchedFrameworks.Contains($key)) {
                        $matchedFrameworks += $key
                        Write-Info "  Found: $($ip.Framework) in $($file.Name)"
                        $importCount++
                    }
                }
            }
        }
    } catch {}
}

Write-OK "Detected $importCount frameworks/libraries"

# Determine primary language
$langCount = @{}
foreach ($f in $codeFiles) {
    $ext = [System.IO.Path]::GetExtension($f.Name)
    if ($ext) { $langCount[$ext] = [int]$langCount[$ext] + 1 }
}
$primaryExt = ($langCount.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Key
if ($primaryExt) { Write-OK "Primary language: $primaryExt ($($langCount[$primaryExt]) files)" }

# ============================================================
# [4/6] Match skills from skill list
# ============================================================

Write-Step "4/$totalSteps" "Matching skills from Skill/skill-list.md..."

$coreSkills = @("tdd-workflow", "security-review", "coding-standards", "verification-loop")
$matchedSkills = @() + $coreSkills

# Map detected frameworks to skills
$frameworkSkills = @{
    "React" = @("react-patterns", "react-performance", "react-testing", "frontend-patterns", "accessibility")
    "Next.js" = @("frontend-patterns", "backend-patterns", "nextjs-turbopack")
    "Vue" = @("frontend-patterns", "ui-to-vue")
    "Angular" = @("angular-developer")
    "Express" = @("backend-patterns", "api-design")
    "NestJS" = @("nestjs-patterns")
    "Prisma" = @("prisma-patterns", "database-migrations")
    "Django" = @("django-patterns", "django-tdd", "django-security", "django-verification")
    "FastAPI" = @("fastapi-patterns", "python-patterns", "python-testing")
    "Flask" = @("python-patterns", "python-testing")
    "Gin" = @("golang-patterns", "golang-testing")
    "Echo" = @("golang-patterns", "golang-testing")
    "Fiber" = @("golang-patterns", "golang-testing")
    "GORM" = @("golang-patterns", "postgres-patterns")
    "Flutter" = @("dart-flutter-patterns")
    "Riverpod" = @("dart-flutter-patterns")
    "BLoC" = @("dart-flutter-patterns")
    "Axum" = @("rust-patterns", "rust-testing")
    "Actix" = @("rust-patterns", "rust-testing")
    "Tokio" = @("rust-patterns", "rust-testing")
    "Laravel" = @("laravel-patterns", "laravel-tdd", "laravel-security", "laravel-verification")
    "JWT" = @("security-review")
    "Supabase" = @("postgres-patterns")
    "Firebase" = @("security-review")
    "SQLAlchemy" = @("postgres-patterns", "database-migrations")
}

foreach ($fw in $matchedFrameworks) {
    if ($frameworkSkills.ContainsKey($fw)) {
        foreach ($skill in $frameworkSkills[$fw]) {
            if ($skill -notin $matchedSkills) { $matchedSkills += $skill }
        }
    }
}

# Also detect from dependency files
$depKeywords = @{
    "react" = @("react-patterns", "frontend-patterns")
    "next" = @("frontend-patterns", "backend-patterns", "nextjs-turbopack")
    "vue" = @("frontend-patterns", "ui-to-vue")
    "@angular" = @("angular-developer")
    "django" = @("django-patterns", "django-tdd", "django-security")
    "fastapi" = @("fastapi-patterns", "python-patterns")
    "flask" = @("python-patterns")
    "gorilla/mux" = @("golang-patterns", "golang-testing")
    "gorm" = @("golang-patterns", "postgres-patterns")
    "flutter" = @("dart-flutter-patterns")
    "riverpod" = @("dart-flutter-patterns")
    "prisma" = @("prisma-patterns", "database-migrations")
    "supabase" = @("postgres-patterns")
    "laravel" = @("laravel-patterns", "laravel-tdd")
    "axios" = @("frontend-patterns")
    "redux" = @("frontend-patterns")
    "zustand" = @("frontend-patterns")
    "jest" = @("react-testing")
    "vitest" = @("react-testing")
    "pytest" = @("python-testing")
    "mongodb" = @("database-migrations")
    "postgres" = @("postgres-patterns", "database-migrations")
    "mysql" = @("mysql-patterns", "database-migrations")
    "redis" = @("redis-patterns")
    "docker" = @("docker-patterns", "deployment-patterns")
}

foreach ($depName in $deps.Keys) {
    $depContent = $deps[$depName].ToLower()
    foreach ($kw in $depKeywords.Keys) {
        if ($depContent -match [regex]::Escape($kw)) {
            foreach ($skill in $depKeywords[$kw]) {
                if ($skill -notin $matchedSkills) {
                    $matchedSkills += $skill
                    Write-Info "  Dep match: $kw → $skill"
                }
            }
        }
    }
}

Write-OK "Matched $($matchedSkills.Count) skills ($($coreSkills.Count) core + $($matchedSkills.Count - $coreSkills.Count) project-specific)"




$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$stackLines = @()
foreach ($fw in $matchedFrameworks) {
    $stackLines += "| $fw | Detected from imports |"
}

$aiNotes = @"
# AI Notes — Code Analysis

**Generated:** $timestamp
**Source:** Source code analysis (code-analyze)

---

## Project Overview

```
$($dirSummary.Name) — $totalFiles files, $totalLines lines
```

## Detected Stack

$($stackLines -join "`n")

## Project Structure

| Directory | Files | Lines |
|-----------|-------|-------|
$($dirSummary | ForEach-Object { "| $($_.Name) | $($_.Files) | $($_.Lines) |" })

## Recommended Skills

### Core (always)
$($coreSkills | ForEach-Object { "- $_" })

### Project-Specific
$($matchedSkills | Where-Object { $_ -notin $coreSkills } | ForEach-Object { "- $_" })

## Recommended Commands

| Command | Kapan Dipakai |
|---------|---------------|
| /code-analyze | Scan ulang (jika ada perubahan) |
| /analyze-project | Deteksi ulang stack |
| /code-review | Review existing code |
| /tdd | TDD untuk fitur baru |
| /security | Security audit |
| /build-fix | Fix build errors |
| /verify | Verification loop |

## Recommended Agents

| Agent | Kapan Dipakai |
|-------|---------------|
| code-reviewer | Review existing code |
| security-reviewer | Security audit |
| tdd-guide | TDD untuk fitur baru |
| build-error-resolver | Fix build errors |

## Architecture Recommendations

1. Review hasil scan di atas
2. Jalankan /code-review untuk cek kualitas kode
3. Jalankan /security untuk audit keamanan
4. Tambah test coverage dengan /tdd
5. Gunakan /verify sebelum commit

## Next Steps

1. Jalankan /analyze-project untuk load skills yang sesuai
2. Restart opencode
3. Mulai improve code dengan /code-review

---

*File ini di-generate otomatis oleh /code-analyze*
"@

Set-Content -Path $AI_NOTES -Value $aiNotes -Encoding UTF8


# ============================================================
# [6/6] Summary
# ============================================================

Write-Step "6/$totalSteps" "Summary"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Code Analysis Complete!             ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Project:    $PROJECT_DIR" -ForegroundColor White
Write-Host "  Files:      $totalFiles ($totalLines lines)" -ForegroundColor White
Write-Host "  Frameworks: $($matchedFrameworks.Count) detected" -ForegroundColor White
Write-Host "  Skills:     $($matchedSkills.Count) matched" -ForegroundColor White
Write-Host "  AI Notes:   $AI_NOTES" -ForegroundColor White
Write-Host ""
Write-Host "  Next: /analyze-project" -ForegroundColor Cyan
Write-Host ""

