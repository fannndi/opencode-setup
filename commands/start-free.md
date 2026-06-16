---
description: Morning routine — auto-heal daily startup (free models)
---

# Start Free

Morning routine untuk free models. Auto-heal: check + fix otomatis.

## Usage

```
/start-free
```

## Workflow

| Step | Action | Auto-fix? |
|------|--------|-----------|
| 1 | LLM: 9Router install/start/health/combos | ✅ |
| 2 | Pre-flight: node, git, opencode | ❌ |
| 3 | ECC: clone/pull | ✅ |
| 4 | Plugin: build | ✅ |
| 5 | Config: apply gratis profile | ✅ |
| 6 | Model test: ping combo models | ❌ |
| 7 | Summary: GO / NO GO | — |

## Execution

```powershell
.\scripts\start.ps1 -Profile gratis
```

## After

Jika GO → `opencode` langsung mulai coding.
