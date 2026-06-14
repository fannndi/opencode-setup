# Daily Workflow — Rutinitas Harian

## Alur Kerja Harian

```
1. cd my-project
2. cd opencode-setup
3. opencode
4. /start-free (atau /start-go)
5. Mulai coding!
```

## Yang Dilakukan /start-free

```
[1/7] Checking repositories...
  [OK] ECC: pulled latest
  [OK] 9Router: pulled latest

[2/7] Syncing changelog...
  [OK] 3 new commits

[3/7] Analyzing updates...
  [OK] Plugin rebuild not needed

[4/7] Testing 9Router...
  [OK] Auto-started on port 20128
  [OK] Health check passed

[5/7] Testing models...
  [OK] oc/mimo-v2.5-free: responding

[6/7] Applying profile...
  [OK] Config: gratis → ~/.config/opencode/opencode.jsonc

[7/7] Ready!
```

## Tanpa Start Script

Jika sudah yakin semua berjalan:

```powershell
cd my-project
opencode
```

Langsung mulai coding tanpa `/start-free`.

## Kapan Perlu /start-free

| Situasi | Perlu? |
|---------|--------|
| Pertama kali buka hari ini | Ya |
| Setelah pull update ECC | Ya |
| 9Router mati | Ya (auto-start) |
| Ganti profile | Ya |
| Sudah jalan, lanjut coding | Tidak |

## Update ECC

```powershell
# Cek perubahan
.\scripts\sync.ps1

# Apply perubahan
.\scripts\setup.ps1

# Atau via OpenCode
/start-free
```

## Lihat Juga

- [Commands](01-commands.md) — Semua commands
- [Scripts](02-scripts.md) — Semua scripts
- [Analyze Project](04-analyze-project.md) — Deteksi stack
