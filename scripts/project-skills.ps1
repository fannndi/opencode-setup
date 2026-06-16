# Project Skills — Tampilkan skills yang cocok untuk project saat ini
# Usage: .\project-skills.ps1 [-ProjectPath "C:\path\to\project"]

param(
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SKILL_LIST = "$ROOT_DIR\Skill\skill-list.md"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"
# Source LLM adapter
. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# Resolve Project Path
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if (-not $ProjectPath) {
    Write-Host "[ERROR] No project path. Usage: .\project-skills.ps1 -ProjectPath 'C:\path'" -ForegroundColor Red
    exit 1
}

$PROJECT_DIR = $ProjectPath

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Project Skills — $([System.IO.Path]::GetFileName($PROJECT_DIR))$( ' ' * (28 - $([System.IO.Path]::GetFileName($PROJECT_DIR)).Length))║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Scan for indicators
$indicators = @{
    "pubspec.yaml" = "dart-flutter"
    "go.mod" = "golang"
    "package.json" = "javascript"
    "next.config.js" = "nextjs"
    "Cargo.toml" = "rust"
    "build.gradle.kts" = "kotlin"
    "CMakeLists.txt" = "cpp"
    "requirements.txt" = "python"
    "Dockerfile" = "docker"
    "manage.py" = "django"
}

$detectedStack = $null
foreach ($f in $indicators.Keys) {
    if (Test-Path "$PROJECT_DIR\$f") { $detectedStack = $indicators[$f]; break }
}
if (-not $detectedStack) { $detectedStack = "general" }

# Core skills (always)
$coreSkills = @(
    @{ Name = "tdd-workflow"; Desc = "Test-driven development"; Use = "Wajib untuk semua project" }
    @{ Name = "security-review"; Desc = "Security checklist OWASP"; Use = "Wajib untuk semua project" }
    @{ Name = "coding-standards"; Desc = "KISS, DRY, YAGNI, immutability"; Use = "Wajib untuk semua project" }
    @{ Name = "verification-loop"; Desc = "Build/type/lint/test verification"; Use = "Wajib sebelum commit" }
)

# Stack-specific skills
$stackSkills = @{
    "dart-flutter" = @(
        @{ Name = "dart-flutter-patterns"; Desc = "BLoC, Riverpod, GoRouter patterns"; Use = "Flutter project" }
    )
    "golang" = @(
        @{ Name = "golang-patterns"; Desc = "Idiomatic Go patterns"; Use = "Go project" }
        @{ Name = "golang-testing"; Desc = "Table-driven tests, benchmarks"; Use = "Go testing" }
    )
    "react" = @(
        @{ Name = "react-patterns"; Desc = "Hooks, Suspense, state"; Use = "React project" }
        @{ Name = "react-performance"; Desc = "70+ performance rules"; Use = "Optimasi React" }
        @{ Name = "frontend-patterns"; Desc = "State management, UI"; Use = "Frontend work" }
    )
    "nextjs" = @(
        @{ Name = "frontend-patterns"; Desc = "State management, UI"; Use = "Frontend work" }
        @{ Name = "backend-patterns"; Desc = "API, database patterns"; Use = "Backend work" }
        @{ Name = "nextjs-turbopack"; Desc = "Turbopack, FS caching"; Use = "Next.js 16+" }
    )
    "python" = @(
        @{ Name = "python-patterns"; Desc = "Pythonic idioms, PEP 8"; Use = "Python project" }
        @{ Name = "python-testing"; Desc = "pytest, TDD"; Use = "Python testing" }
    )
    "django" = @(
        @{ Name = "django-patterns"; Desc = "DRF, ORM patterns"; Use = "Django app" }
        @{ Name = "django-tdd"; Desc = "pytest-django, factory_boy"; Use = "Django testing" }
        @{ Name = "django-security"; Desc = "Auth, CSRF, XSS"; Use = "Django security" }
    )
    "rust" = @(
        @{ Name = "rust-patterns"; Desc = "Ownership, traits, concurrency"; Use = "Rust project" }
        @{ Name = "rust-testing"; Desc = "Unit/async/property tests"; Use = "Rust testing" }
    )
    "kotlin" = @(
        @{ Name = "kotlin-patterns"; Desc = "Coroutines, null safety"; Use = "Kotlin project" }
        @{ Name = "kotlin-testing"; Desc = "Kotest, MockK"; Use = "Kotlin testing" }
    )
    "docker" = @(
        @{ Name = "docker-patterns"; Desc = "Docker/Compose, security"; Use = "Docker project" }
        @{ Name = "deployment-patterns"; Desc = "CI/CD, rollback"; Use = "Deployment" }
    )
}

Write-Host "  Stack yang terdeteksi: $detectedStack" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ─── Core Skills ───" -ForegroundColor Cyan
foreach ($s in $coreSkills) {
    Write-Host "  ⬢ $($s.Name)" -ForegroundColor Green
    Write-Host "    $($s.Desc)" -ForegroundColor Gray
    Write-Host "    ➤ $($s.Use)" -ForegroundColor White
}

if ($stackSkills.ContainsKey($detectedStack)) {
    Write-Host ""
    Write-Host "  ─── Project Skills ($detectedStack) ───" -ForegroundColor Cyan
    foreach ($s in $stackSkills[$detectedStack]) {
        Write-Host "  ⬢ $($s.Name)" -ForegroundColor Yellow
        Write-Host "    $($s.Desc)" -ForegroundColor Gray
        Write-Host "    ➤ $($s.Use)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "  ─── Recommended Commands ───" -ForegroundColor Cyan
Write-Host "  /tdd             — TDD workflow" -ForegroundColor White
Write-Host "  /code-review     — Review kode" -ForegroundColor White
Write-Host "  /security        — Security audit" -ForegroundColor White
Write-Host "  /verify          — Verification loop" -ForegroundColor White
Write-Host "  /build-fix       — Fix build errors" -ForegroundColor White
Write-Host ""

Write-Host "  Total: $($coreSkills.Count + $($stackSkills[$detectedStack] | Measure-Object | Select-Object -ExpandProperty Count)) skills untuk $detectedStack" -ForegroundColor Green
Write-Host ""
