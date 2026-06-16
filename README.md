# Personal Knowledge Operating System

Buat aplikasi tanpa coding. AI yang kerja. Semua gratis.

Local LLM (Ollama, GPU) + Cloud AI (OpenCode) = pipeline hybrid 2-stage.

---

## The Story

Bu Rina punya toko kelontong. Catat stok di buku, hitung manual, sering kehabisan barang. Dia ingin aplikasi kasir — tapi tidak bisa coding dan tidak punya duit.

**Sekarang tinggal bilang, AI yang kerjakan.**

Terinspirasi dari Bu Rina, sistem ini berevolusi jadi **Personal Knowledge Operating System** — gabungan AI agent, local GPU preprocessing, memory per-project, knowledge base, dan self-improvement loop. Semua jalan di laptop lokal, semua gratis.

---

## Quick Start

```powershell
git clone https://github.com/fannndi/opencode-setup.git
cd opencode-setup
.\scripts\setup.ps1
# Fill api-key.txt, then:
.\scripts\setup.ps1 --apply
opencode
```

Atau lewat OpenCode:
```
/setup           # Install everything
/setup --apply   # Apply api-key, verify, done
```

---

## Architecture: 2-Stage Hybrid Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│ USER INPUT                                                      │
│ "bikin CRUD penduduk"                                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 1: LOCAL LLM (Ollama on NVIDIA GPU)                       │
│                                                                  │
│  Langkah yang terjadi di SETIAP user input:                      │
│                                                                  │
│  1. AI baca .opencode/llm-mode.json → tau mode saat ini         │
│  2. Kalo ECO → skip, pake raw input (no LLM)                    │
│  3. Kalo BALANCED → Invoke-LLMEnrich(qwen3:1.7b-s, ~250 tok)   │
│  4. Kalo PERFORMANCE → Invoke-LLMEnrich(coder:3b-s, ~512 tok)   │
│  5. Enriched context disimpan internal (user ga pernah liat)    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 2: CLOUD AI (OpenCode via 9Router)                        │
│                                                                  │
│  1. Terima enriched context dari Stage 1                         │
│  2. ECC skills/agents/commands nambahin konteks                 │
│  3. 9Router route ke model cloud (DS V4 Flash, MiMo, dll)       │
│  4. Jawab user dengan konteks lebih kaya                        │
│  5. Append LLM Status Footer di akhir respons                   │
└─────────────────────────────────────────────────────────────────┘
```

**Konsep kunci:**
- Local LLM = **preprocessor**, bukan responder. Input → enrich → internal.
- Cloud AI = **responder**, pake enriched context buat jawab lebih baik.
- User input "hai" → GPU aktif ~400ms → enriched → Cloud AI jawab.
- ECO mode = bypass local LLM, Cloud AI jawab langsung.

---

## 3 Operating Modes

### VRAM Lifecycle

```
╔═════════════╦══════════╦═══════╦═══════════╦══════════════════════╗
║    Mode     ║  Model   ║ VRAM  ║  GPU      ║ Keep-alive           ║
╠═════════════╬══════════╬═══════╬═══════════╬══════════════════════╣
║ ECO         ║ Unloaded ║ 0 MB  ║ idle      ║ n/a                  ║
║ BALANCED    ║ qwen3    ║ 1.5GB ║ 100%      ║ Forever (loaded)     ║
║ PERFORMANCE ║ coder:3b ║ 2.0GB ║ 100%      ║ Forever (loaded)     ║
╚═════════════╩══════════╩═══════╩═══════════╩══════════════════════╝
```

**Apa yang terjadi pas switch mode:**

```
/llm eco
  → ollama stop qwen2.5-coder:3b-s   (unload dari VRAM)
  → ollama stop qwen3:1.7b-s         (unload dari VRAM)
  → VRAM: 0 MB ✅

/llm balanced
  → ollama stop qwen2.5-coder:3b-s   (free VRAM dulu)
  → [Environment]::SetEnvironmentVariable("OLLAMA_KEEP_ALIVE", "-1", "User")
  → Restart Ollama + env var persist
  → Warmup 1x inference → load model ke VRAM
  → VRAM: ~1493 MB ✅

/llm performance
  → ollama stop qwen3:1.7b-s         (free VRAM dulu)
  → Set env var + restart Ollama
  → Warmup 1x inference → load model
  → VRAM: ~1951 MB ✅
```

**Setiap API call ke Ollama** menyertakan `keep_alive: -1` — model **Forever** di VRAM, ga pernah cold start lagi selama mode sama.

---

## GPU Optimization

| Aspek | Detail |
|-------|--------|
| **Model kustom** | `qwen3:1.7b-s`, `qwen2.5-coder:3b-s` — Modelfile `num_gpu 99`, `num_ctx 2048` |
| **Forced GPU** | `num_gpu=99` di adapter + Modelfile — paksa semua layer ke GPU |
| **VRAM fit** | Q4_K_S (1.71 GB) vs Q4_K_M (1.9 GB). Q4_K_S muat full, Q4_K_M spill ke CPU |
| **Keep-alive** | `keep_alive=-1` di setiap request + `[Environment]::SetEnvironmentVariable` persistent |
| **Auto-warmup** | Switch mode → langsung 1x inference dummy → model loaded |
| **ECO cleanup** | `ollama stop` → unload dari VRAM, GPU 0 buat aplikasi lain |
| **Inference** | ~400ms-3s per enrich tergantung mode + token count |

**Kenapa Q4_K_S?** Q4_K_M (1.9 GB) + KV cache (200 MB) = 2.1 GB > 2 GB VRAM → spill ke CPU. Q4_K_S (1.71 GB) + KV cache = 1.95 GB → **100% GPU, zero CPU**.

---

## Behavioral Contract

Ini yang menentukan apakah pipeline benar-benar jalan atau cuma pajangan:

```
WAJIB — SETIAP user input:

1. BACA  .opencode/llm-mode.json      →  tau mode
   KALO mode != eco:
   a.  JALANKAN  Invoke-LLMEnrich()   →  local GPU aktif
   b.  SIMPAN    enriched context     →  internal, ga ditampilkan
   KALO mode == eco:
   a.  PAKAI     raw input langsung    →  no LLM

2. JAWAB  user pake enriched/raw context

3. TULIS  .opencode/llm-status.json   →  token, mode, profile, model

4. APPEND footer:
   LLM : [ MODE ] - Tokens : [ X ] - Profile : [ Y ] - Model : [ Z ]
```

Instruction file: `ecc/.opencode/instructions/llm-preprocess.md`
Footer format: `instructions/llm-status-footer.md`
Mode state: `.opencode/llm-mode.json` (auto-generated)
Status file: `.opencode/llm-status.json` (auto-generated)

---

## Footer System

```
LLM : [ PERFORMANCE ] - Tokens : [ 18 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```

| Field | Arti | Sumber |
|-------|------|--------|
| MODE | Mode local LLM preprocessing | `.opencode/llm-mode.json` |
| Tokens | Estimasi token output respons AI | Perhitungan ~1 token / 4 chars |
| Profile | Profile opencode aktif | Deteksi dari `profiles/*/opencode.jsonc` |
| Model | Cloud AI model yang menjawab | Nama alias (DS V4 Flash, MiMo V2.5, dll) |

---

## Commands

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `/go <query>` | Universal goal combo | `/go "bikin CRUD penduduk"` |
| `/llm <mode>` | Set operating mode + auto-warmup | `/llm performance` |
| `/audit <path>` | LLM code audit dengan loop | `/audit scripts\` |
| `/intent <query>` | NL → structured JSON spec | `/intent "buat CRUD"` |
| `/route <query>` | Intent → relevant ECC skills | `/route "PHP MySQL"` |
| `/dashboard` | System overview | `/dashboard` |
| `/task-queue <goal>` | Autonomous DAG execution | `/task-queue "bikin login"` |
| `/learn <note>` | Save ke memory + knowledge | `/learn "fixed login bug"` |

---

## 3 Main Workflows

### 1. Setup
```
/setup           # Install dari 0: 9Router, ECC, config, api-key
/setup --apply   # Apply api-key, verify, done
```

### 2. Start (Morning Routine)
```
/start-free      # Free models + auto-heal
/start-go        # Go models + auto-heal
```

### 3. Admin (Update + Doctor)
```
/admin           # Pull repos, changelog, rebuild, doctor
/admin --doctor  # Doctor check only
```

---

## Scripts Reference

### LLM Pipeline (Core)

| Script | Fungsi |
|--------|--------|
| `llm-adapter.ps1` | Ollama wrapper: Invoke-LLM, Invoke-LLMEnrich, Invoke-LLMChunk, failure logging, `num_gpu=99`, `keep_alive=-1` |
| `llm-mode.ps1` | 3-mode toggle + persistent keep-alive + auto-warmup + VRAM management |
| `llm-preprocess.ps1` | Universal input pipeline: stack → skill → feature → memory → knowledge → intent → route |
| `intent-compiler.ps1` | Natural language → structured JSON spec (dual path: LLM + regex) |
| `skill-router.ps1` | Select 3-10 skills from 270 by intent + stack |

### Agent Layer

| Script | Fungsi |
|--------|--------|
| `agent-core.ps1` | Stack detection, intent classification, skill auto-loader, session resume |
| `task-queue.ps1` | Autonomous DAG execution |
| `agent-dashboard.ps1` | System overview dashboard |
| `tool-creator.ps1` | Template-based script/command generator |

### Knowledge Layer

| Script | Fungsi |
|--------|--------|
| `knowledge.ps1` | Structured knowledge base |
| `knowledge-miner.ps1` | Session logs → LLM extract patterns → save |
| `memory.ps1` | Per-project session memory |
| `profile-optimizer.ps1` | Track skill usage → recommend |

### Infrastructure

| Script | Fungsi |
|--------|--------|
| `setup.ps1` | Smart setup: detect 9Router, clone ECC, build plugin |
| `start.ps1` | Auto-heal morning routine + `$env:OLLAMA_KEEP_ALIVE` |
| `admin-update.ps1` | Changelog + update + rebuild + doctor |
| `generate-prd.ps1` | Idea → LLM-enriched PRD document |
| `code-analyze.ps1` | Source code → semantic tech stack |
| `analyze-project.ps1` | File indicator → stack detection |
| `research.ps1` | Web search + AI ringkasan via 9Router |
| `quality-gate.ps1` | Multi-stage quality check |
| `sync.ps1` | Sync changelog ECC + 9Router |
| `token-tracker.ps1` | Token usage display |

### Hooks (Auto-Trigger)

| Hook | Trigger | Action |
|------|---------|--------|
| `self-heal.ps1` | After Edit/Write | Check types → LLM suggest fix |
| `eval-gate.ps1` | After editing test files | Auto-run tests → LLM analyze |
| `instinct-extract.ps1` | Session end | Session log → pattern extraction |
| `proactive-research.ps1` | Before Edit/Write | Unknown library detection |

---

## Project Structure

```
opencode-setup/
├── Project/                   # Per-project data (gitignored)
├── scripts/                   # 40+ automation scripts
│   └── hooks/                 # 4 auto-trigger hooks
├── commands/                  # OpenCode command templates
├── profiles/                  # Config profiles (gratis/go)
├── instructions/              # AI behavioral instructions
├── templates/                 # Project templates
├── ecc/                       # ECC submodule
├── 9router/                   # 9Router submodule
├── Modelfile                  # qwen2.5-coder:3b-s (GPU optimized)
├── Modelfile.qwen3            # qwen3:1.7b-s (GPU optimized)
├── .opencode/                 # Mode state, telemetry (gitignored)
│   ├── llm-mode.json          # Mode saat ini
│   ├── llm-status.json        # Footer status terakhir
│   └── llm-usage.jsonl        # History token usage
├── README.md
├── DEV-PLAN.md
└── CHANGELOG.md
```

---

## Cost

| Komponen | Biaya | Fungsi |
|----------|-------|--------|
| OpenCode Free | ✅ $0 | Cloud AI coding assistant |
| 9Router | ✅ $0 | AI gateway + free model combos |
| ECC (270 skills) | ✅ $0 | Knowledge base |
| Ollama (qwen3:1.7b / qwen2.5-coder:3b) | ✅ $0 | Local GPU preprocessing |
| **Total** | **$0.00** | |

---

## Credits

- **OpenCode** — AI coding assistant by Anomaly Co.
- **9Router** — AI gateway with free model combos
- **ECC** (Everything Claude Code) — 270+ skills, 84 commands, agent hooks

---

**Masa depan: tinggal bilang, AI yang kerjakan.**
