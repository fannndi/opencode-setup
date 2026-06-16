# Fetch changes since last sync and display changelog
# Usage: .\sync.ps1 [-Apply]

param(
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ECC_DIR = "$ROOT_DIR\ecc"
$ROUTER_DIR = "$ROOT_DIR\9router"
$SYNC_STATE = "$SETUP_DIR\.sync-state.json"

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

function Test-OpencodeRelated {
    param([string]$Message)
    $keywords = @("opencode", "plugin", ".opencode", "agent", "command", "skill", "hook", "rule", "config", "build:opencode", "RTK", "caveman", "fallback", "opencode-plugin")
    foreach ($kw in $keywords) {
        if ($Message -match "(?i)$kw") { return $true }
    }
    return $false
}

# ============================================================
# Banner
# ============================================================

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Sync Changelog - ECC + 9Router          ║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# ============================================================
# Check prerequisites
# ============================================================

if (-not (Test-Path "$ECC_DIR\.git")) {
    Write-Fail "ECC not cloned. Run: .\clone.ps1"
    exit 1
}

if (-not (Test-Path "$ROUTER_DIR\.git")) {
    Write-Fail "9Router not cloned. Run: .\clone.ps1"
    exit 1
}

if (-not (Test-Path $SYNC_STATE)) {
    Write-Fail ".sync-state.json not found. Run: .\clone.ps1"
    exit 1
}

# ============================================================
# Read sync state
# ============================================================

$state = Get-Content $SYNC_STATE -Raw | ConvertFrom-Json

$eccLastSHA = $state.ecc.last_sha
$routerLastSHA = $state."9router".last_sha

Write-Host "  Last sync ECC:     $($eccLastSHA.Substring(0,7)) ($($state.ecc.last_sync))" -ForegroundColor Gray
Write-Host "  Last sync 9Router: $($routerLastSHA.Substring(0,7)) ($($state.'9router'.last_sync))" -ForegroundColor Gray

# ============================================================
# Get current SHAs
# ============================================================

$eccCurrentSHA = $(git -C $ECC_DIR log -1 --format="%H")
$routerCurrentSHA = $(git -C $ROUTER_DIR log -1 --format="%H")

$eccHasChanges = ($eccLastSHA -ne $eccCurrentSHA)
$routerHasChanges = ($routerLastSHA -ne $routerCurrentSHA)

if (-not $eccHasChanges -and -not $routerHasChanges) {
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "  ║           No changes since last sync            ║" -ForegroundColor Green
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    exit 0
}

# ============================================================
# ECC Changelog
# ============================================================

if ($eccHasChanges) {
    Write-Step "1/2" "ECC Changelog ($($eccLastSHA.Substring(0,7))..$($eccCurrentSHA.Substring(0,7)))..."
    Write-Host ""

    $eccCommits = $(git -C $ECC_DIR log "$eccLastSHA..$eccCurrentSHA" --format="%H|%ai|%an|%s" 2>$null)

    if ($eccCommits) {
        $opencodeChanges = 0
        $allChanges = @()

        foreach ($line in $eccCommits) {
            $parts = $line -split '\|', 4
            if ($parts.Length -ge 4) {
                $sha = $parts[0]
                $date = $parts[1].Split(' ')[0]
                $author = $parts[2]
                $message = $parts[3]
                $isOpencode = Test-OpencodeRelated $message

                if ($isOpencode) { $opencodeChanges++ }

                $allChanges += @{
                    date = $date
                    author = $author
                    message = $message
                    opencode = $isOpencode
                    sha = $sha
                }
            }
        }

        # Group by date
        $grouped = $allChanges | Group-Object -Property date
        foreach ($group in $grouped) {
            Write-Host "  [$($group.Name)] $($group.Count) commit(s)" -ForegroundColor White
            foreach ($commit in $group.Group) {
                $tag = if ($commit.opencode) { " ← [opencode]" } else { "" }
                $color = if ($commit.opencode) { "Yellow" } else { "Gray" }
                Write-Host "    $($commit.author)  $($commit.message)$tag" -ForegroundColor $color
            }
            Write-Host ""
        }

        if ($opencodeChanges -gt 0) {
            Write-Host "  ⚡ $opencodeChanges change(s) mempengaruhi setup (plugin, agents, config)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  (no commits found between SHAs)" -ForegroundColor Gray
    }
}

# ============================================================
# 9Router Changelog
# ============================================================

if ($routerHasChanges) {
    Write-Step "2/2" "9Router Changelog ($($routerLastSHA.Substring(0,7))..$($routerCurrentSHA.Substring(0,7)))..."
    Write-Host ""

    $routerCommits = $(git -C $ROUTER_DIR log "$routerLastSHA..$routerCurrentSHA" --format="%H|%ai|%an|%s" 2>$null)

    if ($routerCommits) {
        $opencodeChanges = 0
        $allChanges = @()

        foreach ($line in $routerCommits) {
            $parts = $line -split '\|', 4
            if ($parts.Length -ge 4) {
                $sha = $parts[0]
                $date = $parts[1].Split(' ')[0]
                $author = $parts[2]
                $message = $parts[3]
                $isOpencode = Test-OpencodeRelated $message

                if ($isOpencode) { $opencodeChanges++ }

                $allChanges += @{
                    date = $date
                    author = $author
                    message = $message
                    opencode = $isOpencode
                    sha = $sha
                }
            }
        }

        $grouped = $allChanges | Group-Object -Property date
        foreach ($group in $grouped) {
            Write-Host "  [$($group.Name)] $($group.Count) commit(s)" -ForegroundColor White
            foreach ($commit in $group.Group) {
                $tag = if ($commit.opencode) { " ← [opencode]" } else { "" }
                $color = if ($commit.opencode) { "Yellow" } else { "Gray" }
                Write-Host "    $($commit.author)  $($commit.message)$tag" -ForegroundColor $color
            }
            Write-Host ""
        }

        if ($opencodeChanges -gt 0) {
            Write-Host "  ⚡ $opencodeChanges change(s) mempengaruhi setup (RTK, caveman, config)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  (no commits found between SHAs)" -ForegroundColor Gray
    }
}

# ============================================================
# Ask user
# ============================================================

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Apakah ada perubahan berarti yang mempengaruhi setupmu?" -ForegroundColor White
Write-Host ""
Write-Host "  [1] Ya, tampilkan detail" -ForegroundColor Green
Write-Host "  [2] Tidak, skip" -ForegroundColor Gray
Write-Host "  [3] Update setup sekarang" -ForegroundColor Yellow
Write-Host ""

if ($Apply) {
    $choice = "3"
    Write-Host "  (Auto-selected: 3 - Apply mode)" -ForegroundColor Yellow
} else {
    do {
        $choice = Read-Host "  Pilih (1/2/3)"
    } while ($choice -notmatch '^[123]$')
}

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "  Detail perubahan:" -ForegroundColor Cyan
        if ($eccHasChanges) {
            Write-Host ""
            Write-Host "  ECC:" -ForegroundColor Yellow
            $(git -C $ECC_DIR log "$eccLastSHA..$eccCurrentSHA" --oneline 2>$null) | ForEach-Object {
                $isOpencode = Test-OpencodeRelated $_
                $tag = if ($isOpencode) { " ← [opencode]" } else { "" }
                Write-Host "    $_$tag" -ForegroundColor $(if ($isOpencode) { "Yellow" } else { "Gray" })
            }
        }
        if ($routerHasChanges) {
            Write-Host ""
            Write-Host "  9Router:" -ForegroundColor Yellow
            $(git -C $ROUTER_DIR log "$routerLastSHA..$routerCurrentSHA" --oneline 2>$null) | ForEach-Object {
                $isOpencode = Test-OpencodeRelated $_
                $tag = if ($isOpencode) { " ← [opencode]" } else { "" }
                Write-Host "    $_$tag" -ForegroundColor $(if ($isOpencode) { "Yellow" } else { "Gray" })
            }
        }
        Write-Host ""
        Write-Host "  Jalankan '.\setup.ps1' untuk apply perubahan." -ForegroundColor Gray
    }
    "2" {
        Write-Host ""
        Write-Host "  Skipped. SHA tidak di-update." -ForegroundColor Gray
        Write-Host "  Jalankan lagi nanti: .\sync.ps1" -ForegroundColor Gray
        exit 0
    }
    "3" {
        Write-Host ""
        Write-Host "  Updating SHA..." -ForegroundColor Yellow

        $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
        $eccVersion = (Get-Content "$ECC_DIR\VERSION" -ErrorAction SilentlyContinue)
        if (-not $eccVersion) { $eccVersion = "unknown" }

        $syncState = @{
            ecc = @{
                last_sha = $eccCurrentSHA
                last_sync = $timestamp
                repo = "fannndi/ECC"
                version = $eccVersion
            }
            "9router" = @{
                last_sha = $routerCurrentSHA
                last_sync = $timestamp
                repo = "fannndi/9router"
            }
        } | ConvertTo-Json -Depth 5

        Set-Content -Path $SYNC_STATE -Value $syncState -Encoding UTF8
        Write-OK "SHA updated to $($eccCurrentSHA.Substring(0,7)) / $($routerCurrentSHA.Substring(0,7))"
        Write-Host ""
        Write-Host "  Jalankan '.\setup.ps1' untuk apply perubahan." -ForegroundColor Gray
    }
}

Write-Host ""
