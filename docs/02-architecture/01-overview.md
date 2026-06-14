# Arsitektur — Overview

## Bagaimana Semuanya Terhubung

```
my-project/
├── src/                    # Source code kamu
├── pubspec.yaml            # (contoh: Flutter project)
└── opencode-setup/         # Clone ini di sini
    ├── ecc/                # 270+ skills, 64 agents
    ├── 9router/            # AI gateway
    ├── scripts/            # Automation scripts
    ├── profiles/           # Config profiles
    ├── commands/           # Command templates
    ├── Feature/            # Feature inventory
    └── Skill/              # Skill catalog
```

## Alur Data

```
[User] → [OpenCode] → [9Router] → [Provider Model]
                   │
                   ├── ECC Skills (270+)
                   ├── ECC Agents (64)
                   ├── ECC Commands (84)
                   └── ECC Rules (20 bahasa)
```

## 3 Komponen Utama

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
7. Mulai coding!
```

## Lihat Juga

- [9Router](02-9router.md) — Detail AI gateway
- [ECC](03-ecc.md) — Detail skills/agents
- [Combos](04-combos.md) — Detail auto-fallback
