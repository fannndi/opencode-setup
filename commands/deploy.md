---
description: [COMBO] Deploy — preprocess + verify + quality-gate + update-docs + learn
type: combo
agent: build
---
# Deploy
Verifikasi + quality gate + update dokumentasi — dengan enriched context.
## Skills yang Diaktifkan
verification-loop, deployment-patterns, docker-patterns, production-audit
## Instruksi
1. **`/go "deploy"`**
2. `/verify` — full verification (build + test + lint)
3. `/quality-gate` — quality gate
4. `/update-docs` — update dokumentasi
5. `git add -A && git commit -m "release: ..."` — siap push
6. **`/learn "Deploy prepped: [version]"`**
## Task
$ARGUMENTS
