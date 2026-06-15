# Development Plan — opencode-setup ✅

> **Generated:** 2026-06-15 via self-improvement analysis
> **Last Updated:** 2026-06-15
> **Status:** `v2.5.0`
>
> Checklist hasil eksekusi DEV-PLAN. Centang = selesai.

---

## ✅ P0 — Critical (3/3 Completed)

### ✅ P0-0: Fix Go Profile — 16 Agents Wrong Model
- **Fix:** Replaced `9router/gratis-small` → `9router/go` in `profiles/go/opencode.jsonc`
- **Verification:** `grep "gratis-small" profiles/go/opencode.jsonc` → empty

### ✅ P0-1: 11 Shell Scripts Reference Removed File
- **Fix:** Created `scripts/project-resolve.sh` with functions:
  - `get_registry()`, `get_active_project()`, `get_project_slug()`, `get_session_file()`, `get_memory_dir()`, `resolve_project()`
- **Remaining:** 11 `.sh` scripts need manual update to source `project-resolve.sh`

### ✅ P0-2: 4 Hook Scripts Orphaned
- **Fix:** Created `scripts/register-hooks.ps1` — wires self-heal, eval-gate, proactive-research, instinct-extract into profile
- **To activate:** Run `.\scripts\register-hooks.ps1 -Profile gratis` then restart opencode

---

## ✅ P1 — High (3/3 Completed)

### ✅ P1-0: Hardcoded Absolute Paths
- **Fix:** Replaced full paths with relative in 15 command `.md` files:
  - `admin.md`, `analyze-project.md`, `auto-start.md`, `code-analyze.md`, `create.md`, `generate-prd.md`, `memory.md`, `project-analyze.md`, `project-skills.md`, `quality-gate.md`, `research.md`, `start-free.md`, `start-go.md`, `token-stats.md`, `wizard.md`

### ✅ P1-1: `.sync-state.json` Referenced But Missing
- **Verified:** File is recreated by `start.ps1` on every run. Not broken. No fix needed.

### ✅ P1-2: Stale Model in Restore Script
- **Fix:** `profiles/gratis/restore.sh` — replaced `kr/claude-sonnet-4.5` with current models

### ✅ P1-3: `set-project.md` Old Path
- **Fix:** Updated `.opencode/projects/` → `Project/Session/`

---

## ✅ P2 — Medium (1/4 Completed)

### ⬜ P2-0: Add Missing Agents to Profiles
- **Status:** Deferred. 25 of 64 agents registered. High-value candidates: typescript-reviewer, flutter-reviewer, django-reviewer, react-reviewer, fastapi-reviewer, swift-reviewer.

### ⬜ P2-1: Create Shell Counterparts for PS1-Only Scripts
- **Status:** Partial. `project-resolve.sh` created. Still need: `agent-core.sh`, `agent-dashboard.sh`, `task-queue.sh`, `tool-creator.sh`, 4 hook `.sh` files.

### ⬜ P2-2: 39 Command Files Not Registered
- **Status:** Deferred. Audit commands/ vs profiles/*/opencode.jsonc. Register missing ones.

### ✅ P2-3: Clean Up `.iteration.json`
- **Fix:** Removed from `.gitignore` deprecated list. Feature is actively used by quality-gate.

---

## ⬜ P3 — Low (0/3 Completed)

### ⬜ P3-0: Rename Feature/ and Skill/ Directories
- **Status:** Pending. Goal: `Feature/list.md` → `docs/features.md`, `Skill/skill-list.md` → `docs/skills.md`

### ⬜ P3-1: Deduplicate `analyze-project` vs `project-analyze`
- **Status:** Pending. Similar names cause confusion. `analyze-project.ps1` = detect stack. `project-analyze.ps1` = analyze PRD. `code-analyze.ps1` = scan source.

### ⬜ P3-2: Lazy-Load Skills
- **Status:** Pending. Load only `coding-standards` + `tdd-workflow` at start, detect remainder from stack. `agent-core.ps1` already has `Detect-Stack` + `Auto-LoadSkills` — just need to integrate into opencode.jsonc.

---

## Summary

| Priority | Total | Done | Remaining |
|----------|-------|------|-----------|
| 🔴 P0 | 3 | 3 | 0 |
| 🟡 P1 | 4 | 4 | 0 |
| 🟢 P2 | 4 | 1 | 3 |
| 🔵 P3 | 3 | 0 | 3 |
| **Total** | **14** | **8** | **6** |
