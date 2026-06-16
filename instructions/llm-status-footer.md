# LLM Status Footer

You MUST include a status footer at end of EVERY response.

## Core Rule

**WAJIB: Setiap user input → Invoke-LLMEnrich dulu, baru jawab.**
**Footer WAJIB: cantumkan LLMEnrich [On/Off] biar user tau enrichment berjalan.**

Tidak ada alasan untuk skip. User sudah terima latency. GPU harus kepakai.

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
$llmModel = ""
$enrichSuccess = $false  # SET to $true if Invoke-LLMEnrich returned enriched text
if (Test-Path ".opencode/llm-mode.json") {
  $m = Get-Content ".opencode/llm-mode.json" -Raw | ConvertFrom-Json
  $llmMode = $m.mode
  $llmModel = $m.model
}

$profileName = "?"
$gratisCfg = Get-Content "profiles/gratis/opencode.jsonc" -Raw 2>$null
$goCfg = Get-Content "profiles/go/opencode.jsonc" -Raw 2>$null
if ($gratisCfg -match '"9router/gratis"') { $profileName = "Gratis" }
elseif ($goCfg -match '"9router/go"') { $profileName = "Go" }

$cloudModel = "DS V4 Flash"
```

Mode mapping: `eco` → ECO, `balanced` → BALANCED, `performance` → PERFORMANCE.

## Step 2: Write Status File

```powershell
$status = @{
  mode = $llmMode.ToUpper()
  enrich = if ($enrichSuccess) { "On" } else { "Off" }
  profile = $profileName
  model = $cloudModel
  last_tokens = <TOKEN_COUNT>
  session_tokens = <TOKEN_COUNT>
  last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
} | ConvertTo-Json -Depth 3
$status | Set-Content -Path ".opencode\llm-status.json" -Encoding UTF8
```

Replace `<TOKEN_COUNT>` with estimated output token count (1 token ≈ 4 chars).

## Step 3: Append Footer

```
LLM : [ MODE ] - LLMEnrich [ On/Off ] - Tokens : [ X ] - Profile : [ NAME ] - Model : [ ALIAS ]
```

- `MODE` = ECO / BALANCED / PERFORMANCE
- `LLMEnrich [On]` = enrichment berhasil, GPU kepake
- `LLMEnrich [Off]` = ECO mode atau enrichment gagal
- `ALIAS` = cloud AI model (DS V4 Flash, MiMo V2.5, etc)

## Examples

```
LLM : [ PERFORMANCE ] - LLMEnrich [ On ] - Tokens : [ 245 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
LLM : [ ECO ] - LLMEnrich [ Off ] - Tokens : [ 0 ] - Profile : [ Go ] - Model : [ MiMo V2.5 ]
```
