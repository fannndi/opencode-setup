# Register Hooks — Wire agent hooks into opencode.jsonc
# Usage: .\register-hooks.ps1 [-Profile gratis|go]

param(
    [ValidateSet("gratis", "go")]
    [string]$Profile = "gratis"
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$PROFILE_FILE = "$ROOT_DIR\profiles\$Profile\opencode.jsonc"
$ECC_HOOKS = "$ROOT_DIR\ecc\hooks\hooks.json"

if (-not (Test-Path $PROFILE_FILE)) {
    Write-Host "[ERROR] Profile not found: $PROFILE_FILE" -ForegroundColor Red
    exit 1
}

# Read current profile config
$config = Get-Content $PROFILE_FILE -Raw

# Check if hooks section already exists
if ($config -match '"hooks"') {
    Write-Host "  [HOOKS] Hooks section already exists in profile" -ForegroundColor Yellow
    Write-Host "  [HOOKS] Add manually from scripts/hooks/*.ps1" -ForegroundColor Gray
    exit 0
}

# Add hooks section before closing brace
$hookEntry = @"
,
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$ROOT_DIR\\scripts\\hooks\\self-heal.ps1\" -FilePath \"\$FILE_PATH\"",
            "timeout": 15,
            "async": true
          }
        ],
        "description": "Self-heal: check types after file edits",
        "id": "pre:edit-write:self-heal"
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$ROOT_DIR\\scripts\\hooks\\eval-gate.ps1\" -FilePath \"\$FILE_PATH\"",
            "timeout": 30,
            "async": true
          }
        ],
        "description": "Eval gate: run tests on spec file changes",
        "id": "pre:edit-write:eval-gate"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$ROOT_DIR\\scripts\\hooks\\proactive-research.ps1\" -FilePath \"\$FILE_PATH\"",
            "timeout": 5,
            "async": true
          }
        ],
        "description": "Research: track unknown libraries",
        "id": "post:edit-write:proactive-research"
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "powershell -ExecutionPolicy Bypass -File \"$ROOT_DIR\\scripts\\hooks\\instinct-extract.ps1\"",
            "timeout": 10,
            "async": true
          }
        ],
        "description": "Extract patterns from session on end",
        "id": "stop:instinct-extract"
      }
    ]
  }
"@

# Insert hooks before closing brace
$config = $config.TrimEnd("`r`n", " ", "`t") + $hookEntry + "`n"

$config | Set-Content -Path $PROFILE_FILE -Encoding UTF8
Write-Host "  [HOOKS] Registered 4 hooks in $Profile profile" -ForegroundColor Green
Write-Host "  [HOOKS] Self-heal  → after Edit/Write" -ForegroundColor Gray
Write-Host "  [HOOKS] Eval gate  → after test file edits" -ForegroundColor Gray
Write-Host "  [HOOKS] Research   → track new libraries" -ForegroundColor Gray
Write-Host "  [HOOKS] Instinct   → on session end" -ForegroundColor Gray
Write-Host ""
Write-Host "  Next: restart opencode to activate hooks" -ForegroundColor Cyan
