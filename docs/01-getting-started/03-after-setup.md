# Setelah Setup

## 1. Set API Key

API key dibutuhkan agar 9Router bisa menghubungkan ke provider model.

### Dari api-key.txt

Edit file `api-key.txt` di root folder:

```
# Paste API key kamu di sini
sk-xxxxxxxxxxxxxxxxxxxx
```

Lalu jalankan setup ulang:

```powershell
.\scripts\setup.ps1
```

### Manual

```powershell
# Windows
setx NINEROUTER_API_KEY "sk-xxxxxxxxxxxxxxxxxxxx"

# macOS/Linux
export NINEROUTER_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
```

## 2. Buka Dashboard 9Router

Dashboard tersedia di: `http://localhost:20128/dashboard`

- **Login:** password `123456`
- **Ganti password:** Settings → Change Password

## 3. Connect Provider

### Gratis (Recommended untuk Mulai)

1. Buka Dashboard → Providers
2. Connect "Kiro AI" (gratis, pakai Claude 4.5 + GLM-5)
3. Atau connect "OpenCode Free" (tanpa auth)

### Go (Berbayar)

1. Buka Dashboard → Providers
2. Add provider dengan API key OpenCode Go
3. Pilih model: Kimi K2.6, Qwen3.6 Plus, dll

## 4. Mulai Coding (Master Control)

```powershell
cd C:\Users\FANNNDI\Documents\opencode-setup
opencode
/start-free
/set-project C:\path\ke\project-anda
/code-analyze
/analyze-project
restart opencode
```

## 5. Analyze Project (Master Control)

Dari repo opencode-setup, tanpa perlu clone di dalam project:

```powershell
opencode
# Di OpenCode:
/start-free
/set-project C:\path\ke\project-anda   # Set project target
/analyze-project                          # Deteksi stack + load skills
```

Ini akan:
- Deteksi tipe project (Flutter, Go, React, dll)
- Load skills yang sesuai
- Generate config otomatis

## Selanjutnya

- [Commands](../04-usage/01-commands.md) — Semua perintah yang tersedia
- [Daily Workflow](../04-usage/03-daily-workflow.md) — Rutinitas harian
- [Profiles](../03-profiles/01-gratis.md) — Gratis vs Go
