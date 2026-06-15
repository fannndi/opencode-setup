---
description: [COMBO] Rutinitas pagi — preprocess + start-free + admin + quality-gate + token-stats + learn
type: combo
agent: build
---

# Morning Routine — Combo

Rutinitas pagi: preprocess context → update system → health check → cek token → save.
Pertama kali dijalankan setiap hari.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur yang tersedia
- `Skill/skill-list.md` — skill yang bisa dipakai
- `CHANGELOG.md` — update terbaru

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| verification-loop | Feature | Build/type/lint/test — cek kesehatan |
| cost-aware-llm-pipeline | Feature | Optimasi token & biaya |
| strategic-compact | Feature | Context compaction — hemat token |
| coding-standards | Feature | KISS, DRY, YAGNI — kode bersih |

## Instruksi
1. **`/go "morning routine"`** — preprocess context (detect stack, skill, feature, memory)
2. `/start-free` — start 9Router + test model + apply config
3. `/admin` — update ECC/9Router + doctor check
4. `/quality-gate` — verifikasi sistem masih sehat
5. `/token-stats` — cek pemakaian token
6. **`/learn "Morning routine: all systems go"`** — save hasil ke memory + knowledge

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Morning Routine
- Profile: gratis
- Doctor: PASS
- Token: [usage]
- Status: ready
```

## 🔴 Error Recovery
- Jika `/go` gagal: jalankan manual `.\scripts\llm-preprocess.ps1 -Query "morning routine"`
- Jika `/start-free` gagal: cek koneksi internet, 9Router mungkin perlu di-start manual
- Jika `/admin` gagal: jalankan `.\scripts\admin-update.ps1` langsung dari terminal
- Jika `/quality-gate` gagal: ada issue yang perlu di-fix dulu

## Task

$ARGUMENTS
