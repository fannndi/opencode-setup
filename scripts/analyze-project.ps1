# Analyze Project - Detect stack and load appropriate skills
# Usage: .\analyze-project.ps1 [-ProjectPath "C:\path\to\project"]

param(
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SESSION_FILE = "$ROOT_DIR\.opencode-session.json"
$ECC_DIR = "$ROOT_DIR\ecc"
$OPENCODE_DIR = "$env:USERPROFILE\.config\opencode"
$OPENCODE_CONFIG = "$OPENCODE_DIR\opencode.jsonc"
$STACK_MAPPINGS = "$ECC_DIR\config\project-stack-mappings.json"

# ============================================================
# Resolve Project Path
# ============================================================

function Get-ProjectPath {
    if ($ProjectPath) { return $ProjectPath }
    $sessionPath = Read-SessionKey -Key "current_project"
    if ($sessionPath) {
        Write-Host "  [SESSION] Using project: $sessionPath" -ForegroundColor Gray
        return $sessionPath
    }
    return Split-Path -Parent $ROOT_DIR
}

function Read-SessionKey {
    param([string]$Key)
    if (-not (Test-Path $SESSION_FILE)) { return $null }
    try {
        $session = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json
        if ($session.PSObject.Properties.Name -contains $Key) { return $session.$Key }
    } catch {}
    return $null
}

function Write-SessionKey {
    param([string]$Key, [string]$Value)
    $existing = @{}
    if (Test-Path $SESSION_FILE) {
        try { $existing = Get-Content $SESSION_FILE -Raw | ConvertFrom-Json } catch {}
    }
    $existing.$Key = $Value
    $existing | ConvertTo-Json -Depth 5 | Set-Content -Path $SESSION_FILE -Encoding UTF8
}

$PROJECT_DIR = Get-ProjectPath
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Host "  [ERROR] Path not found: $PROJECT_DIR" -ForegroundColor Red
    Write-Host "  Usage: .\analyze-project.ps1 -ProjectPath 'C:\path\to\project'" -ForegroundColor Yellow
    exit 1
}
Write-SessionKey -Key "current_project" -Value $PROJECT_DIR

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
Write-Host "  ║         Project Analysis                         ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

$totalSteps = 5

# ============================================================
# [1/5] Locate project root
# ============================================================

Write-Step "1/$totalSteps" "Locating project root..."

# Project root = 1 level up from opencode-setup (or from session)

Write-Host "  Project: $PROJECT_DIR" -ForegroundColor White
Write-Host "  From:    $ROOT_DIR" -ForegroundColor Gray

# Verify it's a valid project directory
if (-not (Test-Path $PROJECT_DIR)) {
    Write-Fail "Project directory not found: $PROJECT_DIR"
    exit 1
}

# ============================================================
# [2/5] Scan for indicators
# ============================================================

Write-Step "2/$totalSteps" "Scanning for indicators..."

# Indicator files and their corresponding stacks
$indicators = @{
    "pubspec.yaml"        = "dart-flutter"
    "pubspec.lock"        = "dart-flutter"
    "go.mod"              = "golang"
    "go.sum"              = "golang"
    "package.json"        = "javascript"
    "tsconfig.json"       = "typescript"
    "next.config.js"      = "nextjs"
    "next.config.ts"      = "nextjs"
    "next.config.mjs"     = "nextjs"
    "Cargo.toml"          = "rust"
    "Cargo.lock"          = "rust"
    "pom.xml"             = "java"
    "build.gradle"        = "java"
    "build.gradle.kts"    = "kotlin"
    "settings.gradle.kts" = "kotlin"
    "Package.swift"       = "swift"
    "Gemfile"             = "ruby"
    "composer.json"       = "php-laravel"
    "artisan"             = "php-laravel"
    "CMakeLists.txt"      = "cpp"
    "Makefile"            = "cpp"
    "manage.py"           = "django"
    "requirements.txt"    = "python"
    "pyproject.toml"      = "python"
    "setup.py"            = "python"
    "Pipfile"             = "python"
    "Dockerfile"          = "docker"
    "docker-compose.yml"  = "docker"
    "compose.yaml"        = "docker"
    "AndroidManifest.xml" = "android"
}

$detectedStack = $null
$detectedFiles = @()

foreach ($file in $indicators.Keys) {
    $filePath = Join-Path $PROJECT_DIR $file
    if (Test-Path $filePath) {
        $stack = $indicators[$file]
        $detectedFiles += $file
        if (-not $detectedStack) {
            $detectedStack = $stack
        }
    }
}

if ($detectedStack) {
    Write-OK "Found: $($detectedFiles -join ', ')"
} else {
    Write-Fail "No indicators found in $PROJECT_DIR"
    Write-Info "Expected files: pubspec.yaml, go.mod, package.json, etc."
    exit 1
}

# ============================================================
# [3/5] Match stack
# ============================================================

Write-Step "3/$totalSteps" "Matching stack..."

# Stack details
$stackDetails = @{
    "dart-flutter" = @{
        name = "Dart/Flutter"
        skills = @("dart-flutter-patterns")
        rules = @("common", "dart")
        confidence = 100
    }
    "golang" = @{
        name = "Go"
        skills = @("golang-patterns", "golang-testing")
        rules = @("common", "golang")
        confidence = 100
    }
    "javascript" = @{
        name = "JavaScript"
        skills = @("frontend-patterns")
        rules = @("common", "typescript")
        confidence = 80
    }
    "typescript" = @{
        name = "TypeScript"
        skills = @("frontend-patterns", "backend-patterns")
        rules = @("common", "typescript")
        confidence = 90
    }
    "nextjs" = @{
        name = "Next.js"
        skills = @("frontend-patterns", "backend-patterns")
        rules = @("common", "typescript", "web", "react")
        confidence = 100
    }
    "rust" = @{
        name = "Rust"
        skills = @("rust-patterns", "rust-testing")
        rules = @("common", "rust")
        confidence = 100
    }
    "java" = @{
        name = "Java"
        skills = @("java-coding-standards", "jpa-patterns")
        rules = @("common", "java")
        confidence = 90
    }
    "kotlin" = @{
        name = "Kotlin"
        skills = @("kotlin-patterns", "kotlin-testing", "kotlin-coroutines-flows")
        rules = @("common", "kotlin")
        confidence = 90
    }
    "swift" = @{
        name = "Swift"
        skills = @("swiftui-patterns", "swift-concurrency-6-2")
        rules = @("common", "swift")
        confidence = 90
    }
    "ruby" = @{
        name = "Ruby"
        skills = @()
        rules = @("common", "ruby")
        confidence = 80
    }
    "php-laravel" = @{
        name = "PHP/Laravel"
        skills = @("laravel-patterns", "laravel-tdd", "laravel-security")
        rules = @("common", "php")
        confidence = 100
    }
    "cpp" = @{
        name = "C++"
        skills = @("cpp-coding-standards", "cpp-testing")
        rules = @("common", "cpp")
        confidence = 90
    }
    "python" = @{
        name = "Python"
        skills = @("python-patterns", "python-testing")
        rules = @("common", "python")
        confidence = 85
    }
    "django" = @{
        name = "Django"
        skills = @("django-patterns", "django-tdd", "django-security")
        rules = @("common", "python")
        confidence = 100
    }
    "docker" = @{
        name = "Docker"
        skills = @("docker-patterns", "deployment-patterns")
        rules = @("common")
        confidence = 80
    }
    "android" = @{
        name = "Android"
        skills = @("android-clean-architecture", "kotlin-patterns", "compose-multiplatform-patterns")
        rules = @("common", "kotlin")
        confidence = 90
    }
}

if ($stackDetails.ContainsKey($detectedStack)) {
    $detail = $stackDetails[$detectedStack]
    Write-OK "Detected: $($detail.name) ($($detail.confidence)% confidence)"
} else {
    Write-OK "Detected: $detectedStack (custom)"
    $detail = @{
        name = $detectedStack
        skills = @()
        rules = @("common")
        confidence = 70
    }
}

# ============================================================
# [4/5] Load skills
# ============================================================

Write-Step "4/$totalSteps" "Loading skills..."

# Core skills (always loaded)
$coreSkills = @(
    "tdd-workflow",
    "security-review",
    "coding-standards",
    "verification-loop"
)

# Project-specific skills
$projectSkills = $detail.skills

# All skills
$allSkills = $coreSkills + $projectSkills

Write-Host "  Core ($($coreSkills.Count)): $($coreSkills -join ', ')" -ForegroundColor White
if ($projectSkills.Count -gt 0) {
    Write-Host "  Project ($($projectSkills.Count)): $($projectSkills -join ', ')" -ForegroundColor Yellow
}
Write-Host "  Rules: $($detail.rules -join ', ')" -ForegroundColor Gray
Write-Host "  Total: $($allSkills.Count) skills loaded" -ForegroundColor Green

# ============================================================
# [5/5] Generate config
# ============================================================

Write-Step "5/$totalSteps" "Generating config..."

# Check if config exists
$overwrite = $true
if (Test-Path $OPENCODE_CONFIG) {
    Write-Host ""
    Write-Host "  Config already exists:" -ForegroundColor Yellow
    Write-Host "    $OPENCODE_CONFIG" -ForegroundColor Gray

    # Read current model
    try {
        $currentConfig = Get-Content $OPENCODE_CONFIG -Raw | ConvertFrom-Json
        Write-Host "    Current model: $($currentConfig.model)" -ForegroundColor White
    } catch {
        Write-Host "    Current model: unknown" -ForegroundColor White
    }

    Write-Host ""
    Write-Host "  Detected stack: $($detail.name)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Overwrite (apply detected stack)" -ForegroundColor Green
    Write-Host "  [2] Keep current" -ForegroundColor Gray
    Write-Host "  [3] Merge (add project skills)" -ForegroundColor Yellow
    Write-Host ""

    do {
        $choice = Read-Host "  Pilih (1/2/3)"
    } while ($choice -notmatch '^[123]$')

    switch ($choice) {
        "1" { $overwrite = $true }
        "2" {
            Write-Host ""
            Write-OK "Keeping current config"
            Write-Host ""
            exit 0
        }
        "3" {
            # Merge: add project skills to existing instructions
            Write-Info "Merging project skills into existing config..."
            $overwrite = $false
        }
    }
}

# Build skills paths
$skillPaths = @()
$skillRoot = "$ROOT_DIR/ecc/skills"
foreach ($skill in $allSkills) {
    $skillPath = "$skillRoot/$skill/SKILL.md"
    if (Test-Path $skillPath) {
        $skillPaths += $skillPath.Replace('\', '/')
    }
}

# Build rules paths
$rulesPaths = @()
$rulesRoot = "$ROOT_DIR/ecc/rules"
foreach ($rule in $detail.rules) {
    $rulePath = "$rulesRoot/$rule"
    if (Test-Path $rulePath) {
        $rulesPaths += $rulePath.Replace('\', '/')
    }
}

# Generate config JSON
$config = @{
    '$schema' = "https://opencode.ai/config.json"
    model = "9router/gratis"
    small_model = "9router/gratis-small"
    default_agent = "build"
    provider = @{
        '9router' = @{
            npm = "@ai-sdk/openai-compatible"
            name = "Local 9Router"
            options = @{
                baseURL = "http://localhost:20128/v1"
                apiKey = "{env:NINEROUTER_API_KEY}"
            }
            models = @{
                "oc/mimo-v2.5-free" = @{ name = "MiMo V2.5 Free" }
                "oc/deepseek-v4-flash-free" = @{ name = "DeepSeek V4 Flash Free" }
                "oc/nemotron-3-ultra-free" = @{ name = "Nemotron 3 Ultra Free" }
                "oc/north-mini-code-free" = @{ name = "North Mini Code Free" }
                "oc/big-pickle" = @{ name = "Big Pickle" }
                "kr/claude-sonnet-4.5" = @{ name = "Kiro Claude 4.5 Free" }
                "kr/glm-5" = @{ name = "Kiro GLM-5 Free" }
            }
        }
    }
    instructions = @(
        "$($ROOT_DIR.Replace('\', '/'))/ecc/AGENTS.md",
        "$($ROOT_DIR.Replace('\', '/'))/ecc/CONTRIBUTING.md"
    ) + $skillPaths
    plugin = @("$($ROOT_DIR.Replace('\', '/'))/ecc/plugins")
    skills = @{
        paths = @("$($ROOT_DIR.Replace('\', '/'))/ecc/skills")
    }
    permission = @{
        mcp_* = "ask"
    }
}

# Add commands
$config.command = @{
    "plan" = @{ description = "Create implementation plan"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/plan.md}`n`n`$ARGUMENTS"; agent = "planner"; subtask = $true }
    "tdd" = @{ description = "Enforce TDD workflow"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/tdd.md}`n`n`$ARGUMENTS"; agent = "tdd-guide"; subtask = $true }
    "code-review" = @{ description = "Review code quality"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/code-review.md}`n`n`$ARGUMENTS"; agent = "code-reviewer"; subtask = $true }
    "security" = @{ description = "Run security review"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/security.md}`n`n`$ARGUMENTS"; agent = "security-reviewer"; subtask = $true }
    "build-fix" = @{ description = "Fix build errors"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/build-fix.md}`n`n`$ARGUMENTS"; agent = "build-error-resolver"; subtask = $true }
    "verify" = @{ description = "Run verification loop"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/ecc/.opencode/commands/verify.md}`n`n`$ARGUMENTS" }
    "analyze-project" = @{ description = "Analyze project stack"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/commands/analyze-project.md}`n`n`$ARGUMENTS" }
    "start-free" = @{ description = "Daily workflow - free models"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/commands/start-free.md}`n`n`$ARGUMENTS" }
    "start-go" = @{ description = "Daily workflow - go models"; template = "{file:$($ROOT_DIR.Replace('\', '/'))/commands/start-go.md}`n`n`$ARGUMENTS" }
}

# Write config
New-Item -ItemType Directory -Force -Path $OPENCODE_DIR | Out-Null

if ($overwrite) {
    # Backup existing
    if (Test-Path $OPENCODE_CONFIG) {
        $backup = "$OPENCODE_CONFIG.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $OPENCODE_CONFIG $backup
        Write-OK "Existing config backed up"
    }

    $config | ConvertTo-Json -Depth 10 | Set-Content -Path $OPENCODE_CONFIG -Encoding UTF8
    Write-OK "Config generated: $OPENCODE_CONFIG"
} else {
    # Merge: add new instructions to existing
    try {
        $existing = Get-Content $OPENCODE_CONFIG -Raw | ConvertFrom-Json
        $existingInstructions = @($existing.instructions)
        $newInstructions = $existingInstructions + $skillPaths
        $existing.instructions = $newInstructions
        $existing | ConvertTo-Json -Depth 10 | Set-Content -Path $OPENCODE_CONFIG -Encoding UTF8
        Write-OK "Config merged: added $($skillPaths.Count) skill paths"
    } catch {
        Write-Fail "Merge failed: $($_.Exception.Message)"
    }
}

# ============================================================
# Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Analysis Complete!                  ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Stack:     $($detail.name)" -ForegroundColor White
Write-Host "  Project:   $PROJECT_DIR" -ForegroundColor White
Write-Host "  Config:    $OPENCODE_CONFIG" -ForegroundColor White
Write-Host "  Skills:    $($allSkills.Count) loaded" -ForegroundColor White
Write-Host "  Rules:     $($detail.rules -join ', ')" -ForegroundColor White
Write-Host ""
Write-Host "  Next: opencode" -ForegroundColor Cyan
Write-Host ""
