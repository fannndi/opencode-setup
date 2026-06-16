# Personal Knowledge Operating System

Buat aplikasi tanpa coding. AI yang kerja. Semua gratis.

---

## The Story

Bu Rina punya toko kelontong. Catat stok di buku, hitung manual, sering kehabisan barang. Dia ingin aplikasi kasir — tapi tidak bisa coding dan tidak punya duit.

**Sekarang tinggal bilang, AI yang kerjakan.**

Terinspirasi dari Bu Rina, sistem ini berevolusi jadi **Personal Knowledge Operating System** — gabungan AI agent, memory per-project, knowledge base, dan self-improvement loop. Semua jalan di laptop lokal, semua gratis.

---

## Quick Start

### End User (2 langkah)
```
1. Clone repo -> cd opencode-setup
2. .\scripts\setup.ps1 -> isi api-key.txt -> .\scripts\setup.ps1 --apply
3. opencode -> /go "bikin aplikasi kasir"
```

### Developer
```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
# Fill api-key.txt, then:
.\scripts\setup.ps1 --apply
opencode
```

### Via OpenCode Command
```
/setup           # Install everything
/setup --apply   # Apply api-key, verify, done
```

---

## 3 Main Workflows

### 1. Setup (Install dari 0)
```
/setup              # Install: 9Router, ECC, config, api-key
/setup --apply      # Apply api-key, verify, done
```

| Step | Action | Auto-fix? |
|------|--------|-----------|
| 1 | Pre-flight (node, git, opencode) | fail if missing |
| 2 | Detect 9Router (install if missing) | yes |
| 3 | Clone/pull ECC | yes |
| 4 | Install deps + build plugin | yes |
| 5 | Apply profile config | yes |
| 6 | Generate api-key.txt | yes |
| 7 | STOP - user fills api-key | - |

### 2. Start (Morning Routine - Auto-heal)
```
/start-free         # Free models
/start-go           # Go models
```

| Step | Action | Auto-fix? |
|------|--------|-----------|
| 1 | LLM: 9Router health + combos | yes |
| 2 | Pre-flight (node, git, opencode) | no |
| 3 | ECC: clone/pull | yes |
| 4 | Plugin: build | yes |
| 5 | Config: apply profile | yes |
| 6 | Model test (ping combos) | no |
| 7 | Summary: GO / NO GO | - |

### 3. Admin (Changelog + Update + Doctor)
```
/admin              # Pull repos, changelog, rebuild, doctor
/admin --doctor     # Doctor check only
```

| Step | Action |
|------|--------|
| 1 | LLM: 9Router health + combos |
| 2 | Pull ECC |
| 3 | Pull 9Router |
| 4 | ECC changelog (full, tagged) |
| 5 | 9Router changelog (full, tagged) |
| 6 | Analyze: rework needed? (keyword-based) |
| 7 | Rebuild plugin if opencode changes |
| 8 | Doctor check |
| 9 | Save admin log |
| 10 | Summary + recommendations |

**Changelog Tags:**
- `[setup]` - Setup rework needed -> re-run /setup
- `[config]` - Config changes -> update config
- `[plugin]` - Plugin changes -> auto-rebuild
- `[skill]` - New/updated skills -> auto-load
- `[breaking]` - Breaking changes -> manual review
- `[info]` - No action needed

---

## Operating Modes

Didesain untuk GPU minimal (MX150 2GB VRAM, 16GB RAM). Tiga mode:

| Mode | LLM | Model | VRAM | Context Window | Chunk Size | Cocok |
|------|-----|-------|------|----------------|------------|-------|
| **ECO** | ❌ Mati | — | 0 GB | N/A | N/A | Outdoor, baterai tipis |
| **BALANCED** | ✅ | qwen3:1.7b | ~1.4 GB | ~1500 tokens | 1000 chars | Default daily |
| **PERFORMANCE** | ✅ | qwen2.5-coder:3b | ~2 GB | ~800 tokens | 600 chars | Charger connected |

```powershell
/llm eco          # GPU idle, all LLM skip
/llm balanced     # Default
/llm performance  # Full power
/llm status       # Cek mode + model
```

Setiap input user — bahkan "Hai" — lewat `Invoke-LLMEnrich` dulu sebelum model AI. ECO mode: pass-through tanpa LLM. 100% coverage.

---

## Architecture

### LLM Pipeline
```
Input User
   │
   ▼
┌──────────────────────────────────┐
│  Invoke-LLMEnrich (universal)    │
│  ├─ ECO:        pass-through     │
│  ├─ BALANCED:   enrich ~250 tok  │
│  └─ PERFORMANCE: enrich ~512 tok │
└──────────┬───────────────────────┘
           │
           ▼
┌──────────────────────────────────┐
│  Intent-Compiler (NL → JSON)     │
│  Skill-Router (pick 3-10 skills) │
│  Invoke-LLM (Ollama API)         │
│  Invoke-LLMChunk (mode-aware)    │
└──────────────────────────────────┘
```

### Self-Improvement Loop
```
Session Start → LLM-Evolve (config)
   ↓
User Works → Usage Telemetry
   ↓
Session End → Knowledge-Miner (session → patterns)
   ↓
Next Session → LLM-Feedback (failure analysis)
```

### Modular Code Constraint
```
1000 chars soft / 1500 hard max per file
Satu file = satu function + doc
Dependency tracking: # Requires: / # Exports:
Max 5 file per dir, index.ps1 wajib
Generator: .\create-function.ps1 -Name "Func" -Module "mod"
```

---

## Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/go <query>` | Universal goal combo | `/go "bikin CRUD penduduk"` |
| `/llm <mode>` | Set operating mode | `/llm balanced` |
| `/audit <path>` | LLM code audit | `/audit scripts\` |
| `/intent <query>` | NL → structured JSON spec | `/intent "buat CRUD"` |
| `/route <query>` | Intent → relevant skills | `/route "PHP MySQL"` |
| `/dashboard` | System overview | `/dashboard` |
| `/task-queue <goal>` | Autonomous task DAG | `/task-queue "bikin login"` |
| `/learn <note>` | Save to memory + knowledge | `/learn "fixed login bug"` |

---

## Scripts

### LLM Layer

| Script | Fungsi |
|--------|--------|
| `llm-adapter.ps1` | Universal wrapper: Invoke-LLM, Invoke-LLMEnrich, Invoke-LLMChunk, failure logging, usage telemetry |
| `llm-mode.ps1` | 3-mode toggle: eco/balanced/performance |
| `llm-preprocess.ps1` | Universal input pipeline: stack → skill → feature → memory → knowledge → intent → route |
| `intent-compiler.ps1` | Natural language → structured JSON spec (dual path: LLM + regex) |
| `skill-router.ps1` | Select 3-10 skills from 270 ECC skills by intent |
| `llm-audit.ps1` | Multi-mode code audit (quality/security/perf) with chunking |
| `llm-benchmark.ps1` | Benchmark harness — 5 scenarios, 3 rounds, pass@k metrics |
| `llm-feedback.ps1` | Analyze failure log → LLM recommendations → auto-config |
| `llm-evolve.ps1` | Auto-adjust Timeout/Temperature/Model from usage stats |

### Agent Layer

| Script | Fungsi |
|--------|--------|
| `agent-core.ps1` | Stack detection, intent classification, skill auto-loader, session resume |
| `task-queue.ps1` | Autonomous DAG execution — decompose goal → dependency resolve → execute |
| `agent-dashboard.ps1` | System overview: health, sessions, LLM usage, model status |
| `tool-creator.ps1` | Template-based script/command generator |
| `create-function.ps1` | Boilerplate function generator (ps1/ts/py/go) with 1500 char limit |

### Knowledge Layer

| Script | Fungsi |
|--------|--------|
| `knowledge.ps1` | Structured, categorized, searchable knowledge base (semantic + keyword) |
| `knowledge-miner.ps1` | Session logs → LLM extract patterns → auto-save to knowledge |
| `memory.ps1` | Per-project session memory: logs, patterns, error solutions |
| `profile-optimizer.ps1` | Track skill usage → recommend load/unload |

### Infrastructure

| Script | Fungsi |
|--------|--------|
| `setup.ps1` | Smart setup: detect 9Router, clone ECC, build plugin, apply profile |
| `start.ps1` | Auto-heal morning routine: LLM check, ECC, plugin, config, model test |
| `admin-update.ps1` | Changelog + update + rebuild + doctor check |
| `generate-prd.ps1` | Idea -> LLM-enriched PRD document |
| `project-analyze.ps1` | PRD → semantic stack + feature detection |
| `code-analyze.ps1` | Project directory → semantic tech stack extraction |
| `analyze-project.ps1` | File indicator → stack detection → skill loading |
| `research.ps1` | Web search + LLM summarization via 9Router |
| `quality-gate.ps1` | Multi-stage quality check + LLM analysis |
| `wizard.ps1` | Interactive onboarding wizard (Indonesian) |
| `create.ps1` | Component boilerplate: widget/api/test/model |
| `template-loader.ps1` | Project template copier |
| `session-manager.ps1` | CRUD session JSON files |
| `project-resolve.ps1` | Active project resolution + slug management |
| `token-tracker.ps1` | 9Router token usage display |

### Hooks (Auto-Trigger)

| Hook | Trigger | Action |
|------|---------|--------|
| `self-heal.ps1` | After Edit/Write | Check types → LLM suggest fix |
| `eval-gate.ps1` | After editing test files | Auto-run tests → LLM analyze |
| `instinct-extract.ps1` | Session end | Session log → LLM pattern extraction → save to memory + knowledge |
| `proactive-research.ps1` | Before Edit/Write | Unknown library detection → LLM research → save |

---

## Project Structure

```
opencode-setup/
├── Project/                   # Per-project data
│   ├── <slug>/                # Cloned source
│   ├── Session/<slug>/        # Session state
│   └── Memory/<slug>/         # Logs, patterns, errors
├── scripts/                   # 40+ automation scripts
│   └── hooks/                 # 4 auto-trigger hooks
├── commands/                  # OpenCode command templates
├── profiles/                  # Config profiles
├── templates/                 # Project templates
├── rules/                     # Code constraints
│   └── common/
│       └── modular-code.md    # 1000 char rule
├── Feature/                   # 600+ feature inventory
├── Skill/                     # 270 skills catalog
├── docs/                      # Documentation
├── ecc/                       # ECC repo (auto-cloned)
├── 9router/                   # 9Router repo (auto-cloned)
├── .opencode/                 # Telemetry, usage logs (gitignored)
├── README.md
├── DEV-PLAN.md                # Self-improvement roadmap
└── CHANGELOG.md               # Release history
```

---

## Cost

| Komponen | Biaya | Kegunaan |
|----------|-------|----------|
| OpenCode Free | ✅ $0 | AI coding assistant |
| 9Router | ✅ $0 | AI gateway + free model combos |
| ECC (270 skills) | ✅ $0 | Knowledge base |
| Ollama (qwen3:1.7b / qwen2.5-coder:3b) | ✅ $0 | Local LLM |

**Total: $0.00.** Tidak perlu API key. Tidak perlu kartu kredit.

---

## Credits

Proyek ini gabungan 3 teknologi open-source gratis:

- **OpenCode** — AI coding assistant by Anomaly Co.
- **9Router** — AI gateway dengan free model combos (MiMo, DeepSeek, Mimo)
- **ECC** (Everything Claude Code) — 270+ skills, 84 commands, agent hooks

Dibuat agar siapapun bisa bikin aplikasi tanpa coding dan tanpa biaya.

---

**Masa depan: tinggal bilang, AI yang kerjakan.**
