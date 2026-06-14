# OpenCode Setup — AI Coding Assistant

Asisten coding AI yang bisa kamu clone ke dalam project manapun.

```
my-project/
├── src/                    # Source code kamu
└── opencode-setup/         # Clone ini di sini
    ├── ecc/                # 270+ skills, 64 agents
    ├── 9router/            # AI gateway
    └── profiles/           # Config profiles
```

## Quick Start

```powershell
# 1. Clone project repo (prd.md only)
git clone https://github.com/user/my-project.git
cd my-project

# 2. Clone opencode-setup
git clone https://github.com/fannndi/opencode-setup.git

# 3. Jalankan OpenCode
opencode

# 4. Analisa PRD
/plan                    # AI analisa PRD
/project-analyze         # Buat ai-notes.md

# 5. Deteksi stack + restart
/analyze-project         # Deteksi stack, load skills
# Restart OpenCode

# 6. Mulai coding
```

## Yang Kamu Dapat

| Komponen | Jumlah | Fungsi |
|----------|--------|--------|
| Skills | 270 | Domain knowledge per bahasa/framework |
| Agents | 64 | AI assistant spesialis |
| Commands | 84 | Perintah slash (/plan, /tdd, dll) |
| Rules | 20 pack | Konvensi coding per bahasa |
| Combos | 3 | Auto-fallback chain |

## Profile

| Profile | Model | Biaya |
|---------|-------|-------|
| **gratis** | mimo-v2.5-free, deepseek-v4-flash-free, claude-sonnet-4.5 | $0 |
| **go** | kimi-k2.6, qwen3.6-plus, glm-5.1 | Limited quota |

## Commands

| Command | Fungsi |
|---------|--------|
| `/project-analyze` | Analisa PRD → ai-notes.md |
| `/analyze-project` | Deteksi stack project |
| `/start-free` | Daily workflow (gratis) |
| `/start-go` | Daily workflow (go) |
| `/plan` | Buat rencana implementasi |
| `/tdd` | Test-driven development |
| `/code-review` | Review kode |
| `/security` | Security review |
| `/build-fix` | Fix build errors |
| `/verify` | Verification loop |

## Token Savings

| Feature | Hemat |
|---------|-------|
| RTK Token Saver | -20-40% input tokens |
| Caveman Mode | -65% output tokens |
| Auto-fallback | Zero downtime |
| **Total** | **~70-80%** |

## Dokumentasi

Lengkapnya baca: **[`docs/index.md`](docs/index.md)**

| Dokumen | Isi |
|---------|-----|
| [Quick Start](docs/01-getting-started/01-quick-start.md) | Setup 1 menit |
| [Instalasi](docs/01-getting-started/02-installation.md) | Instalasi lengkap |
| [Architecture](docs/02-architecture/01-overview.md) | Arsitektur sistem |
| [Commands](docs/04-usage/01-commands.md) | Referensi commands |
| [Scripts](docs/04-usage/02-scripts.md) | Referensi scripts |
| [Troubleshooting](docs/08-troubleshooting/01-common-issues.md) | FAQ |

## Struktur

```
opencode-setup/
├── docs/                    # Dokumentasi
├── scripts/                 # Automation scripts
├── commands/                # Command templates
├── profiles/                # Config profiles
├── Feature/                 # Feature inventory (600+ komponen)
├── Skill/                   # Skill catalog (270 skills)
├── ecc/                     # ECC repo (auto-cloned)
├── 9router/                 # 9Router repo (auto-cloned)
└── README.md                # File ini
```

## Lisensi

MIT
