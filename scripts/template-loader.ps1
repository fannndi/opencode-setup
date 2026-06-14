# Template Loader — Copy template docs ke project
# Usage: .\template-loader.ps1 -Template flutter-firebase|go-api|nextjs-fullstack|python-fastapi

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("flutter-firebase", "go-api", "nextjs-fullstack", "python-fastapi")]
    [string]$Template
)

$ErrorActionPreference = "Stop"

$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR
$TEMPLATE_DIR = "$ROOT_DIR\templates\$Template"
$PROJECT_DIR = Split-Path -Parent $ROOT_DIR

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "  ║         Template Loader: $Template$( ' ' * (24 - $Template.Length))║" -ForegroundColor Magenta
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""

# Step 1: Check template exists
Write-Host "  [1/3] Checking template..." -ForegroundColor Cyan
if (-not (Test-Path "$TEMPLATE_DIR\template.md")) {
    Write-Host "  [FAIL] Template not found: $TEMPLATE_DIR" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Template found" -ForegroundColor Green

# Step 2: Read template
Write-Host "  [2/3] Reading template..." -ForegroundColor Cyan
$templateContent = Get-Content "$TEMPLATE_DIR\template.md" -Raw
Write-Host "  [OK] Template loaded" -ForegroundColor Green

# Step 3: Apply template
Write-Host "  [3/3] Applying template..." -ForegroundColor Cyan

# Create docs structure based on template
$docsDir = "$PROJECT_DIR\docs"

# Create docs subdirectories based on template type
switch ($Template) {
    "flutter-firebase" {
        New-Item -ItemType Directory -Path "$docsDir\frontend" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\backend" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\database" -Force | Out-Null
        Write-Host "  [OK] Created: docs/frontend, docs/backend, docs/database" -ForegroundColor Green
    }
    "go-api" {
        New-Item -ItemType Directory -Path "$docsDir\api" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\database" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\deployment" -Force | Out-Null
        Write-Host "  [OK] Created: docs/api, docs/database, docs/deployment" -ForegroundColor Green
    }
    "nextjs-fullstack" {
        New-Item -ItemType Directory -Path "$docsDir\frontend" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\backend" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\database" -Force | Out-Null
        Write-Host "  [OK] Created: docs/frontend, docs/backend, docs/database" -ForegroundColor Green
    }
    "python-fastapi" {
        New-Item -ItemType Directory -Path "$docsDir\api" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\database" -Force | Out-Null
        New-Item -ItemType Directory -Path "$docsDir\deployment" -Force | Out-Null
        Write-Host "  [OK] Created: docs/api, docs/database, docs/deployment" -ForegroundColor Green
    }
}

# Copy template guide to project
Copy-Item "$TEMPLATE_DIR\template.md" "$docsDir\TEMPLATE-GUIDE.md" -Force
Write-Host "  [OK] Copied template guide to docs/TEMPLATE-GUIDE.md" -ForegroundColor Green

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║              Template Applied!                   ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  Project:  $PROJECT_DIR" -ForegroundColor White
Write-Host "  Template: $Template" -ForegroundColor White
Write-Host "  Docs:     $docsDir" -ForegroundColor White
Write-Host ""
Write-Host "  Next: isi docs/ sesuai prd.md + ai-notes.md" -ForegroundColor Cyan
Write-Host ""
