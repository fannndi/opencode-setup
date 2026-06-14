# OpenCode Setup — AI Coding Assistant

Asisten coding AI yang bisa kamu clone ke dalam project manapun.

```
opencode-setup/              ← Master repo (clone sekali)
    ├── ecc/                 # 270+ skills, 64 agents
    ├── 9router/             # AI gateway
    ├── profiles/            # Config profiles
    ├── scripts/             # Automation scripts (control semua project)
    ├── commands/            # Command templates
    ├── templates/           # Project templates
    ├── Feature/             # Feature inventory
    ├── Skill/               # Skill catalog
    └── docs/                # Dokumentasi
```

---

## Setup dari 0

### Prasyarat

| Tool | Cek | Install |
|------|-----|---------|
| Node.js | `node --version` | [nodejs.org](https://nodejs.org) |
| Git | `git --version` | [git-scm.com](https://git-scm.com) |
| OpenCode | `opencode --version` | `npm install -g opencode` |

### Step 1: Clone + Setup

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

Script akan otomatis:
- Clone ECC + 9Router repos
- Install dependencies
- Build plugin
- Generate config
- Start 9Router

### Step 2: Set API Key

Edit `api-key.txt`, paste API key, lalu jalankan ulang:

```powershell
.\scripts\setup.ps1
```

### Step 3: Start

```powershell
opencode

# Di OpenCode, jalankan DULU sebelum mulai apapun:
/start-free    # Untuk model gratis
# atau
/start-go      # Untuk model go (limited)
```

**Penting:** `/start-free` atau `/start-go` harus dijalankan pertama kali agar:
- 9Router running
- Model terkoneksi
- Config terapply
- Skills terload

### Step 4: Set Project (Master Control)

```powershell
# Di OpenCode, set project yang akan di-handle:
/set-project C:\Users\FANNNDI\Documents\expense_tracker

# Atau ganti ke project lain kapan saja:
/set-project C:\Users\FANNNDI\Documents\project-lain
```

### Step 5: Mulai Pakai

Setelah `/start-free` dan `/set-project` selesai, jalankan sesuai kebutuhan:

```powershell
# Project existing (source code sudah ada):
/code-analyze          # Scan source code → ai-notes.md
/analyze-project       # Deteksi stack + load skills

# Project baru (pake PRD):
/project-analyze       # Analisa PRD → ai-notes.md
/analyze-project       # Deteksi stack + load skills

# Setelah restart opencode:
/plan                  # Buat rencana
/tdd                   # Mulai coding
/code-review           # Review kode
/security              # Security audit
```

---

## Workflow

### Master Control (Recommended)
Satu repo opencode-setup untuk semua project.

```powershell
# Setup sekali:
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1

# Setiap hari — control project dari sini:
opencode
/start-free
/set-project C:\Users\FANNNDI\Documents\expense_tracker  ← ganti sesuai project

# Analisa existing code:
/code-analyze          ← scan source code → ai-notes.md
/analyze-project       ← load skills sesuai stack
restart opencode

# Review & improve:
/code-review lib/
/security api/
/tdd

# Ganti project:
/set-project C:\Users\FANNNDI\Documents\project-lain
/code-analyze
/analyze-project
```

### Project Baru (dengan PRD)

```powershell
/set-project C:\Users\FANNNDI\Documents\project-baru
/project-analyze          ← analisa PRD → ai-notes.md
/analyze-project          ← load skills
restart opencode
/tdd buat fitur
```

## Alur Singkat

```
Clone sekali:
opencode-setup/ → setup.ps1 → opencode → /start-free

Setiap hari:
/set-project [path] → /code-analyze → /analyze-project → restart → coding
               atau
/set-project [path] → /project-analyze → /analyze-project → restart → coding
```

## Master Control Mode

Kontrol semua project dari satu repo opencode-setup, tanpa clone di dalam project.

### Setup

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
```

### Daily Workflow

```powershell
cd opencode-setup
opencode
/start-free
/set-project C:\Users\FANNNDI\Documents\expense_tracker  ← set project
/code-analyze          ← scan source code → ai-notes.md
/analyze-project       ← load skills sesuai stack
restart
```

### Ganti Project

```powershell
/set-project C:\Users\FANNNDI\Documents\project-lain
/code-analyze
/analyze-project
```

### Commands Master Control

| Command | Fungsi |
|---------|--------|
| `/set-project [path]` | Set project path aktif |
| `/current-project` | Lihat project path aktif |
| `/code-analyze` | Scan project aktif → ai-notes.md |
| `/analyze-project` | Deteksi stack project aktif |
| `/project-analyze` | Analisa PRD project aktif |

---

## Yang Kamu Dapat

| Komponen | Jumlah | Fungsi |
|----------|--------|--------|
| Skills | 270 | Domain knowledge per bahasa/framework |
| Agents | 64 | AI assistant spesialis |
| Commands | 84 | Perintah slash |
| Rules | 20 pack | Konvensi coding per bahasa |
| Combos | 3 | Auto-fallback chain |
| Templates | 4 | Project template cepat |
| Session | Persist | Status workflow tersimpan |

---

## Fitur Tambahan

### Session Persistence

Status workflow tersimpan otomatis. Kalau restart OpenCode, tidak perlu ulang dari awal.

```
/start-free → session saved
# restart opencode
/start-free → session loaded → skip yang udah dilakuin
```

Session file: `.opencode-session.json` (di root project)

Reset session:
```
/reset-session
```

### Auto-Update

`/start-free` otomatis deteksi git changes di ECC/9Router:
- Kalau ada update → auto rebuild plugin
- Kalau tidak ada → skip, langsung jalan
- Tidak perlu manual `/sync` lagi

### Project Templates

Quick start dengan template yang sudah ada:

```
/template flutter-firebase    # Mobile app
/template go-api              # REST API
/template nextjs-fullstack    # Fullstack web
/template python-fastapi      # API service
```

Template akan generate:
- `docs/` structure sesuai stack
- `docs/TEMPLATE-GUIDE.md` — panduan lengkap

---

## Profile

| Profile | Model | Biaya |
|---------|-------|-------|
| **gratis** | mimo-v2.5-free, deepseek-v4-flash-free, claude-sonnet-4.5 | $0 |
| **go** | kimi-k2.6, qwen3.6-plus, glm-5.1 | Limited quota |

Ganti profile:

```powershell
.\profiles\gratis\restore.ps1    # Switch ke gratis
.\profiles\go\restore.ps1        # Switch ke go
```

---

## Commands

### Yang Wajib Dijalankan Pertama

| Command | Kapan |
|---------|-------|
| `/start-free` | Pertama kali buka OpenCode (gratis) |
| `/start-go` | Pertama kali buka OpenCode (go) |

### Workflow Commands

| Command | Fungsi |
|---------|--------|
| `/project-analyze` | Analisa PRD → generate ai-notes.md |
| `/code-analyze` | Scan source code → generate ai-notes.md |
| `/analyze-project` | Deteksi stack + load skills |
| `/template` | Load project template |
| `/start-free` | Daily workflow (gratis) |
| `/start-go` | Daily workflow (go) |
| `/reset-session` | Reset session state |
| `/set-project` | Set project path untuk Master Control |
| `/current-project` | Lihat project path yang aktif |
| `/plan` | Buat rencana implementasi |

### Development Commands

| Command | Agent | Fungsi |
|---------|-------|--------|
| `/tdd` | tdd-guide | Test-driven development |
| `/code-review` | code-reviewer | Review kode |
| `/security` | security-reviewer | Security review |
| `/build-fix` | build-error-resolver | Fix build errors |
| `/verify` | — | Verification loop |

---

## Token Savings

| Feature | Hemat |
|---------|-------|
| RTK Token Saver | -20-40% input tokens |
| Caveman Mode | -65% output tokens |
| Auto-fallback | Zero downtime |
| **Total** | **~70-80%** |

---

## Dokumentasi

| Dokumen | Isi |
|---------|-----|
| [docs/index.md](docs/index.md) | Peta dokumentasi |
| [Quick Start](docs/01-getting-started/01-quick-start.md) | Setup 1 menit |
| [Instalasi](docs/01-getting-started/02-installation.md) | Instalasi lengkap |
| [Architecture](docs/02-architecture/01-overview.md) | Arsitektur sistem |
| [Commands](docs/04-usage/01-commands.md) | Referensi commands |
| [Scripts](docs/04-usage/02-scripts.md) | Referensi scripts |
| [Analyze Project](docs/04-usage/04-analyze-project.md) | Deteksi stack |
| [Troubleshooting](docs/08-troubleshooting/01-common-issues.md) | FAQ |

---

## Struktur

```
opencode-setup/
├── docs/                    # Dokumentasi
├── scripts/                 # Automation scripts
│   ├── setup.ps1            # Full setup
│   ├── start.ps1            # Daily workflow (session-aware + auto-update)
│   ├── analyze-project.ps1  # Deteksi stack
│   ├── project-analyze.ps1  # PRD → ai-notes.md
│   ├── session-manager.ps1  # Session management
│   └── template-loader.ps1  # Template loader
├── commands/                # Command templates
├── profiles/                # Config profiles
│   ├── gratis/              # Free models
│   └── go/                  # Go models
├── templates/               # Project templates
│   ├── flutter-firebase/    # Mobile app
│   ├── go-api/              # REST API
│   ├── nextjs-fullstack/    # Fullstack web
│   └── python-fastapi/      # API service
├── Feature/                 # Feature inventory (600+ komponen)
├── Skill/                   # Skill catalog (270 skills)
├── ecc/                     # ECC repo (auto-cloned)
├── 9router/                 # 9Router repo (auto-cloned)
├── CHANGELOG.md             # Changelog project
└── README.md                # File ini
```

---

## Contoh Penggunaan

### Flutter Project

```powershell
# Terminal — di opencode-setup (Master Control):
cd C:\Users\FANNNDI\Documents\opencode-setup
opencode

# Di OpenCode:
/start-free                           # WAJIB dulu
/set-project C:\Users\User\flutter-app  # Set project
/code-analyze                         # → ai-notes.md (flutter detected)
/analyze-project                      # → load dart-flutter-patterns
restart opencode

# Review & improve:
/code-review lib/screens/
/tdd buat halaman login
```

### Go API Project

```powershell
# Terminal — di opencode-setup (Master Control):
cd C:\Users\FANNNDI\Documents\opencode-setup
opencode

# Di OpenCode:
/start-free                           # WAJIB dulu
/set-project C:\Users\User\go-api      # Set project
/code-analyze                         # → ai-notes.md (golang detected)
/analyze-project                      # → load golang-patterns
restart opencode

# Review & improve:
/code-review internal/handler/
/security internal/auth/
/tdd buat endpoint /api/users
```

---

## Lisensi

MIT
