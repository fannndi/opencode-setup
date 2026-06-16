---
description: Admin update — pull repos, changelog, rebuild, doctor check
---

# Admin Update

Update ECC + 9Router, lihat changelog, rebuild plugin, doctor check.

## Usage

```
/admin              # Full: pull + changelog + rebuild + doctor
/admin --doctor     # Doctor check only (no pull)
```

## Workflow

| Step | Action |
|------|--------|
| 1 | LLM: 9Router health + combos |
| 2 | Pull ECC |
| 3 | Pull 9Router |
| 4 | ECC changelog (full, tagged) |
| 5 | 9Router changelog (full, tagged) |
| 6 | Analyze: rework needed? (keyword-based) |
| 7 | Rebuild plugin if opencode changes |
| 8 | Doctor check (ECC, 9Router, combos, config) |
| 9 | Save admin log |
| 10 | Summary + recommendations |

## Changelog Tags

| Tag | Meaning | Action |
|-----|---------|--------|
| `[setup]` | Setup rework needed | Re-run /setup |
| `[config]` | Config changes | Update config |
| `[plugin]` | Plugin changes | Auto-rebuild |
| `[skill]` | New/updated skills | Auto-load |
| `[breaking]` | Breaking changes | Manual review |
| `[info]` | General changes | No action |

## Execution

```powershell
.\scripts\admin-update.ps1 $ARGUMENTS
```

## After

Follow recommendations in summary. If setup rework needed → run `/setup`.
