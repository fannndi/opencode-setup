---
description: Save session results to memory + knowledge
---

# Learn

Simpan hasil kerja ke memory dan knowledge base.

## Flow

```powershell
# Save ke memory
.\scripts\memory.ps1 -Action save -Value "$ARGUMENTS"

# Extract pattern ke knowledge (PERFORMANCE mode only)
.\scripts\knowledge.ps1 -Action save -Key "session-$(Get-Date -Format 'yyyyMMdd')" -Value "$ARGUMENTS" -Category "sessions"
```

## Output

- Memory: `Project/Memory/<slug>/sessions/YYYY-MM-DD.md`
- Knowledge: `Project/Knowledge/<slug>/sessions/`

## Task

$ARGUMENTS
