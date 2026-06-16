# Changelog — opencode-setup

Semua perubahan penting di project ini.

---

## [5.5.0] — 2026-06-16 — Balanced Mode 1GB VRAM + Real GPU Enrichment Pipeline

### Added — qwen2.5:1.5b-s for Balanced Mode
- **qwen2.5:1.5b-s** — Model 1.5B parameter dengan `num_ctx 1024`, `num_gpu 99`
- VRAM target ~1GB tercapai: **1075/2048 MB** (52%)
- 100% GPU, keep_alive Forever
- Download via `ollama pull qwen2.5:1.5b` (986 MB)
- Modelfile: `Modelfile.qwen2-1.5b`

### Changed — Performance Mode Now Uses 1.5B Model
- qwen2.5-coder:3b-s dihapus karena terlalu lambat di MX150 (~2 tok/s)
- qwen2.5:1.5b-s: **6.5 tok/s, enrich 200 tok dalam ~4s**
- Tok/s 3x lebih cepat dari 3B model, VRAM ~1GB vs ~2GB
- Status display updated di llm-mode.ps1

### Real GPU Enrichment — VERIFIED WORKING
- PERFORMANCE: Invoke-LLMEnrich 200 tok → **✅ 4.2s, GPU 25%, enriched output meaningful**
- BALANCED: Invoke-LLMEnrich 100 tok → **✅ ~15s, GPU spike confirmed**
- ECO: pass-through, no LLM — same as before
- Invoke-LLMEnrich no longer uses Get-PSCallStack (fixed Split-Path null error)

### Config Updates
- `llm-mode.ps1` — MODEL_MAP: balanced+performance both = `qwen2.5:1.5b-s`
- `llm-adapter.ps1` — Invoke-LLMEnrich tokens: PERFORMANCE=200, BALANCED=100
- `llm-adapter.ps1` — Timeouts: PERFORMANCE=45s, BALANCED=30s
- `llm-adapter.ps1` — Removed broken Get-PSCallStack in caller detection

### Behavioral Enforcement
- AI (opencode model) mulai comply: Invoke-LLMEnrich dijalankan tiap user input
- GPU utilization spike 25-100% selama enrichment
- Footer: `LLM : [ PERFORMANCE ] - Tokens : [ X ] - Profile : [ Y ] - Model : [ DS V4 Flash ]`

---

## [5.4.0] — 2026-06-16 — Forever VRAM: keep_alive=-1 + Auto-Warmup + Self-Improvement Audit

### Added — `keep_alive = -1` di Semua API Call
- `llm-adapter.ps1` — Setiap `Invoke-LLM` request menyertakan `keep_alive = -1`
- `llm-mode.ps1` — Warmup function juga pake `keep_alive = -1`
- **Efek: model Forever di VRAM.** `ollama ps` menunjukkan `UNTIL: Forever`
- Tidak ada cold start lagi selama mode balanced/performance aktif

### Added — Persistent Environment Variable
- `llm-mode.ps1` — `Set-KeepAlivePersistent()` function
- `[Environment]::SetEnvironmentVariable("OLLAMA_KEEP_ALIVE", "-1", "User")`
- Persistent across PowerShell restarts
- Ollama process otomatis direstart setelah set env var — apply instant

### Added — Auto-Warmup pada Mode Switch
- `llm-mode.ps1` — `Invoke-Warmup()` function: 1x inference dummy setelah switch mode
- Dilakukan setelah `Set-Mode` dan `Set-KeepAlivePersistent`
- **Flow:** `/llm performance` → unload model lain → set mode → warmup → VRAM langsung 1951 MB
- Switch time termasuk warmup: ~10-16s (cold load + inference)

### Added — 4-Phase Self-Improvement Audit
- **C1:** Fix go profile JSON structure collapsed (lines 299-309)
- **C2-C3:** Fix `$AI_NOTES` orphan variable in project-analyze.ps1, code-analyze.ps1
- **H1:** Fix sync.ps1 path bug (`$SETUP_DIR/ecc` → `$ROOT_DIR/ecc`)
- **H2-H3:** Fix parameter mismatch auto-start.ps1/wizard.ps1 passing `-ProjectPath` to start.ps1
- **H4:** Add `llm-preprocess.md` to go profile instructions list
- **H5:** Deduplicate duplicate `go`/`learn` command keys in gratis profile
- **M1:** Fix skill-router.ps1 `$enrichedQuery` referenced before assignment
- **LLM Integration:** Source adapter in project-skills.ps1, profile-optimizer.ps1, tool-creator.ps1
- **Profile cleanup:** Remove 6-8 missing `9router-*` skill references from both profiles
- **API_PASS:** All 5 scripts now read from `$env:NINEROUTER_PASSWORD` → `.env` file → `"admin"` fallback
- **Hook paths:** Harmonize all 3 hooks to use `$SETUP_DIR` instead of `$ROOT_DIR\scripts`
- **tool-creator.ps1:** Fix `[string]$$ProjectPath` double `$` typo
- **generate-prd.ps1:** Fix `$featureCount = "..."` placeholder → real estimate

### Behavioral Contract Enforced
- AI (opencode model) WAJIB menjalankan Invoke-LLMEnrich pada SETIAP user input
- Footer WAJIB muncul di SETIAP respons
- VRAM lifecycle terverifikasi: ECO → 0 MB, PERFORMANCE → 1951 MB Forever

---

## [5.3.0] — 2026-06-16 — GPU Pipeline: Local Enrich → Cloud Respond

### Added — Q4_K_S Quantized Models for 100% GPU
- **qwen2.5-coder:3b-s** (1.71 GB) — Q4_K_S quantization fits 2GB VRAM fully
- **qwen3:1.7b-s** (1.27 GB) — With `num_gpu 99` force all layers to GPU
- Modelfiles created with `num_gpu 99`, `num_ctx 2048`
- Download dari bartowski/Qwen2.5-Coder-3B-Instruct-GGUF via curl + resume

### Added — Forced GPU via `num_gpu = 99`
- `llm-adapter.ps1` — Every `Invoke-LLM` call passes `num_gpu = 99` in API options
- Modelfiles — `PARAMETER num_gpu 99` embedded at model level
- **100% GPU:** qwen2.5-coder:3b-s = 1951/2048 MB (95%), qwen3:1.7b-s = 1493/2048 MB (73%)

### Added — ECO Mode VRAM Unload
- `llm-mode.ps1` — ECO switch runs `ollama stop` on both models → VRAM 0 MB
- BALANCED mode unloads PERFORMANCE model first (and vice versa) — prevents OOM
- Cold load: ~6s (balanced), ~10s (performance)

### Added — Thinking Field Fallback for Qwen3
- `llm-adapter.ps1` — When `message.content` empty but `message.thinking` exists, use thinking as fallback response

### Added — LLM Status Footer System
- `instructions/llm-status-footer.md` — AI wajib append footer setiap respons
- Footer format: `LLM : [ MODE ] - Tokens : [ X ] - Profile : [ Y ] - Model : [ Z ]`
- Shows local Ollama mode + Cloud AI model identity
- Profile auto-detection via config name matching

### Added — Preprocess Instruction Enforcement
- `ecc/.opencode/instructions/llm-preprocess.md` — Step-by-step AI behavioral contract
- Wajib: baca mode → Invoke-LLMEnrich → enriched context → jawab → footer
- Architecture: Local Ollama = preprocessor only. Cloud AI = responder.

### Added — `$env:OLLAMA_KEEP_ALIVE = "-1"`
- `scripts/start.ps1` — Model stays loaded in VRAM during balanced/performance mode
- Prevents cold start on every inference

### Changes
- `llm-mode.ps1` — balanced model `qwen3:1.7b` → `qwen3:1.7b-s`, performance model `qwen2.5-coder:3b` → `qwen2.5-coder:3b-s`
- `Modelfile` — FROM absolute GGUF blob, num_ctx 2048, num_gpu 99
- `Modelfile.qwen3` — FROM qwen3:1.7b, num_ctx 2048, num_gpu 99
- README.md — Full rewrite: 2-stage pipeline, GPU section, VRAM lifecycle, footer docs, tables

### Behavioral Contract
- AI wajib panggil `Invoke-LLMEnrich` pada SETIAP user input sebelum merespons
- AI wajib append `LLM Status Footer` setelah SETIAP respons
- ECO = passthrough (no LLM). BALANCED = 250 tok enrich. PERFORMANCE = 512 tok enrich.

---

## [5.2.0] — 2026-06-16 — Bugfix: Adapter, Intent Compiler, Skill Router

### Fixed
- **llm-adapter.ps1** — Qwen3 thinking field fallback (empty content → use thinking field)
- **intent-compiler.ps1** — Variable order bug (`$enrichedQuery` referenced before assignment)
- **intent-compiler.ps1** — Mode `off` not recognized (only checked `eco`, not `off`)
- **skill-router.ps1** — Mode `off` not recognized (same fix)
- **llm-status-footer.md** — Footer format rapi + profile detection + model alias vs cloud model

### Added
- `.opencode/llm-mode.json` — Initialized (was missing, caused ECO fallback despite showing BALANCED)

---

## [5.1.0] — 2026-06-16 — Workflow Rework: 3 Main Workflows

### Reworked — Setup Workflow
- **Deleted** `install.bat` — legacy batch installer
- **Rewritten** `scripts/setup.ps1` — clean, smart detection, 2-mode (install/apply)
- **New** `commands/setup.md` — `/setup` command for opencode
- Flow: pre-flight -> detect 9Router -> clone ECC -> build -> apply profile -> generate api-key -> STOP

### Reworked — Start Workflow (Morning Routine)
- **Rewritten** `scripts/start.ps1` — auto-heal, LLM-first (593 -> 200 lines)
- **Updated** `commands/start-free.md` — new workflow docs
- **Updated** `commands/start-go.md` — new workflow docs
- Flow: LLM check -> pre-flight -> ECC -> plugin -> config -> model test -> summary
- Removed: project-resolve dependency, complex session management

### Reworked — Admin Workflow
- **Rewritten** `scripts/admin-update.ps1` — changelog + keyword rework detection
- **Updated** `commands/admin.md` — changelog tags + recommendations
- Flow: LLM check -> pull repos -> changelog (full, tagged) -> analyze -> rebuild -> doctor -> log
- New: keyword-based rework detection from commit messages
- New: recommendations (setup rework, breaking changes, plugin rebuild)

### Updated — Profiles
- Both profiles (gratis/go) updated with new `/setup`, `/start-free`, `/start-go`, `/admin` commands
- Commands now use direct PowerShell script calls instead of markdown templates
- Gratis profile: correct combo models (6 free models: mmf/mimo-auto, oc/deepseek-v4-flash-free, oc/mimo-v2.5-free, oc/nemotron-3-ultra-free, oc/big-pickle, oc/north-mini-code-free)

### Updated — Documentation
- README.md: new "3 Main Workflows" section with flow tables
- CHANGELOG.md: this entry

### Removed
- `install.bat` — replaced by `/setup` command
- LLM dependency in start.ps1 — graceful fallback (llm-adapter optional)

---

## [5.0.0] — 2026-06-16 — Universal Goal-Based Combo + Clean Slate

### Changed — Combo System (10 files → 1)
- **10 combo `.md` files removed** — morning-routine, start-project, quick-review, full-audit, prd-combo, maintenance, generate, bug-fix, security, deploy
- **1 universal `/go` command** — goal-based, AI decompose, auto-recovery
- AI sekarang tentukan step sendiri berdasarkan goal + constraints
- Tidak ada hardcoded step chains — adaptif per request

### Changed — Preprocessor Integration
- **`/go`** terintegrasi penuh dengan preprocessor:
  - Skill index (270) — match by stack/domain
  - Feature index (600+) — reuse before create
  - Memory — session logs per project
  - Knowledge — patterns per project
  - Intent compiler — structured spec
  - Skill router — 5-10 relevant skills

### Removed — ai-notes.md (Outdated)
- **`ai-notes.md`** dihapus — sudah digantikan oleh LLM pipeline
- References dihapus dari: code-analyze.ps1, project-analyze.ps1, template-loader.ps1
- References dihapus dari: docs/index.md, 01-overview.md, 02-scripts.md, 04-analyze-project.md, 03-session-persistence.md
- `.gitignore` entry removed

### Cleanup
- 10 command entries removed from `profiles/gratis/opencode.jsonc`
- 10 command entries removed from `profiles/go/opencode.jsonc`
- Added `/go` to both profiles as universal entry point

---

## [4.3.0] — 2026-06-16 — Self-Improvement Loop v3: Closed

### Fixed — Telemetry Channels (4/4 Alive)
- **llm-usage.jsonl** — `Invoke-LLM` success path now logs: timestamp, script, model, duration, tokens/sec
- **llm-failures.jsonl** — Already alive, auto-trimmed to 100 entries
- **llm-evolve.jsonl** — Now written on every evolve run
- **llm-mode.json** — Updated per mode switch

### Fixed — Actuation
- **llm-evolve.ps1 -Apply** — Now actually adjusts config:
  - Timeout > 30% → auto-increase (60→180s)
  - JSON fail > 30% → auto-decrease temperature
  - Failure rate > 50% → auto-switch to ECO
  - Auto-trim failure log to 100 entries
- **profile-optimizer.ps1** — Saves recommendations to `.opencode/recommended-skills.json`
- **start.ps1** — Auto-runs `evolve -Apply` + `feedback` on session start
- **instinct-extract.ps1** — Auto-runs `knowledge-miner` in PERFORMANCE mode on session end
- **llm-adapter.ps1** — Auto-ECO on connect failure (was switching to balanced)

### Fixed — Bugs
- **profile-optimizer.ps1** — Removed orphaned closing brace (syntax error)

### Seed Data
- Telemetry files populated: 1 LLM success, 31 failures logged
- Evolve detected: 77.4% timeout rate → auto-fix applied

### Loop Status
```
Session Start → evolve -Apply → adjust config
  → LLM call → success? → llm-usage.jsonl ✅
             → fail? → llm-failures.jsonl ✅
Session End → instinct-extract → patterns → knowledge
           → knowledge-miner → extract → knowledge
Next Start → feedback analysis → evolve adjust → better config
```

---

## [4.2.0] — 2026-06-16 — Preprocess-Execute-Learn Pipeline

### Added — LLM Preprocessor Layer
- **llm-preprocess.ps1** — Universal orchestrator: stack → skill → feature → memory → knowledge → intent → route
- **Skill index** — Parses 270 skills from `Skill/skill-list.md`, matches by stack/domain/module
- **Feature index** — Parses 600+ features from `Feature/list.md`, recommends reuse before create
- **Memory search** — Searches session logs by domain/module
- **Knowledge search** — Searches knowledge base for patterns
- **String fix** — Fixed foreach syntax errors + `.Skip(0)` calls

### Added — Commands
- **`/go`** — Universal: query → preprocess → enriched context
- **`/learn`** — Save session results to memory + knowledge

### Added — ECC Instructions
- **`ecc/.opencode/instructions/llm-preprocess.md`** — AI instruction: "always check preprocessor first"

### Reworked — 10 Combos
All combos now include preprocess (step 1) + learn (final step):
| Combo | Steps |
|-------|-------|
| morning-routine | preprocess → start-free → admin → quality-gate → token-stats → learn |
| start-project | preprocess → start-free → set-project → code-analyze → analyze-project → learn |
| quick-review | preprocess → code-review → security-scan → verify → learn |
| full-audit | preprocess → code-analyze → analyze-project → project-skills → memory → learn |
| prd-combo | preprocess → generate-prd → project-analyze → learn |
| maintenance | preprocess → admin → quality-gate → reset-session → learn |
| generate | preprocess → template → create → learn |
| bug-fix | preprocess → build-fix → quality-gate → memory → learn |
| security | preprocess → security-scan → quality-gate → research → learn |
| deploy | preprocess → verify → quality-gate → update-docs → learn |

### Fixed
- **Duplicate command** — Removed duplicate `intent` entry in opencode.jsonc

---

## [4.1.0] — 2026-06-15 — Self-Improvement Loop v2

### Added — Feedback Analysis
- **llm-feedback.ps1** — Analyze `.opencode/llm-failures.jsonl` → categorize → LLM recommendations
- Failure categories: timeout, json_parse, connection, model_error
- Per-script + per-model breakdown
- Auto-trim log to 100 entries (with `-Apply`)

### Added — Auto-Evolution
- **llm-evolve.ps1** — Calculate failure rate, avg latency, timeout/JSON ratio
- Config recommendations: adjust Timeout/Temperature/Model based on stats
- State persisted to `.opencode/llm-evolve.jsonl`

### Added — Profile Optimizer
- **profile-optimizer.ps1** — Track skill usage patterns vs profile load
- Identify: high-usage skills not loaded, low-usage skills wasting context
- Skill usage via `.opencode/skill-usage.jsonl`
- Load/unload recommendations

### Added — Knowledge Miner
- **knowledge-miner.ps1** — Scan memory sessions → LLM extract patterns → save to knowledge
- PERFORMANCE mode: LLM extraction with tags
- ECO mode: regex keyword extraction
- Save to `Project/Knowledge/<slug>/auto-mined/`

### Self-Improvement Cycle
```
LLM call → usage logged → failure logged
  ↓ (periodic)
Feedback analysis → categorize → recommendations
  ↓
Evolve → adjust config
  ↓
Profile optimizer → load/unload skills
  ↓
Knowledge miner → sessions → patterns → knowledge
```

---

### Added — LLM Code Audit
- **llm-audit.ps1** — Autonomous code audit using local LLM (qwen2.5-coder:3b)
- **3 audit modes** — quality (error handling, style), security (vulns, secrets), perf (efficiency)
- **Loop mode** — continuous audit cycle. Kirim file bertubi-tubi ke LLM tanpa jeda
- **GPU stress test** — Loop mode maksimalin VRAM MX150 2GB (~90% load, ~1.8GB VRAM)
- **Auto-report** — hasil audit disimpan ke `Project/Knowledge/<slug>/audits/`
- **/audit command** — `/audit <path>` atau `/audit scripts\ -Loop`

### Self-Improvement Cycle (completed)
```
Execution → LLM Audit → Findings → Knowledge Base → Future Execution
```
Now wired: setiap iterasi audit feed hasilnya ke Knowledge base.

---

## [3.2.0] — 2026-06-15 — 3-Mode Operating System

### Added — Operating Modes
- **ECO mode** — zero LLM, regex fallback only. Battery optimized, no GPU.
- **BALANCED mode** — default. qwen3:1.7b. Search before generate.
- **PERFORMANCE mode** — qwen2.5-coder:3b. Deep analysis, pattern mining.
- Mode auto-switches model: ECO→none, BALANCED→qwen3:1.7b, PERFORMANCE→qwen2.5-coder:3b

### Added — Knowledge Base
- **knowledge.ps1** — structured, categorized, searchable knowledge separate from Memory
- `Project/Knowledge/<slug>/` — per-project knowledge directory
- Commands: `save`, `search`, `list`
- YAML frontmatter (title, category, date)

### Added — Memory Search
- **memory search** — `.\memory.ps1 -Action search -Key "keyword"`
- Recursive grep across sessions, patterns, and errors
- Context preview (40 chars around match)

### Changed
- **llm-mode.ps1** — ECO/BALANCED/PERFORMANCE (was ON/OFF)
- **llm-adapter.ps1** — `Get-OperatingMode`, `Get-ModeForLLM` functions
- **intent-compiler.ps1** — respects 3 modes
- **skill-router.ps1** — respects 3 modes
- **instinct-extract.ps1** — ECO→regex, BALANCED→LLM summary, PERFORMANCE→deep
- **/llm command** — `eco`, `balanced`, `performance` (not just on/off)

---

## [3.1.0] — 2026-06-15 — Self-Improvement Round 2

### Improved — Intent Compiler
- **New schema fields** — `estimated_hours`, `confidence`, `language`, `dependencies`, `_compiler` tracking
- **LLM vs regex tracking** — tiap output tagged `llm` atau `regex`

### Improved — LLM Adapter
- **Chat API** — `/api/generate` → `/api/chat` (quality lebih baik buat instruction-tuned models)
- **Response handling** — Qwen3 dual-mode thinking field handled properly

### Improved — Profile
- **Removed 5 niche skills** — `frontend-slides`, `9router-image`, `9router-tts`, `9router-stt`, `9router-embeddings`
- **21 → 16 instructions** — hemat token ~25% baseline

### Improved — Skill Router
- **Category grouping** — 284 flat names → grouped by category (max 100)
- **Timeout fix** — prompt size turun drastis, LLM bisa process dalam 60s

### Improved — Instinct Extract
- **LLM pattern mining** — session end → LLM extract problem+solusi+pattern
- **Dual path** — LLM kaya (ON) + regex coverage (OFF)
- **Path fix** — sourcing dari hooks/ ke scripts/ parent dir

### Improved — Stack Detection
- **11 new stack mappings** — django, fastapi, laravel, springboot, golang, rust, python, android, express, dotnet, prisma
- **16 stacks total** — dari sebelumnya 5

---

## [3.0.0] — 2026-06-15 — Personal Knowledge Operating System

### Added — Local LLM Foundation
- **llm-mode.ps1** — Toggle local LLM ON/OFF (thermal management untuk outdoor)
- **llm-adapter.ps1** — Ollama API wrapper dengan auto-fallback + Qwen3 thinking field support
- **llm-benchmark.ps1** — Benchmark harness: 5 scenarios, 3 models (including no-LLM baseline)
- **/llm command** — `/llm on|off|status` via opencode.jsonc

### Added — Intent Compiler
- **intent-compiler.ps1** — Natural language → structured JSON spec (domain, module, features, etc.)
- Dual path: LLM (qwen3:1.7b) → rich output / Regex fallback → instant, basic
- **/intent command** — `/intent "buat CRUD penduduk"`

### Added — Skill Router
- **skill-router.ps1** — Select 3-10 relevant skills from 270 based on detected stack
- Dual path: LLM / Regex fallback (auto-fallback kalo timeout)
- Reads `Skill/skill-list.md` into searchable index
- **/route command** — `/route "PHP MySQL desa"`

### Architecture (DEV-PLAN v3.0)
- **2 operating modes** — ON (local LLM) / OFF (regex fallback)
- **Default model** — `qwen3:1.7b` (1.4GB VRAM, 0.6GB headroom)
- **1-Month MVP** completed (Week 1-4)

### Fixed
- **Qwen3 thinking field** — Adapter sekarang fallback ke `thinking` field kalo `response` kosong
- **Max tokens** — Dinaikin 512→2048 biar model gak kepotong waktu "berpikir"
- **Skill index parser** — Fix parsing untuk 3-column table format di Skill/skill-list.md

---

### Fixed
- **Go profile model routing** — Semua sub-agent pake `9router/go`
- **Absolute paths** — Semua command `.md` pake relative path
- **Shell scripts** — `project-resolve.sh` untuk cross-platform session

### Added
- **Agent Core** — intent detection, skill auto-loader, resume session
- **Agent Dashboard** — system overview, memory stats
- **Task Queue** — autonomous DAG execution
- **Tool Creator** — template-based script generator
- **4 agent hooks** — self-heal, eval-gate, instinct-extract, proactive-research
- **register-hooks.ps1** — wire hooks into profile config
- **project-resolve.sh** — shell equivalent for Linux/macOS
- **DEV-PLAN.md** — self-improvement roadmap

### Changed
- **Per-project session** — `Project/` directory structure
- **.gitignore** — Project/ di-ignore
- **15 command files** — absolute → relative paths

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

