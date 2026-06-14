# Profile Gratis — 100% Free Models

## Model yang Digunakan

| Model | Provider | Biaya |
|-------|----------|-------|
| `mmf/mimo-auto` | MiMo Code Free | $0 |
| `oc/mimo-v2.5-free` | OpenCode Free | $0 |
| `oc/deepseek-v4-flash-free` | OpenCode Free | $0 |
| `oc/big-pickle` | OpenCode Free | $0 |
| `oc/north-mini-code-free` | OpenCode Free | $0 |

## Combo Chain

```
Primary:     mmf/mimo-auto → oc/deepseek-v4-flash-free → oc/mimo-v2.5-free
Emergency:   oc/nemotron-3-ultra-free → oc/big-pickle → oc/north-mini-code-free
```

## Kelebihan

- ✅ 100% gratis
- ✅ Unlimited usage
- ✅ Auto-fallback jika model gagal
- ✅ RTK Token Saver (hemat 20-40%)
- ✅ Caveman Mode (hemat 65% output). Lihat [caveman-mode.md](../../caveman-mode.md)

## Kekurangan

- ⚠️ Rate limit (kadang 429)
- ⚠️ Tidak semua model support vision
- ⚠️ Kualitas bervariasi per model

## Setup

### Via Script

```powershell
.\scripts\start.ps1 -Profile gratis
```

### Via OpenCode

```
/start-free
```

### Manual

```powershell
Copy-Item "profiles\gratis\opencode.jsonc" "$env:USERPROFILE\.config\opencode\opencode.jsonc"
```

## Config

Config tersedia di `profiles/gratis/opencode.jsonc`.

## Lihat Juga

- [Go Profile](02-go.md) — Model berbayar
- [Switching](03-switching.md) — Cara ganti profile
- [Combos](../02-architecture/04-combos.md) — Detail auto-fallback
