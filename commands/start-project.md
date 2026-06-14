---
description: [COMBO] Setup project baru — start-free + code-analyze + analyze-project
type: combo
agent: build
---

# Start Project — Combo

Setup project baru dalam 1 command.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur yang tersedia
- `Skill/skill-list.md` — skill yang bisa dipakai
- `CHANGELOG.md` — update terbaru

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| tdd-workflow | Feature | Test-driven development |
| coding-standards | Feature | KISS, DRY, YAGNI, immutability |
| codebase-onboarding | Feature | Memahami codebase baru |
| 270+ ECC skills | ECC | Siap di-load sesuai stack terdeteksi |

## Instruksi
1. `/start-free` — start 9Router + test model + apply config
2. `/set-project path` — set project aktif
3. `/code-analyze` — scan source → ai-notes.md (atau `/project-analyze` jika ada PRD)
4. `/analyze-project` — deteksi stack + load skills
5. restart opencode — tekan Ctrl+C untuk keluar, lalu ketik `opencode` lagi

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Start Project
- Project: [nama]
- Status: siap
- Mode: existing/baru
```

## 🔴 Error Recovery
- Jika `/code-analyze` gagal: pastikan project path benar dengan `/set-project`
- Jika `/analyze-project` gagal: cek apakah ECC skills sudah terload
- Jika semua gagal: `/reset-session` lalu mulai dari `/morning-routine`

## Task

$ARGUMENTS
