# LLM Pipeline — Local Preprocess + Cloud Respond

## Arsitektur 2-Stage

```
┌─────────────────────────────────────────────────────┐
│ USER INPUT                                          │
│ "buat CRUD penduduk"                                │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ STAGE 1: LOCAL OLLAMA (GPU) — Preprocessor          │
│                                                     │
│  1. Baca mode dari .opencode/llm-mode.json          │
│  2. Invoke-LLMEnrich() → enrich input               │
│  3. Output: enriched context (internal, user ga liat)│
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ STAGE 2: CLOUD AI (OpenCode + 9Router) — Responder  │
│                                                     │
│  1. Terima enriched context                         │
│  2. Proses via ECC skills + commands                │
│  3. Output: jawaban + footer status                 │
└─────────────────────────────────────────────────────┘
```

## 3 Operating Modes

| Mode | Model | Quant | VRAM | GPU | Enrich |
|------|-------|-------|------|-----|--------|
| **ECO** | Unloaded | — | 0 MB | idle | pass-through |
| **BALANCED** | qwen3:1.7b-s | Q4_K_M | ~1493 MB | 100% | ~250 tok |
| **PERFORMANCE** | qwen2.5-coder:3b-s | Q4_K_S | ~1951 MB | 100% | ~512 tok |

### Mode Switching

```powershell
/llm eco           # Unload model, VRAM 0 MB
/llm balanced      # Load qwen3:1.7b-s ke GPU
/llm performance   # Load qwen2.5-coder:3b-s ke GPU
/llm status        # Cek mode + VRAM + model
```

**VRAM management otomatis:**
- ECO → `ollama stop` → unload semua model → VRAM 0 MB
- BALANCED → unload qwen2.5-coder dulu → load qwen3 → VRAM ~1493 MB
- PERFORMANCE → unload qwen3 dulu → load qwen2.5-coder → VRAM ~1951 MB

## GPU Optimization

| Aspek | Detail |
|-------|--------|
| **Forced GPU** | Parameter `num_gpu = 99` di adapter + Modelfile — 100% GPU |
| **Quantization** | Q4_K_S (1.71 GB) vs Q4_K_M (1.9 GB) — Q4_K_S fit di 2GB VRAM |
| **Keep Alive** | `$env:OLLAMA_KEEP_ALIVE = "-1"` — model stay di VRAM |
| **Cold Load** | ~6s (balanced), ~10s (performance) |

**Modelfiles:**
- `Modelfile` — qwen2.5-coder:3b-s (num_gpu 99, num_ctx 2048)
- `Modelfile.qwen3` — qwen3:1.7b-s (num_gpu 99, num_ctx 2048)

## Footer System

Setiap respons AI menyertakan footer status:

```
LLM : [ PERFORMANCE ] - Tokens : [ 18 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```

| Field | Sumber | Arti |
|-------|--------|------|
| MODE | `.opencode/llm-mode.json` | ECO / BALANCED / PERFORMANCE |
| Tokens | Estimasi output | ~1 token per 4 chars |
| Profile | `profiles/*/opencode.jsonc` | Gratis / Go |
| Model | Cloud AI model | DS V4 Flash, MiMo V2.5, dll |

Dijalankan otomatis via `instructions/llm-status-footer.md` — AI wajib append footer.

## Script Pipeline

| Script | Stage | Fungsi |
|--------|-------|--------|
| `llm-adapter.ps1` | Local | Ollama wrapper: Invoke-LLM, Invoke-LLMEnrich, num_gpu=99 |
| `llm-mode.ps1` | Local | 3-mode toggle + auto VRAM management |
| `llm-preprocess.ps1` | Local | Full preprocessor: stack → skill → feature → memory → intent → route |
| `intent-compiler.ps1` | Local | NL → JSON spec (LLM + regex dual path) |
| `skill-router.ps1` | Local | Select 3-10 skills dari 270 by intent |
| - | - | - |
| `instructions/llm-status-footer.md` | Behavioral | AI wajib append footer tiap respons |
| `ecc/.opencode/instructions/llm-preprocess.md` | Behavioral | AI wajib panggil Invoke-LLMEnrich tiap input |

## Behavioral Contract

WAJIB di setiap sesi chat:

```
1. BACA .opencode/llm-mode.json  →  tau mode
2. KALO mode != eco:
   a. JALANKAN Invoke-LLMEnrich("<input>", "universal preprocess")
   b. SIMPAN enriched context (internal)
3. KALO mode == eco:
   a. PAKAI raw input (no LLM)
4. JAWAB user pake enriched context
5. TULIS .opencode/llm-status.json
6. APPEND footer
```

## File State

| File | Fungsi | Git? |
|------|--------|------|
| `.opencode/llm-mode.json` | Mode saat ini (eco/balanced/performance) + model | ❌ auto-generated |
| `.opencode/llm-status.json` | Status footer terakhir | ❌ auto-generated |
| `.opencode/llm-usage.jsonl` | History token usage | ❌ auto-generated |

## Lihat Juga

- [Architecture Overview](01-overview.md) — Keseluruhan arsitektur
- [9Router](02-9router.md) — Cloud AI gateway
- [ECC](03-ecc.md) — Skills, agents, commands
- [Scripts Reference](../../04-usage/02-scripts.md) — Detail script pipeline
