---
description: [COMBO] Security — security-scan + quality-gate + research
agent: build
---

# Security

Audit keamanan + verifikasi + cari referensi — 1x jalan.
Type: combo (memanggil sub-command security-scan, quality-gate)

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur security yang tersedia
- `Skill/skill-list.md` — skill security yang bisa dipakai
- `README.md` — overview

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| security-review | Feature | OWASP checklist lengkap |
| security-scan | Feature | Config scanning |
| security-bounty-hunter | Feature | Bug bounty guidance |
| evm-token-decimals | Feature | EVM token safety (jika DeFi) |
| deep-research | Feature | Riset mendalam |

## Instruksi
1. `/security-scan` — full OWASP security review (sub-command)
2. `/quality-gate` — verifikasi
3. `/research "best practices [topik]"` — cari referensi keamanan terkini

## 🔴 Error Recovery
- Jika `/security-scan` gagal: cek 9Router running, coba `/start-free` dulu
- Jika `/quality-gate` gagal: fix issues dulu, lalu ulangi
- Jika semua gagal: `/reset-session` lalu mulai ulang

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Security
- Issues: [jumlah]
- Severity: [critical/high/medium/low]
- Fixed: [jumlah]
```

## Task

$ARGUMENTS
