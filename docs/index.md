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
1. git clone project-repo (prd.md only)
2. cd project-repo
3. git clone opencode-setup
4. opencode
5. /plan → analisa PRD
6. /project-analyze → buat ai-notes.md
7. /analyze-project → deteksi stack + load skills
8. restart opencode
9. mulai coding
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
opencode-setup/
├── docs/                    # Dokumentasi (anda di sini)
│   ├── index.md
│   ├── 01-getting-started/
│   ├── 02-architecture/
│   ├── 03-profiles/
│   ├── 04-usage/
│   ├── 05-skills/
│   ├── 06-catalogs/
│   ├── 07-advanced/
│   └── 08-troubleshooting/
├── scripts/                 # Script automation
├── commands/                # Command templates
├── profiles/                # Config profiles
├── Feature/                 # Feature inventory
├── Skill/                   # Skill catalog
├── ecc/                     # ECC repo (auto-cloned)
├── 9router/                 # 9Router repo (auto-cloned)
└── README.md                # Overview
```
