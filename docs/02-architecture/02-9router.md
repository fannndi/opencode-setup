# 9Router — AI Gateway

## Apa Itu 9Router?

9Router adalah AI gateway lokal yang berjalan di `localhost:20128`. Berfungsi sebagai proxy antara OpenCode dan berbagai provider model.

## Endpoint

| URL | Fungsi |
|-----|--------|
| `http://localhost:20128/dashboard` | Web dashboard |
| `http://localhost:20128/api/health` | Health check |
| `http://localhost:20128/v1/chat/completions` | Chat completions |
| `http://localhost:20128/v1/models` | List models |

## Fitur Utama

### RTK Token Saver

Kompres tool output (git diff, grep, ls) secara otomatis.

**Hemat:** 20-40% input tokens
**Status:** ON by default

### Caveman Mode

Response lebih singkat dan padat. Tidak ada filler, langsung ke inti.

**Hemat:** 65% output tokens
**Status:** Bisa diaktifkan via config

### Combos (Auto-Fallback)

Ketika model utama gagal, otomatis pindah ke model berikutnya.

Lihat [Combos](04-combos.md) untuk detail.

## Provider yang Tersedia

### Gratis

| Provider | Model | Auth |
|----------|-------|------|
| OpenCode Free | mimo-v2.5-free, deepseek-v4-flash-free | Tidak perlu |
| Kiro AI | claude-sonnet-4.5, glm-5 | OAuth |

### Berbayar

| Provider | Model | Auth |
|----------|-------|------|
| OpenCode Go | kimi-k2.6, qwen3.6-plus, glm-5.1 | API key |
| OpenRouter | GPT-4o, Claude, Gemini | API key |

## Management

### Start/Stop

```powershell
# Start (background)
Start-Process "9router" -WindowStyle Minimized

# Stop
Get-Process -Name "node" | Where-Object { $_.CommandLine -match "9router" } | Stop-Process
```

### Health Check

```powershell
Invoke-RestMethod "http://localhost:20128/api/health"
# Output: {"ok":true}
```

### Login Dashboard

```powershell
$session = Invoke-RestMethod -Uri "http://localhost:20128/api/auth/login" `
  -Method POST -Body '{"password":"123456"}' `
  -ContentType "application/json" -SessionVariable session
```

## Lihat Juga

- [Overview](01-overview.md) — Bagaimana 9Router terhubung
- [Combos](04-combos.md) — Auto-fallback chain
- [Gratis Profile](../03-profiles/01-gratis.md) — Model gratis
