# LLM Status Footer

**Footer = ENFORCEMENT HOOK, bukan dekorasi.**
**Footer menunjukkan compliance AI. Jika LLMEnrich [Off] = AI gagal comply.**

## Core Rules

1. **SESSION INIT** (first input, SILENT — no footer) → baca config, setup mode/role
2. **REGULAR** (every response, INCLUDING first) → enrich → respond → update context → footer
3. LLMEnrich WAJIB [On] di mode BALANCED/PERFORMANCE
4. Mode harus sesuai: [User] untuk coding, [Admin] untuk setup/maintenance

## SESSION INIT (First Input Only — Silent, No Footer)

**Ini fase WAJIB. Jangan skip.**

Jalankan di INPUT PERTAMA saja, SEBELUM menjawab:

```
1. Read .opencode/context.md         → state terkini
2. Read .opencode/llm-mode.json      → mode (ECO/BALANCED/PERFORMANCE)
3. Detect User/Admin mode:
   - /admin, /setup, /llm, /audit → Admin
   - else → User
4. Update .opencode/context.md       → "Session initialized"
5. Write .opencode/llm-status.json   → setup state
6. JAWAB user (TANPA footer)
```

Setelah Step 6, session init selesai. Input berikutnya masuk ke pipeline REGULAR.

## REGULAR Pipeline (Every Response — Includes First Response AFTER Init)

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
Execute → Respond + Footer
```

### Step 1: Gather Info

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

### Step 2: Write Status File

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

### Step 3: Append Footer (ALWAYS after response, never on Session Init)

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

- Jika sesi baru → Session Init dulu (tanpa footer), baru pipeline REGULAR
- LLMEnrich [Off] di BALANCED/PERFORMANCE = AI tidak comply → koreksi
- Mode: [Admin] dengan input User = mode salah → AI harus deteksi otomatis
- Footer tidak boleh skip atau di-simplify di mode REGULAR

## VRAM Lifecycle (5 min timeout)

```
Default:     VRAM 0 MB (model unloaded, 5 min timeout)
User input:  Warmup → cold load ~6-10s → VRAM ~1-2 GB → enrichment → response
During chat: Model stays loaded (< 5 min gap)
Idle 5 min:  Model auto-unloads → VRAM 0 MB
```

Model stays in VRAM selama user aktif chat. Setelah 5 menit idle, auto-unload.
