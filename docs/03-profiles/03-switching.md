# Switching Profile

## Cara Ganti Profile

### Method 1: Script Restore

```powershell
# Switch ke gratis
.\profiles\gratis\restore.ps1

# Switch ke go
.\profiles\go\restore.ps1
```

### Method 2: Start Script

```powershell
# Switch ke gratis
.\scripts\start.ps1 -Profile gratis

# Switch ke go
.\scripts\start.ps1 -Profile go
```

### Method 3: OpenCode Command

```
/start-free    # Switch ke gratis
/start-go      # Switch ke go
```

### Method 4: Manual Copy

```powershell
# Backup config lama
Copy-Item "$env:USERPROFILE\.config\opencode\opencode.jsonc" `
  "$env:USERPROFILE\.config\opencode\opencode.jsonc.bak"

# Copy config baru
Copy-Item "profiles\gratis\opencode.jsonc" `
  "$env:USERPROFILE\.config\opencode\opencode.jsonc"
```

## Yang Terjadi Saat Switch

1. Config lama di-backup
2. Config baru di-copy
3. Environment variable di-update
4. Restart OpenCode untuk apply

## Verifikasi

```powershell
# Cek config aktif
Get-Content "$env:USERPROFILE\.config\opencode\opencode.jsonc" | ConvertFrom-Json | Select-Object model
```

## Troubleshooting

### Config tidak ter-update

```powershell
# Restart OpenCode
# Ctrl+C dulu, lalu:
opencode
```

### Model tidak work

```powershell
# Cek 9Router running
curl http://localhost:20128/api/health

# Jika tidak running, start:
Start-Process "9router" -WindowStyle Minimized
```

## Lihat Juga

- [Gratis](01-gratis.md) — Detail gratis profile
- [Go](02-go.md) — Detail go profile
