# Arsitektur — Overview

## Bagaimana Semuanya Terhubung

```
opencode-setup/
├── scripts/                    # Automation + LLM pipeline scripts
├── commands/                   # OpenCode command templates
├── profiles/                   # Config profiles (gratis/go)
├── instructions/               # AI behavioral instructions
├── templates/                  # Project templates
├── ecc/                        # 270+ skills, 64 agents (auto-cloned)
├── 9router/                    # AI gateway (auto-cloned)
├── Modelfile / Modelfile.qwen3 # GPU-optimized model configs
├── .opencode/                  # Mode state, telemetry (gitignored)
├── Feature/                    # Feature inventory
├── Skill/                      # Skill catalog
└── docs/                       # Documentation
```

## Alur Data (2-Stage Pipeline)

```
┌─────────────────────────────────────────────────────┐
│ USER INPUT                                          │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ STAGE 1: LOCAL OLLAMA (GPU)                         │
│                                                     │
│  Invoke-LLMEnrich()                                 │
│    ECO      → pass-through                          │
│    BALANCED → qwen3:1.7b-s (GPU) ~250 tok          │
│    PERFORM  → qwen2.5-coder:3b-s (GPU) ~512 tok    │
│                                                     │
│  Output: enriched context (internal)                │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│ STAGE 2: CLOUD AI (OpenCode + 9Router)              │
│                                                     │
│  OpenCode → ECC Skills/Agents → 9Router → AI Model  │
│                                                     │
│  Output: jawaban + LLM Status Footer                │
└─────────────────────────────────────────────────────┘
```

## 4 Komponen Utama

### 0. LLM Pipeline (NEW)

Local Ollama preprocessing di GPU sebelum input diteruskan ke Cloud AI:

- **3 mode**: ECO (0 VRAM), BALANCED (~1.5 GB), PERFORMANCE (~2 GB)
- **Invoke-LLMEnrich** — wajib di tiap input user
- **Footer system** — status mode + token + profile tiap respons
- **[Detail →](05-llm-pipeline.md)**

### 1. ECC (Everything Claude Code)

Kumpulan knowledge base untuk AI coding assistant:

| Komponen | Jumlah | Fungsi |
|----------|--------|--------|
| Skills | 270 | Domain knowledge per bahasa/framework |
| Agents | 64 | AI assistant spesialis |
| Commands | 84 | Perintah slash (/plan, /tdd, dll) |
| Hooks | 20+ | Otomasi sebelum/sesudah tool |
| Rules | 20 pack | Konvensi coding per bahasa |

### 2. 9Router

AI gateway yang menghubungkan ke berbagai provider:

```
9Router (localhost:20128)
    │
    ├── OpenCode Free (gratis, unlimited)
    ├── Kiro AI (gratis, Claude 4.5)
    ├── OpenCode Go (berbayar, limited)
    ├── OpenRouter
    └── Provider lainnya
```

Fitur utama:
- **RTK Token Saver** — Kompres tool output (-20-40% tokens)
- **Caveman Mode** — Reply singkat (-65% output tokens)
- **Combos** — Auto-fallback chain

### 3. Combo System

Ketika model pertama gagal (429, 503), otomatis pindah ke model berikutnya:

```
gratis: mimo-v2.5-free → deepseek-v4-flash-free → claude-sonnet-4.5
go: kimi-k2.6 → qwen3.6-plus → glm-5.1
gratis-small: deepseek-v4-flash-free → glm-5 → north-mini-code-free
```

## Alur Kerja Harian

```
1. cd my-project
2. cd opencode-setup
3. opencode
4. /analyze-project      ← deteksi stack
5. restart opencode
6. /start-free           ← mulai dengan model gratis
7. /llm performance      ← aktifkan local GPU preprocessing
8. Mulai coding!         ← tiap input via Invoke-LLMEnrich dulu
```

## Lihat Juga

- [LLM Pipeline](05-llm-pipeline.md) — Detail local preprocessing + 3 mode
- [9Router](02-9router.md) — Detail AI gateway
- [ECC](03-ecc.md) — Detail skills/agents
- [Combos](04-combos.md) — Detail auto-fallback

