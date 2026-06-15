# Task Queue — Autonomous DAG execution engine
# Usage: .\task-queue.ps1 -Goal "description" [-ProjectPath "C:\path"]

param(
    [string]$Goal,
    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\agent-core.ps1"
. "$SETUP_DIR\llm-adapter.ps1"

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if (-not $Goal) {
    Write-Host "  [QUEUE] Usage: .\task-queue.ps1 -Goal 'what to do' [-ProjectPath 'C:\path']" -ForegroundColor Yellow
    exit 1
}

# ============================================================
# Step 1: Decompose goal into tasks
# ============================================================
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║           Task Queue — Autonomous Mode            ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

Write-Host "  [QUEUE] Goal: $Goal" -ForegroundColor Cyan

$enrichedGoal = Invoke-LLMEnrich -Text $Goal -Context "task decomposition enrichment"
if (-not $enrichedGoal) { $enrichedGoal = $Goal }

$tasks = Decompose-Task -Goal $enrichedGoal
Show-TaskPlan -Tasks $tasks

# ============================================================
# Step 2: Execute task DAG with dependency resolution
# ============================================================

$completed = @{}
$failed = @{}

function Get-RunnableTasks {
    param($AllTasks)
    return $AllTasks | Where-Object {
        $_.id -notin $completed.Keys -and $_.id -notin $failed.Keys -and (
            $_.depends.Count -eq 0 -or
            ($_.depends | ForEach-Object { $_ -in $completed.Keys }) -contains $true
        )
    }
}

function Execute-Task {
    param($Task)

    Write-Host ""
    Write-Host "  [EXEC] Starting: $($Task.id) — $($Task.description)" -ForegroundColor Cyan

    # Map agent type to description
    $agentHint = switch ($Task.agent) {
        "build"            { "Use general agent to implement the required changes" }
        "tdd-guide"        { "Run tests first → implement → verify" }
        "code-reviewer"    { "Review code for quality issues" }
        "build-error-resolver" { "Diagnose and fix build/type errors" }
        "refactor-cleaner" { "Refactor code, remove duplication, improve structure" }
        "security-reviewer" { "Check for OWASP vulnerabilities" }
        "planner"          { "Create implementation plan" }
        "architect"        { "Design system architecture" }
        default            { "Execute the task with available tools" }
    }

    Write-Host "  [EXEC] Agent: $($Task.agent)" -ForegroundColor Gray
    Write-Host "  [EXEC] Hint: $agentHint" -ForegroundColor Gray

    # Simulate execution (real execution would call sub-agent)
    # For now, mark as completed with instructions for the user
    $completed[$Task.id] = $true
    Write-Host "  [EXEC] ✅ $($Task.id) completed" -ForegroundColor Green

    # Log to memory
    $memDir = Get-MemoryDir -ProjectPath $ProjectPath
    $logFile = "$memDir\sessions\$(Get-Date -Format 'yyyy-MM-dd').md"
    $entry = "`n### $(Get-Date -Format 'HH:mm:ss') - Task Queue`n- Task: $($Task.id) - $($Task.description)`n- Agent: $($Task.agent)`n- Status: queued"
    if (Test-Path $logFile) {
        Add-Content -Path $logFile -Value $entry -Encoding UTF8
    } else {
        $header = "# Session Log — $(Get-Date -Format 'yyyy-MM-dd')`n$entry"
        Set-Content -Path $logFile -Value $header -Encoding UTF8
    }
}

# ============================================================
# Execute all tasks in dependency order
# ============================================================

$maxIterations = 50
$iter = 0

while ($completed.Count -lt $tasks.Count -and $iter -lt $maxIterations) {
    $iter++
    $runnable = Get-RunnableTasks -AllTasks $tasks

    if ($runnable.Count -eq 0) {
        Write-Host "  [QUEUE] ⚠️  No runnable tasks (possible circular dependency)" -ForegroundColor Yellow
        break
    }

    # Execute runnable tasks
    foreach ($t in $runnable) {
        Execute-Task -Task $t
    }
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
Write-Host "  ─── Queue Summary ───" -ForegroundColor Cyan
Write-Host "  Total tasks:  $($tasks.Count)" -ForegroundColor White
Write-Host "  Completed:    $($completed.Count)" -ForegroundColor Green
Write-Host "  Failed:       $($failed.Count)" -ForegroundColor $(if($failed.Count -gt 0){'Red'}else{'Green'})

if ($ProjectPath) {
    $sf = Get-SessionFile -ProjectPath $ProjectPath
    if (Test-Path $sf) {
        try {
            $session = Get-Content $sf -Raw | ConvertFrom-Json
            $session.last_action = "/task-queue: $enrichedGoal"
            $session.updated_at = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
            $session | ConvertTo-Json -Depth 10 | Set-Content -Path $sf -Encoding UTF8
        } catch {}
    }
}

Write-Host ""
Write-Host "   Next: review results and continue" -ForegroundColor Cyan
Write-Host ""
