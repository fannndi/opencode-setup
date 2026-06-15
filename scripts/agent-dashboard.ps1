# Agent Dashboard — project overview + system health + recent activity

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\agent-core.ps1"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║          Agent Dashboard — System Overview      ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan

# ─── System Health ───
Write-Host ""
Write-Host "  ─── System Health ───" -ForegroundColor Cyan

# 9Router
$apiUrl = "http://localhost:20128"
$routerOk = $false
try {
    $null = Invoke-RestMethod -Uri "$apiUrl/api/health" -TimeoutSec 3 -ErrorAction SilentlyContinue
    $routerOk = $true
    Write-Host "  9Router:      ✅ Running" -ForegroundColor Green
} catch {
    Write-Host "  9Router:      ❌ Not running" -ForegroundColor Red
}

# ECC
$eccOk = (Test-Path "$ROOT_DIR\ecc\AGENTS.md")
Write-Host "  ECC:          $(if($eccOk){'✅'}else{'❌'}) $(if($eccOk){'Skills: 270, Agents: 64'}else{'Not found'})" -ForegroundColor $(if($eccOk){'Green'}else{'Red'})

# Session
$active = Get-ActiveProject
if ($active) {
    Write-Host "  Session:      ✅ Active: $active" -ForegroundColor Green
    $slug = Get-ProjectSlug -Path $active
    $sf = Get-SessionFile -ProjectPath $active
    if (Test-Path $sf) {
        $session = Get-Content $sf -Raw | ConvertFrom-Json
        Write-Host "  Last action:  $($session.last_action)" -ForegroundColor Gray
    }
} else {
    Write-Host "  Session:      ⬜ None active" -ForegroundColor Yellow
}

# ─── Active Project ───
if ($active) {
    Write-Host ""
    Write-Host "  ─── Active Project ───" -ForegroundColor Cyan

    $stacks = Detect-Stack -ProjectPath $active
    Write-Host "  Project:      $(Split-Path $active -Leaf)" -ForegroundColor White
    Write-Host "  Path:         $active" -ForegroundColor White
    Write-Host "  Stack:        $(if($stacks){$stacks -join ', '}else{'Not detected'})" -ForegroundColor White

    # Memory stats
    $memDir = Get-MemoryDir -ProjectPath $active
    $sessionCount = (Get-ChildItem "$memDir\sessions\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
    $patternCount = (Get-ChildItem "$memDir\patterns\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count
    $errorCount = (Get-ChildItem "$memDir\errors\*.md" -ErrorAction SilentlyContinue | Measure-Object).Count

    Write-Host "  Logs:         $sessionCount session logs" -ForegroundColor Gray
    Write-Host "  Patterns:     $patternCount learned" -ForegroundColor Gray
    Write-Host "  Error fixes:  $errorCount saved" -ForegroundColor Gray
}

# ─── All Projects ───
Write-Host ""
Write-Host "  ─── All Projects ───" -ForegroundColor Cyan
List-Projects

# ─── Recommendations ───
if ($active) {
    Write-Host ""
    Write-Host "  ─── Recommendations ───" -ForegroundColor Cyan

    $stacks = Detect-Stack -ProjectPath $active
    $skills = Get-SkillsForStack -Stacks $stacks

    if ($skills.Count -gt 0) {
        Write-Host "  Recommended skills for project:" -ForegroundColor Yellow
        foreach ($s in $skills) {
            Write-Host "    • $s" -ForegroundColor Gray
        }
    }

    # Check TODO.md
    if (Test-Path "$active\TODO.md") {
        Write-Host "" -ForegroundColor Gray
        Write-Host "  Project has TODO.md" -ForegroundColor Yellow
        $todoTasks = (Get-Content "$active\TODO.md" | Select-String -Pattern "### P\d-" | Measure-Object).Count
        Write-Host "  $todoTasks pending tasks" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "  Commands: /set-project <path> | /resume | /agent-core detect <path>" -ForegroundColor Cyan
Write-Host ""
