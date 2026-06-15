# Intent Compiler — Natural language → structured JSON specification
# Usage: .\intent-compiler.ps1 -Query "buat CRUD penduduk desa"
#        .\intent-compiler.ps1 -Query "fix bug login" -Mode off

param(
    [Parameter(Mandatory=$true)]
    [string]$Query,

    [ValidateSet("auto", "on", "off")]
    [string]$Mode = "auto"
)

$ErrorActionPreference = "Stop"
$SETUP_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SETUP_DIR

. "$SETUP_DIR\llm-adapter.ps1"

# ============================================================
# LLM-based compilation
# ============================================================

$SYSTEM_PROMPT = @"
You are an intent compiler. Convert user requests into a structured JSON specification.

Rules:
- Output ONLY valid JSON. No explanation, no markdown, no code block.
- If you cannot parse the request, output: {"error": "description of what's missing"}
- Estimate confidence (1.0 = certain, 0.5 = guessing, 0.0 = cannot parse)
- Estimate effort in hours (story-points relative scale)
- Set language: "id" if mostly Indonesian, "en" if English, "mixed" if both

Schema:
{
  "domain": "project domain (web_desa, ecommerce, api, auth, etc)",
  "module": "specific module name",
  "features": ["array of features: crud, auth, audit_log, report, search, export, import, notification, dashboard, etc"],
  "validation": ["array of validation needs: email, phone, nik, unique, required, etc"],
  "roles": ["array of roles: admin, user, guest, superadmin, etc"],
  "security": ["array of security: prepared_statement, xss_protection, csrf, rate_limit, auth, encryption, etc"],
  "stack_hint": ["detected technology hints from request"],
  "crud_entities": ["entities mentioned that need CRUD"],
  "dependencies": ["modules this depends on"],
  "estimated_hours": 0,
  "confidence": 1.0,
  "language": "id"
}
"@

function CompileWithLLM {
    param([string]$Query)

    $prompt = "Convert this request to the specified JSON format.`nRequest: $Query`n`nOutput ONLY the JSON specification. No explanation."

    $MAX_RETRIES = 2
    $attempt = 0
    $spec = $null

    while (-not $spec -and $attempt -lt $MAX_RETRIES) {
        $attempt++
        if ($attempt -gt 1) {
            Write-Host "  [INTENT] Retry $attempt..." -ForegroundColor Yellow
        }

        $result = Invoke-LLM -Prompt $prompt -System $SYSTEM_PROMPT -MaxTokens 2048 -Temperature 0.1 -TimeoutSec 60
        if (-not $result) { return $null }

        $text = $result.response.Trim()

        # Clean markdown code blocks if present
        if ($text -match '```(?:json)?\s*([\s\S]*?)```') {
            $text = $Matches[1].Trim()
        }

        # Validate JSON
        try {
            $spec = $text | ConvertFrom-Json
            if ($spec.error) {
                Write-Warning "LLM returned error: $($spec.error)"
                return $null
            }
        } catch {
            # Log failure and retry
            Write-LLMFailure -Script "intent-compiler" -Model (Get-LLMModel) -Prompt $prompt -RawOutput $text -Error $_.Exception.Message
            if ($attempt -lt $MAX_RETRIES) {
                $prompt = "Your previous output was invalid JSON: $($_.Exception.Message)`n`nRetry with ONLY valid JSON. No explanation.`n`nRequest: $Query"
                continue
            }
            return $null
        }
    }

    # Add metadata
    $spec | Add-Member -NotePropertyName "_compiler" -NotePropertyValue "llm" -Force
    if (-not $spec.PSObject.Properties.Name.Contains("confidence")) {
        $spec | Add-Member -NotePropertyName "confidence" -NotePropertyValue 0.8 -Force
    }
    if (-not $spec.PSObject.Properties.Name.Contains("estimated_hours")) {
        $spec | Add-Member -NotePropertyName "estimated_hours" -NotePropertyValue 0 -Force
    }
    if (-not $spec.PSObject.Properties.Name.Contains("language")) {
        $spec | Add-Member -NotePropertyName "language" -NotePropertyValue "id" -Force
    }
    if (-not $spec.PSObject.Properties.Name.Contains("dependencies")) {
        $spec | Add-Member -NotePropertyName "dependencies" -NotePropertyValue @() -Force
    }
    return $spec
}

# ============================================================
# Regex-based fallback (existing Detect-Intent)
# ============================================================

function CompileWithRegex {
    param([string]$Query)
    $lower = $Query.ToLower()

    # Detect domain
    $domain = "unknown"
    if ($lower -match "desa|penduduk|kelurahan|kecamatan") { $domain = "web_desa" }
    elseif ($lower -match "ecommerce|toko|jual|beli|shop") { $domain = "ecommerce" }
    elseif ($lower -match "api|backend|service") { $domain = "api_service" }
    elseif ($lower -match "blog|cms|artikel|post") { $domain = "cms" }
    elseif ($lower -match "auth|login|register") { $domain = "auth" }

    # Detect module from noun after keyword
    $module = ""
    if ($lower -match "(?:modul|module|fitur|feature)\s+(\w+)") { $module = $Matches[1] }
    elseif ($lower -match "(?:crud|buat|bikin|create|add)\s+(?:crud\s+)?(\w+)") {
        $module = $Matches[1]
        # Skip domain words masquerading as module
        $domainWords = @("desa", "web", "app", "aplikasi", "api", "system", "sistem", "website", "proyek", "project")
        if ($module -in $domainWords) {
            # Try to find the real entity name — first noun-sounding word in query
            $words = $lower -split "\s+"
            $skipAll = @("buat", "bikin", "create", "add", "crud", "dan", "yang", "dengan", "untuk", "di", "ke", "dari", "pada", "serta", "atau") + $domainWords
            $module = ($words | Where-Object { $_ -notin $skipAll -and $_.Length -gt 2 } | Select-Object -First 1)
            if (-not $module) { $module = $words | Where-Object { $_ -notin $skipAll } | Select-Object -First 1 }
        }
    }
    if (-not $module) { $module = "general" }

    # Detect features
    $features = @()
    if ($lower -match "crud") { $features += "crud" }
    if ($lower -match "auth|login|register") { $features += "auth" }
    if ($lower -match "\baudit\b|\blog\b(?!in)") { $features += "audit_log" }
    if ($lower -match "report|laporan") { $features += "report" }
    if ($lower -match "search|cari") { $features += "search" }
    if ($lower -match "export") { $features += "export" }
    if ($lower -match "import") { $features += "import" }
    if ($lower -match "notif|email") { $features += "notification" }
    if ($lower -match "dashboard|grafik|chart") { $features += "dashboard" }
    $features = $features | Select-Object -Unique
    if (-not $features) { $features += "crud" }

    # Detect validation
    $validation = @()
    if ($lower -match "nik|ktp") { $validation += "nik" }
    if ($lower -match "email") { $validation += "email" }
    if ($lower -match "phone|telp|hp") { $validation += "phone" }
    if ($lower -match "unique") { $validation += "unique" }

    # Detect roles
    $roles = @()
    if ($lower -match "admin") { $roles += "admin" }
    if ($lower -match "user|pengguna") { $roles += "user" }
    if ($lower -match "guest|tamu") { $roles += "guest" }
    if (-not $roles) { $roles += "user" }

    # Detect security
    $security = @()
    if ($lower -match "sql injection|sqli|prepared|parameterized") { $security += "prepared_statement" }
    if ($lower -match "xss") { $security += "xss_protection" }
    if ($lower -match "csrf") { $security += "csrf" }
    $security += "auth"

    # Detect stack
    $stack = @()
    if ($lower -match "php|lara|ci|codeigniter") { $stack += "php" }
    if ($lower -match "node|express|nestjs") { $stack += "nodejs" }
    if ($lower -match "python|django|flask") { $stack += "python" }
    if ($lower -match "go|golang") { $stack += "golang" }
    if ($lower -match "flutter|dart") { $stack += "flutter" }
    if ($lower -match "react|next") { $stack += "react" }
    if ($lower -match "mysql|mariadb") { $stack += "mysql" }
    if ($lower -match "postgres") { $stack += "postgresql" }
    if (-not $stack) { $stack += "general" }

    return [PSCustomObject]@{
        domain = $domain
        module = $module
        features = $features
        validation = $validation
        roles = $roles
        security = $security
        stack_hint = $stack
        crud_entities = if ($module -ne "general") { @($module) } else { @() }
        dependencies = @()
        estimated_hours = 0
        confidence = 0.3
        language = "id"
        _compiler = "regex"
    }
}

# ============================================================
# Main
# ============================================================
# Determine mode
# ============================================================
$operatingMode = if ($Mode -eq "auto") { Get-ModeForLLM } else { $Mode }
$effectiveMode = if ($operatingMode -eq "eco") { "off" } else { "on" }

Write-Host ""
Write-Host "  [INTENT] Compiling: $Query" -ForegroundColor Cyan
Write-Host "  [INTENT] System mode: $operatingMode" -ForegroundColor Gray

$spec = $null

if ($effectiveMode -eq "on") {
    Write-Host "  [INTENT] Using LLM..." -ForegroundColor Gray
    $spec = CompileWithLLM -Query $Query
}

if (-not $spec) {
    Write-Host "  [INTENT] Using regex fallback..." -ForegroundColor Gray
    $spec = CompileWithRegex -Query $Query
}

# Output
Write-Host ""
Write-Host "  [INTENT] Result:" -ForegroundColor Cyan
$spec | ConvertTo-Json -Depth 5
Write-Host ""

return $spec
