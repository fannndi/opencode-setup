---
description: [COMBO] Quick review — code-review + security-scan + verify + research
type: combo
agent: build
---

# Quick Review — Combo

Review kode + security + verify + research dalam 1 command.
Jalankan sebelum commit.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur yang tersedia
- `Skill/skill-list.md` — skill yang bisa dipakai
- `CHANGELOG.md` — update terbaru

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| coding-standards | Feature | KISS, DRY, YAGNI — review kualitas |
| security-review | Feature | OWASP checklist — audit keamanan |
| verification-loop | Feature | Build/type/lint/test — verifikasi |
| search-first | Feature | Research sebelum coding |
| deep-research | Feature | Riset mendalam best practices |

## Instruksi
1. `/code-review` — review kualitas kode
2. `/security-scan` — cek keamanan (sub-command, bukan combo)
3. `/verify` — build + test + lint
4. `/research "best practices [topik]"` — cari referensi (opsional)

## 🔴 Error Recovery
- Jika `/code-review` gagal: pastikan project path sudah di-set dengan `/set-project`
- Jika `/security-scan` gagal: cek koneksi 9Router
- Jika `/verify` gagal: fix error build dulu dengan `/build-fix`

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Quick Review
- Issues: [jumlah]
- Security: PASS/FAIL
- Build: PASS/FAIL
- Status: [ready/perlu fix]
```

## Task

$ARGUMENTS
