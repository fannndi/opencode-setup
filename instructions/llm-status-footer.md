# LLM Status Footer

**Footer = ENFORCEMENT HOOK, bukan dekorasi.**
**Footer menunjukkan compliance AI. Jika LLMEnrich [Off] = AI gagal comply.**

## Core Rules

1. Footer WAJIB di SETIAP respons
2. LLMEnrich WAJIB [On] di mode BALANCED/PERFORMANCE
3. Mode harus sesuai: [User] untuk coding, [Admin] untuk setup/maintenance

## Architecture

```
User Input
   │
   ▼
Invoke-LLMEnrich() ← WAJIB di SETIAP input
   │
   ├── SUCCESS → LLMEnrich [On], enriched context → Cloud AI
   ├── FAIL    → LLMEnrich [Off], raw input → Cloud AI
   └── ECO     → LLMEnrich [Off], raw input → Cloud AI
   │
   ▼
Cloud AI responds + footer
```

## Step 1: Gather Info

```powershell
$llmMode = "eco"
$enrichSuccess = $false
$userMode = "User"  # "User" or "Admin"
$profileName = "?"
if (Test-Path ".opencode/llm-mode.json") {
  $m = Get-Content ".opencode/llm-mode.json" -Raw | ConvertFrom-Json
  $llmMode = $m.mode
}

$gratisCfg = Get-Content "profiles/gratis/opencode.jsonc" -Raw 2>$null
$goCfg = Get-Content "profiles/go/opencode.jsonc" -Raw 2>$null
if ($gratisCfg -match '"9router/gratis"') { $profileName = "Gratis"; $cloudModel = "gratis" }
elseif ($goCfg -match '"9router/go"') { $profileName = "Go"; $cloudModel = "go" }
else { $cloudModel = "?" }
```

Mode mapping: `eco` → ECO, `balanced` → BALANCED, `performance` → PERFORMANCE.
User mode: `/admin`, `/setup`, `/llm`, `/audit` → Admin. Default → User.

## Step 2: Write Status File

```powershell
$status = @{
  mode = $llmMode.ToUpper()
  user_mode = $userMode
  enrich = if ($enrichSuccess) { "On" } else { "Off" }
  enrich_time = <ENRICH_TIME_SEC>
  profile = $profileName
  cloud = $cloudModel
  last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json -Depth 3
$status | Set-Content -Path ".opencode\llm-status.json" -Encoding UTF8
```

## Step 3: Append Footer

```
Mode : [ User ] | LLM : [ PERFORMANCE ] - LLMEnrich : [ On ] - EnrichTime : [ 4.2s ] - Profile : [ Gratis ] - Cloud : [ gratis ]
```

| Field | Arti | Enforcement |
|-------|------|-------------|
| `Mode: [User]` | Presisi, max 2 tanya, eksekusi cepat | |
| `Mode: [Admin]` | Goal-oriented, boleh clarify | |
| `LLMEnrich: [On]` | Enrichment berjalan | |
| `LLMEnrich: [Off]` | **AI GAGAL COMPLY** | User langsung lihat |
| `EnrichTime` | Waktu GPU enrichment (0ms=ECO, 4s=warm, 10s=cold) | |
| `Profile` | Gratis / Go | |
| `Cloud` | Cloud AI model name (from profile config) | |

## Enforcement

- LLMEnrich [Off] di BALANCED/PERFORMANCE = AI tidak comply → koreksi
- Mode: [Admin] dengan input User = mode salah → AI harus deteksi otomatis
- Footer tidak boleh skip atau di-simplify

## VRAM Lifecycle (5 min timeout)

```
Default:     VRAM 0 MB (model unloaded, 5 min timeout)
User input:  Warmup → cold load ~6-10s → VRAM ~1-2 GB → enrichment → response
During chat: Model stays loaded (< 5 min gap)
Idle 5 min:  Model auto-unloads → VRAM 0 MB
```

Model stays in VRAM selama user aktif chat. Setelah 5 menit idle, auto-unload.
