---
description: Daily workflow - go models (limited quota)
agent: build
---

# Start Go

Jalankan daily workflow untuk go models.

## Instructions

1. Jalankan script berikut:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\start.ps1 -Profile go
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
- Test models (ocg/kimi-k2.6, ocg/qwen3.6-plus)
- Apply profile go ke global config
- Tampilkan status summary

## Warning

Go models punya limited quota. Gunakan dengan bijak.

## Task

$ARGUMENTS
