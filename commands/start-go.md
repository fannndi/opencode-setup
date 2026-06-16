---
description: Morning routine — auto-heal daily startup (go models)
---

# Start Go

Morning routine untuk go models. Auto-heal: check + fix otomatis.

## Usage

```
/start-go
```

## Workflow

| Step | Action | Auto-fix? |
|------|--------|-----------|
| 1 | LLM: 9Router install/start/health/combos | ✅ |
| 2 | Pre-flight: node, git, opencode | ❌ |
| 3 | ECC: clone/pull | ✅ |
| 4 | Plugin: build | ✅ |
| 5 | Config: apply go profile | ✅ |
| 6 | Model test: ping combo models | ❌ |
| 7 | Summary: GO / NO GO | — |

## Execution

```powershell
.\scripts\start.ps1 -Profile go
```

## Warning

Go models punya limited quota. Gunakan dengan bijak.
