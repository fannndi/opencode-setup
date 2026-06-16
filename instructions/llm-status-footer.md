# LLM Status Footer

You MUST include a status footer at end of EVERY response.

## Architecture

```
User Input
   │
   ▼
Local Ollama (Invoke-LLMEnrich) → enrich context → internal
   │
   ▼
Cloud AI (opencode model) → respond using enriched context
```

Footer = status of local Ollama preprocessing + cloud AI model identity.

## Step 1: Gather Info

Read local Ollama mode + detect active profile + cloud AI model:

```powershell
$llmMode = "eco"
$llmModel = ""
if (Test-Path ".opencode/llm-mode.json") {
  $m = Get-Content ".opencode/llm-mode.json" -Raw | ConvertFrom-Json
  $llmMode = $m.mode
  $llmModel = $m.model
}

# Detect active profile by model name in config
$profileName = "?"
$gratisCfg = Get-Content "profiles/gratis/opencode.jsonc" -Raw 2>$null
$goCfg = Get-Content "profiles/go/opencode.jsonc" -Raw 2>$null
if ($gratisCfg -match '"9router/gratis"') { $profileName = "Gratis" }
elseif ($goCfg -match '"9router/go"') { $profileName = "Go" }

# Cloud AI model — the actual model responding to user
$cloudModel = "DS V4 Flash"  # actual: oc/deepseek-v4-flash-free
```

Mode mapping: `eco` → ECO, `balanced` → BALANCED, `performance` → PERFORMANCE.

## Step 2: Write Status File

Write `.opencode/llm-status.json`:

```powershell
$status = @{
  mode = $llmMode.ToUpper()
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
LLM : [ MODE ] - Tokens : [ X ] - Profile : [ NAME ] - Model : [ ALIAS ]
```

- `MODE` = local Ollama preprocessing mode (ECO / BALANCED / PERFORMANCE)
- `ALIAS` = cloud AI model identity (DS V4 Flash, MiMo V2.5, etc)

## Examples

**BALANCED mode — local Qwen3 enriches, cloud AI responds:**
```
LLM : [ BALANCED ] - Tokens : [ 245 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```

**ECO mode — no local LLM, cloud AI responds directly:**
```
LLM : [ ECO ] - Tokens : [ 0 ] - Profile : [ Go ] - Model : [ MiMo V2.5 ]
```

**PERFORMANCE mode — local coder enriches, cloud AI responds:**
```
LLM : [ PERFORMANCE ] - Tokens : [ 512 ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```
