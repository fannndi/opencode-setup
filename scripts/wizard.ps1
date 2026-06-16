# Wizard — Panduan interaktif untuk orang awam
# Usage: .\wizard.ps1

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"
. "$SETUP_DIR\llm-adapter.ps1"

function Write-Header {
    param([string]$Title)
    Clear-Host
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Cyan
    $len = $Title.Length
    $pad = [Math]::Max(0, (50 - $len) / 2)
    Write-Host ("  ║" + " " * [Math]::Floor($pad) + $Title + " " * [Math]::Ceiling($pad) + "║") -ForegroundColor Cyan
    Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Num, [string]$Text)
    Write-Host "  [$Num] $Text" -ForegroundColor Yellow
}

function Wait-Key {
    Write-Host ""
    Write-Host "  Tekan Enter untuk lanjut..." -ForegroundColor Gray
    $null = Read-Host
}

# ============================================================
# START
# ============================================================

Write-Header "Selamat datang di AI Coding Studio!"
Write-Host "  Saya akan bantu Anda membuat aplikasi" -ForegroundColor White
Write-Host "  tanpa perlu bisa coding. GRATIS." -ForegroundColor White
Write-Host ""
Write-Host "  Yang Anda butuhkan:" -ForegroundColor Gray
Write-Host "  • Ide aplikasi" -ForegroundColor Gray
Write-Host "  • Koneksi internet" -ForegroundColor Gray
Write-Host "  • 10 menit" -ForegroundColor Gray
Wait-Key

# ============================================================
# Step 1: Mode
# ============================================================

Write-Header "Langkah 1: Pilih Mode"
Write-Host "  Apa yang ingin Anda lakukan?" -ForegroundColor White
Write-Host ""
Write-Host "  1. BIKIN PROJECT BARU — dari nol" -ForegroundColor Green
Write-Host "     (cocok untuk ide aplikasi baru)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. IMPROVE PROJECT — yang sudah ada" -ForegroundColor Yellow
Write-Host "     (tambah fitur, review kode, fix bug)" -ForegroundColor Gray
Write-Host ""

do {
    $mode = Read-Host "  Pilih (1/2)"
} while ($mode -notmatch '^[12]$')

$llmResponse = Invoke-LLMEnrich -Text "User chose mode '$mode' (1=new project, 2=improve existing). Give a brief encouraging adaptive follow-up in Indonesian: $mode"
Write-Host "  [LLM] $llmResponse" -ForegroundColor Cyan

# ============================================================
# Step 2: Project name/path
# ============================================================

Write-Header "Langkah 2: Nama Project"

if ($mode -eq "1") {
    Write-Host "  Beri nama project Anda:" -ForegroundColor White
    Write-Host "  (contoh: aplikasi-kasir, toko-online, dll)" -ForegroundColor Gray
    $projectName = Read-Host "  Nama"
    if (-not $projectName) { $projectName = "my-app" }
    $projectPath = "$env:USERPROFILE\Documents\$projectName"
    New-Item -ItemType Directory -Force -Path $projectPath | Out-Null
    Write-Host "  [OK] Folder dibuat: $projectPath" -ForegroundColor Green
} else {
    Write-Host "  Masukkan path folder project Anda:" -ForegroundColor White
    Write-Host "  (contoh: C:\Users\nama\Documents\my-app)" -ForegroundColor Gray
    do {
        $projectPath = Read-Host "  Path"
    } while (-not $projectPath -or -not (Test-Path $projectPath))
    $projectName = Split-Path $projectPath -Leaf
    Write-Host "  [OK] Project ditemukan: $projectName" -ForegroundColor Green
}

$llmResponse = Invoke-LLMEnrich -Text "User created/selected project '$projectName' at '$projectPath' in mode '$mode'. Give a brief relevant follow-up question in Indonesian about what they want to build."
Write-Host "  [LLM] $llmResponse" -ForegroundColor Cyan

# Save to session
try {
    Resolve-Project -Path $projectPath | Out-Null
    Set-ActiveProject -Path $projectPath
} catch {}

Wait-Key

# ============================================================
# Step 3: Describe idea (for new projects)
# ============================================================

if ($mode -eq "1") {
    Write-Header "Langkah 3: Ceritakan Ide Anda"
    Write-Host "  Jelaskan aplikasi yang ingin dibuat:" -ForegroundColor White
    Write-Host "  Contoh: Aplikasi kasir untuk toko kelontong dengan" -ForegroundColor Gray
    Write-Host "  fitur catat stok, laporan harian, dan cetak struk" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Semakin detail semakin baik." -ForegroundColor Gray
    Write-Host ""
    $idea = Read-Host "  Ide Anda"
    
    Write-Host ""
    Write-Host "  [INFO] AI sedang memproses ide Anda..." -ForegroundColor Cyan
    
    $llmResponse = Invoke-LLMEnrich -Text "User described this app idea: $idea. Give brief helpful refinement advice in Indonesian (2-3 sentences)."
    Write-Host "  [LLM] $llmResponse" -ForegroundColor Cyan

    # Generate PRD otomatis
    & "$SETUP_DIR\generate-prd.ps1" -Idea $idea -ProjectPath $projectPath
    
    Wait-Key
} else {
    Write-Header "Langkah 3: Analisa Project"
    Write-Host "  [INFO] AI sedang menganalisa project Anda..." -ForegroundColor Cyan
    
    $llmResponse = Invoke-LLMEnrich -Text "User is analyzing existing project at '$projectPath'. Give brief relevant advice in Indonesian for improving existing code."
    Write-Host "  [LLM] $llmResponse" -ForegroundColor Cyan

    & "$SETUP_DIR\code-analyze.ps1" -ProjectPath $projectPath
    Wait-Key
}

# ============================================================
# Step 4: Start workflow
# ============================================================

Write-Header "Langkah 4: Siap-siap!"
Write-Host "  AI sudah siap membantu Anda!" -ForegroundColor Green
Write-Host ""
Write-Host "  Berikut yang sudah disiapkan:" -ForegroundColor White
Write-Host "  • Project : $projectName" -ForegroundColor White
if ($mode -eq "1") { Write-Host "  • PRD     : prd.md (sudah dibuat AI)" -ForegroundColor White }
Write-Host "  • Skills  : siap di-load" -ForegroundColor White
Write-Host ""
Write-Host "  Mulai workflow:" -ForegroundColor Yellow
& "$SETUP_DIR\start.ps1" -Profile gratis

# ============================================================
# Step 5: Done
# ============================================================

Write-Header "SELESAI! 🎉"
Write-Host "  Project Anda siap dikerjakan!" -ForegroundColor Green
Write-Host ""
Write-Host "  Langkah selanjutnya:" -ForegroundColor White
Write-Host "  1. Buka terminal di folder opencode-setup" -ForegroundColor White
Write-Host "  2. Ketik: opencode" -ForegroundColor White
Write-Host "  3. Di OpenCode, ketik command berikut:" -ForegroundColor White
Write-Host ""

if ($mode -eq "1") {
    Write-Host "     /plan -- buat rencana implementasi" -ForegroundColor Cyan
    Write-Host "     /tdd -- mulai coding" -ForegroundColor Cyan
    Write-Host "     /code-review -- review hasil" -ForegroundColor Cyan
} else {
    Write-Host "     /code-review -- review kode yang ada" -ForegroundColor Cyan
    Write-Host "     /security -- cek keamanan" -ForegroundColor Cyan
    Write-Host "     /tdd -- tambah fitur baru" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  Butuh bantuan? Ketik /wizard lagi" -ForegroundColor Yellow
Write-Host ""
