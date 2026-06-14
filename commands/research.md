---
description: Web search + AI ringkasan via 9Router
---

# Research

Cari informasi dari internet dan dapatkan ringkasan dari AI.

## Instructions

```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\research.ps1 -Query "topik yang ingin dicari"
```

Atau dengan quotes untuk query panjang:
```powershell
C:\Users\FANNNDI\Documents\opencode-setup\scripts\research.ps1 -Query "Flutter best practices 2026"
```

## Yang Dilakukan

| Step | Aksi |
|------|------|
| 1/3 | Mencari informasi via 9Router search/fetch |
| 2/3 | Chat model merangkum hasil |
| 3/3 | Tampilkan ringkasan + sumber |

## Catatan

Untuk hasil riset real-time, connect search provider:
- Buka 9Router Dashboard → Providers
- Add Tavily (free tier available)
- Atau Exa / Brave Search

## Task

$ARGUMENTS
