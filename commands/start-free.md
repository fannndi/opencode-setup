---
description: Daily workflow - free models with auto-fallback
agent: build
---

# Start Free

Jalankan daily workflow untuk free models.

## Instructions

1. Jalankan script berikut (dari mana saja):
```powershell
.\scripts\start.ps1 -Profile gratis
```

2. Review output workflow

3. Jika ada issues, troubleshoot

4. Setelah workflow selesai, user bisa langsung mulai coding

## Expected Output

Workflow akan:
- Check repos (clone/pull ECC + 9Router)
- Sync changelog
- Rebuild plugin jika ada opencode changes
- Test 9Router (auto-start jika mati)
- Test models (oc/mimo-v2.5-free, oc/deepseek-v4-flash-free)
- Apply profile gratis ke global config
- Tampilkan status summary

## Task

$ARGUMENTS

