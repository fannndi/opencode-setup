---
description: Set project path + GitHub URL → clone + session
---

# Set Project

Set project path, clone dari GitHub, dan buat session.

## Instructions

```powershell
# Interactive — akan ditanya path dan GitHub URL
.\scripts\project-resolve.ps1 -Action resolve -ProjectPath "C:\path\to\project" -GitHubUrl "https://github.com/user/repo"

# Atau via session-manager
.\scripts\session-manager.ps1 -Action write -Key current_project -Value "C:\path\to\project"
```

## Flow

1. User masukin path project
2. System tanya GitHub URL (wajib)
3. Git clone ke path itu (kalau belum ada)
4. Buat `Project/Session/<slug>/session.json` + `memory/`
5. Register di `registry.json`
6. Set sebagai active project

## Contoh

```
/set-project C:\path\to\your-project
GitHub URL: https://github.com/username/repo
→ Cloning...
→ Session created
→ Ready!
```

## Output

- Project ter-clone
- Session + memory terbuat
- Semua command berikutnya otomatis pakai project ini

## Task

$ARGUMENTS
