# Session Persistence — Simpan Status Workflow

## Apa Itu?

File `.opencode-session.json` menyimpan status workflow antar sesi OpenCode. 
Jadi kalau restart, tidak perlu ulang dari awal.

## Format

```json
{
  "version": "1.0",
  "last_profile": "gratis",
  "stack": "dart-flutter",
  "skills_loaded": ["tdd-workflow", "security-review", "coding-standards", "dart-flutter-patterns"],
  "rules_applied": ["common", "dart"],
  "workflow_state": {
    "prd_analyzed": true,
    "ai_notes_generated": true,
    "analyze_project_done": true
  },
  "last_action": "/analyze-project",
  "created_at": "2026-06-14T10:00:00+07:00",
  "updated_at": "2026-06-14T10:30:00+07:00"
}
```

## Alur Kerja

```
/start-free
    ├── Cek .opencode-session.json
    │   ├── ADA → Lanjut (skip yang udah dilakuin)
    │   └── TIDAK ADA → Mulai dari awal
    ├── Check repos
    ├── Sync changelog
    ├── Test 9Router
    ├── Test models
    ├── Apply profile
    └── Update session file

/project-analyze
    ├── Baca prd.md
    ├── Baca session file → tau stack sebelumnya
    ├── Generate ai-notes.md
    └── Update session: prd_analyzed = true

/analyze-project
    ├── Baca session file → tau stack + skills
    ├── Scan indicators
    ├── Match stack
    ├── Load skills
    └── Update session: analyze_project_done = true
```

## Reset Session

```powershell
# Hapus session file
Remove-Item .opencode-session.json

# Atau reset via command
/reset-session
```

## Lihat Juga

- [Daily Workflow](../04-usage/03-daily-workflow.md)
- [Analyze Project](../04-usage/04-analyze-project.md)
