---
description: [COMBO] Deploy — verify + quality-gate + update-docs
agent: build
---

# Deploy

Verifikasi + quality gate + update dokumentasi — siap deploy.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `CHANGELOG.md` — catat perubahan untuk release
- `README.md` — pastikan dokumentasi sesuai
- `docs/` — update jika ada perubahan API

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| verification-loop | Feature | Build/type/lint/test |
| deployment-patterns | Feature | CI/CD, health check, rollback |
| docker-patterns | Feature | Container, orchestrasi |
| production-audit | Feature | Kesiapan produksi |

## Instruksi
1. `/verify` — full verification (build + test + lint)
2. `/quality-gate` — quality gate
3. `/update-docs` — update dokumentasi
4. `git add -A && git commit -m "release: ..."` — siap push

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Deploy Prep
- Build: PASS/FAIL
- Tests: PASS/FAIL
- Quality: PASS/FAIL
- Docs: updated
```

## Task

$ARGUMENTS
