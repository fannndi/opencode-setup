---
description: Verify code quality, track iterations, check fixes
agent: build
---

# Quality Gate

Verify apakah issues dari code-review sudah di-fix. Track iteration count.

## Instructions

```powershell
.\scripts\quality-gate.ps1
```

## Yang Dicek

| Check | Detail |
|-------|--------|
| Git status | Modified files, staged changes |
| Build | flutter analyze, tsc --noEmit |
| Tests | flutter test, npm test |
| Iteration | Attempt tracking |

## Output

- ✅ QUALITY GATE PASSED — semua check lulus
- ⚠️ Issues remaining — tampilkan jumlah dan attempt

## Task

$ARGUMENTS

