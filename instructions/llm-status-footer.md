# LLM Status Footer

**Footer = ENFORCEMENT HOOK, bukan dekorasi.**
**Footer menunjukkan compliance AI. Jika LLMEnrich [Off] = AI gagal comply.**

## Core Rules

1. **RESPON PERTAMA** dalam sesi: Session Init (setup mode/role), **JANGAN** append footer
2. **RESPON KEDUA+**: WAJIB melalui enrich → respond → update context → footer
3. LLMEnrich WAJIB [On] di mode BALANCED/PERFORMANCE
4. Mode: [User] untuk coding, [Admin] untuk setup/maintenance

## SESSION INIT (Respons Pertama — Silent, Tanpa Footer)

Ini WAJIB untuk RESPON PERTAMA Anda dalam sesi ini. Jangan skip.

```
1. Baca .opencode/llm-mode.json      → mode (ECO/BALANCED/PERFORMANCE)
2. Baca .opencode/context.md         → state terkini
3. Deteksi User/Admin:
   - /admin, /setup, /llm, /audit → Admin
   - else → User
4. Update .opencode/context.md       → "Session initialized"
5. Update .opencode/llm-status.json  → setup state
6. ⚠️ JAWAB user — JANGAN append footer ⚠️
```

## REGULAR (Respons Kedua dan Seterusnya — WAJIB Footer)

```
User Input → Invoke-LLMEnrich() → Execute → Respond + Footer
```

### Gather Info

```powershell
$llmMode = "eco"; $enrichSuccess = $false; $userMode = "User"
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

### Write Status & Append Footer

```
Mode : [ User/Admin ] | LLM : [ MODE ] - LLMEnrich : [ On/Off ] - EnrichTime : [ Xs ] - Profile : [ Y ] - Cloud : [ Z ]
```

## Enforcement

- ❌ Footer di respons pertama = GAGAL COMPLY
- ❌ Tidak ada footer di respons kedua+ = GAGAL COMPLY
- LLMEnrich [Off] di BALANCED/PERFORMANCE = GAGAL
- Footer tidak boleh di-skip atau di-simplify