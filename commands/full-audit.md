---
description: [COMBO] Audit — preprocess + code-analyze + analyze-project + project-skills + memory + learn
type: combo
agent: build
---
# Full Audit — Combo
Audit menyeluruh dengan enriched context.
## Skills yang Diaktifkan
codebase-onboarding, coding-standards, skill-scout
## Instruksi
1. **`/go "full audit"`** — preprocess context
2. `/code-analyze` — scan source → ai-notes.md
3. `/analyze-project` — deteksi stack + load skills
4. `/project-skills` — lihat skills yang cocok
5. `memory save "Full audit: [result]"` — simpan ke memori
6. **`/learn "Audit complete"`**
## 🔴 Error Recovery
Jika gagal: cek project path dengan `/set-project`
## Task
$ARGUMENTS
