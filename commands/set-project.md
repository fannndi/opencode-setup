---
description: Set project path untuk Master Control mode
---

# Set Project

Set project path yang akan digunakan oleh semua command.

## Instructions

```powershell
.\scripts\session-manager.ps1 -Action write -Key current_project -Value "C:\path\to\project"
```

## Contoh

```
/set-project C:\Users\FANNNDI\Documents\expense_tracker
/set-project "C:\Users\FANNNDI\Documents\project lain"
```

Setelah set, command `/code-analyze`, `/project-analyze`, `/analyze-project` akan otomatis menggunakan project ini.

## Task

$ARGUMENTS
