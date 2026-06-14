---
description: Scan existing source code → ai-notes.md dengan rekomendasi skill & architecture
agent: build
---

# Code Analyze

Scan existing source code, deteksi stack, architecture, patterns, dan generate ai-notes.md.

## Workflow

1. Set project path dulu atau kasih parameter:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\code-analyze.ps1 -ProjectPath "C:\path\to\project"
```

Atau kalau sudah pakai session:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\code-analyze.ps1
```

2. Script akan melakukan:
   - Scan semua folder (frontend, backend, lib, dll)
   - Baca dependencies file (package.json, pubspec.yaml, go.mod, dll)
   - Analisa imports & patterns
   - Match skills dari `Skill/skill-list.md`
   - Generate `ai-notes.md` di project root

## Yang Didapat

Setelah `ai-notes.md` ter-generate, kamu bisa:
- `/analyze-project` — load skills yang sesuai
- `/tdd` — test-driven development
- `/code-review` — review existing code
- `/security-scan` — security audit (OWASP)
- `/verify` — verification loop

## Task

$ARGUMENTS
