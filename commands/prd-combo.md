---
description: [COMBO] PRD — preprocess + generate-prd + project-analyze + learn
type: combo
agent: build
---
# PRD Combo
Ubah ide jadi PRD + analisa — dengan enriched context.
## Skills yang Diaktifkan
blueprint, product-capability, architecture-decision-records
## Instruksi
1. **`/go "generate PRD for [idea]"`** — preprocess context
2. `/generate-prd "deskripsi ide"` — AI buat PRD
3. `/project-analyze` — AI analisa PRD → ai-notes.md
4. **`/learn "PRD generated for [project]"`**
## Task
$ARGUMENTS
