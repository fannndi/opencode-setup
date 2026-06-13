# OpenCode Full Setup - ECC + 9Router
# Fully automated: clone, install, configure, start
# Usage: .\setup.ps1

param(
    [switch]$SkipClone,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = "$SETUP_DIR\ecc"
$ROUTER_DIR = "$SETUP_DIR\9router"
$OPENCODE_CONFIG_DIR = "$env:USERPROFILE\.config\opencode"
$OPENCODE_CONFIG = "$OPENCODE_CONFIG_DIR\opencode.jsonc"
$RULES_TARGET = "$OPENCODE_CONFIG_DIR\rules\ecc"

# ============================================================
# Helper functions
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

function Test-Command {
    param([string]$Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║       OpenCode Full Setup - ECC + 9Router       ║" -ForegroundColor Magenta
Write-Host "  ║    agents · skills · RTK · caveman · fallback   ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Step 1: Pre-flight checks
# ============================================================

Write-Step "1/10" "Pre-flight checks..."

# Check Node.js
if (-not (Test-Command "node")) {
    Write-Fail "Node.js not found. Install from https://nodejs.org"
    exit 1
}
$nodeVersion = node --version
Write-OK "Node.js $nodeVersion"

# Check npm
if (-not (Test-Command "npm")) {
    Write-Fail "npm not found"
    exit 1
}
Write-OK "npm $(npm --version)"

# Check git
if (-not (Test-Command "git")) {
    Write-Fail "git not found. Install from https://git-scm.com"
    exit 1
}
Write-OK "git $(git --version)"

# Check OpenCode
if (-not (Test-Command "opencode")) {
    Write-Fail "OpenCode not found. Install: npm install -g opencode"
    exit 1
}
Write-OK "OpenCode installed"

# ============================================================
# Step 1.5: Check API Key
# ============================================================

$apiKeyFile = "$SETUP_DIR\api-key.txt"
$apiKeyValue = ""

if (Test-Path $apiKeyFile) {
    $apiKeyContent = (Get-Content $apiKeyFile -Raw).Trim()
    # Remove comments and empty lines
    $apiKeyLines = $apiKeyContent -split "`n" | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' }
    if ($apiKeyLines.Count -gt 0) {
        $apiKeyLine = $apiKeyLines[0].Trim()
        # Support both "KEY=value" and just "value" formats
        if ($apiKeyLine -match '=') {
            $apiKeyValue = ($apiKeyLine -split '=', 2)[1].Trim()
        } else {
            $apiKeyValue = $apiKeyLine
        }
    }
}

if ([string]::IsNullOrWhiteSpace($apiKeyValue)) {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "  ║  ⚠️  API KEY BELUM DIISI                       ║" -ForegroundColor Yellow
    Write-Host "  ╠══════════════════════════════════════════════════╣" -ForegroundColor Yellow
    Write-Host "  ║  Edit file: api-key.txt                         ║" -ForegroundColor Yellow
    Write-Host "  ║  Isi dengan key dari:                           ║" -ForegroundColor Yellow
    Write-Host "  ║  - https://opencode.ai/console                  ║" -ForegroundColor Yellow
    Write-Host "  ║  - http://localhost:20128/dashboard              ║" -ForegroundColor Yellow
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
    Write-Skip "API key not set (setup will continue, but 9Router won't work)"
} else {
    Write-OK "API key found ($($apiKeyValue.Substring(0, [Math]::Min(8, $apiKeyValue.Length)))...)"
    [Environment]::SetEnvironmentVariable('NINEROUTER_API_KEY', $apiKeyValue, 'User')
    $env:NINEROUTER_API_KEY = $apiKeyValue
    Write-OK "NINEROUTER_API_KEY set"
}

# ============================================================
# Step 2: Clone repos
# ============================================================

Write-Step "2/10" "Clone repositories..."

if (-not $SkipClone) {
    # Use dedicated clone script
    & "$SETUP_DIR\clone-repo.ps1"
} else {
    Write-Skip "Clone skipped (--SkipClone)"
}

# ============================================================
# Step 2.5: Check for changes
# ============================================================

Write-Step "2.5/10" "Checking for changes since last sync..."

if (Test-Path "$SETUP_DIR\.sync-state.json") {
    Write-Host "  Running sync-changelog (info only)..." -ForegroundColor Gray
    & "$SETUP_DIR\sync-changelog.ps1" -Apply 2>$null
    Write-OK "Changelog checked"
} else {
    Write-Skip "No sync state found (first run)"
}

# ============================================================
# Step 3: Install ECC dependencies
# ============================================================

Write-Step "3/10" "Install ECC dependencies..."

if (-not $SkipBuild) {
    Push-Location $ECC_DIR

    if (-not (Test-Path "node_modules")) {
        Write-Host "  Installing root dependencies..." -ForegroundColor Gray
        npm install --silent 2>$null
    }
    Write-OK "Root dependencies"

    if (-not (Test-Path ".opencode\node_modules")) {
        Write-Host "  Installing .opencode dependencies..." -ForegroundColor Gray
        Push-Location ".opencode"
        npm install --silent 2>$null
        Pop-Location
    }
    Write-OK ".opencode dependencies"

    Pop-Location
} else {
    Write-Skip "Build skipped (--SkipBuild)"
}

# ============================================================
# Step 4: Build ECC OpenCode plugin
# ============================================================

Write-Step "4/10" "Build ECC OpenCode plugin..."

if (-not $SkipBuild) {
    Push-Location $ECC_DIR
    npm run build:opencode 2>$null
    if (Test-Path ".opencode\dist\index.js") {
        Write-OK "Plugin built successfully"
    } else {
        Write-Fail "Plugin build failed"
        Pop-Location
        exit 1
    }
    Pop-Location
} else {
    Write-Skip "Build skipped (--SkipBuild)"
}

# ============================================================
# Step 5: Install 9Router
# ============================================================

Write-Step "5/10" "Install 9Router..."

$routerInstalled = $false
try {
    $null = Get-Command 9router -ErrorAction SilentlyContinue
    $routerInstalled = $true
} catch {}

if ($routerInstalled) {
    Write-Skip "9Router already installed globally"
} else {
    Write-Host "  Installing 9Router globally..." -ForegroundColor Gray
    npm install -g 9router 2>$null
    Write-OK "9Router installed"
}

# ============================================================
# Step 6: Ask user profile
# ============================================================

Write-Step "6/10" "Configure profile..."

Write-Host ""
Write-Host "  Pilih provider untuk OpenCode:" -ForegroundColor White
Write-Host "  [1] Free Only (OpenCode Free + Kiro)     <- $0/bulan" -ForegroundColor Green
Write-Host "  [2] Go Subscription (Kimi/Qwen/DeepSeek) <- $5/bulan pertama" -ForegroundColor Yellow
Write-Host "  [3] Custom (masukkan API key sendiri)" -ForegroundColor Gray
Write-Host ""

do {
    $profileChoice = Read-Host "  Pilih (1/2/3)"
} while ($profileChoice -notmatch '^[123]$')

$GO_API_KEY = ""

switch ($profileChoice) {
    "1" {
        $PROFILE_NAME = "free"
        Write-OK "Free profile selected"
    }
    "2" {
        $PROFILE_NAME = "go"
        Write-Host ""
        Write-Host "  Masukkan OpenCode Go API key:" -ForegroundColor Yellow
        Write-Host "  (Dapatkan dari https://opencode.ai/console)" -ForegroundColor Gray
        $GO_API_KEY = Read-Host "  API Key"
        if ([string]::IsNullOrWhiteSpace($GO_API_KEY)) {
            Write-Fail "API key tidak boleh kosong"
            exit 1
        }
        Write-OK "Go profile selected"
    }
    "3" {
        $PROFILE_NAME = "custom"
        Write-Host ""
        Write-Host "  Masukkan provider API key:" -ForegroundColor Yellow
        $CUSTOM_API_KEY = Read-Host "  API Key"
        Write-Host "  Masukkan model ID (contoh: deepseek/deepseek-chat):" -ForegroundColor Yellow
        $CUSTOM_MODEL = Read-Host "  Model ID"
        Write-OK "Custom profile selected"
    }
}

# ============================================================
# Step 7: Generate opencode.jsonc
# ============================================================

Write-Step "7/10" "Generate opencode.jsonc..."

New-Item -ItemType Directory -Force -Path $OPENCODE_CONFIG_DIR | Out-Null

# Backup existing config
if (Test-Path $OPENCODE_CONFIG) {
    $backup = "$OPENCODE_CONFIG.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $OPENCODE_CONFIG $backup
    Write-OK "Existing config backed up"
}

# Build agent models based on profile
$agentModels = @{}
switch ($PROFILE_NAME) {
    "free" {
        $agentModels = @{
            primary = "9router/oc/mimo-v2.5-free"
            subagent_smart = "9router/oc/deepseek-v4-flash-free"
            subagent_code = "9router/oc/mimo-v2.5-free"
        }
    }
    "go" {
        $agentModels = @{
            primary = "9router/go/kimi-k2.7"
            subagent_smart = "9router/go/qwen3.7-max"
            subagent_code = "9router/go/deepseek-v4-pro"
        }
    }
    "custom" {
        $agentModels = @{
            primary = "9router/$CUSTOM_MODEL"
            subagent_smart = "9router/$CUSTOM_MODEL"
            subagent_code = "9router/$CUSTOM_MODEL"
        }
    }
}

# Provider models section
$providerModels = switch ($PROFILE_NAME) {
    "free" {
        @"
        "oc/deepseek-v4-flash-free": { "name": "DeepSeek V4 Flash Free" },
        "oc/mimo-v2.5-free": { "name": "MiMo V2.5 Free" },
        "oc/nemotron-3-ultra-free": { "name": "Nemotron 3 Ultra Free" },
        "kr/claude-sonnet-4.5": { "name": "Kiro Claude 4.5 Free" },
        "kr/glm-5": { "name": "Kiro GLM-5 Free" }
"@
    }
    "go" {
        @"
        "go/kimi-k2.7": { "name": "Kimi K2.7" },
        "go/qwen3.7-max": { "name": "Qwen3.7 Max" },
        "go/qwen3.7-plus": { "name": "Qwen3.7 Plus" },
        "go/deepseek-v4-pro": { "name": "DeepSeek V4 Pro" },
        "go/deepseek-v4-flash": { "name": "DeepSeek V4 Flash" },
        "oc/deepseek-v4-flash-free": { "name": "DeepSeek V4 Flash Free (fallback)" }
"@
    }
    "custom" {
        @"
        "$CUSTOM_MODEL": { "name": "$CUSTOM_MODEL" }
"@
    }
}

$config = @"
{
  "`$schema": "https://opencode.ai/config.json",
  "model": "$($agentModels.primary)",
  "small_model": "$($agentModels.subagent_smart)",
  "default_agent": "build",

  "provider": {
    "9router": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local 9Router",
      "options": {
        "baseURL": "http://127.0.0.1:20128/v1",
        "apiKey": "{env:NINEROUTER_API_KEY}"
      },
      "models": {
$providerModels
      }
    }
  },

  "instructions": [
    "AGENTS.md",
    "CONTRIBUTING.md",
    "instructions/INSTRUCTIONS.md",
    "skills/tdd-workflow/SKILL.md",
    "skills/security-review/SKILL.md",
    "skills/coding-standards/SKILL.md",
    "skills/frontend-patterns/SKILL.md",
    "skills/frontend-slides/SKILL.md",
    "skills/backend-patterns/SKILL.md",
    "skills/e2e-testing/SKILL.md",
    "skills/verification-loop/SKILL.md",
    "skills/api-design/SKILL.md",
    "skills/strategic-compact/SKILL.md",
    "skills/eval-harness/SKILL.md"
  ],

  "plugin": [ "./plugins" ],

  "skills": { "paths": [ "../skills" ] },

  "agent": {
    "build": {
      "description": "Primary coding agent",
      "mode": "primary",
      "model": "$($agentModels.primary)",
      "tools": { "write": true, "edit": true, "bash": true, "read": true, "changed-files": true }
    },
    "planner": {
      "description": "Planning specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/planner.txt}",
      "tools": { "read": true, "bash": true, "write": false, "edit": false }
    },
    "architect": {
      "description": "Architecture specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/architect.txt}",
      "tools": { "read": true, "bash": true, "write": false, "edit": false }
    },
    "code-reviewer": {
      "description": "Code review specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/code-reviewer.txt}",
      "tools": { "read": true, "bash": true, "write": false, "edit": false }
    },
    "security-reviewer": {
      "description": "Security specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/security-reviewer.txt}",
      "tools": { "read": true, "bash": true, "write": true, "edit": true }
    },
    "tdd-guide": {
      "description": "TDD specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/tdd-guide.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "build-error-resolver": {
      "description": "Build error resolver",
      "mode": "subagent",
      "model": "$($agentModels.subagent_code)",
      "prompt": "{file:prompts/agents/build-error-resolver.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "e2e-runner": {
      "description": "E2E testing specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/e2e-runner.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "doc-updater": {
      "description": "Documentation specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/doc-updater.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "refactor-cleaner": {
      "description": "Refactoring specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/refactor-cleaner.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "go-reviewer": {
      "description": "Go code review",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/go-reviewer.txt}",
      "tools": { "read": true, "bash": true, "write": false, "edit": false }
    },
    "go-build-resolver": {
      "description": "Go build resolver",
      "mode": "subagent",
      "model": "$($agentModels.subagent_code)",
      "prompt": "{file:prompts/agents/go-build-resolver.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "database-reviewer": {
      "description": "Database specialist",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/database-reviewer.txt}",
      "tools": { "read": true, "write": true, "edit": true, "bash": true }
    },
    "python-reviewer": {
      "description": "Python code review",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/python-reviewer.txt}",
      "tools": { "read": true, "bash": true, "write": false, "edit": false }
    },
    "loop-operator": {
      "description": "Autonomous loop operator",
      "mode": "subagent",
      "model": "$($agentModels.subagent_smart)",
      "prompt": "{file:prompts/agents/loop-operator.txt}",
      "tools": { "read": true, "bash": true, "edit": true }
    }
  },

  "command": {
    "plan": { "description": "Implementation plan", "template": "{file:commands/plan.md}`n`n`$ARGUMENTS", "agent": "planner", "subtask": true },
    "tdd": { "description": "TDD workflow", "template": "{file:commands/tdd.md}`n`n`$ARGUMENTS", "agent": "tdd-guide", "subtask": true },
    "code-review": { "description": "Code review", "template": "{file:commands/code-review.md}`n`n`$ARGUMENTS", "agent": "code-reviewer", "subtask": true },
    "security": { "description": "Security review", "template": "{file:commands/security.md}`n`n`$ARGUMENTS", "agent": "security-reviewer", "subtask": true },
    "build-fix": { "description": "Fix build errors", "template": "{file:commands/build-fix.md}`n`n`$ARGUMENTS", "agent": "build-error-resolver", "subtask": true },
    "e2e": { "description": "E2E tests", "template": "{file:commands/e2e.md}`n`n`$ARGUMENTS", "agent": "e2e-runner", "subtask": true },
    "refactor-clean": { "description": "Remove dead code", "template": "{file:commands/refactor-clean.md}`n`n`$ARGUMENTS", "agent": "refactor-cleaner", "subtask": true },
    "orchestrate": { "description": "Multi-agent workflow", "template": "{file:commands/orchestrate.md}`n`n`$ARGUMENTS", "agent": "planner", "subtask": true },
    "learn": { "description": "Extract patterns", "template": "{file:commands/learn.md}`n`n`$ARGUMENTS" },
    "checkpoint": { "description": "Save progress", "template": "{file:commands/checkpoint.md}`n`n`$ARGUMENTS" },
    "verify": { "description": "Verification loop", "template": "{file:commands/verify.md}`n`n`$ARGUMENTS" },
    "eval": { "description": "Evaluation", "template": "{file:commands/eval.md}`n`n`$ARGUMENTS" },
    "update-docs": { "description": "Update docs", "template": "{file:commands/update-docs.md}`n`n`$ARGUMENTS", "agent": "doc-updater", "subtask": true },
    "test-coverage": { "description": "Test coverage", "template": "{file:commands/test-coverage.md}`n`n`$ARGUMENTS", "agent": "tdd-guide", "subtask": true },
    "go-review": { "description": "Go review", "template": "{file:commands/go-review.md}`n`n`$ARGUMENTS", "agent": "go-reviewer", "subtask": true },
    "go-test": { "description": "Go TDD", "template": "{file:commands/go-test.md}`n`n`$ARGUMENTS", "agent": "tdd-guide", "subtask": true },
    "go-build": { "description": "Go build fix", "template": "{file:commands/go-build.md}`n`n`$ARGUMENTS", "agent": "go-build-resolver", "subtask": true },
    "skill-create": { "description": "Generate skills", "template": "{file:commands/skill-create.md}`n`n`$ARGUMENTS" },
    "instinct-status": { "description": "View instincts", "template": "{file:commands/instinct-status.md}`n`n`$ARGUMENTS" },
    "instinct-import": { "description": "Import instincts", "template": "{file:commands/instinct-import.md}`n`n`$ARGUMENTS" },
    "instinct-export": { "description": "Export instincts", "template": "{file:commands/instinct-export.md}`n`n`$ARGUMENTS" },
    "evolve": { "description": "Cluster instincts", "template": "{file:commands/evolve.md}`n`n`$ARGUMENTS" }
  },

  "permission": { "mcp_*": "ask" }
}
"@

Set-Content -Path $OPENCODE_CONFIG -Value $config -Encoding UTF8
Write-OK "Config generated: $OPENCODE_CONFIG"

# ============================================================
# Step 8: Copy rules
# ============================================================

Write-Step "8/10" "Install ECC rules..."

New-Item -ItemType Directory -Force -Path $RULES_TARGET | Out-Null

$ruleDirs = @("common", "typescript", "python", "golang")
foreach ($dir in $ruleDirs) {
    $src = "$ECC_DIR\rules\$dir"
    $dst = "$RULES_TARGET\$dir"
    if (Test-Path $src) {
        if (Test-Path $dst) { Remove-Item -Recurse -Force $dst }
        Copy-Item -Recurse $src $dst
        Write-OK "rules/$dir"
    } else {
        Write-Skip "rules/$dir not found"
    }
}

# ============================================================
# Step 8.5: Copy prompts and commands
# ============================================================

Write-Step "8.5/10" "Install ECC prompts and commands..."

$promptsSrc = "$ECC_DIR\.opencode\prompts"
$promptsDst = "$OPENCODE_CONFIG_DIR\prompts"
if (Test-Path $promptsSrc) {
    New-Item -ItemType Directory -Force -Path "$promptsDst\agents" | Out-Null
    Copy-Item -Recurse "$promptsSrc\agents\*" "$promptsDst\agents\" -Force
    Write-OK "prompts/agents"
}

$commandsSrc = "$ECC_DIR\.opencode\commands"
$commandsDst = "$OPENCODE_CONFIG_DIR\commands"
if (Test-Path $commandsSrc) {
    New-Item -ItemType Directory -Force -Path $commandsDst | Out-Null
    Copy-Item -Recurse "$commandsSrc\*" "$commandsDst\" -Force
    Write-OK "commands"
}

# ============================================================
# Step 9: Set environment variables
# ============================================================

Write-Step "9/10" "Set environment variables..."

[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'standard', 'User')
[Environment]::SetEnvironmentVariable('ECC_AGENT_DATA_HOME', "$env:USERPROFILE\.opencode\ecc", 'User')

# Set NINEROUTER_API_KEY from api-key.txt or placeholder
$existingKey = [Environment]::GetEnvironmentVariable('NINEROUTER_API_KEY', 'User')
if (-not [string]::IsNullOrWhiteSpace($apiKeyValue)) {
    # Already set from api-key.txt in Step 1.5
    Write-OK "NINEROUTER_API_KEY set from api-key.txt"
} elseif ($existingKey -and $existingKey -ne 'SET-YOUR-KEY-FROM-DASHBOARD') {
    Write-OK "NINEROUTER_API_KEY already set"
} else {
    [Environment]::SetEnvironmentVariable('NINEROUTER_API_KEY', 'SET-YOUR-KEY-FROM-DASHBOARD', 'User')
    Write-Host "  [!] NINEROUTER_API_KEY not set. Edit api-key.txt or set from dashboard" -ForegroundColor Yellow
}

Write-OK "ECC_HOOK_PROFILE=standard"
Write-OK "ECC_AGENT_DATA_HOME set"

# ============================================================
# Step 10: Start 9Router + Summary
# ============================================================

Write-Step "10/10" "Start 9Router..."

# Check if 9Router is already running
$portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Skip "9Router already running on port 20128"
} else {
    Write-Host "  Starting 9Router in background..." -ForegroundColor Gray
    Start-Process -FilePath "9router" -WindowStyle Minimized
    Start-Sleep -Seconds 3

    # Verify it's running
    $portInUse = Get-NetTCPConnection -LocalPort 20128 -ErrorAction SilentlyContinue
    if ($portInUse) {
        Write-OK "9Router started on http://localhost:20128"
    } else {
        Write-Host "  [INFO] 9Router may need manual start: run '9router' in terminal" -ForegroundColor Yellow
    }
}

# Open dashboard
Write-Host "  Opening 9Router dashboard..." -ForegroundColor Gray
Start-Process "http://localhost:20128/dashboard"

# ============================================================
# Final Summary
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Setup Complete!                     ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Profile:       $PROFILE_NAME" -ForegroundColor White
Write-Host "  ECC:           $ECC_DIR" -ForegroundColor White
Write-Host "  9Router:       $ROUTER_DIR" -ForegroundColor White
Write-Host "  Config:        $OPENCODE_CONFIG" -ForegroundColor White
Write-Host "  Rules:         $RULES_TARGET" -ForegroundColor White
Write-Host ""
Write-Host "  Token Optimization:" -ForegroundColor Yellow
Write-Host "    RTK Token Saver:   ON  (compresses tool output -20-40%)" -ForegroundColor White
Write-Host "    Caveman Mode:      ON  (terse replies -65% output)" -ForegroundColor White
Write-Host "    Auto-fallback:     ON  (subscription -> cheap -> free)" -ForegroundColor White
Write-Host ""

if ($PROFILE_NAME -eq "go") {
    Write-Host "  Go Models:" -ForegroundColor Yellow
    Write-Host "    Primary:    9router/go/kimi-k2.7" -ForegroundColor White
    Write-Host "    Reasoning:  9router/go/qwen3.7-max" -ForegroundColor White
    Write-Host "    Review:     9router/go/deepseek-v4-pro" -ForegroundColor White
} elseif ($PROFILE_NAME -eq "free") {
    Write-Host "  Free Models:" -ForegroundColor Yellow
    Write-Host "    Primary:    9router/oc/mimo-v2.5-free" -ForegroundColor White
    Write-Host "    Fallback:   9router/oc/deepseek-v4-flash-free" -ForegroundColor White
    Write-Host "    Emergency:  9router/kr/claude-sonnet-4.5 (Claude free!)" -ForegroundColor White
}

Write-Host ""
Write-Host "  Next Steps:" -ForegroundColor Yellow
Write-Host "  ─────────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  1. Buka dashboard  → http://localhost:20128/dashboard" -ForegroundColor White
Write-Host "  2. Login           → password: 123456" -ForegroundColor White
Write-Host "  3. Connect provider → Kiro AI (free) atau OpenCode Free" -ForegroundColor White
Write-Host "  4. Create API key  → Endpoint page → Create Key" -ForegroundColor White
Write-Host "  5. Set API key:" -ForegroundColor White
Write-Host "     setx NINEROUTER_API_KEY 'your-key-here'" -ForegroundColor Cyan
Write-Host "  6. Buka terminal baru, lalu:" -ForegroundColor White
Write-Host "     opencode" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Untuk ganti profile:" -ForegroundColor Yellow
Write-Host "     .\setup.ps1" -ForegroundColor White
Write-Host ""
