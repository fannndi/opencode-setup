---
description: Tampilkan skills yang cocok untuk project saat ini
agent: build
---

# Project Skills

Tampilkan skills yang cocok untuk project yang sedang aktif.

## Instructions

Jalankan script berikut:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\project-skills.ps1
```

Atau untuk project tertentu:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\project-skills.ps1 -ProjectPath "C:\path\to\project"
```

## Output

- Core skills (selalu di-load)
- Project-specific skills (berdasarkan stack)
- Recommended commands
- Total skills count

## Task

$ARGUMENTS
