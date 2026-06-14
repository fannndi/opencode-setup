---
description: Load project template untuk quick start
agent: build
---

# Template Command

Load project template untuk quick start.

## Instructions

1. Tampilkan daftar template yang tersedia:

```powershell
Get-ChildItem ".\templates" -Directory | Select-Object Name
```

2. User pilih template, lalu jalankan:

```powershell
.\scripts\template-loader.ps1 -Template [nama-template]
```

3. Script akan:
   - Copy template docs/ ke project
   - Generate docs/ structure sesuai template
   - Apply project-specific skills

## Available Templates

| Template | Stack | Use Case |
|----------|-------|----------|
| `flutter-firebase` | Dart + Firebase | Mobile app |
| `go-api` | Go + PostgreSQL | REST API |
| `nextjs-fullstack` | Next.js + Prisma | Fullstack web |
| `python-fastapi` | Python + FastAPI | API service |

## Task

$ARGUMENTS
