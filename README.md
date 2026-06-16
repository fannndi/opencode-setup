# Personal Knowledge Operating System

Buat aplikasi tanpa coding. AI yang kerja. Semua gratis.

Local LLM (Ollama) + Cloud AI (OpenCode) = pipeline 2-stage.

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

## Architecture: 2-Stage AI Pipeline

```
┌──────────────────────────────────────────────────┐
│ USER INPUT                                       │
│ "hai"                                            │
└──────────────────────┬───────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────┐
│ STAGE 1: Local LLM (Ollama, GPU)                 │
│                                                   │
│  Invoke-LLMEnrich()                               │
│    ├─ ECO:        pass-through, no LLM            │
│    ├─ BALANCED:   qwen3:1.7b-s, ~250 tok enrich  │
│    └─ PERFORMANCE: qwen2.5-coder:3b-s, ~512 tok  │
│                                                   │
│  Output: enriched context (internal, user ga liat)│
└──────────────────────┬───────────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────────┐
│ STAGE 2: Cloud AI (OpenCode model)               │
│                                                   │
│  Menerima enriched context dari Stage 1           │
│  Menjawab user dengan konteks yang lebih kaya     │
│  Append footer status setiap response             │
└──────────────────────────────────────────────────┘
```

**Konsep kunci:** User tidak pernah lihat output local LLM. Local LLM cuma memproses input, menghasilkan enriched context, lalu Cloud AI yang jawab menggunakan konteks itu.

---

## GPU Pipeline: 3 Operating Modes

Didesain untuk GPU minimal (MX150 2GB VRAM, 16GB RAM). Tiga mode dengan manajemen VRAM otomatis:

| Mode | Model Lokal (Ollama) | Quant | VRAM | GPU | Enrich Tokens |
|------|---------------------|-------|------|-----|---------------|
| **ECO** | ❌ Unloaded | — | 0 MB | idle | 0 (passthrough) |
| **BALANCED** | qwen3:1.7b-s | Q4_K_M | ~1493 MB | 100% | ~250 tok |
| **PERFORMANCE** | qwen2.5-coder:3b-s | Q4_K_S | ~1951 MB | 100% | ~512 tok |

**VRAM Lifecycle:**
```
ECO         → VRAM 0 MB   (ollama stop → unload)
Switch BAL  → Cold load ~6s → VRAM 1493 MB
Switch PERF → Cold load ~10s → VRAM 1951 MB (unloads BAL dulu)
ECO lagi    → Unload → VRAM 0 MB
```

```powershell
/llm eco          # GPU idle, all LLM skip, VRAM 0
/llm balanced     # qwen3:1.7b-s, enrich 250 tok
/llm performance  # qwen2.5-coder:3b-s (Q4_K_S), enrich 512 tok
/llm status       # Cek mode + model + VRAM
```

**Setiap input user — bahkan "Hai":**
1. AI baca `.opencode/llm-mode.json` → tau mode
2. Kalo bukan ECO → `Invoke-LLMEnrich()` di GPU → enriched context
3. Kalo ECO → raw input langsung (no LLM)
4. Cloud AI jawab pake enriched context
5. Append footer: `LLM : [ MODE ] - Tokens : [ X ] - Profile : [ Y ] - Model : [ Z ]`

---

## GPU Optimization Details

| Aspek | Detail |
|-------|--------|
| **Model kustom** | `qwen3:1.7b-s`, `qwen2.5-coder:3b-s` — Modelfile dgn `num_gpu 99`, `num_ctx 2048` |
| **Forced GPU** | Parameter `num_gpu=99` di adapter dan Modelfile — paksa semua layer ke GPU |
| **VRAM fit** | Q4_K_S (1.71 GB → 97% layer di GPU) vs Q4_K_M (1.9 GB → hanya 28%) |
| **KEEP_ALIVE** | `-1` = model stay di VRAM selama mode balanced/performance |
| **ECO cleanup** | `ollama stop` → unload model dari VRAM, GPU free buat aplikasi lain |
| **Cold load** | ~6s (balanced) / ~10s (performance) — terjadi pas switch mode |
| **Inference** | ~400ms-3s per enrich tergantung token count |

**Kenapa Q4_K_S?** Q4_K_M (1.9 GB) + KV cache (200 MB) = 2.1 GB > 2 GB VRAM → spill ke CPU. Q4_K_S (1.71 GB) + KV cache = 1.95 GB → **100% GPU**.

---

## Footer System

Setiap respons AI menyertakan status footer:

```
LLM : [ PERFORMANCE ] - Tokens : [ 18 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```

| Field | Arti |
|-------|------|
| `MODE` | Mode local Ollama: ECO / BALANCED / PERFORMANCE |
| `Tokens` | Estimasi token output respons ini |
| `Profile` | Profile opencode aktif: Gratis / Go |
| `Model` | Cloud AI model yang menjawab (DS V4 Flash, MiMo V2.5, dll) |

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

Changelog Tags: `[setup]` `[config]` `[plugin]` `[skill]` `[breaking]` `[info]`

---

## Self-Improvement Loop

```
Session Start → LLM-Evolve (config)
   ↓
User Works → Usage Telemetry
   ↓
Session End → Knowledge-Miner (session → patterns)
   ↓
Next Session → LLM-Feedback (failure analysis)
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

## Scripts Reference

### LLM Layer

| Script | Fungsi |
|--------|--------|
| `llm-adapter.ps1` | Universal wrapper: Invoke-LLM, Invoke-LLMEnrich, Invoke-LLMChunk, failure logging, usage telemetry, `num_gpu=99` |
| `llm-mode.ps1` | 3-mode toggle: eco/balanced/performance + auto VRAM management |
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

### Knowledge Layer

| Script | Fungsi |
|--------|--------|
| `knowledge.ps1` | Structured, categorized, searchable knowledge base |
| `knowledge-miner.ps1` | Session logs → LLM extract patterns → auto-save to knowledge |
| `memory.ps1` | Per-project session memory: logs, patterns, error solutions |
| `profile-optimizer.ps1` | Track skill usage → recommend load/unload |

### Infrastructure

| Script | Fungsi |
|--------|--------|
| `setup.ps1` | Smart setup: detect 9Router, clone ECC, build plugin, apply profile |
| `start.ps1` | Auto-heal morning routine + `$env:OLLAMA_KEEP_ALIVE = "-1"` |
| `admin-update.ps1` | Changelog + update + rebuild + doctor check |
| `generate-prd.ps1` | Idea -> LLM-enriched PRD document |
| `project-analyze.ps1` | PRD → semantic stack + feature detection |
| `code-analyze.ps1` | Project directory → semantic tech stack extraction |
| `analyze-project.ps1` | File indicator → stack detection → skill loading |
| `research.ps1` | Web search + LLM summarization via 9Router |
| `quality-gate.ps1` | Multi-stage quality check + LLM analysis |
| `session-manager.ps1` | CRUD session JSON files |
| `project-resolve.ps1` | Active project resolution + slug management |
| `token-tracker.ps1` | 9Router token usage display |

### Hooks (Auto-Trigger)

| Hook | Trigger | Action |
|------|---------|--------|
| `self-heal.ps1` | After Edit/Write | Check types → LLM suggest fix |
| `eval-gate.ps1` | After editing test files | Auto-run tests → LLM analyze |
| `instinct-extract.ps1` | Session end | Session log → LLM pattern extraction → save to knowledge |
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
├── profiles/                  # Config profiles (gratis/go)
├── instructions/              # AI behavioral instructions
├── templates/                 # Project templates
├── ecc/                       # ECC repo (auto-cloned)
├── 9router/                   # 9Router repo (auto-cloned)
├── Modelfile                  # qwen2.5-coder:3b-s (GPU optimized)
├── Modelfile.qwen3            # qwen3:1.7b-s (GPU optimized)
├── .opencode/                 # Mode state, telemetry (gitignored)
├── README.md
├── DEV-PLAN.md                # Self-improvement roadmap
└── CHANGELOG.md               # Release history
```

---

## Cost

| Komponen | Biaya | Kegunaan |
|----------|-------|----------|
| OpenCode Free | ✅ $0 | AI coding assistant (Cloud AI) |
| 9Router | ✅ $0 | AI gateway + free model combos |
| ECC (270 skills) | ✅ $0 | Knowledge base |
| Ollama (qwen3:1.7b / qwen2.5-coder:3b) | ✅ $0 | Local LLM preprocessing |

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
