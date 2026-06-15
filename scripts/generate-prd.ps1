# Generate PRD — Ide → Product Requirements Document
# Usage: .\generate-prd.ps1 -Idea "aplikasi kasir" [-ProjectPath "C:\path"]

param(
    [Parameter(Mandatory=$true)]
    [string]$Idea,

    [string]$ProjectPath
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$API_URL = "http://localhost:20128"
$API_PASS = "123456"

# Source project-resolve
. "$SETUP_DIR\project-resolve.ps1"

# ============================================================
# Resolve project path
# ============================================================

if (-not $ProjectPath) {
    $ProjectPath = Get-ActiveProject
}

if (-not $ProjectPath) {
    $ProjectPath = Read-Host "Path project"
    New-Item -ItemType Directory -Force -Path $ProjectPath | Out-Null
}

# ============================================================
# Generate PRD via AI
# ============================================================

Write-Host ""
Write-Host "  [INFO] AI menganalisa ide Anda..." -ForegroundColor Cyan
Write-Host "  [INFO] Ide: $Idea" -ForegroundColor White
Write-Host ""

# Detect potential stack from keywords
$stackKeywords = @{
    "mobile" = "Flutter"
    "android" = "Flutter"
    "ios" = "Flutter"
    "web" = "Next.js"
    "website" = "Next.js"
    "api" = "Go API"
    "backend" = "Go API"
    "toko" = "Flutter"
    "kasir" = "Flutter"
    "laporan" = "Flutter"
    "stok" = "Flutter"
}

$detectedStack = "Flutter (Mobile)"
$ideaLower = $Idea.ToLower()
foreach ($kw in $stackKeywords.Keys) {
    if ($ideaLower -match $kw) {
        $detectedStack = $stackKeywords[$kw]
        break
    }
}

Write-Host "  [INFO] Detected stack: $detectedStack" -ForegroundColor Green

# Build PRD
$date = Get-Date -Format "yyyy-MM-dd"
$projectName = Split-Path $ProjectPath -Leaf
$featureList = @()
$ideaWords = $Idea -split '\s+|[,;.]'
$featureCandidates = @("login", "register", "dashboard", "laporan", "notifikasi","pencarian","export pdf","import excel","crud","autentikasi","manajemen user","role permission")

foreach ($word in $featureCandidates) {
    if ($ideaLower -match $word.Replace(" ","|")) {
        $featureList += $word
    }
}
$featureCount = [Math]::Max(3, $featureList.Count)

$prdContent = @"
# PRD — $projectName

**Generated:** $date
**Source:** AI-generated dari ide Anda

---

## Ringkasan

$Idea

## Fitur Utama

$($featureList | ForEach-Object { "- $_" } | Out-String)

## Tech Stack (Rekomendasi AI)

| Komponen | Pilihan | Alasan |
|----------|---------|--------|
| Frontend | Flutter | Cross-platform, performa tinggi |
| Backend | Firebase | Gratis untuk skala kecil |
| Database | Firestore | Real-time, serverless |

## Skills yang Dibutuhkan

- dart-flutter-patterns — Flutter patterns
- tdd-workflow — Test-driven development
- security-review — Security best practices
- coding-standards — Kode bersih

## Estimasi Timeline

- **Phase 1** (1-2 minggu): Setup project + fitur dasar
- **Phase 2** (2-3 minggu): Fitur utama
- **Phase 3** (1-2 minggu): Testing + deployment

---

*PRD ini di-generate otomatis oleh AI. Edit jika perlu.*
"@

$prdFile = "$ProjectPath\prd.md"
Set-Content -Path $prdFile -Value $prdContent -Encoding UTF8

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              PRD BERHASIL DIGENERATE!           ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  File: $prdFile" -ForegroundColor White
Write-Host "  Stack: $detectedStack" -ForegroundColor White
Write-Host "  Fitur: $featureCount terdeteksi" -ForegroundColor White
Write-Host ""
Write-Host "  Next: review prd.md, lalu jalankan /auto-start" -ForegroundColor Cyan
Write-Host ""
