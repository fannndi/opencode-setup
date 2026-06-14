# Profile Gratis — 100% Free Models

## Model yang Digunakan

| Model | Provider | Biaya |
|-------|----------|-------|
| `oc/mimo-v2.5-free` | OpenCode Free | $0 |
| `oc/deepseek-v4-flash-free` | OpenCode Free | $0 |
| `kr/claude-sonnet-4.5` | Kiro AI | $0 (OAuth) |
| `kr/glm-5` | Kiro AI | $0 (OAuth) |

## Combo Chain

```
Primary:     oc/mimo-v2.5-free → oc/deepseek-v4-flash-free → kr/claude-sonnet-4.5
Small:       oc/deepseek-v4-flash-free → kr/glm-5 → oc/north-mini-code-free
```

## Kelebihan

- ✅ 100% gratis
- ✅ Unlimited usage
- ✅ Auto-fallback jika model gagal
- ✅ RTK Token Saver (hemat 20-40%)
- ✅ Caveman Mode (hemat 65% output)

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
