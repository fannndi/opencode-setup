---
description: [COMBO] PRD — generate → project-analyze → analyze-project
agent: build
---

# PRD Combo

Ubah ide jadi PRD, analisa, deteksi stack — 1x jalan.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur yang tersedia
- `Skill/skill-list.md` — skill yang bisa dipakai
- `CHANGELOG.md` — update terbaru

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| blueprint | Feature | Perencanaan multi-sesi |
| product-capability | Feature | Analisa kemampuan produk |
| intent-driven-development | Skill | Kriteria penerimaan |
| architecture-decision-records | Feature | Keputusan arsitektur |

## Instruksi
1. `/generate-prd "deskripsi ide"` — AI buat PRD dari ide
2. `/project-analyze` — AI analisa PRD → ai-notes.md
3. `/analyze-project` — deteksi stack + load skills

## ✅ Auto-Changelog
```
### YYYY-MM-DD — PRD Combo
- Project: [nama]
- Stack: [detected]
- Status: siap
```

## Task

$ARGUMENTS
