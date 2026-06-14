# OpenCode Setup — AI Coding Assistant

Asisten coding AI yang bisa kamu clone ke dalam project manapun.

```
my-project/
├── prd.md                 # Product Requirements Document
├── src/                   # Source code kamu
├── ai-notes.md            # Rekomendasi dari AI
├── docs/                  # Rencana implementasi
└── opencode-setup/        # Clone ini di sini
    ├── ecc/               # 270+ skills, 64 agents
    ├── 9router/           # AI gateway
    └── profiles/          # Config profiles
```

---

## Workflow Lengkap

### Step 1: Clone Project

```powershell
git clone https://github.com/user/my-project.git
cd my-project
```

### Step 2: Clone opencode-setup

```powershell
git clone https://github.com/fannndi/opencode-setup.git
```

### Step 3: Buka OpenCode

```powershell
opencode
```

### Step 4: Analisa PRD

```
/plan
```

AI membaca `prd.md` dan menganalisa:
- Fitur-fitur yang dibutuhkan
- Komponen-komponen (frontend, backend, database)
- Kompleksitas project
- Revisi jika ada yang kurang jelas

### Step 5: Generate ai-notes.md

```
/project-analyze
```

AI membaca PRD dan `Skill/skill-list.md`, lalu generate `ai-notes.md` berisi:
- Detected stack (bahasa, framework)
- Recommended skills (270+ → yang relevan saja)
- Recommended commands
- Recommended rules
- Implementation phases

### Step 6: Deteksi Stack + Load Skills

```
/analyze-project
```

AI mendeteksi indicator files (pubspec.yaml, go.mod, dll) dan load skills yang sesuai.

### Step 7: Restart OpenCode

```
# Ctrl+C dulu, lalu:
opencode
```

### Step 8: Mulai Coding

```
/tdd buat function login
/code-review src/auth.ts
/security src/api/
```

---

## Alur Singkat

```
prd.md → /plan → /project-analyze → ai-notes.md
                                     ↓
                              /analyze-project
                                     ↓
                              restart opencode
                                     ↓
                              mulai coding
```

---

## Yang Kamu Dapat

| Komponen | Jumlah | Fungsi |
|----------|--------|--------|
| Skills | 270 | Domain knowledge per bahasa/framework |
| Agents | 64 | AI assistant spesialis |
| Commands | 84 | Perintah slash |
| Rules | 20 pack | Konvensi coding per bahasa |
| Combos | 3 | Auto-fallback chain |

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

### Workflow Commands

| Command | Fungsi |
|---------|--------|
| `/project-analyze` | Analisa PRD → generate ai-notes.md |
| `/analyze-project` | Deteksi stack + load skills |
| `/start-free` | Daily workflow (gratis) |
| `/start-go` | Daily workflow (go) |

### Development Commands

| Command | Agent | Fungsi |
|---------|-------|--------|
| `/plan` | planner | Buat rencana implementasi |
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
│   ├── start.ps1            # Daily workflow
│   ├── analyze-project.ps1  # Deteksi stack
│   └── project-analyze.ps1  # PRD → ai-notes.md
├── commands/                # Command templates
├── profiles/                # Config profiles
│   ├── gratis/              # Free models
│   └── go/                  # Go models
├── Feature/                 # Feature inventory (600+ komponen)
├── Skill/                   # Skill catalog (270 skills)
├── ecc/                     # ECC repo (auto-cloned)
├── 9router/                 # 9Router repo (auto-cloned)
└── README.md                # File ini
```

---

## Contoh Penggunaan

### Flutter Project

```powershell
git clone https://github.com/user/flutter-app.git
cd flutter-app
git clone https://github.com/fannndi/opencode-setup.git
opencode

# Di OpenCode:
/project-analyze         # → ai-notes.md (deteksi: dart-flutter)
/analyze-project         # → load dart-flutter-patterns
# Restart
opencode

# Mulai coding:
/tdd buat halaman login
/code-review lib/screens/
```

### Go API Project

```powershell
git clone https://github.com/user/go-api.git
cd go-api
git clone https://github.com/fannndi/opencode-setup.git
opencode

# Di OpenCode:
/project-analyze         # → ai-notes.md (deteksi: golang)
/analyze-project         # → load golang-patterns, golang-testing
# Restart
opencode

# Mulai coding:
/tdd buat endpoint /api/users
/security internal/auth/
```

---

## Lisensi

MIT
