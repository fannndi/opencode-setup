# OpenCode Setup — Dokumentasi

**Versi:** 2.0.0
**Terakhir diperbarui:** 2026-06-14

---

## Apa Ini?

OpenCode Setup adalah **asisten coding AI** yang bisa kamu clone ke dalam project manapun. Terdiri dari 3 komponen utama:

- **ECC** — 270+ skills, 64 agents, 84 commands untuk berbagai bahasa/framework
- **9Router** — AI gateway yang menghubungkan ke berbagai provider model
- **Combo System** — Auto-fallback chain agar selalu ada model yang tersedia

---

## Peta Dokumentasi

### Pemula

| Dokumen | Isi |
|---------|-----|
| [Quick Start](01-getting-started/01-quick-start.md) | Setup 1 menit |
| [Instalasi](01-getting-started/02-installation.md) | Instalasi lengkap |
| [Setelah Setup](01-getting-started/03-after-setup.md) | API key, dashboard, mulai coding |

### Arsitektur

| Dokumen | Isi |
|---------|-----|
| [Overview](02-architecture/01-overview.md) | Bagaimana semuanya saling terhubung |
| [9Router](02-architecture/02-9router.md) | AI gateway dan provider |
| [ECC](02-architecture/03-ecc.md) | Skills, agents, commands |
| [Combos](02-architecture/04-combos.md) | Auto-fallback chain |

### Profile

| Dokumen | Isi |
|---------|-----|
| [Gratis](03-profiles/01-gratis.md) | Model 100% gratis |
| [Go](03-profiles/02-go.md) | Model berbayar (limited) |
| [Switching](03-profiles/03-switching.md) | Cara ganti profile |

### Cara Pakai

| Dokumen | Isi |
|---------|-----|
| [Commands](04-usage/01-commands.md) | Referensi semua perintah |
| [Scripts](04-usage/02-scripts.md) | Script PowerShell/Bash |
| [Daily Workflow](04-usage/03-daily-workflow.md) | Rutinitas harian |
| [Analyze Project](04-usage/04-analyze-project.md) | Deteksi stack project |

### Skills

| Dokumen | Isi |
|---------|-----|
| [Skill Selection](05-skills/01-skill-selection.md) | Cara memilih skills |

### Katalog

| Dokumen | Isi |
|---------|-----|
| [Features](06-catalogs/01-features.md) | Daftar lengkap 600+ komponen |
| [Skills](06-catalogs/02-skills.md) | Katalog 270 skills |

### Lanjutan

| Dokumen | Isi |
|---------|-----|
| [Hooks](07-advanced/01-hooks.md) | Sistem hook otomatis |
| [MCP](07-advanced/02-mcp.md) | Server MCP |
| [Session Persistence](07-advanced/03-session-persistence.md) | Simpan status workflow |

### Templates

| Dokumen | Isi |
|---------|-----|
| [Flutter + Firebase](../../templates/flutter-firebase/template.md) | Mobile app template |
| [Go API](../../templates/go-api/template.md) | REST API template |
| [Next.js Fullstack](../../templates/nextjs-fullstack/template.md) | Fullstack web template |
| [Python FastAPI](../../templates/python-fastapi/template.md) | API service template |

### Troubleshooting

| Dokumen | Isi |
|---------|-----|
| [FAQ](08-troubleshooting/01-common-issues.md) | Masalah umum dan solusi |

---

## Alur Cepat

```
1. git clone opencode-setup (SEKALI)
2. cd opencode-setup
3. .\scripts\setup.ps1
4. opencode
5. /start-free
6. /set-project C:\path\ke\project-anda
7. /code-analyze atau /project-analyze
8. /analyze-project
9. restart opencode
10. mulai coding
```

### Full Workflow

```
/project-analyze → ai-notes.md (rekomendasi skills/commands)
/make-docs → docs/ (berdasarkan prd.md + ai-notes.md)
/implement → code (berdasarkan docs/ + prd.md + ai-notes.md)
```

---

## Struktur Project

```
my-project/
├── prd.md                 # Product Requirements Document
├── frontend/              # Source code frontend
├── backend/               # Source code backend
├── lib/                   # Source code library/shared
├── ai-notes.md            # Rekomendasi dari AI
├── docs/                  # Rencana implementasi
│   ├── frontend/          # Rencana frontend
│   ├── backend/           # Rencana backend
│   └── database/          # Rencana database
└── opencode-setup/        # Clone ini di sini
    ├── docs/              # Dokumentasi (anda di sini)
    ├── scripts/           # Script automation
    ├── commands/          # Command templates
    ├── profiles/          # Config profiles
    ├── templates/         # Project templates
    ├── Feature/           # Feature inventory
    ├── Skill/             # Skill catalog
    ├── ecc/               # ECC repo (auto-cloned)
    ├── 9router/           # 9Router repo (auto-cloned)
    └── README.md          # Overview
```
