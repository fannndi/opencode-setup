# Personal Knowledge Operating System

**An AI-powered development platform with hybrid local/cloud LLM processing.**  
*Zero cost. Local GPU preprocessing. Cloud AI execution.*

> Seperti punya asisten coding yang nalarnya dibantu procesor dedicated —  
> GPU lokal mikir dulu, baru AI cloud jawab.

---

## What Is This?

Imagine you walk into a restaurant and tell the waiter your order in casual language.  
The waiter translates it into a precise kitchen ticket, then passes it to the chef.

That's this system.

| Role | Component | Task |
|------|-----------|------|
| **You** | User | Speak naturally: _"bikin CRUD penduduk desa"_ |
| **Waiter** | Ollama (local GPU) | Preprocesses your words into enriched context |
| **Chef** | OpenCode + 9Router (cloud AI) | Executes using the enriched context + 270+ expert skills |

**Local LLM (Ollama) parses, enriches, and refines your input before the cloud AI ever sees it.**  
This means: better responses, lower cloud token usage, and full control over your data preprocessing.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           USER INPUT                                        │
│                     "bikin CRUD penduduk desa"                              │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 1 — LOCAL GPU PREPROCESSOR  (Ollama on NVIDIA MX150)                │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │  Invoke-LLMEnrich()                                                 │   │
│  │                                                                     │   │
│  │  ECO        → bypass — raw input goes directly to cloud             │   │
│  │  BALANCED   → qwen2.5:1.5b-s — enrich 100 tokens                    │   │
│  │  PERFORMANCE → qwen2.5:1.5b-s — enrich 200 tokens                   │   │
│  │                                                                     │   │
│  │  Output: enriched context (kept internal, never shown to user)      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  VRAM:  0 MB (idle) │  ~1 GB (enriching) │  ~1 GB (enriching)              │
│  GPU:   idle        │  25-60% utilization │  25-60% utilization             │
│  Keep:  5 min timeout — auto-unload setelah idle                            │
│  Auto:  Warmup on input, unload setelah 5 min idle                         │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 2 — CLOUD AI EXECUTOR  (OpenCode + 9Router)                        │
│                                                                             │
│  Receives enriched context from Stage 1                                    │
│  + ECC (270 skills, 64 agents, 84 commands)                               │
│  + 9Router routes to free providers (DeepSeek, MiMo, Nemotron...)         │
│  + Returns answer + LLM Status Footer                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Why Two Stages?

| Without Local Preprocessing | With Local Preprocessing |
|---------------------------|--------------------------|
| _"bikin CRUD penduduk desa"_ goes raw to cloud AI | Input enriched to: `domain:web_desa, module:penduduk, features:[crud,auth], stack:[php,mysql]` |
| Cloud AI must guess your intent | Cloud AI knows exactly what you need |
| More tokens wasted on clarification | Less tokens, better output |

---

## Operating Modes

Like a car transmission: three gears for different driving conditions.

```
┌─────────────┬─────────────────┬────────┬──────────┬──────────┬──────────────────┐
│    Mode     │ Model           │ VRAM   │ GPU      │ Enrich   │ Use Case         │
├─────────────┼─────────────────┼────────┼──────────┼──────────┼──────────────────┤
│  ECO        │ Unloaded        │  0 MB  │ idle     │    0 tok │ Battery, gaming  │
│  BALANCED   │ qwen2.5:1.5b-s │ ~1 GB  │ 25-60%   │  100 tok │ Daily coding     │
│  PERFORMANCE│ qwen2.5:1.5b-s │ ~1 GB  │ 25-60%   │  200 tok │ Complex tasks    │
└─────────────┴─────────────────┴────────┴──────────┴──────────┴──────────────────┘
```

### VRAM Lifecycle (5 min timeout)

```
Default:     VRAM 0 MB (model unloaded)
User input:  Warmup → cold load ~6-10s → VRAM ~1 GB → enrichment → response
During chat: Model stays loaded (< 5 min gap between inputs)
Idle 5 min:  Model auto-unloads → VRAM 0 MB
```

### Switching Cost

| Event | Time | What Happens |
|-------|------|-------------|
| First input (cold) | ~6-10s | Model loads to VRAM |
| Subsequent inputs (< 5 min) | ~0.1-1s | Model still in VRAM |
| After 5 min idle | 0s | Model auto-unloads, VRAM 0 MB |

---

## Execution Rules

### User Mode (Default)
```
1. Input presisi → eksekusi langsung
2. Max 1-2 pertanyaan → lalu eksekusi
3. NEW task → HOLD → PLAN → eksekusi
4. Fix/bug → langsung eksekusi
5. Jika ambigu → pilih opsi terbaik → eksekusi → user koreksi kalo salah
```

### Admin Mode (`/admin`, `/setup`, `/llm`)
```
1. Goal-oriented → langsung eksekusi
2. Boleh tanya untuk clarify
3. Eksplorasi boleh
4. No planning hold
```

### Session Start (Morning Routine)
```
1. Read .opencode/context.md → state terkini
2. Read .opencode/llm-mode.json → mode info
3. Detect mode: User atau Admin
4. Write status → append footer
```

---

## How It Works — Step by Step

### With Analogy

> Imagine you're dictating a letter to an assistant.  
> Your **local processor** (Stage 1) listens, notes the key points, and organizes them on a sticky note.  
> Your **cloud AI** (Stage 2) takes the sticky note and writes the actual letter — beautifully, with all the right formatting, tone, and detail.

### The Behavioral Contract

Every user message triggers this sequence:

```
STEP 0: Session Init (first message)
├── Read .opencode/context.md → state terkini
├── Read .opencode/llm-mode.json → mode (ECO/BALANCED/PERFORMANCE)
├── Detect User/Admin mode
└── Write .opencode/llm-status.json + footer

STEP 1: Enrich
├── Read .opencode/llm-mode.json
├── IF mode != eco → Invoke-LLMEnrich() → GPU spike >0%
├── IF mode == eco → skip, raw input
└── Save enriched context (internal)

STEP 2: Execute
├── User mode: presisi, max 2 tanya, plan untuk NEW task
├── Admin mode: goal-oriented, boleh clarify
└── Apply mode rules

STEP 3: Footer (COMPLIANCE HOOK)
├── Write .opencode/llm-status.json
└── Append footer: Mode : [User/Admin] | LLMEnrich : [On/Off] - EnrichTime : [Xs] - Cloud : [Y]
```

---

## The Footer System (Enforcement Hook)

Every response includes a footer that acts as a **compliance enforcement hook**:

```
Mode : [ User ] | LLM : [ PERFORMANCE ] - LLMEnrich : [ On ] - EnrichTime : [ 4.2s ] - Profile : [ Gratis ] - Cloud : [ gratis ]
```

| Field | Meaning | Enforcement |
|-------|---------|-------------|
| `Mode: [User]` | Input presisi, max 2 tanya, eksekusi cepat | Default chat mode |
| `Mode: [Admin]` | Goal-oriented, boleh clarify | `/admin`, `/setup`, `/llm` |
| `LLMEnrich: [On]` | Local GPU preprocessing berjalan | |
| `LLMEnrich: [Off]` | **AI GAGAL COMPLY** | User langsung lihat kegagalan |
| `EnrichTime` | Waktu GPU enrichment (0ms=ECO, 4s=warm, 10s=cold) | |
| `Profile` | Gratis / Go | |
| `Cloud` | Cloud AI model name (from profile config) | |

**Footer bukan dekorasi** — ini enforcement hook. LLMEnrich [Off] berarti enrichment tidak berjalan.

### User Mode vs Admin Mode

| Aspect | User Mode | Admin Mode |
|--------|-----------|------------|
| Input style | Presisi, coding task | Goal-oriented, setup/maintenance |
| Pertanyaan | Max 1-2 lalu eksekusi | Boleh clarify dulu |
| Planning | NEW task → HOLD → PLAN → BUILD | No hold, langsung eksekusi |
| Commands | Coding task, bug fix | `/admin`, `/setup`, `/llm`, `/audit` |
| Default | Yes | Only when admin commands used |

---

## Quick Setup (WAJIB — JANGAN SKIP)

> **Peringatan:** Jangan langsung chat tanpa setup. AI akan **MENOLAK** menjawab sampai setup selesai.

### First Install (sekali doang)

```powershell
# 1. Clone repo
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup

# 2. Install semua dependencies (Node, npm, OpenCode, 9Router, ECC)
.\scripts\setup.ps1

# 3. Isi API key
#    Buka file api-key.txt, ganti YOUR-API-KEY-HERE dengan key dari 9Router
#    Dashboard: http://localhost:20128/dashboard (password: 123456)

# 4. Apply + verify
.\scripts\setup.ps1 --apply
```

### Setiap Mulai Sesi Baru (daily)

```powershell
# Cara 1: Lewat terminal
.\scripts\start.ps1 -Profile gratis
opencode

# Cara 2: Lewat OpenCode CLI (di terminal)
opencode
/start-free    # Morning routine
/go "bikin CRUD"  # Mulai kerja

# Cara 3: Lewat IDE (VS Code, dll)
#    Buka folder opencode-setup di IDE
#    Jalankan terminal di dalam IDE
#    Ketik: /setup atau /start-free
```

### Command Reference

| Command | Fungsi | Kapan Dipake |
|---------|--------|--------------|
| `/setup` | Install lengkap (dependencies + config) | Pertama kali |
| `/setup --apply` | Apply API key + verify | Setelah isi api-key.txt |
| `/start-free` | Morning routine (free models) | Setiap hari |
| `/admin` | Update + changelog + doctor check | Maintenance |

### ⛔ JANGAN lakukan ini:
- Langsung chat tanpa `/setup` atau `/start-free` dulu
- Skip langkah `.\scripts\setup.ps1`
- Lupa isi `api-key.txt`

---

## Commands Reference

| Command | Function | Example |
|---------|----------|---------|
| `/go <query>` | Universal goal-based execution | `/go "bikin CRUD penduduk"` |
| `/llm <mode>` | Switch operating mode (eco/balanced/performance) | `/llm performance` |
| `/intent <query>` | Compile natural language → JSON spec | `/intent "buat CRUD"` |
| `/route <query>` | Route intent → relevant ECC skills | `/route "PHP MySQL"` |
| `/audit <path>` | LLM-powered code audit | `/audit scripts\` |
| `/dashboard` | System overview | `/dashboard` |
| `/task-queue <goal>` | Autonomous task DAG execution | `/task-queue "bikin login"` |
| `/learn <note>` | Save to memory + knowledge base | `/learn "fixed login bug"` |

---

## Project Structure

```
opencode-setup/
│
├── Project/                    # Per-project data (gitignored)
│   ├── <slug>/                 # Cloned source code
│   ├── Knowledge/<slug>/       # Project knowledge base
│   ├── Session/<slug>/         # Session state per project
│   ├── Memory/<slug>/          # Logs, patterns, errors
│   └── registry.json           # Project index + active tracking
│
├── scripts/                    # 45+ PowerShell automation scripts
│   ├── llm-adapter.ps1         # Core: Ollama API wrapper + enrichment
│   ├── llm-mode.ps1            # Mode toggle + VRAM management
│   ├── llm-preprocess.ps1      # Full preprocessing pipeline
│   ├── intent-compiler.ps1     # Natural language → JSON spec
│   ├── skill-router.ps1        # Select 3-10 skills from 270
│   └── hooks/                  # 4 auto-trigger hooks
│
├── profiles/                   # Config profiles (gratis/go)
├── instructions/               # AI behavioral instructions
├── templates/                  # Project templates
├── ecc/                        # ECC submodule (270 skills, 64 agents)
├── 9router/                    # 9Router submodule (AI gateway)
│
├── Modelfile                   # GPU-optimized model configs
├── Modelfile.qwen3             # (legacy, preserved for reference)
├── Modelfile.qwen2-1.5b        # Active balanced/performance model
│
├── .opencode/                  # AI system state (gitignored)
│   ├── context.md              # Compiled session state
│   ├── active-instructions.md  # Mode-compiled instructions
│   ├── session-summary.md      # End-of-session report
│   ├── file-index.json         # Content hash cache
│   ├── llm-mode.json           # Current operating mode
│   ├── llm-status.json         # Last response footer data
│   └── llm-usage.jsonl         # Token usage history
│
├── README.md
├── CHANGELOG.md
└── DEV-PLAN.md
```

---

## Technical Details

### GPU Optimization

| Component | Detail |
|-----------|--------|
| GPU | NVIDIA MX150 — 2 GB VRAM, 384 CUDA cores |
| Model | qwen2.5:1.5b (1.5B parameters, Q4_K_M) |
| Quantization | Q4_K_M — 4-bit, minimal quality loss |
| VRAM Usage | ~1 GB (52% of available) |
| GPU Utilization | 25-60% during enrichment |
| Inference Speed | ~6.5 tokens/second |
| Keep-Alive | Default 5 min timeout — model auto-unloads setelah idle |

### Why This Model?

Comparing the options evaluated for this GPU:

| Model | Parameters | VRAM | Tok/s | Verdict |
|-------|-----------|------|-------|---------|
| qwen2.5-coder:3b-s | 3.1B | ~2 GB (95%) | ~2 tok/s | ❌ Too slow, VRAM saturation |
| **qwen2.5:1.5b-s** | **1.5B** | **~1 GB (52%)** | **~6.5 tok/s** | **✅ Optimal balance** |
| qwen3:1.7b | 1.7B | ~1.5 GB (73%) | ~5 tok/s | ⚠️ Adequate but legacy |

### What Happens on Mode Switch (Detailed)

```
PERFORMANCE → ECO:
  1. [Environment]::SetEnvironmentVariable("OLLAMA_KEEP_ALIVE", ...)
  2. ollama stop qwen2.5:1.5b-s    → unload from VRAM
  3. VRAM: 0 MB                     → free for other apps

ECO → PERFORMANCE:
  1. ollama stop qwen2.5:1.5b-s   (if loaded from previous mode)
  2. Start ollama serve if not running
  3. Set keep_alive=-1 persistent
  4. Warmup: 1x inference → load model to VRAM
  5. VRAM: ~1 GB                   → ready for enrichment
```

---

## Cost

| Component | Cost | Role |
|-----------|------|------|
| OpenCode Free | **$0** | Cloud AI coding assistant |
| 9Router | **$0** | AI gateway + free model providers |
| ECC (270 skills) | **$0** | Expert knowledge base |
| Ollama (local models) | **$0** | GPU preprocessing |

**Total: $0.00.** No API keys required. No credit card needed.

---

## Credits

Built on three open-source foundations:

- **OpenCode** by Anomaly Co. — AI coding assistant platform
- **9Router** — AI gateway with free model routing
- **ECC** (Everything Claude Code) — 270+ skills, 84 commands, 64 agents

---

*"Masa depan: tinggal bilang, AI yang kerjakan."*
