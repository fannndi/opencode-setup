# Changelog — opencode-setup

Semua perubahan penting di project ini.

---

## [2.5.0] — 2026-06-15

### Fixed (from DEV-PLAN execution)
- **Go profile model routing** — 16 agents now use `9router/go` instead of `9router/gratis-small`
- **Absolute paths** — 15 command `.md` files now use relative `.\scripts\` paths instead of hardcoded `C:\Users\...`
- **Restore script** — `profiles/gratis/restore.sh` model references synced with current config
- **set-project.md** — Path updated from `.opencode/projects/` to `Project/Session/`

### Added
- **project-resolve.sh** — Shell equivalent of project-resolve.ps1 for Linux/macOS compatibility
- **register-hooks.ps1** — Wires 4 agent hooks (self-heal, eval-gate, proactive-research, instinct-extract) into profile config
- **DEV-PLAN.md** — Self-improvement development plan with checklist (14 tasks, 8 completed)

### Changed
- **.gitignore** — Removed `.opencode/` and `.iteration.json` deprecated listings (files still actively used)

---

## [2.4.0] — 2026-06-15

### Added — AI Agent System
- **Agent Core** (`agent-core.ps1`) — Intent detection, stack auto-detect, skill auto-loader, session resume, task decomposition
- **Self-Healing Hook** (`hooks/self-heal.ps1`) — Post-edit typecheck + error count detection
- **Instinct Engine** (`hooks/instinct-extract.ps1`) — Stop hook: auto-extract error→solution patterns, framework dependencies
- **Eval Gate** (`hooks/eval-gate.ps1`) — Post-edit hook: auto-run tests on spec/test file changes
- **Proactive Research** (`hooks/proactive-research.ps1`) — Track unknown libraries, auto-log discoveries
- **Agent Dashboard** (`agent-dashboard.ps1`) — Project overview, system health, memory stats, recommendations
- **Task Queue** (`task-queue.ps1`) — Autonomous DAG execution engine: goal → decompose → execute
- **Tool Creator** (`tool-creator.ps1`) — Template-based script/command generation
- **8 new commands** — `/agent-core`, `/dashboard`, `/task-queue`, `/tool-create`, `/resume`, `/detect`, `/auto-load`

### Changed
- **project-resolve.ps1** — Stack detection integrated, registry tracks stack per project
- **session-manager.ps1** — Supports `list` and `switch` for multi-project management
- **opencode.jsonc (gratis)** — 8 agent commands registered

### Flow
```
User: "bikin fitur A"
→ /task-queue "bikin fitur A"
→ Agent detect stack → auto-load skills
→ Decompose: backend → frontend → test
→ Execute each subtask
→ Log ke memory, update session
```

---

### Added
- **Per-project session & memory** — Setiap project punya session.json + memory/ sendiri di `Project/<slug>/`
- **Project directory structure** — `Project/Session/<slug>/`, `Project/Memory/<slug>/`, `Project/<slug>/` (source)
- **project-resolve.ps1** — Core script: registry CRUD, path resolve, auto-clone dari GitHub
- **session-manager.ps1** — Updated: per-project sessions, list all projects, switch project
- **memory.ps1** — Updated: per-project memory directories
- **GitHub auto-clone** — `/set-project` sekarang minta GitHub URL, clone ke `Project/<slug>/`
- **registry.json** — Path-to-project mapping dengan last_seen tracking
- **P3 tasks** — 10 task quality & infrastructure baru di service-hub TODO.md
- **Logging, Redis, Monitoring** — Task untuk AI agent di TODO.md (P3)

### Changed
- **13 scripts** — Updated from flat `.opencode-session.json` to per-project session via project-resolve
- **start.ps1** — Session save/write menggunakan `Project/Session/<slug>/session.json`
- **token-tracker.ps1** — Membaca session dari active project
- **.gitignore** — Add `Project/` (cloned repos + user session/memory data)
- **Set-project command** — Wajib GitHub URL + auto-clone

### Removed
- `.opencode-session.json` — Migrated to per-project format
- `.sync-state.json` — Cleaned up
- `.opencode/` directory — Replaced by `Project/`

---
## [2.2.0] — 2026-06-15

### Fixed
- **security-scan rename** — base command renamed from `security` → `security-scan` to fix duplicate key conflict. Combo `security` now calls `/security-scan` as sub-command.
- **AI clarity** — All 10 combo commands now have `type: combo` frontmatter for AI disambiguation.
- **Error Recovery** — All 10 combos now have `## 🔴 Error Recovery` section with concrete fix steps.
- **Restart protocol** — "restart opencode" now includes concrete steps (Ctrl+C → `opencode`).
- **Cyclic combo fix** — `security` combo no longer calls itself. Calls `/security-scan` instead.
- **References updated** — `commands/code-analyze.md` and `commands/quick-review.md` updated to use `/security-scan`.
- **README** — Workflow examples updated, quick-review steps corrected.

### Changed
- **10 Combos** — Complete with skill mappings from Feature/list.md + Skill/skill-list.md:
  🌅 Morning Routine | 🚀 Start Project | 📋 PRD Combo | ⚡ Quick Review
  🔍 Full Audit | 🛠️ Maintenance | 🎨 Generate | 🐛 Bug Fix | 🔒 Security | 🚢 Deploy
- **Command type system** — All combos marked `type: combo`, primitives have no type (default).
- **security-scan** registered in all 3 configs (global, gratis, go).

---

## [2.1.0] — 2026-06-14

### Added
- **Session Persistence** — `.opencode-session.json` menyimpan status workflow antar sesi
- **Auto-Update Detection** — `/start-free` otomatis deteksi git changes, rebuild plugin
- **Project Templates** — 4 template: Flutter+Firebase, Go API, Next.js, Python FastAPI
- `/template` command — load project template
- `/reset-session` command — reset session state
- `scripts/session-manager.ps1` — session management
- `scripts/template-loader.ps1` — template loader
- `profiles/gratis/restore.sh` — cross-platform restore
- `profiles/go/restore.sh` — cross-platform restore
- `docs/07-advanced/03-session-persistence.md` — session docs

### Changed
- **Combo gratis updated** — `mmf/mimo-auto → oc/deepseek-v4-flash-free → oc/mimo-v2.5-free`
- Combo `go` removed (暂时 skip)
- Profile models updated: removed `oc/nemotron-3-ultra-free`, `kr/claude-sonnet-4.5`; added `mmf/mimo-auto`
- README rewritten with complete workflow + setup dari 0 guide
- All commands use relative paths

### Fixed
- 8 broken path references (`clone-repo.ps1` → `clone.ps1`, `sync-changelog.ps1` → `sync.ps1`)
- API key security — live keys replaced with placeholders
- Hardcoded absolute paths → dynamic `$ROOT_DIR` in scripts
- Fragile cookie parsing in `start.sh` — replaced with `curl -b`
- Profile restore scripts auto-fix hardcoded paths on copy
- Session variable overwrite bug in `start.ps1`

---

## [2.0.0] — 2026-06-14

### Added
- Initial release
- 270+ ECC skills loaded
- 64 agents, 84 commands
- 9Router integration (RTK, Caveman Mode, Combos)
- Profile system (gratis/go)
- Combo system (gratis, go, gratis-small)
- `/analyze-project` command — auto-detect stack
- `/project-analyze` command — PRD → ai-notes.md
- `/start-free` / `/start-go` daily workflow commands
- 21 structured documentation files (Bahasa Indonesia)
- `Feature/list.md` — 600+ component inventory
- `Skill/skill-list.md` — 270 skill catalog
- `scripts/` — 10 automation scripts (ps1 + sh)
- `profiles/gratis/` + `profiles/go/` — config profiles
- `commands/` — 5 command templates

