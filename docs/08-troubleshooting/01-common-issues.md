# Troubleshooting — FAQ

## 9Router

### 9Router tidak mau start

```powershell
# Cek apakah sudah running
Get-NetTCPConnection -LocalPort 20128

# Jika sudah running, stop dulu
Get-Process -Name "node" | Where-Object { $_.CommandLine -match "9router" } | Stop-Process

# Start ulang
Start-Process "9router" -WindowStyle Minimized
Start-Sleep 4

# Verify
curl http://localhost:20128/api/health
```

### Health check gagal

```powershell
# Cek port
Get-NetTCPConnection -LocalPort 20128

# Cek process
Get-Process -Name "node" | Where-Object { $_.CommandLine -match "9router" }

# Jika tidak ada, start ulang
Start-Process "9router" -WindowStyle Minimized
```

### Login gagal

```
Password default: 123456
Dashboard: http://localhost:20128/dashboard
```

## Model Errors

### 429 Too Many Requests

Model kena rate limit. Solusi:

1. Tunggu beberapa menit
2. Combo akan otomatis pindah ke model berikutnya
3. Atau switch profile

### 503 Service Unavailable

Model sedang down. Solusi:

1. Combo akan otomatis pindah ke model berikutnya
2. Atau switch profile

### Model tidak dikenali

```powershell
# Cek models yang tersedia
Invoke-RestMethod "http://localhost:20128/v1/models" | Select-Object -ExpandProperty data | Select-Object id
```

## Config

### Config tidak ter-update

```powershell
# Cek config aktif
Get-Content "$env:USERPROFILE\.config\opencode\opencode.jsonc" | ConvertFrom-Json | Select-Object model

# Restart OpenCode
# Ctrl+C, lalu:
opencode
```

### Skills tidak load

```powershell
# Cek skills.paths di config
Get-Content "$env:USERPROFILE\.config\opencode\opencode.jsonc" | ConvertFrom-Json | Select-Object -ExpandProperty skills

# Pastikan path benar
Test-Path "C:\Users\FANNNDI\Documents\opencode-setup\ecc\skills"
```

## Build Errors

### ECC plugin build gagal

```powershell
cd ecc
npm install --silent
cd .opencode
npm install --silent
cd ..
npm run build:opencode
```

### Node modules missing

```powershell
cd ecc
npm install
cd .opencode
npm install
```

## API Key

### NINEROUTER_API_KEY tidak set

```powershell
# Windows
setx NINEROUTER_API_KEY "sk-xxxxxxxxxxxx"

# macOS/Linux
export NINEROUTER_API_KEY="sk-xxxxxxxxxxxx"
```

### API key invalid

1. Buka Dashboard → Endpoint
2. Create new key
3. Copy key
4. Set environment variable

## General

### OpenCode tidak dikenali

```bash
npm install -g opencode
```

### Git tidak dikenali

Download dari: https://git-scm.com

### Node.js tidak dikenali

Download dari: https://nodejs.org

## Masih Error?

1. Cek [CHANGELOG](../../CHANGELOG.md) untuk info update terbaru
2. Jalankan `.\scripts\session-manager.ps1 -Action status` untuk cek session
3. Jalankan `.\scripts\start.ps1 -Profile gratis` untuk reset workflow
4. Buka issue di GitHub
