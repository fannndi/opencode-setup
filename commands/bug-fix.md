---
description: [COMBO] Bug Fix — preprocess + build-fix + quality-gate + memory + learn
type: combo
agent: build
---
# Bug Fix
Fix error build + verifikasi + simpan solusi — dengan enriched context.
## Skills yang Diaktifkan
error-handling, verification-loop, continuous-learning-v2, coding-standards
## Instruksi
1. **`/go "fix bug: [description]"`**
2. `/build-fix` — AI analisa dan fix error build
3. `/quality-gate` — verifikasi fix berhasil
4. `memory add-error "[error]" "[solution]"` — simpan solusi
5. **`/learn "Fixed: [bug description]"`**
## Task
$ARGUMENTS
