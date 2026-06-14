---
description: [COMBO] Generate — template + create boilerplate
type: combo
agent: build
---

# Generate

Load template + generate komponen — 1x jalan.

## ⚡ Auto Docs Trigger
Sebelum mulai, baca:
- `Feature/list.md` — fitur yang tersedia
- `templates/` — template yang bisa dipilih

## Skills yang Diaktifkan
| Skill | Sumber | Fungsi |
|-------|--------|--------|
| coding-standards | Feature | Konvensi kode |
| project-stack | Feature | Deteksi stack |
| ECC 42 framework skills | Feature | Patterns per framework |

## Instruksi
1. `/template flutter-firebase` (atau template lain) — load template
2. `/create widget nama` — generate widget
3. `/create api nama` — generate API route
4. `/create model nama` — generate model/entity
5. `/create test nama` — generate test file

## ✅ Auto-Changelog
```
### YYYY-MM-DD — Generate
- Template: [nama]
- Components: [daftar]
```

## 🔴 Error Recovery
- Jika `/template` gagal: pastikan nama template benar (flutter-firebase, go-api, nextjs-fullstack, python-fastapi)
- Jika `/create` gagal: pastikan tipe benar (widget, api, test, model)
- Pastikan project path sudah di-set dengan `/set-project`

## Task

$ARGUMENTS
