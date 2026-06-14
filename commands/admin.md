---
description: Update ECC + 9Router, rebuild plugin, doctor check
---

# Admin Update

Update ECC dan 9Router ke versi terbaru, rebuild plugin, dan cek kesehatan.

## Instructions

Jalankan script berikut:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\admin-update.ps1
```

## Yang Dilakukan

| Step | Aksi |
|------|------|
| 1/6 | Pull ECC repo + catat perubahan |
| 2/6 | Pull 9Router repo + catat perubahan |
| 3/6 | Rebuild plugin jika ada opencode-related update |
| 4/6 | Doctor check (skills, 9Router, combos, config) |
| 5/6 | Save admin log |
| 6/6 | Summary |

## Output

ECC dan 9Router akan ter-update, changelogs terisi, plugin di-rebuild jika perlu.

## Task

$ARGUMENTS
