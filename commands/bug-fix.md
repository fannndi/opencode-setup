---
description: [COMBO] Bug Fix — build-fix + quality-gate + memory
agent: build
---

# Bug Fix

Fix error build + verifikasi + simpan solusi — 1x jalan.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `project-memory/errors/` — error sebelumnya dan solusinya
- `CHANGELOG.md` — update terbaru

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| error-handling | Feature | Typed errors, boundaries, retry |
| verification-loop | Feature | Build/type/lint/test |
| continuous-learning-v2 | Feature | Ekstraksi pola dari session |
| coding-standards | Feature | KISS, DRY, YAGNI |

## Instruksi
1. `/build-fix` — AI analisa dan fix error build
2. `/quality-gate` — verifikasi fix berhasil
3. `memory add-error "nama error" "solusi"` — simpan solusi ke memori

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Bug Fix
- Error: [nama]
- Solution: [deskripsi]
- Iterations: [jumlah]
- Status: fixed ✅
```

## Task

$ARGUMENTS
