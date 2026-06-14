---
description: Mulai semua workflow dalam 1 command
---

# Auto Start

Chain semua workflow dalam 1 command: start → analyze → detect → ready.

## Instructions

```powershell
cd C:\Users\FANNNDI\Documents\opencode-setup
.\scripts\auto-start.ps1 -Profile gratis -Mode existing -ProjectPath "C:\path"
```

Atau pakai session:
```powershell
.\scripts\auto-start.ps1 -Profile gratis
```

## Mode

| Mode | Use Case |
|------|----------|
| `existing` | Source code sudah ada → code-analyze |
| `new` | Project baru dengan PRD → project-analyze |

## Output

1/4 Start workflow → 2/4 Analyze code → 3/4 Detect stack → 4/4 Save memory

## Task

$ARGUMENTS
