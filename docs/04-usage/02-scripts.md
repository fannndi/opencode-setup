# Scripts — Referensi

## Daftar Scripts

| Script | Platform | Fungsi |
|--------|----------|--------|
| `setup.ps1` | Windows | Full setup (clone + install + config) |
| `setup.sh` | macOS/Linux | Full setup |
| `install.ps1` | Windows | Quick re-apply config |
| `install.sh` | macOS/Linux | Quick re-apply |
| `clone.ps1` | Windows | Clone ECC + 9Router |
| `clone.sh` | macOS/Linux | Clone repos |
| `sync.ps1` | Windows | Sync changelog |
| `sync.sh` | macOS/Linux | Sync changelog |
| `start.ps1` | Windows | Daily workflow |
| `start.sh` | macOS/Linux | Daily workflow |
| `analyze-project.ps1` | Windows | Deteksi stack |
| `analyze-project.sh` | macOS/Linux | Deteksi stack |

## setup.ps1 / setup.sh

Full setup dari nol.

```powershell
.\scripts\setup.ps1
```

**Yang dilakukan:**
1. Pre-flight checks (Node.js, npm, git)
2. Clone ECC + 9Router repos
3. Install dependencies
4. Build OpenCode plugin
5. Generate config
6. Copy rules
7. Set environment variables
8. Start 9Router

## install.ps1 / install.sh

Quick re-apply config.

```powershell
.\scripts\install.ps1 -Profile gratis
.\scripts\install.ps1 -Profile go
```

**Opsi:**
- `-Profile gratis|go` — Pilih profile
- `-SyncFirst` — Sync changelog dulu

## clone.ps1 / clone.sh

Clone ECC + 9Router repos.

```powershell
.\scripts\clone.ps1
```

## sync.ps1 / sync.sh

Sync changelog dari repos.

```powershell
.\scripts\sync.ps1
```

## start.ps1 / start.sh

Daily workflow.

```powershell
.\scripts\start.ps1 -Profile gratis
.\scripts\start.ps1 -Profile go
```

**Yang dilakukan:**
1. Check repos (clone/pull)
2. Sync changelog
3. Analyze updates → auto rebuild jika perlu
4. Test 9Router → auto-start jika mati
5. Test models → kirim "hi"
6. Apply profile
7. Ready summary

## analyze-project.ps1 / analyze-project.sh

Deteksi stack project.

```powershell
.\scripts\analyze-project.ps1
```

**Yang dilakukan:**
1. Locate project root (1 level up)
2. Scan for indicators
3. Match stack (dart-flutter, golang, dll)
4. Load skills
5. Generate config

## Lihat Juga

- [Commands](01-commands.md) — Referensi commands
- [Daily Workflow](03-daily-workflow.md) — Rutinitas harian
