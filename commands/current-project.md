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
    Project:        service-hub
    Path:           C:\Users\FANNNDI\Documents\service-hub
    GitHub:         https://github.com/fannndi/service-hub
    Profile:        gratis
    Stack:          flutter
    Last action:    /code-analyze

  Registered Projects:
  ─────────────────────────────────────────
   * service-hub        (active)
      Path:   C:\Users\FANNNDI\Documents\service-hub
      GitHub: https://github.com/fannndi/service-hub

    expense-tracker
      Path:   C:\Users\FANNNDI\Documents\expense-tracker
```

## Task

$ARGUMENTS
