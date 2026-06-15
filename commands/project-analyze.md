---
description: Analisa PRD dan buat ai-notes.md dengan rekomendasi skills, commands, dan architecture
agent: build
---

# Project Analyze

Analisa PRD.md dan buat rekomendasi lengkap untuk project ini.

## Instructions

1. Baca file `prd.md` di project root
2. Set project path dulu atau kasih parameter:
```powershell
.\scripts\project-analyze.ps1 -ProjectPath "C:\path\to\project"
```
3. Baca `Feature/list.md` dan `Skill/skill-list.md` untuk referensi
4. Generate file `ai-notes.md` di project root

## Yang Harus Di-analyze

### Dari PRD:
- Tipe aplikasi (web, mobile, desktop, API, dll)
- Bahasa/stack yang dibutuhkan
- Fitur-fitur utama
- Komponen-komponen (frontend, backend, database, dll)
- Kompleksitas project

### Dari Feature/list.md:
- Skills yang relevan (berdasarkan stack)
- Agents yang dibutuhkan
- Commands yang berguna
- Hooks yang sesuai
- Rules yang applicable

### Dari Skill/skill-list.md:
- Skill spesifik per bahasa/framework
- Skill workflow (tdd, verification, security)
- Skill domain (jika ada kebutuhan spesifik)

## Format ai-notes.md

```markdown
# AI Notes — [Project Name]

**Generated:** [tanggal]
**PRD Source:** prd.md

---

## Project Overview

[Ringkasan project dari PRD]

## Detected Stack

| Komponen | Pilihan | Alasan |
|----------|---------|--------|
| Frontend | [framework] | [alasan] |
| Backend | [framework] | [alasan] |
| Database | [database] | [alasan] |
| Language | [bahasa] | [alasan] |

## Recommended Skills

### Core (always)
- tdd-workflow
- security-review
- coding-standards
- verification-loop

### Project-Specific
- [skill-1] — [kenapa]
- [skill-2] — [kenapa]
- [skill-3] — [kenapa]

### Domain-Specific (jika ada)
- [skill] — [kenapa]

## Recommended Agents

| Agent | Kapan Dipakai |
|-------|---------------|
| [agent-1] | [use case] |
| [agent-2] | [use case] |

## Recommended Commands

| Command | Kapan Dipakai |
|---------|---------------|
| [command-1] | [use case] |
| [command-2] | [use case] |

## Recommended Rules

| Rules | Bahasa/Framework |
|-------|------------------|
| common | Universal |
| [language] | [bahasa] |

## Architecture Suggestion

[Diagram atau penjelasan arsitektur yang disarankan]

## Implementation Phases

### Phase 1: [nama]
- [ ] [task-1]
- [ ] [task-2]

### Phase 2: [nama]
- [ ] [task-1]
- [ ] [task-2]

## Notes

[Catatan tambahan]
```

## Task

$ARGUMENTS

