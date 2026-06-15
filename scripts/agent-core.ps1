# Agent Core — AI Agent orchestrator
# Functions: intent detection, skill auto-loader, session resume, task decomposition
# Usage: Source this file from other scripts

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$SKILL_LIST = "$ROOT_DIR\Skill\skill-list.md"
$FEATURE_LIST = "$ROOT_DIR\Feature\list.md"
$ECC_DIR = "$ROOT_DIR\ecc"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Stack Detection — auto-detect project stack from files
# ============================================================

$STACK_SIGNATURES = @{
    "nextjs"     = @("next.config.js", "next.config.ts", "next.config.mjs")
    "react"      = @("package.json")  # fallback: check for react in deps
    "flutter"    = @("pubspec.yaml", "pubspec.yml")
    "nestjs"     = @("nest-cli.json", "nest-cli.ts")
    "fastapi"    = @("requirements.txt")  # fallback: check fastapi
    "express"    = @("package.json")  # fallback: check express
    "django"     = @("manage.py", "django-admin.py")
    "laravel"    = @("artisan")
    "springboot" = @("pom.xml", "build.gradle", "build.gradle.kts")
    "golang"     = @("go.mod", "go.sum")
    "rust"       = @("Cargo.toml")
    "python"     = @("setup.py", "pyproject.toml", "requirements.txt")
    "dotnet"     = @("*.csproj", "*.sln")
    "android"    = @("AndroidManifest.xml", "build.gradle.kts")
    "docker"     = @("Dockerfile", "docker-compose.yml")
    "prisma"     = @("schema.prisma")
}

$STACK_SKILLS = @{
    "nestjs"     = @("typescript-reviewer", "nest-js-patterns", "jpa-patterns")
    "flutter"    = @("dart-flutter-patterns", "flutter-dart-code-review")
    "react"      = @("react-patterns", "react-performance", "react-testing")
    "nextjs"     = @("react-patterns", "nextjs-turbopack", "frontend-patterns")
    "django"     = @("django-patterns", "django-tdd", "django-security")
    "fastapi"    = @("fastapi-patterns", "python-testing")
    "laravel"    = @("laravel-patterns", "laravel-tdd", "laravel-security")
    "springboot" = @("springboot-patterns", "springboot-tdd", "springboot-security")
    "golang"     = @("golang-patterns", "golang-testing", "go-reviewer")
    "rust"       = @("rust-patterns", "rust-testing", "rust-reviewer")
    "python"     = @("python-patterns", "python-testing")
    "android"    = @("android-clean-architecture", "kotlin-patterns")
}

$STACK_ECC_SKILLS = @{
    "flutter"    = @("dart-flutter-patterns", "flutter-dart-code-review", "tdd-workflow", "verification-loop", "e2e-testing")
    "nestjs"     = @("backend-patterns", "api-design", "security-review", "tdd-workflow", "verification-loop", "postgres-patterns")
    "nextjs"     = @("frontend-patterns", "react-patterns", "react-performance", "backend-patterns", "api-design", "tdd-workflow")
    "react"      = @("frontend-patterns", "react-patterns", "react-performance", "react-testing", "tdd-workflow")
    "docker"     = @("docker-patterns", "deployment-patterns", "production-audit")
    "django"     = @("django-patterns", "django-tdd", "django-security", "django-verification", "python-patterns")
    "fastapi"    = @("fastapi-patterns", "python-patterns", "python-testing", "api-design", "security-review")
    "laravel"    = @("laravel-patterns", "laravel-tdd", "laravel-security", "laravel-verification", "mysql-patterns")
    "springboot" = @("springboot-patterns", "springboot-tdd", "springboot-security", "springboot-verification", "jpa-patterns")
    "golang"     = @("golang-patterns", "golang-testing", "error-handling", "api-design")
    "rust"       = @("rust-patterns", "rust-testing", "error-handling")
    "python"     = @("python-patterns", "python-testing", "error-handling")
    "android"    = @("android-clean-architecture", "kotlin-patterns", "compose-multiplatform-patterns")
    "express"    = @("backend-patterns", "api-design", "security-review", "error-handling")
    "dotnet"     = @("dotnet-patterns", "csharp-testing", "api-design")
    "prisma"     = @("prisma-patterns", "postgres-patterns", "backend-patterns")
}

# ============================================================
# Detect Stack
# ============================================================

function Detect-Stack {
    param([string]$ProjectPath)

    if (-not $ProjectPath -or -not (Test-Path $ProjectPath)) {
        return @()
    }

    $detected = @()

    # Check by file presence
    foreach ($stack in $STACK_SIGNATURES.Keys) {
        $signatures = $STACK_SIGNATURES[$stack]
        foreach ($sig in $signatures) {
            if ($sig -like "*.*") {
                # Glob pattern
                $found = Get-ChildItem -Path $ProjectPath -Filter $sig -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($found) {
                    $detected += $stack
                    break
                }
            }
        }
    }

    # Check package.json for framework dependencies
    $pkgJson = "$ProjectPath\package.json"
    if (Test-Path $pkgJson) {
        try {
            $pkg = Get-Content $pkgJson -Raw | ConvertFrom-Json
            $allDeps = @()
            if ($pkg.dependencies) { $allDeps += $pkg.dependencies.PSObject.Properties.Name }
            if ($pkg.devDependencies) { $allDeps += $pkg.devDependencies.PSObject.Properties.Name }

            if ($allDeps -contains "next") { $detected += "nextjs" }
            if ($allDeps -contains "react") { $detected += "react" }
            if ($allDeps -contains "express") { $detected += "express" }
            if ($allDeps -contains "@nestjs/core") { $detected += "nestjs" }
            if ($allDeps -contains "@prisma/client") { $detected += "prisma" }
        } catch {}
    }

    # Deduplicate
    return $detected | Select-Object -Unique
}

# ============================================================
# Get Recommended Skills for Stack
# ============================================================

function Get-SkillsForStack {
    param([string[]]$Stacks)

    $skills = @()
    foreach ($s in $Stacks) {
        if ($STACK_ECC_SKILLS.ContainsKey($s)) {
            $skills += $STACK_ECC_SKILLS[$s]
        } elseif ($STACK_SKILLS.ContainsKey($s)) {
            $skills += $STACK_SKILLS[$s]
        }
    }

    # Always include core skills
    $core = @("coding-standards", "tdd-workflow", "error-handling")
    $skills += $core

    return $skills | Select-Object -Unique
}

# ============================================================
# Intent Detection — classify user input
# ============================================================

$INTENT_PATTERNS = @{
    "bug_fix"     = @("bug", "error", "fail", "broken", "not working", "fix", "broken", "wrong")
    "feature"     = @("add", "create", "new", "feature", "implement", "build", "bikin", "buat", "tambah")
    "refactor"    = @("refactor", "clean", "cleanup", "restructure", "split", "optimize")
    "research"    = @("search", "find", "look up", "cari", "research", "how to", "docs")
    "review"      = @("review", "audit", "check", "inspeksi", "cek")
    "security"    = @("security", "vulnerability", "exploit", "injection", "xss", "csrf")
    "deploy"      = @("deploy", "release", "push", "production", "go-live")
    "test"        = @("test", "coverage", "spec", "tdd", "unittest")
    "plan"        = @("plan", "design", "architecture", "blueprint", "rename")
}

function Detect-Intent {
    param([string]$Input)

    $lower = $Input.ToLower()
    $scores = @{}

    foreach ($intent in $INTENT_PATTERNS.Keys) {
        $score = 0
        foreach ($keyword in $INTENT_PATTERNS[$intent]) {
            if ($lower -match $keyword) { $score++ }
        }
        if ($score -gt 0) { $scores[$intent] = $score }
    }

    if ($scores.Count -eq 0) { return @{intent = "general"; confidence = 0.0} }

    # Return highest scoring intent with normalized confidence
    $top = $scores.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1
    $maxPossible = $INTENT_PATTERNS[$top.Key].Count
    $confidence = if ($maxPossible -gt 0) { [math]::Round($top.Value / $maxPossible, 2) } else { 0.5 }

    return @{intent = $top.Key; confidence = $confidence; method = "regex"}
}

# ============================================================
# Auto-Load Skills — write opencode.jsonc with stack-matched skills
# ============================================================

function Auto-LoadSkills {
    param([string]$ProjectPath)

    $stacks = Detect-Stack -ProjectPath $ProjectPath
    $skills = Get-SkillsForStack -Stacks $stacks

    Write-Host ""
    Write-Host "  [AGENT] Stack detected: $($stacks -join ', ')" -ForegroundColor Cyan

    if ($skills.Count -gt 0) {
        Write-Host "  [AGENT] Loading $($skills.Count) skills: $($skills -join ', ')" -ForegroundColor Gray
    }

    # Update session with stack info
    if ($ProjectPath) {
        $session = Get-Registry
        $normalized = $ProjectPath.TrimEnd('\', '/')
        if ($session.projects.PSObject.Properties.Name -contains $normalized) {
            $session.projects.$normalized.stack = ($stacks -join ',')
            Set-Registry -Registry $session
        }
    }

    return @{
        stacks = $stacks
        skills = $skills
    }
}

# ============================================================
# Session Resume — get context from last session
# ============================================================

function Get-SessionResume {
    param([string]$ProjectPath)

    if (-not $ProjectPath) { return $null }

    $sf = Get-SessionFile -ProjectPath $ProjectPath
    if (-not (Test-Path $sf)) { return $null }

    try {
        $session = Get-Content $sf -Raw | ConvertFrom-Json

        $resume = @{
            project_name  = $session.project_name
            stack         = $session.stack
            last_action   = $session.last_action
            updated_at    = $session.updated_at
            workflow      = @{
                prd_analyzed          = $session.workflow_state.prd_analyzed
                ai_notes_generated    = $session.workflow_state.ai_notes_generated
                analyze_project_done  = $session.workflow_state.analyze_project_done
            }
        }

        # Read latest memory
        $memDir = Get-MemoryDir -ProjectPath $ProjectPath
        $latestSession = Get-ChildItem "$memDir\sessions\*.md" -ErrorAction SilentlyContinue | Sort-Object Name -Descending | Select-Object -First 1
        if ($latestSession) {
            $resume.last_session_log = $latestSession.BaseName
            $firstLine = Get-Content $latestSession.FullName -TotalCount 3 | Where-Object { $_ -match "Project:" } | Select-Object -First 1
            $resume.session_summary = $firstLine
        }

        # Read patterns
        $patterns = Get-ChildItem "$memDir\patterns\*.md" -ErrorAction SilentlyContinue
        if ($patterns) {
            $resume.pattern_count = $patterns.Count
        }

        return $resume
    } catch {
        return $null
    }
}

# ============================================================
# Display Session Resume
# ============================================================

function Show-SessionResume {
    param([string]$ProjectPath)

    $resume = Get-SessionResume -ProjectPath $ProjectPath
    if (-not $resume) {
        Write-Host "  [RESUME] No previous session found" -ForegroundColor Gray
        return
    }

    Write-Host ""
    Write-Host "  ─── Session Resume: $($resume.project_name) ───" -ForegroundColor Cyan
    Write-Host "  Last action: $($resume.last_action)" -ForegroundColor White
    Write-Host "  Stack:       $($resume.stack)" -ForegroundColor White
    Write-Host "  Last active: $($resume.updated_at)" -ForegroundColor Gray

    if ($resume.last_session_log) {
        Write-Host "  Last log:    $($resume.last_session_log)" -ForegroundColor Gray
    }
    if ($resume.pattern_count -and $resume.pattern_count -gt 0) {
        Write-Host "  Patterns:    $($resume.pattern_count) saved" -ForegroundColor Green
    }

    # Show workflow progress
    Write-Host ""
    Write-Host "  Workflow Progress:" -ForegroundColor Yellow
    $wf = $resume.workflow
    Write-Host "    PRD analyzed:       $(if($wf.prd_analyzed){'✅'}else{'⬜'})" -ForegroundColor $(if($wf.prd_analyzed){'Green'}else{'Gray'})
    Write-Host "    AI Notes generated: $(if($wf.ai_notes_generated){'✅'}else{'⬜'})" -ForegroundColor $(if($wf.ai_notes_generated){'Green'}else{'Gray'})
    Write-Host "    Analyze project:    $(if($wf.analyze_project_done){'✅'}else{'⬜'})" -ForegroundColor $(if($wf.analyze_project_done){'Green'}else{'Gray'})
    Write-Host ""
}

# ============================================================
# Task Decomposition — parse goal into subtasks
# ============================================================

function Decompose-Task {
    param([string]$Goal)

    Write-Host ""
    Write-Host "  [DECOMPOSE] Parsing goal: $Goal" -ForegroundColor Cyan

    # Basic heuristic decomposition
    $lower = $Goal.ToLower()
    $tasks = @()

    # Detect feature addition
    if ($lower -match "(add|create|bikin|buat|implement|tambah)\s+(.*)") {
        $feature = $Matches[2]
        $tasks += @{
            id = "backend"
            description = "Create backend endpoint for $feature"
            depends = @()
            agent = "build"
        }
        $tasks += @{
            id = "frontend"
            description = "Create frontend UI for $feature"
            depends = @("backend")
            agent = "build"
        }
        $tasks += @{
            id = "test"
            description = "Add tests for $feature"
            depends = @("backend", "frontend")
            agent = "tdd-guide"
        }
    }
    # Detect bug fix
    elseif ($lower -match "(fix|bug|error|broken)\s+(.*)") {
        $bug = $Matches[2]
        $tasks += @{
            id = "diagnose"
            description = "Diagnose bug: $bug"
            depends = @()
            agent = "build-error-resolver"
        }
        $tasks += @{
            id = "fix"
            description = "Fix the bug"
            depends = @("diagnose")
            agent = "build"
        }
        $tasks += @{
            id = "verify"
            description = "Verify fix works"
            depends = @("fix")
            agent = "tdd-guide"
        }
    }
    # Detect refactor
    elseif ($lower -match "(refactor|split|restructure|cleanup)\s+(.*)") {
        $target = $Matches[2]
        $tasks += @{
            id = "analyze"
            description = "Analyze current structure of $target"
            depends = @()
            agent = "code-reviewer"
        }
        $tasks += @{
            id = "refactor"
            description = "Refactor $target"
            depends = @("analyze")
            agent = "refactor-cleaner"
        }
        $tasks += @{
            id = "verify"
            description = "Verify tests still pass"
            depends = @("refactor")
            agent = "tdd-guide"
        }
    }
    # Default: single task
    else {
        $tasks += @{
            id = "execute"
            description = $Goal
            depends = @()
            agent = "build"
        }
    }

    return $tasks
}

# ============================================================
# Display Task Plan
# ============================================================

function Show-TaskPlan {
    param($Tasks)

    if (-not $Tasks -or $Tasks.Count -eq 0) {
        Write-Host "  [PLAN] No tasks to show" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "  ─── Task Plan ───" -ForegroundColor Cyan
    foreach ($t in $Tasks) {
        $deps = if ($t.depends -and $t.depends.Count -gt 0) { " (after: $($t.depends -join ', '))" } else { " (no deps)" }
        Write-Host "    [$($t.id)] $($t.description)$deps" -ForegroundColor White
        Write-Host "           → Agent: $($t.agent)" -ForegroundColor Gray
    }
    Write-Host ""
}

# ============================================================
# Direct execution
# ============================================================

if ($MyInvocation.InvocationName -ne '.') {
    $action = $args[0]
    $pathArg = $args[1]
    $goalArg = $args[2]

    switch ($action) {
        "detect" {
            if (-not $pathArg) { Write-Host "Error: path required" -ForegroundColor Red; exit 1 }
            $result = Detect-Stack -ProjectPath $pathArg
            Write-Host "  Stack: $($result -join ', ')" -ForegroundColor Cyan
        }
        "resume" {
            Show-SessionResume -ProjectPath $pathArg
        }
        "auto-load" {
            if (-not $pathArg) { Write-Host "Error: path required" -ForegroundColor Red; exit 1 }
            $result = Auto-LoadSkills -ProjectPath $pathArg
        }
        "decompose" {
            if (-not $goalArg) { Write-Host "Error: goal required" -ForegroundColor Red; exit 1 }
            $tasks = Decompose-Task -Goal $goalArg
            Show-TaskPlan -Tasks $tasks
        }
        "dashboard" {
            # Show agent dashboard
            . "$SETUP_DIR\agent-dashboard.ps1"
        }
        default {
            Write-Host "Usage: .\agent-core.ps1 <detect|resume|auto-load|decompose|dashboard> [args]" -ForegroundColor Yellow
        }
    }
}
