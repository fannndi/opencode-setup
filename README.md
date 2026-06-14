# OpenCode Full Setup

One command setup: ECC (agents/skills) + 9Router (RTK/Caveman/auto-fallback).

```
[OpenCode] → [9Router] → [Provider]
               │
               ├── RTK: compress tool output (-20-40% tokens)
               ├── Caveman: terse replies (-65% output tokens)
               └── Auto-fallback: subscription → cheap → free
```

## Quick Start

### Windows (PowerShell)
```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

### macOS / Linux
```bash
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## Scripts

| Command | Description |
|---------|-------------|
| `scripts/start.ps1 -Profile gratis` | Daily workflow - free models |
| `scripts/start.ps1 -Profile go` | Daily workflow - go models |
| `scripts/setup.ps1` | Full setup (clone + config + start) |
| `scripts/install.ps1 -Profile gratis` | Quick re-apply config |
| `scripts/clone.ps1` | Clone ECC + 9Router repos |
| `scripts/sync.ps1` | Show changes since last sync |

## Daily Workflow

### Via OpenCode (Recommended)

```bash
# Buka opencode-setup folder
cd C:\Users\FANNNDI\Documents\opencode-setup

# Mulai OpenCode
opencode

# Jalankan daily workflow
/start-free    # 100% free models
/start-go      # Go models (limited quota)
```

### Via PowerShell

```powershell
.\scripts\start.ps1 -Profile gratis
.\scripts\start.ps1 -Profile go
```

### Via Bash (macOS/Linux)

```bash
./scripts/start.sh --profile gratis
./scripts/start.sh --profile go
```

### Manual Steps

```powershell
# First time / fresh install
.\scripts\setup.ps1

# Check for updates
.\scripts\sync.ps1

# Apply updates
.\scripts\setup.ps1

# Quick re-apply (ganti profile)
.\scripts\install.ps1 -Profile go
.\scripts\install.ps1 -Profile gratis -SyncFirst
```

## Profiles

| Profile | Models | Cost |
|---------|--------|------|
| **gratis** | MiMo V2.5, DeepSeek V4 Flash, Kiro Claude 4.5 | $0 |
| **go** | Kimi K2.6, Qwen3.6 Plus, GLM-5.1 | Limited quota |

### Switch Profiles

```powershell
# Switch ke gratis (free)
.\profiles\gratis\restore.ps1

# Switch ke go (limited)
.\profiles\go\restore.ps1
```

### Combos (Auto-Fallback)

| Combo | Chain |
|-------|-------|
| `gratis` | `oc/mimo-v2.5-free` → `oc/deepseek-v4-flash-free` → `kr/claude-sonnet-4.5` |
| `go` | `ocg/kimi-k2.6` → `ocg/qwen3.6-plus` → `ocg/glm-5.1` |
| `gratis-small` | `oc/deepseek-v4-flash-free` → `kr/glm-5` → `oc/north-mini-code-free` |

## After Setup

### 1. Connect Provider (in 9Router Dashboard)

Dashboard: `http://localhost:20128/dashboard`

- **Login:** password `123456`
- **Free option:** Connect "Kiro AI" (free Claude 4.5 + GLM-5)
- **Free option:** Connect "OpenCode Free" (no auth)
- **Go option:** Add your OpenCode Go API key

### 2. Set API Key

```powershell
# Windows
setx NINEROUTER_API_KEY "your-key-here"

# macOS/Linux
export NINEROUTER_API_KEY="your-key-here"
```

### 3. Start Coding

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

## Features

270+ ECC skills loaded. See `Feature/list.md` for full list of available features and setup guides.

## Token Savings

| Feature | Source | Savings |
|---------|--------|---------|
| RTK Token Saver | 9Router | -20-40% input tokens |
| Caveman Mode | 9Router | -65% output tokens |
| Free providers | 9Router | $0 cost |
| Auto-fallback | 9Router | Zero downtime |
| **Combined** | | **~70-80% total** |

## File Structure

```
opencode-setup/
├── README.md                  # This file
├── Feature/
│   └── list.md                # 20 features tracking + setup guides
├── profiles/
│   ├── gratis/
│   │   ├── opencode.jsonc     # Config: free models + combos
│   │   └── restore.ps1        # Restore script
│   └── go/
│       ├── opencode.jsonc     # Config: Go models + combos
│       └── restore.ps1        # Restore script
├── scripts/
│   ├── setup.ps1              # Full auto setup (Windows)
│   ├── setup.sh               # Full auto setup (macOS/Linux)
│   ├── install.ps1            # Quick re-apply (Windows)
│   ├── install.sh             # Quick re-apply (macOS/Linux)
│   ├── clone.ps1              # Clone repos (Windows)
│   ├── clone.sh               # Clone repos (macOS/Linux)
│   ├── sync.ps1               # Sync changelogs (Windows)
│   └── sync.sh                # Sync changelogs (macOS/Linux)
├── ecc/                       # ECC fork (auto-cloned)
│   ├── skills/                # 270+ skills
│   ├── agents/                # 64 agents
│   ├── commands/              # 84 commands
│   ├── hooks/                 # 20+ hooks
│   └── rules/                 # 18 language rules
├── 9router/                   # 9Router fork (auto-cloned)
├── opencode-free-config.jsonc # Config backup
├── api-key.txt                # API keys (gitignored)
├── caveman-mode.md            # Caveman Mode reference
└── .sync-state.json           # SHA tracking
```

## Update

```bash
cd opencode-setup

# Pull latest
.\scripts\sync.ps1

# Re-apply setup
.\scripts\setup.ps1
```
