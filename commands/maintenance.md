---
description: [COMBO] Maintenance — admin + quality-gate + reset-session
type: combo
agent: build
---

# Maintenance

Update system + cek kesehatan + reset session — 1x jalan.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `README.md` — overview command
- `CHANGELOG.md` — update terbaru
- `log-admin.md` — history maintenance sebelumnya

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| verification-loop | Feature | Build/type/lint/test |
| strategic-compact | Feature | Context compaction |
| cost-aware-llm-pipeline | Feature | Optimasi token & biaya |
| context-budget | Feature | Manajemen context window |

## Instruksi
1. `/admin` — update ECC + 9Router + doctor check
2. `/quality-gate` — verifikasi sistem masih sehat
3. `/reset-session` — reset session (opsional)

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Maintenance
- ECC: [SHA]
- 9Router: [SHA]
- Doctor: PASS/FAIL
- Session: reset/tidak
```

## 🔴 Error Recovery
- Jika `/admin` gagal: jalankan `.\scripts\admin-update.ps1` langsung dari terminal
- Jika `/quality-gate` gagal: cek output untuk melihat issue spesifik
- Jika session corrupt: `/reset-session` lalu mulai ulang

## Task

$ARGUMENTS
