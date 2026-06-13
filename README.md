# OpenCode Full Setup

One command setup: ECC (agents/skills) + 9Router (RTK/Caveman/auto-fallback).

```
[OpenCode] → [9Router] → [Provider]
               │
               ├── RTK: compress tool output (-20-40% tokens)
               ├── Caveman: terse replies (-65% output tokens)
               └── Auto-fallback: subscription → cheap → free
```

## Commands

| Command | Description |
|---------|-------------|
| `clone-repo.ps1` | Clone ECC + 9Router repos |
| `sync-changelog.ps1` | Show changes since last sync |
| `setup.ps1` | Full setup (clone + config + start) |
| `install.ps1 -Profile gratis` | Quick re-apply config |

## Daily Workflow

```powershell
# First time / fresh install
.\clone-repo.ps1
.\sync-changelog.ps1
.\setup.ps1

# Check for updates
.\sync-changelog.ps1

# Apply updates
.\setup.ps1

# Quick re-apply (ganti profile)
.\install.ps1 -Profile go
.\install.ps1 -Profile gratis -SyncFirst
```

## Two Install Paths

| Path | Script | When to use |
|------|--------|-------------|
| **Full setup** | `setup.ps1` | Laptop baru — clone + install dari nol |
| **Quick re-apply** | `install.ps1 -Profile go` | Ganti profile / pindah laptop tanpa re-clone |

## Quick Start (Full Setup)

### Windows (PowerShell)

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\setup.ps1
```

### macOS / Linux

```bash
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
chmod +x setup.sh
./setup.sh
```

## Quick Re-Apply (Sudah Clone Sebelumnya)

```powershell
# Ganti profile
.\install.ps1 -Profile go

# Atau
.\install.ps1 -Profile gratis
```

Config lama otomatis di-backup.

## What It Does

Setup script will automatically:

1. Clone ECC (agents/skills/hooks) from `fannndi/ECC`
2. Clone 9Router (RTK/Caveman/fallback) from `fannndi/9router`
3. Install & build ECC OpenCode plugin
4. Install 9Router globally
5. Ask your profile (free / go / custom)
6. Generate `opencode.jsonc` with 9Router as proxy
7. Copy language rules (common + TS + Python + Go)
8. Set environment variables
9. Start 9Router
10. Open dashboard

## Profiles

| Profile | Models | Cost |
|---------|--------|------|
| **free** | MiMo V2.5, DeepSeek V4 Flash, Kiro Claude 4.5 | $0 |
| **go** | Kimi K2.7, Qwen3.7 Max, DeepSeek V4 Pro | $5/mo first month |
| **custom** | Your provider + model | Varies |

## After Setup

### 1. Connect Provider (in 9Router Dashboard)

Dashboard opens automatically at `http://localhost:20128/dashboard`

- **Login:** password `123456`
- **Free option:** Connect "Kiro AI" (free Claude 4.5 + GLM-5 + MiniMax)
- **Free option:** Connect "OpenCode Free" (no auth, auto-fetch models)
- **Go option:** Add your OpenCode Go API key

### 2. Create API Key

Go to **Endpoint** page → **Create Key** → copy the key

### 3. Set API Key

```powershell
# Windows
setx NINEROUTER_API_KEY "your-key-here"

# macOS/Linux
export NINEROUTER_API_KEY="your-key-here"
```

### 4. Start Coding

```bash
opencode
```

## Commands

| Command | Agent | Description |
|---------|-------|-------------|
| `/plan` | planner | Implementation plan |
| `/tdd` | tdd-guide | TDD workflow |
| `/code-review` | code-reviewer | Code review |
| `/security` | security-reviewer | Security review |
| `/build-fix` | build-error-resolver | Fix build errors |
| `/e2e` | e2e-runner | E2E tests |
| `/go-review` | go-reviewer | Go code review |
| `/go-test` | tdd-guide | Go TDD |
| `/orchestrate` | planner | Multi-agent workflow |
| `/learn` | — | Extract patterns |
| `/checkpoint` | — | Save progress |
| `/verify` | — | Verification loop |

## Token Savings

| Feature | Source | Savings |
|---------|--------|---------|
| RTK Token Saver | 9Router | -20-40% input tokens |
| Caveman Mode | 9Router | -65% output tokens |
| Free providers | 9Router | $0 cost |
| Auto-fallback | 9Router | Zero downtime |
| **Combined** | | **~70-80% total** |

## Update

```bash
cd opencode-setup

# Pull latest ECC + 9Router
cd ecc && git pull && cd ..
cd 9router && git pull && cd ..

# Rebuild ECC plugin
cd ecc && npm run build:opencode && cd ..

# Re-run setup (keeps your profile)
.\setup.ps1    # Windows
./setup.sh     # macOS/Linux
```

## File Structure

```
opencode-setup/
├── README.md              # This file
├── clone-repo.ps1         # Clone ECC + 9Router (Windows)
├── clone-repo.sh          # Clone ECC + 9Router (macOS/Linux)
├── sync-changelog.ps1     # Show changes since last sync (Windows)
├── sync-changelog.sh      # Show changes since last sync (macOS/Linux)
├── setup.ps1              # Full auto setup (Windows)
├── setup.sh               # Full auto setup (macOS/Linux)
├── install.ps1            # Quick re-apply (Windows)
├── install.sh             # Quick re-apply (macOS/Linux)
├── caveman-mode.md        # Caveman Mode reference
├── .sync-state.json       # SHA tracking (committed for zip backup)
├── profiles/
│   ├── gratis/
│   │   └── opencode.jsonc # Static config: free models
│   └── go/
│       └── opencode.jsonc # Static config: Go models
├── ecc/                   # ECC fork (auto-cloned)
│   ├── .opencode/         # OpenCode plugin
│   ├── agents/            # 64 specialized agents
│   ├── skills/            # 262 workflow skills
│   ├── commands/          # 84 command shims
│   ├── rules/             # Language rules
│   ├── hooks/             # Event automations
│   └── fanndi/            # Your setup profiles
└── 9router/               # 9Router (auto-cloned)
    ├── src/               # Router source
    └── dashboard/         # Web UI
```

## Profiles Reference

### Gratis (Free)

| Agent | Model |
|-------|-------|
| build (primary) | `9router/oc/mimo-v2.5-free` |
| planner, architect | `9router/oc/deepseek-v4-flash-free` |
| code-reviewer, security | `9router/oc/deepseek-v4-flash-free` |
| build-error-resolver | `9router/oc/mimo-v2.5-free` |

Fallback chain: MiMo → DeepSeek → Kiro Claude 4.5 (free Claude!)

### Go ($5/mo first month)

| Agent | Model |
|-------|-------|
| build (primary) | `9router/go/kimi-k2.7` |
| planner, architect | `9router/go/qwen3.7-max` |
| code-reviewer, security | `9router/go/deepseek-v4-pro` |
| build-error-resolver | `9router/go/deepseek-v4-flash` |

Fallback chain: Kimi → Qwen → DeepSeek → OpenCode Free

## Caveman Mode

Terse-style prompting. Same technical accuracy, fewer tokens.

| Before | After |
|--------|-------|
| "I've analyzed the code and found that there's a missing null check..." | "Missing null check in auth.ts:42. Fix: `const token = user?.token ?? '';`" |
| ~200-500 tokens/response | ~50-150 tokens/response |

Caveman Mode is handled by 9Router (not ECC). Toggle in Dashboard → Endpoint settings.

## Troubleshooting

### 9Router not starting

```bash
# Run manually
9router

# Or check port
lsof -i :20128    # macOS/Linux
netstat -ano | findstr :20128    # Windows
```

### "model not found" error

Query available models:
```powershell
Invoke-RestMethod -Uri "http://127.0.0.1:20128/v1/models" -Headers @{Authorization="Bearer $env:NINEROUTER_API_KEY"} | Select-Object -ExpandProperty data | Select-Object id
```

### RTK not compressing

Check Dashboard → Endpoint settings → RTK Token Saver → Toggle ON

### Caveman not working

Check Dashboard → Endpoint settings → Caveman Mode → Toggle ON

### Config tidak ke-load

```bash
# Cek config
cat ~/.config/opencode/opencode.jsonc

# Cek file exist
ls -la ~/.config/opencode/
```

### Plugin hooks tidak jalan

```bash
cd ecc && npm run build:opencode
```

### Rate limit (gratis)

Switch ke go profile atau tunggu reset. Atau connect Kiro AI (free Claude unlimited).

## License

MIT
