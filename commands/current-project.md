---
description: Tampilkan project aktif + list semua project
---

# Current Project

Tampilkan project yang sedang aktif dan list semua project yang terdaftar.

## Instructions

```powershell
# Show active project + session status
.\scripts\session-manager.ps1 -Action status

# List all registered projects
.\scripts\session-manager.ps1 -Action list

# Switch project
.\scripts\session-manager.ps1 -Action switch -ProjectPath "C:\path\to\other\project"
```

## Output

```
  Session Status:
    Project:        my-project
    Path:           C:\path\to\my-project
    GitHub:         https://github.com/username/my-project
    Profile:        gratis
    Stack:          detected
    Last action:    /code-analyze

  Registered Projects:
  ─────────────────────────────────────────
   * my-project        (active)
      Path:   C:\path\to\my-project
      GitHub: https://github.com/username/my-project

    other-project
      Path:   C:\path\to\other-project
```

## Task

$ARGUMENTS
