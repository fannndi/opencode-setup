# Scripts — Referensi

## Daftar Scripts (31 file)

| Script | Platform | Fungsi |
|--------|----------|--------|
| `setup.ps1` / `.sh` | Both | Full setup (clone + install + config) |
| `install.ps1` / `.sh` | Both | Quick re-apply config |
| `clone.ps1` / `.sh` | Both | Clone ECC + 9Router |
| `sync.ps1` / `.sh` | Both | Sync changelog |
| `start.ps1` / `.sh` | Both | Daily workflow (session-aware) |
| `auto-start.ps1` | Win | Chain semua workflow 1 command |
| `full-start.ps1` | Win | Start → code-analyze → ready |
| `admin-update.ps1` | Win | Update ECC/9Router + doctor |
| `analyze-project.ps1` / `.sh` | Both | Deteksi stack + load skills |


| `project-skills.ps1` | Win | Lihat skills yang cocok |
| `research.ps1` / `.sh` | Both | Web search + AI ringkasan |
| `generate-prd.ps1` | Win | Ide → PRD otomatis |
| `wizard.ps1` | Win | Panduan interaktif pemula |
| `quality-gate.ps1` | Win | Verify fixes, track iterations |
| `token-tracker.ps1` | Win | Token usage + session stats |
| `memory.ps1` | Win | Simpan/baca memori session |
| `session-manager.ps1` | Win | Session management |
| `template-loader.ps1` / `.sh` | Both | Load project template |
| `create.ps1` | Win | Generate boilerplate |

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

## start.ps1 / start.sh

Daily workflow. Session-aware + auto-heal + auto-update.

```powershell
.\scripts\start.ps1 -Profile gratis
.\scripts\start.ps1 -Profile go
```

**Yang dilakukan:**
1. Self-healing check (9Router, ECC, plugin, session)
2. Auto-update (pull ECC/9Router, rebuild plugin)
3. Check repos
4. Sync changelog
5. Test models
6. Apply profile
7. Save session

## auto-start.ps1

Chain semua workflow dalam 1 command.

```powershell
.\scripts\auto-start.ps1 -Profile gratis -Mode existing -ProjectPath "C:\project"
```

**Yang dilakukan:**
1. Start workflow
2. Code-analyze (atau project-analyze)
3. Analyze-project
4. Save memory

## admin-update.ps1

Update ECC + 9Router + doctor check.

```powershell
.\scripts\admin-update.ps1
```

**Yang dilakukan:**
1. Pull ECC
2. Pull 9Router
3. Rebuild plugin (jika perlu)
4. Doctor check
5. Save admin log

## analyze-project.ps1 / analyze-project.sh

Deteksi stack project.

```powershell
.\scripts\analyze-project.ps1 -ProjectPath "C:\project"
```

## code-analyze.ps1 / code-analyze.sh



```powershell
.\scripts\code-analyze.ps1 -ProjectPath "C:\project"
```

## research.ps1 / research.sh

Web search + AI ringkasan.

```powershell
.\scripts\research.ps1 -Query "Flutter best practices"
```

## wizard.ps1

Panduan interaktif untuk pemula. Tanya-jawab, auto setup.

```powershell
.\scripts\wizard.ps1
```

## Lihat Juga

- [Commands](01-commands.md) — Referensi commands
- [Daily Workflow](03-daily-workflow.md) — Rutinitas harian

