@echo off
title OpenCode AI Setup
color 0A
cls

echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║       OpenCode AI Coding Studio — Installer      ║
echo  ║         Biaya: $0  |  Tanpa Coding               ║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo  Installer akan mengecek dan menginstall otomatis:
echo    1. Node.js (runtime)
echo    2. Git (version control)
echo    3. OpenCode (AI coding CLI)
echo    4. ECC (270+ skills)
echo    5. 9Router (AI gateway)
echo    6. Config & Dashboard
echo.
echo  Butuh koneksi internet untuk install pertama kali.
echo.
pause
cls

:: ============================================================
:: Step 1: Check Node.js
:: ============================================================
echo [1/6] Mengecek Node.js...
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo   [INSTALL] Node.js tidak ditemukan. Menginstall...
    echo   Download dari https://nodejs.org (v20 LTS)
    echo   Atau jalankan perintah berikut manual:
    echo   curl -o node-install.msi https://nodejs.org/dist/v20.11.0/node-v20.11.0-x64.msi
    echo   node-install.msi /quiet
    echo.
    echo   Setelah install, jalankan installer ini lagi.
    echo.
    timeout /t 10
    start https://nodejs.org
    exit /b 1
) else (
    for /f "tokens=*" %%a in ('node --version') do echo   [OK] Node.js %%a
)

:: ============================================================
:: Step 2: Check Git
:: ============================================================
echo [2/6] Mengecek Git...
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo   [INSTALL] Git tidak ditemukan. Download dari:
    echo   https://git-scm.com
    timeout /t 5
    start https://git-scm.com
    exit /b 1
) else (
    for /f "tokens=*" %%a in ('git --version') do echo   [OK] %%a
)

:: ============================================================
:: Step 3: Check/Install OpenCode
:: ============================================================
echo [3/6] Mengecek OpenCode...
where opencode >nul 2>nul
if %errorlevel% neq 0 (
    echo   [INSTALL] Menginstall OpenCode via npm...
    call npm install -g opencode
    if %errorlevel% neq 0 (
        echo   [ERROR] Gagal install OpenCode. Jalankan manual:
        echo   npm install -g opencode
        pause
        exit /b 1
    )
) else (
    echo   [OK] OpenCode terinstall
)

:: ============================================================
:: Step 4: Clone/Update opencode-setup
:: ============================================================
echo [4/6] Clone opencode-setup...
if exist "opencode-setup\.git" (
    echo   [OK] Sudah ada. Update terbaru...
    cd opencode-setup
    git pull --quiet
    cd ..
) else (
    echo   [INFO] Clone repo...
    git clone --quiet https://github.com/fannndi/opencode-setup.git
    if exist "opencode-setup\.git" (
        echo   [OK] Clone berhasil
    ) else (
        echo   [ERROR] Gagal clone. Cek koneksi internet.
        pause
        exit /b 1
    )
)

:: ============================================================
:: Step 5: Run Setup
:: ============================================================
echo [5/6] Setup ECC + 9Router...
cd opencode-setup
powershell -ExecutionPolicy Bypass -File "scripts\setup.ps1"
cd ..

:: ============================================================
:: Step 6: Done
:: ============================================================
cls
echo.
echo  ╔══════════════════════════════════════════════════╗
echo  ║              INSTALLASI SELESAI!                 ║
echo  ╚══════════════════════════════════════════════════╝
echo.
echo  Yang sudah terinstall:
echo     / Node.js + Git + OpenCode
echo     / ECC (270 skills)
echo     / 9Router (AI gateway)
echo     / Config siap pakai
echo.
echo  Cara pakai:
echo  ──────────────────────────────────────────
echo  1. Buka terminal di folder ini
echo  2. Ketik: opencode
echo  3. Di OpenCode, ketik: /wizard
echo  4. Jawab pertanyaan AI
echo  5. Selesai! AI bantu bikin project Anda
echo.
echo  Atau langsung:
echo     opencode
echo     /start-free
echo     /wizard
echo.
timeout /t 15
exit /b 0
