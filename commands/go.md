---
description: Universal combo — goal-based, AI decompose, preprocess + execute + learn
---

# Go — Universal Combo

Satu command untuk semua workflow. Goal-based, bukan step-based.

## Cara Kerja

1. **Preprocess** — jalankan `llm-preprocess.ps1` (intent → skill index 270 → feature index 600+ → memory → knowledge)
2. **AI Decompose** — AI tentukan langkah yang relevan untuk goal ini
3. **Execute** — jalankan step dengan auto-recovery (error = skip → retry → log)
4. **Learn** — simpan hasil ke memory + knowledge via `knowledge-miner.ps1`

## Contoh

| Perintah | Yang Dilakukan |
|----------|----------------|
| `/go morning routine` | Update system, start 9Router, health check, token stats |
| `/go review project` | Code review + security scan + verify + learn |
| `/go fix bug: [desc]` | Build-fix + quality-gate + error log ke knowledge |
| `/go deploy v1.2` | Verify + quality-gate + update-docs + commit |
| `/go setup project` | Start-free + set-project + code-analyze + learn |

## Constraints (otomatis)

| Constraint | Sumber |
|------------|--------|
| Profile | session → last_profile |
| Project | registry → active_project |
| Mode | llm-mode.json (eco/balanced/performance) |
| Last action | session → last_action |

## Integrasi

- **Skill index** — 270 skills dari `Skill/skill-list.md`
- **Feature index** — 600+ features dari `Feature/list.md`
- **Memory** — session logs per project (`Project/Memory/`)
- **Knowledge** — patterns per project (`Project/Knowledge/`)
- **Error recovery** — built-in, gak perlu manual

## Task

$ARGUMENTS
