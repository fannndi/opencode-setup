# Changelog — opencode-setup

Semua perubahan penting di project ini.

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

### Fixed
- 8 broken path references (`clone-repo.ps1` → `clone.ps1`, `sync-changelog.ps1` → `sync.ps1`)
- API key security — live keys replaced with placeholders
- Hardcoded absolute paths → dynamic `$ROOT_DIR` in scripts
- Fragile cookie parsing in `start.sh` — replaced with `curl -b`
- Profile restore scripts auto-fix hardcoded paths on copy

### Changed
- README rewritten with complete workflow + setup dari 0 guide
- All commands use relative paths
- `analyze-project.sh` uses dynamic heredoc paths
- `project-analyze.sh` uses dynamic heredoc paths

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
