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

Schema:
{
  "domain": "project domain (web_desa, ecommerce, api, etc)",
  "module": "specific module name",
  "features": ["array of features: crud, auth, audit_log, report, search, export, import, notification, etc"],
  "validation": ["array of validation needs: email, phone, nik, unique, required, etc"],
  "roles": ["array of roles: admin, user, guest, superadmin, etc"],
  "security": ["array of security: prepared_statement, xss_protection, csrf, rate_limit, auth, encryption, etc"],
  "stack_hint": ["detected technology hints from request"],
  "crud_entities": ["entities mentioned that need CRUD"]
}
"@

function CompileWithLLM {
    param([string]$Query)

    $prompt = "Request: $Query`n`nOutput the JSON specification only."
    $result = Invoke-LLM -Prompt $prompt -System $SYSTEM_PROMPT -MaxTokens 512 -Temperature 0.1

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
        return $spec
    } catch {
        Write-Warning "LLM returned invalid JSON. Falling back to regex."
        return $null
    }
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
        _compiler = "regex"
    }
}

# ============================================================
# Main
# ============================================================

# Determine mode
$effectiveMode = $Mode
if ($effectiveMode -eq "auto") {
    $modeState = Get-LLMMode
    $effectiveMode = if ($modeState -eq "on") { "on" } else { "off" }
}

Write-Host ""
Write-Host "  [INTENT] Compiling: $Query" -ForegroundColor Cyan
Write-Host "  [INTENT] Mode: $effectiveMode" -ForegroundColor Gray

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
