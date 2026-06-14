# OpenCode Setup — AI Coding Assistant

Asisten coding AI — clone sekali, kontrol semua project.

```
opencode-setup/              ← Master repo
    ├── ecc/                 # 270+ skills, 64 agents
    ├── 9router/             # AI gateway + combos
    ├── scripts/             # Automation scripts
    ├── commands/            # Command templates
    ├── profiles/            # Config profiles
    ├── templates/           # Project templates
    ├── Feature/             # Feature inventory
    ├── Skill/               # Skill catalog
    └── docs/                # Dokumentasi
```

---

## Setup dari 0

| Tool | Cek | Install |
|------|-----|---------|
| Node.js | `node --version` | [nodejs.org](https://nodejs.org) |
| Git | `git --version` | [git-scm.com](https://git-scm.com) |
| OpenCode | `opencode --version` | `npm install -g opencode` |

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

Edit `api-key.txt`, paste API key, lalu:

```powershell
.\scripts\setup.ps1
```

---

## Quick Start

```powershell
opencode
/start-free                    ← WAJIB dulu (9Router, model, config)
/set-project C:\path\ke\project
/code-analyze                  ← scan code → ai-notes.md
/analyze-project               ← load skills sesuai stack
restart opencode
```

---

## Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/start-free` | Start workflow gratis | `/start-free` |
| `/start-go` | Start workflow go | `/start-go` |
| `/set-project C:\path` | Set project aktif | `/set-project C:\Users\me\project` |
| `/current-project` | Lihat project aktif | `/current-project` |
| `/project-analyze` | Analisa PRD → ai-notes.md | `/project-analyze` |
| `/code-analyze` | Scan source code → ai-notes.md | `/code-analyze` |
| `/analyze-project` | Deteksi stack + load skills | `/analyze-project` |
| `/project-skills` | Lihat skills yang cocok | `/project-skills` |
| `/template` | Load project template | `/template flutter-firebase` |
| `/plan` | Buat rencana implementasi | `/plan buat fitur login` |
| `/tdd` | Test-driven development | `/tdd buat function hitung` |
| `/code-review` | Review kode | `/code-review lib/` |
| `/security` | Security audit | `/security lib/` |
| `/build-fix` | Fix build errors | `/build-fix` |
| `/verify` | Verification loop | `/verify` |
| `/reset-session` | Reset session state | `/reset-session` |
| `/research` | Web search + AI ringkasan | `/research Flutter 2026` |
| `/quality-gate` | Verify fixes, track iterations | `/quality-gate` |
| `/token-stats` | Token usage + session stats | `/token-stats` |
| `/admin` | Update ECC/9Router, doctor check | `/admin` |

---

## Workflow Examples

### Flutter Project — Source Code Existing

```powershell
cd C:\Users\FANNNDI\Documents\opencode-setup
opencode

/start-free
/set-project C:\Users\User\flutter-app
/code-analyze
/analyze-project
restart opencode

# Improve & review:
/code-review lib/screens/
/security lib/
/tdd buat halaman login
/verify
```

### Flutter Project — Start New (dengan PRD)

```powershell
opencode

/start-free
/set-project C:\Users\User\flutter-app-baru
/project-analyze            ← AI baca prd.md
/analyze-project
restart opencode

# Development:
/plan "buat halaman login"
/tdd buat state management
/code-review lib/
/security
```

### Go API — Source Code Existing

```powershell
opencode

/start-free
/set-project C:\Users\User\go-api
/code-analyze               ← detect golang + gin
/analyze-project            ← load golang-patterns
restart opencode

/code-review internal/handler/
/security internal/auth/
/tdd buat endpoint /api/users
/verify
```

### Ganti Project

```powershell
/set-project C:\Users\User\project-lain
/code-analyze
/analyze-project
```

### Lihat Skills yang Cocok

```
/project-skills

Output:
  Stack: dart-flutter
  Core:   tdd-workflow, security-review, coding-standards, verification-loop
  Project: dart-flutter-patterns
  Total: 5 skills untuk dart-flutter
```

---

## Alur Singkat

```
Clone sekali:  setup.ps1 → opencode → /start-free

Source code:   /set-project → /code-analyze → /analyze-project → restart → coding
New project:   /set-project → /project-analyze → /analyze-project → restart → coding
Ganti project: /set-project [path baru] → /code-analyze → /analyze-project
```

---

## Profile

| Profile | Model | Biaya |
|---------|-------|-------|
| **gratis** | mimo-v2.5-free, deepseek-v4-flash-free, nemotron-3-ultra-free | $0 |
| **go** | kimi-k2.6, qwen3.6-plus, glm-5.1 | Limited quota |

### Combo Aktif

| Nama | Chain |
|------|-------|
| **gratis** | `mmf/mimo-auto → oc/deepseek-v4-flash-free → oc/mimo-v2.5-free` |
| **emergency** | `oc/nemotron-3-ultra-free → oc/big-pickle → oc/north-mini-code-free` |

### Token Savings

| Feature | Hemat |
|---------|-------|
| RTK Token Saver | -20-40% input tokens |
| Caveman Mode | -65% output tokens |
| Auto-fallback | Zero downtime |
| **Total** | **~70-80%** |

---

## Yang Kamu Dapat

| Komponen | Jumlah | Fungsi |
|----------|--------|--------|
| Skills | 270 | Domain knowledge per bahasa/framework |
| Agents | 64 | AI assistant spesialis |
| Commands | 84 | Perintah slash |
| Rules | 20 pack | Konvensi coding per bahasa |
| Combos | 2 | Auto-fallback + emergency |
| Templates | 4 | Project template |
| Session | Persist | Status workflow tersimpan |

---

## Struktur

```
opencode-setup/
├── scripts/
│   ├── setup.ps1              # Full setup
│   ├── start.ps1              # Daily workflow (session-aware)
│   ├── full-start.ps1         # 1 command auto-deploy
│   ├── code-analyze.ps1       # Scan source → ai-notes.md
│   ├── project-analyze.ps1    # Analisa PRD → ai-notes.md
│   ├── analyze-project.ps1    # Deteksi stack + load skills
│   ├── project-skills.ps1     # Lihat skills yang cocok
│   ├── session-manager.ps1    # Session management
│   └── template-loader.ps1    # Template loader
├── commands/                  # Command templates (16 files)
├── profiles/                  # Config profiles
│   ├── gratis/                # Free models
│   └── go/                    # Go models
├── templates/                 # Project templates (4)
├── docs/                      # Dokumentasi (21 files)
├── Feature/                   # 600+ component inventory
├── Skill/                     # 270 skill catalog
├── ecc/                       # ECC repo (auto-cloned)
├── 9router/                   # 9Router repo (auto-cloned)
├── CHANGELOG.md
└── README.md
```

---

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| [docs/index.md](docs/index.md) | Peta dokumentasi |
| [Quick Start](docs/01-getting-started/01-quick-start.md) | Setup 1 menit |
| [Instalasi](docs/01-getting-started/02-installation.md) | Instalasi lengkap |
| [Commands](docs/04-usage/01-commands.md) | Referensi commands |
| [Scripts](docs/04-usage/02-scripts.md) | Referensi scripts |
| [Analyze Project](docs/04-usage/04-analyze-project.md) | Deteksi stack |
| [Troubleshooting](docs/08-troubleshooting/01-common-issues.md) | FAQ |

---

## Workflow Development

Untuk mengembangkan project opencode-setup ini sendiri.

### Update ECC + 9Router

```powershell
.\scripts\admin-update.ps1
```

Atau via OpenCode:
```
/admin-update
```

### Changelogs

| File | Isi |
|------|-----|
| [changelog-ecc.md](changelog-ecc.md) | Perubahan ECC (skills, agents, commands) |
| [changelog-9router.md](changelog-9router.md) | Perubahan 9Router (models, features) |
| [log-admin.md](log-admin.md) | History update admin |

### Development Flow

1. `.\scripts\admin-update.ps1` — update ECC + 9Router + doctor
2. `.\scripts\start.ps1 -Profile gratis` — test model
3. `opencode` — verify commands jalan
4. `git add -A && git commit -m "feat: ..."` — save perubahan
5. `git push` — push ke repo
