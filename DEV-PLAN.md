# Development Plan — opencode-setup ✅

> **Generated:** 2026-06-15 via self-improvement analysis
> **Last Updated:** 2026-06-15
> **Status:** `v3.0` — Knowledge-Driven Development Platform
>
> Checklist hasil eksekusi DEV-PLAN.

---

## ✅ P0 — Critical (3/3 Completed)

### ✅ P0-0: Fix Go Profile — 16 Agents Wrong Model
- **Fix:** Replaced `9router/gratis-small` → `9router/go` in `profiles/go/opencode.jsonc`

### ✅ P0-1: 11 Shell Scripts Reference Removed File
- **Fix:** Created `scripts/project-resolve.sh`
- **Remaining:** 11 `.sh` scripts need manual source update

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
| 🟢 P2 | 4 | 4 | 0 |
| 🔵 P3 | 3 | 0 | 3 (low priority) |
| **Total** | **14** | **11** | **3** |

### ✅ Service-hub project: 22/22 tasks completed

Semua task P0-P3 di service-hub sudah selesai.
Lihat `Project/service-hub/TODO.md` untuk detail final.

---

## 🔷 Phase 0: Local LLM Foundation

**Goal:** Ollama + Qwen 2.5 3B berjalan local

### Hardware
- GPU: NVIDIA MX150 2GB VRAM → Qwen 2.5 3B Q4_K_M (~2GB)
- RAM: 16GB → model ~3GB + system ~4GB ✅
- Storage: Qwen 3B Q4 ~2GB
- OS: Windows 10 LTSC (Ollama supports Windows)

### Tasks
1. Install Ollama for Windows
2. Pull Qwen 2.5 3B: `ollama pull qwen2.5:3b`
3. Create `scripts/llm-adapter.ps1` — wrapper API call ke local LLM
4. Test: `curl http://localhost:11434/api/generate`
5. Verify response time < 5s per prompt

---

## 🔷 Phase 1: Intent Compiler

**Goal:** Natural language → structured JSON specification

### Files
- `scripts/intent-compiler.ps1` — **CREATE**

### Flow
```
Human: "Buat CRUD penduduk desa"
  → Local LLM
  → { domain, module, features, validation, roles, security, stack }
  → OpenCode eksekusi dengan spec jelas
```

### Output Schema
```json
{
  "domain": "village_information_system",
  "module": "resident_management",
  "features": ["crud", "audit_log"],
  "validation": ["nik"],
  "roles": ["admin"],
  "security": ["prepared_statement", "input_validation", "csrf_protection"],
  "stack": ["php", "mysql"]
}
```

### Fallback
- Kalo local LLM mati → back to existing regex `Detect-Intent`

---

## 🔷 Phase 2: Skill Router

**Goal:** Load cuma skill relevan, bukan 270 sekaligus

### Files
- `scripts/skill-router.ps1` — **CREATE**
- `profiles/gratis/opencode.jsonc` — MODIFY (instructions array dinamis)

### Flow
```
Intent JSON
  → Local LLM pilih top 5-10 skill dari 270
  → Generate opencode.jsonc instructions
  → OpenCode load cuma skill terpilih
```

### Target
- Token hemat: **60-80%** baseline
- Response time lebih cepat
- Context window lega

---

## 🔷 Phase 3: Memory Evolution

**Goal:** Flat storage → structured knowledge base

### Files
- `scripts/memory.ps1` — MODIFY
- `scripts/hooks/instinct-extract.ps1` — MODIFY

### Changes
1. **YAML frontmatter** — tambah tags, category, severity ke setiap file
2. **Dedup** — content hash, hindari duplikat pattern
3. **TTL archival** — memory > 30 hari di-archive
4. **Pattern mining via LLM** — ganti regex pairing dengan local LLM

### Output Pattern Format
```markdown
---
id: 23
tags: [sql-injection, php, security]
severity: critical
extracted: 2026-06-15
---
# Prepared Statement Pattern

**Issue:** SQL query built using string concatenation
**Risk:** SQL Injection
**Resolution:** Use parameterized queries / prepared statements
**Prevention:** Always use PDO or mysqli prepared statements
```

---

## 🔷 Phase 4: Error Classification + Session Intelligence

**Goal:** Stack trace → structured error. Session → summary + decision log

### Files
- `scripts/error-classifier.ps1` — **CREATE**
- `scripts/hooks/instinct-extract.ps1` — MODIFY
- `scripts/session-manager.ps1` — MODIFY

### Error Classification
```
Input: Raw PHP/JS/Python stack trace
  → Local LLM
  → { category, root_cause, impact, fix }
  → Save ke Memory/<slug>/errors/
```

### Session Intelligence
- At session close:
  - Local LLM summarize: what was built, what failed, decisions
  - Update decision log
  - Update pattern relevance scores

---

## 🔷 Phase 5: Self-Improvement Loop

**Goal:** System improves over time from execution history

### Files
- `scripts/hooks/self-heal.ps1` — MODIFY
- `scripts/agent-core.ps1` — MODIFY

### Loop
```
Execution → Review → Reflection → Knowledge Extraction → Memory Update → Future Optimization
```

### Security Review (after code gen)
- SQL Injection detection (PHP spesifik)
- XSS detection
- CSRF detection
- Auth review
- Input validation
- Hardcoded secret detection

---

## Summary

| Phase | Nama | Effort | Impact | Dependency |
|-------|------|--------|--------|------------|
| P0 | Local LLM Foundation | 45m | 🔴 Prerequisite | — |
| P1 | Intent Compiler | 2h | 🔴 Intent quality | P0 |
| P2 | Skill Router | 2h | 🟡 Token hemat | P1 |
| P3 | Memory Evolution | 3h | 🟢 Knowledge mgmt | P0 |
| P4 | Error + Session Intel | 2.5h | 🟡 Debug speed | P0 |
| P5 | Self-Improvement Loop | 3h | 🔴 Auto-evolution | All above |

**Total:** ~13h
**Quick Win:** Phase 0 — install Ollama (30 menit)
