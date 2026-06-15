# Development Plan — opencode-setup

> **Generated:** 2026-06-15 via self-improvement analysis
> **Status:** v2.4.0 — AI Agent system deployed
>
> Plan ini hasil analisa otomatis dari `agent-core.ps1` + `agent-dashboard.ps1`.
> Setiap task punya konteks lengkap — file path, root cause, dan action.

---

## Priority Legend

| Label | Arti |
|-------|------|
| 🔴 P0 | Critical — broken or blocking |
| 🟡 P1 | High — degradation or inconsistency |
| 🟢 P2 | Medium — polish or missing feature |
| 🔵 P3 | Low — nice to have |

---

## 🔴 P0 — Critical

### P0-0: Fix Go Profile — 16 Agents Use Wrong Model

**Root Cause:** `profiles/go/opencode.jsonc` has 16 of 25 sub-agents using `"model": "9router/gratis-small"` instead of `"model": "9router/go"`.

**Affected agents:**
e2e-runner, doc-updater, refactor-cleaner, cpp-reviewer, cpp-build-resolver, docs-lookup, harness-optimizer, java-reviewer, java-build-resolver, kotlin-reviewer, kotlin-build-resolver, loop-operator, php-reviewer, python-reviewer, rust-reviewer, rust-build-resolver

**Action:** Replace `9router/gratis-small` → `9router/go` in all 16.

**Verification:** `grep "gratis-small" profiles/go/opencode.jsonc` → empty.

---

### P0-1: 11 Shell Scripts Still Reference Removed `.opencode-session.json`

**Root Cause:** CHANGELOG v2.4.0 removed `.opencode-session.json`. `.ps1` scripts migrated to `project-resolve.ps1`. `.sh` scripts were not updated.

**Affected scripts:**
- `scripts/start.sh` — lines 75, 89-90, 414
- `scripts/session-manager.sh` — entire file
- `scripts/token-tracker.sh` — lines 8, 19, 22
- `scripts/quality-gate.sh` — lines 12-13
- `scripts/project-skills.sh` — lines 12-13
- `scripts/create.sh` — lines 22-23
- `scripts/auto-start.sh` — lines 9, 15-16
- `scripts/code-analyze.sh` — lines 23, 32-33, 49-50
- `scripts/project-analyze.sh` — lines 23, 61-62, 73-74
- `scripts/analyze-project.sh` — lines 23, 33-34, 47-48
- `scripts/template-loader.sh` — lines 26, 29-30

**Action:**
1. Create `scripts/project-resolve.sh` — shell equivalent with functions:
   - `get_registry()` — read `Project/registry.json`
   - `get_active_project()` — return current active project path
   - `get_project_slug()` — extract folder name from path
   - `get_session_file()` — return `Project/Session/<slug>/session.json`
   - `get_memory_dir()` — return `Project/Memory/<slug>/`
2. Update all 11 `.sh` scripts to source `project-resolve.sh` instead of reading `.opencode-session.json`
3. Patch pattern:
   ```bash
   # BEFORE:
   SESSION_FILE="$ROOT_DIR/.opencode-session.json"
   if [ -f "$SESSION_FILE" ]; then
       PROJECT_PATH=$(python3 -c "import json; d=json.load(open('$SESSION_FILE')); print(d.get('current_project',''))")
   fi

   # AFTER:
   SESSION_DIR="$ROOT_DIR/scripts"
   . "$SESSION_DIR/project-resolve.sh"
   PROJECT_PATH=$(get_active_project)
   ```

**Verification:**
```bash
grep -rn "opencode-session.json" scripts/*.sh  # → should be empty
```

---

### P0-2: 4 Hook Scripts Are Orphaned — Never Wired

**Root Cause:** Files written, announced in CHANGELOG v2.4.0, but have no activation mechanism.

**Files:**
- `scripts/hooks/self-heal.ps1`
- `scripts/hooks/eval-gate.ps1`
- `scripts/hooks/instinct-extract.ps1`
- `scripts/hooks/proactive-research.ps1`

**Action (Option A — immediate):** Create `scripts/register-hooks.ps1` that:
1. Reads the current profile's `opencode.jsonc`
2. Injects the hook scripts into the `hooks` section
3. Restarts OpenCode

**Action (Option B — proper):** Convert each hook to OpenCode plugin events in `ecc/.opencode/plugins/`:
- `self-heal` → `tool.execute.after` (after Edit/Write)
- `eval-gate` → `file.edited` (on test files)
- `instinct-extract` → `session.created` (on session end)
- `proactive-research` → `tool.execute.before` (before Edit/Write)

**Verification:** Each hook fires in response to its trigger event.

---

## 🟡 P1 — High

### P1-0: Hardcoded Absolute Paths in Commands

**Root Cause:** All `commands/*.md` files use `C:\Users\FANNNDI\Documents\opencode-setup\scripts\...`.

**Files affected:** All 84 `.md` files in `commands/`.

**Action (three approaches):**
- **Short term:** Replace absolute paths with relative `.\scripts\...` in command `.md` files
- **Medium term:** Move all script paths from `.md` templates into `opencode.jsonc` command definitions (they're already there)
- **Long term:** The `.md` files become documentation-only; actual execution comes from `opencode.jsonc` `command.template` field

**Note:** The `opencode.jsonc` already has the right paths in `command.template` fields. The `.md` files are secondary. Fix only the `.md` files for consistency.

---

### P1-1: `.sync-state.json` Referenced But Missing

**Root Cause:** File was deleted in v2.4.0 cleanup. `start.ps1` line 21 still defines `$SYNC_STATE = "$ROOT_DIR\.sync-state.json"`, and `start.sh` reads it.

**Files affected:**
- `scripts/start.ps1` — line 21 (variable still defined, may be used in sync logic)
- `scripts/start.sh` — lines 190-191, 227 (reads sync state)

**Action:**
1. Check `start.ps1` lines ~190-320 for sync logic that uses `$SYNC_STATE`
2. If the sync logic is broken, either:
   a. Recreate `.sync-state.json` on admin update, OR
   b. Remove all references to it
3. Same for `start.sh`

---

### P1-2: Stale Model Reference in Restore Script

**Root Cause:** `profiles/gratis/restore.sh` line 17 references `kr/claude-sonnet-4.5` which is not in the current profile config.

**File:** `profiles/gratis/restore.sh`

**Action:** Update references to match current `opencode.jsonc` models:
- Remove: `kr/claude-sonnet-4.5`
- Current: `mmf/mimo-auto`, `oc/deepseek-v4-flash-free`, `oc/mimo-v2.5-free`

---

### P1-3: `set-project.md` Uses Old Session Path

**Root Cause:** Outdated path reference in command docs.

**File:** `commands/set-project.md` line 24

**Current:** `.opencode/projects/<slug>/session.json`
**Should be:** `Project/Session/<slug>/session.json`

**Action:** Update the path string.

---

## 🟢 P2 — Medium

### P2-0: Add Missing Agents to Profiles (10 of 39)

**Root Cause:** Only 25 of 64 agents are registered in profiles.

**High-value candidates to add:**
1. `django-reviewer`, `django-build-resolver` — Python/Django
2. `typescript-reviewer` — primary stack language
3. `flutter-reviewer`, `dart-build-resolver` — Flutter projects
4. `react-reviewer`, `react-build-resolver` — React/Next.js
5. `fastapi-reviewer` — Python API
6. `swift-reviewer` — iOS
7. `csharp-reviewer` — .NET

**Action per new agent:**
1. Create agent prompt file in `.opencode/prompts/agents/` if missing
2. Register in `profiles/gratis/opencode.jsonc` and `profiles/go/opencode.jsonc`
3. Add to `ecc/commands/` if it needs a command

---

### P2-1: Create Shell Counterparts for PS1-Only Scripts

**Root Cause:** 5 core + 4 hook scripts are PS1-only. No `.sh` equivalent.

**Missing .sh scripts:**
- `scripts/project-resolve.sh` (P0-1 blocker)
- `scripts/agent-core.sh`
- `scripts/agent-dashboard.sh`
- `scripts/task-queue.sh`
- `scripts/tool-creator.sh`
- `scripts/hooks/self-heal.sh`
- `scripts/hooks/eval-gate.sh`
- `scripts/hooks/instinct-extract.sh`
- `scripts/hooks/proactive-research.sh`

**Action:** Create `.sh` equivalents. Start with `project-resolve.sh` (blocks P0-1).

---

### P2-2: 39 Command `.md` Files Not Registered in Profiles

**Root Cause:** `commands/` has 84 `.md` files, but profiles register only ~45.

**Action:** Audit which commands are registered in `profiles/*/opencode.jsonc` vs which exist in `commands/`. Add missing ones.

---

### P2-3: Clean Up `.iteration.json`

**Root Cause:** File is deprecated (listed in .gitignore) but still exists and is read/written by quality-gate scripts.

**Action:** Either:
a. Remove it entirely (update quality-gate to not use it)
b. Keep it but remove from .gitignore deprecated list

---

## 🔵 P3 — Low

### P3-0: Rename `Feature/` and `Skill/` Directories

**Root Cause:** These are single files, not directories. Misleading naming.

**Action:** Rename to `Feature/list.md` → `docs/features.md` and `Skill/skill-list.md` → `docs/skills.md`. Update all references in README, docs, and scripts.

---

### P3-1: Deduplicate `analyze-project` vs `project-analyze`

**Root Cause:** Two scripts with confusingly similar names.

**Action:**
- Keep `code-analyze.ps1` (scans source code)
- Keep `project-analyze.ps1` (analyzes PRD)
- Rename or alias `analyze-project.ps1` to something clearer, or merge with one of the above

---

### P3-2: Lazy-Load Skills Instead of 270-at-Once

**Root Cause:** `opencode.jsonc` instructions array loads all 270 skills on every session start.

**Action:** Implement trigger-table pattern:
- Load only `coding-standards` + `tdd-workflow` at session start
- Load language/framework skills on demand when user mentions them
- Detect from project stack (uses `agent-core.ps1` `Detect-Stack`)

**Expected impact:** 60-80% reduction in baseline token consumption.

---

## Summary

| Priority | Count | Key Files |
|----------|-------|-----------|
| 🔴 P0 | 3 | `profiles/go/*`, `scripts/*.sh`, `scripts/hooks/*` |
| 🟡 P1 | 4 | `commands/*.md`, `start.ps1`, `start.sh`, `.sync-state.json` |
| 🟢 P2 | 4 | agent prompts, `.sh` scripts, `.iteration.json` |
| 🔵 P3 | 3 | `Feature/`, `Skill/`, `analyze-project.ps1` |

**Quick wins (30 min each):**
1. P0-0: Fix 16 model names in go profile
2. P1-2: Fix restore.sh model references
3. P1-3: Fix set-project.md path
4. P2-3: Clean up .iteration.json

**Biggest impact:** P0-1 (shell scripts) + P2-0 (more agents) + P3-2 (lazy skills)
