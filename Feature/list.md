# Unexplored Features — ECC + 9Router

**Last Updated:** 2026-06-14
**Total Features:** 20
**Status:** 3 Done, 17 Todo

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Done — sudah di-setup dan berfungsi |
| 🔲 | Todo — belum dieksplor |
| ⏳ | Partial — sebagian sudah |
| ❌ | Broken — tidak berfungsi |

## Priority Legend

| Level | Meaning |
|-------|---------|
| 🔥 | HIGH — quick win, langsung berguna |
| 💡 | MEDIUM — butuh setup lebih tapi worth it |
| 🚀 | POWER — advanced, butuh pemahaman lebih dalam |

---

## HIGH IMPACT (Quick Wins)

### 1. Combos (Auto-Fallback)

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | ✅ Done |
| **Priority** | 🔥 HIGH |
| **Dependencies** | 9Router running |

**Apa itu:**
Model chain — kalau model pertama fail (429 rate limit, 503 down), 9Router otomatis coba model berikutnya.

**Combos yang sudah dibuat:**
| Nama | Chain | Use Case |
|------|-------|----------|
| `gratis` | `oc/mimo-v2.5-free` → `oc/deepseek-v4-flash-free` → `kr/claude-sonnet-4.5` | Free utama |
| `go` | `ocg/kimi-k2.6` → `ocg/qwen3.6-plus` → `ocg/glm-5.1` | Go models (limited) |
| `gratis-small` | `oc/deepseek-v4-flash-free` → `kr/glm-5` → `oc/north-mini-code-free` | Light tasks |

**Cara Setup (Reproduce):**
```bash
# 1. Login ke 9Router API
$session = Invoke-RestMethod -Uri "http://localhost:20128/api/auth/login" `
  -Method POST -Body '{"password":"123456"}' `
  -ContentType "application/json" -SessionVariable session

# 2. Buat combo
Invoke-RestMethod -Uri "http://localhost:20128/api/combos" `
  -Method POST `
  -Body '{"name":"gratis","models":["oc/mimo-v2.5-free","oc/deepseek-v4-flash-free","kr/claude-sonnet-4.5"]}' `
  -ContentType "application/json" -WebSession $session

# 3. Gunakan di config
# "model": "9router/gratis"
```

**Changelog:**
- 2026-06-14: Initial setup — 3 combos created (gratis, go, gratis-small)

---

### 2. Context7 MCP

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🔥 HIGH |
| **Dependencies** | MCP server config |

**Apa itu:**
Live docs lookup — selalu ambil dokumentasi terbaru dari library/framework, bukan dari training data yang sudah stale.

**Manfaat:**
- Jawaban selalu up-to-date
- Tidak salah spread API yang sudah berubah
- Support React, Next.js, Prisma, dll

**Cara Setup (Reproduce):**
```bash
# 1. Buka mcp-configs/mcp-servers.json
# 2. Cari "context7"
# 3. Tambahkan ke OpenCode config:

# Di opencode.jsonc, tambah:
"mcp": {
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp@latest"]
  }
}

# 4. Atau set environment variable:
# CONTEXT7_API_KEY=your-key (if needed)
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 3. Sequential-Thinking MCP

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🔥 HIGH |
| **Dependencies** | MCP server config |

**Apa itu:**
Forced chain-of-thought reasoning — memaksa AI berpikir step-by-step sebelum jawab, mengurangi hallucination.

**Manfaat:**
- Lebih akurat untuk masalah kompleks
- Mengurangi AI hallucination
- Reasoning lebih terstruktur

**Cara Setup (Reproduce):**
```bash
# 1. Buka mcp-configs/mcp-servers.json
# 2. Cari "sequential-thinking"
# 3. Tambahkan ke OpenCode config:

"mcp": {
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 4. contexts/dev.md

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🔥 HIGH |
| **Dependencies** | ECC installed |

**Apa itu:**
Behavioral override — load context file di session start untuk ubah cara AI berpikir. dev.md = "write code first, explain after".

**Contexts tersedia:**
| Context | Behavior |
|---------|----------|
| `contexts/dev.md` | "Write code first, explain after", run tests, atomic commits |
| `contexts/research.md` | "Read widely, ask questions, document findings, don't code until clear" |
| `contexts/review.md` | Severity prioritized checklist, suggest fixes not just problems |

**Cara Setup (Reproduce):**
```bash
# 1. Copy context file ke project
Copy-Item "C:/Users/FANNNDI/Documents/opencode-setup/ecc/contexts/dev.md" ".claude/context.md"

# 2. Atau tambah ke instructions di config:
"instructions": [
  "C:/Users/FANNNDI/Documents/opencode-setup/ecc/contexts/dev.md"
]

# 3. Atau load manual saat session start:
# /context load dev
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 5. Token Optimizer MCP

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🔥 HIGH |
| **Dependencies** | MCP server config |

**Apa itu:**
Auto-compress context — mengurangi 95%+ token usage dengan deduplikasi dan kompresi.

**Manfaat:**
- Session panjang tidak kehabisan context
- Hemat cost (kalau pake paid models)
- Response lebih cepat

**Cara Setup (Reproduce):**
```bash
# 1. Buka mcp-configs/mcp-servers.json
# 2. Cari "token-optimizer"
# 3. Tambahkan ke OpenCode config:

"mcp": {
  "token-optimizer": {
    "command": "npx",
    "args": ["-y", "@anthropic/token-optimizer-mcp"]
  }
}
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 6. scripts/doctor.js

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🔥 HIGH |
| **Dependencies** | ECC installed, Node.js |

**Apa itu:**
Diagnostic tool — cek apakah ECC install kamu sehat, ada yang missing atau corrupted.

**Manfaat:**
- Deteksi masalah sebelum jadi besar
- Pastikan semua components terload
- Fix otomatis beberapa masalah

**Cara Setup (Reproduce):**
```bash
# Dari ECC root directory:
cd C:\Users\FANNNDI\Documents\opencode-setup\ecc

# Jalankan doctor
node scripts/doctor.js

# Output akan tunjukkan:
# - Missing files
# - Broken symlinks
# - Config drift
# - Version mismatches
```

**Changelog:**
- 2026-06-14: Not yet run

---

### 7. RTK Token Saver

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | ✅ Done |
| **Priority** | 🔥 HIGH |
| **Dependencies** | 9Router running |

**Apa itu:**
Auto-compress tool_result payloads (git diff, grep, ls output) untuk hemat 20-40% tokens.

**Manfaat:**
- Hemat tokens secara otomatis
- Tidak perlu konfigurasi
- Sudah ON by default

**Cara Setup (Reproduce):**
```bash
# Sudah aktif by default. Untuk toggle:
Invoke-RestMethod -Uri "http://localhost:20128/api/settings" `
  -Method PATCH `
  -Body '{"rtkEnabled":true}' `
  -ContentType "application/json" -WebSession $session

# Cek status:
Invoke-RestMethod -Uri "http://localhost:20128/api/settings" -WebSession $session | Select-Object rtkEnabled
```

**Changelog:**
- 2026-06-14: Verified ON by default

---

## MEDIUM IMPACT

### 8. Hooks (strict mode)

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | ECC installed |

**Apa itu:**
20+ hooks yang otomatis jalan saat PreToolUse, PostToolUse, SessionStart, Stop. Strict mode = semua guardrails aktif.

**Hooks tersedia:**
| Hook | Event | Fungsi |
|------|-------|--------|
| `config-protection` | PreToolUse | Blok agent dari melemahkan linter/formatter |
| `gateguard-fact-force` | PreToolUse | Minta agent investigasi dulu sebelum edit |
| `design-quality-check` | PostToolUse | Warn kalau UI jadi generic template |
| `accumulator` | PostToolUse | Batch edits untuk format+typecheck |
| `context-monitor` | PostToolUse | Warn kalau context habis |
| `format-typecheck` | Stop | Auto format + typecheck di akhir response |
| `check-console-log` | Stop | Audit console.log di modified files |
| `cost-tracker` | Stop | Track token/cost per session |

**Cara Setup (Reproduce):**
```bash
# Set hook profile ke strict:
[Environment]::SetEnvironmentVariable("ECC_HOOK_PROFILE", "strict", "User")

# Atau standard:
[Environment]::SetEnvironmentVariable("ECC_HOOK_PROFILE", "standard", "User")

# Disable specific hooks:
[Environment]::SetEnvironmentVariable("ECC_DISABLED_HOOKS", "gateguard-fact-force", "User")

# Reload config:
# Restart OpenCode
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 9. Governance Capture

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | ECC hooks |

**Apa itu:**
Log semua security events — secrets, policy violations, approval requests ke governance log.

**Manfaat:**
- Audit trail untuk security
- Compliance logging
- Deteksi anomali

**Cara Setup (Reproduce):**
```bash
# Enable governance capture:
[Environment]::SetEnvironmentVariable("ECC_GOVERNANCE_CAPTURE", "1", "User")

# Logs tersimpan di:
# ~/.claude/governance/

# Restart OpenCode
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 10. Custom Provider Nodes

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | 9Router running |

**Apa itu:**
Tambah any OpenAI-compatible atau Anthropic-compatible API sebagai provider — termasuk local Ollama, vLLM, dll.

**Manfaat:**
- Gunakan local models
- Privacy-first (data tidak keluar)
- Custom endpoints

**Cara Setup (Reproduce):**
```bash
# Tambah custom provider via API:
Invoke-RestMethod -Uri "http://localhost:20128/api/provider-nodes" `
  -Method POST `
  -Body '{
    "name": "local-ollama",
    "prefix": "ollama",
    "baseUrl": "http://localhost:11434/v1",
    "type": "openai-compatible",
    "apiType": "chat"
  }' `
  -ContentType "application/json" -WebSession $session

# Verify:
Invoke-RestMethod -Uri "http://localhost:20128/api/provider-nodes" -WebSession $session

# Gunakan di config:
# "model": "ollama/llama3"
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 11. Model Info Query

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | 9Router running |

**Apa itu:**
Query detail model — contextWindow, parameters, capabilities, supported features.

**Manfaat:**
- Tahu batasan model sebelum pilih
- Optimalkan usage
- Debug model compatibility

**Cara Setup (Reproduce):**
```bash
# Query model info:
Invoke-RestMethod -Uri "http://localhost:20128/v1/models/info?id=openai/gpt-4o"

# List semua models dengan capability:
Invoke-RestMethod -Uri "http://localhost:20128/v1/models" | Select-Object -ExpandProperty data | ForEach-Object {
  [PSCustomObject]@{ id=$_.id; owned_by=$_.owned_by; kind=$_.kind }
} | Format-Table
```

**Changelog:**
- 2026-06-14: Not yet explored

---

### 12. Tunnel

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | 9Router running, Cloudflare/Tailscale account |

**Apa itu:**
Expose 9Router ke internet — akses dari mana saja via public URL.

**Manfaat:**
- Akses dari mobile/lain device
- Share ke team
- Remote development

**Cara Setup (Reproduce):**
```bash
# Enable tunnel via API:
Invoke-RestMethod -Uri "http://localhost:20128/api/tunnel/enable" `
  -Method POST -WebSession $session

# Cek status:
Invoke-RestMethod -Uri "http://localhost:20128/api/tunnel/status" -WebSession $session

# Disable:
Invoke-RestMethod -Uri "http://localhost:20128/api/tunnel/disable" `
  -Method POST -WebSession $session
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 13. MITM Aliases

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | 9Router running, admin access |

**Apa itu:**
Redirect requests dari Cursor/Copilot/Kiro ke model pilihan kamu — tanpa mereka tahu.

**Manfaat:**
- Gunakan free models di paid tools
- Centralize all AI traffic
- Cost control

**Cara Setup (Reproduce):**
```bash
# Edit aliases file:
# ~/.9router/mitm/aliases.json

# Contoh:
# {
#   "cursor": {
#     "gpt-4": "oc/mimo-v2.5-free",
#     "claude-3.5-sonnet": "kr/claude-sonnet-4.5"
#   }
# }

# Enable MITM (butuh admin/root):
# Jalankan 9Router dengan --mitm flag
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 14. Rules (18 bahasa)

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | ECC installed |

**Apa itu:**
Language-specific rules — coding conventions, best practices, security patterns untuk 18+ bahasa/ framework.

**Bahasa tersedia:**
| Language | Rules |
|----------|-------|
| TypeScript | coding-style, hooks, security, testing, patterns |
| Python | coding-style, hooks, security, testing, patterns |
| Go | coding-style, hooks, security, testing, patterns |
| Rust | coding-style, hooks, security, testing, patterns |
| Dart/Flutter | coding-style, hooks, security, testing, patterns |
| Java/Spring | coding-style, hooks, security, testing, patterns |
| Kotlin | coding-style, hooks, security, testing, patterns |
| C#/.NET | coding-style, hooks, security, testing, patterns |
| PHP/Laravel | coding-style, hooks, security, testing, patterns |
| Ruby | coding-style, hooks, security, testing, patterns |
| Swift | coding-style, hooks, security, testing, patterns |
| C/C++ | coding-style, hooks, security, testing, patterns |
| Perl | coding-style, hooks, security, testing, patterns |
| Angular | coding-style, hooks, security, testing, patterns |
| React | coding-style, hooks, security, testing, patterns |

**Cara Setup (Reproduce):**
```bash
# Tambah language rules ke instructions:
"instructions": [
  "C:/Users/FANNNDI/Documents/opencode-setup/ecc/rules/dart/coding-style.md",
  "C:/Users/FANNNDI/Documents/opencode-setup/ecc/rules/dart/testing.md"
]

# Atau load semua rules sekaligus:
# (belum tersedia otomatis)
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 15. Control Pane

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 💡 MEDIUM |
| **Dependencies** | ECC scripts, Node.js |

**Apa itu:**
Web dashboard untuk monitor ECC sessions, state, work items — real-time visibility.

**Manfaat:**
- Monitor semua sessions
- Track progress
- Debug issues

**Cara Setup (Reproduce):**
```bash
# Dari ECC root:
cd C:\Users\FANNNDI\Documents\opencode-setup\ecc

# Jalankan control pane:
node scripts/control-pane.js

# Buka browser:
# http://localhost:3000
```

**Changelog:**
- 2026-06-14: Not yet configured

---

## POWER FEATURES

### 16. DevFleet MCP

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🚀 POWER |
| **Dependencies** | MCP server config, tmux |

**Apa itu:**
Multi-agent orchestration — jalankan beberapa Claude Code agents secara paralel di isolated worktrees.

**Manfaat:**
- Parallel development
- Feature isolation
- Faster completion

**Cara Setup (Reproduce):**
```bash
# 1. Pastikan tmux installed:
# Windows: scoop install tmux
# macOS: brew install tmux

# 2. Tambah MCP config:
"mcp": {
  "devfleet": {
    "command": "npx",
    "args": ["-y", "@anthropic/devfleet-mcp"]
  }
}

# 3. Gunakan:
# /fleet start "feature-name"
# /fleet status
# /fleet stop
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 17. EvalView MCP

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🚀 POWER |
| **Dependencies** | MCP server config |

**Apa itu:**
AI regression testing — snapshot tool calls, detect regressions, generate visual reports.

**Manfaat:**
- Deteksi AI behavior changes
- Quality assurance
- Rollback capability

**Cara Setup (Reproduce):**
```bash
# Tambah MCP config:
"mcp": {
  "evalview": {
    "command": "npx",
    "args": ["-y", "@anthropic/evalview-mcp"]
  }
}

# Jalankan eval:
# /eval start "test-scenario"
# /eval report
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 18. ECC2 Rust Dashboard

| Field | Value |
|-------|-------|
| **Sumber** | ECC |
| **Status** | 🔲 Todo |
| **Priority** | 🚀 POWER |
| **Dependencies** | Rust, Cargo |

**Apa itu:**
Terminal UI dashboard — session management, SQLite-backed, observability + risk scoring.

**Manfaat:**
- Real-time monitoring
- Session lifecycle management
- Risk assessment

**Cara Setup (Reproduce):**
```bash
# Build ECC2:
cd C:\Users\FANNNDI\Documents\opencode-setup\ecc\ecc2

# Install Rust (if not installed):
# https://rustup.rs

# Build:
cargo build --release

# Jalankan:
cargo run

# Atau binary:
./target/release/ecc2
```

**Changelog:**
- 2026-06-14: Not yet built

---

### 19. Multi-Account Round-Robin

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 🚀 POWER |
| **Dependencies** | 9Router, multiple accounts |

**Apa itu:**
Load balancing antar akun — kalau punya beberapa akun OAuth, 9Router automatically distribute requests.

**Manfaat:**
- Higher rate limits
- Better availability
- Cost distribution

**Cara Setup (Reproduce):**
```bash
# 1. Tambah multiple connections per provider:
Invoke-RestMethod -Uri "http://localhost:20128/api/providers" `
  -Method POST `
  -Body '{
    "alias": "gh",
    "provider": "github-copilot",
    "accounts": [
      {"token": "token-1", "priority": 1},
      {"token": "token-2", "priority": 2}
    ]
  }' `
  -ContentType "application/json" -WebSession $session

# 2. Set strategy:
Invoke-RestMethod -Uri "http://localhost:20128/api/settings" `
  -Method PATCH `
  -Body '{"providerStrategies":{"gh":"round-robin"}}' `
  -ContentType "application/json" -WebSession $session
```

**Changelog:**
- 2026-06-14: Not yet configured

---

### 20. Auto-Start on Boot

| Field | Value |
|-------|-------|
| **Sumber** | 9Router |
| **Status** | 🔲 Todo |
| **Priority** | 🚀 POWER |
| **Dependencies** | 9Router |

**Apa itu:**
9Router start otomatis saat OS boot — tidak perlu manual start setiap kali.

**Manfaat:**
- Always available
- No manual intervention
- Seamless workflow

**Cara Setup (Reproduce):**
```bash
# Windows (via Task Scheduler):
# 1. Open Task Scheduler
# 2. Create Basic Task
# 3. Name: "9Router"
# 4. Trigger: "When the computer starts"
# 5. Action: "Start a program"
# 6. Program: "C:\Users\FANNNDI\AppData\Roaming\npm\9router.cmd"
# 7. Arguments: "--tray"

# Atau via PowerShell:
$action = New-ScheduledTaskAction -Execute "9router.cmd" -Argument "--tray"
$trigger = New-ScheduledTaskTrigger -AtStartup
Register-ScheduledTask -TaskName "9Router" -Action $action -Trigger $trigger -Description "9Router AI Gateway"

# macOS/Linux:
# Tambah ke crontab:
# @reboot 9router --tray
```

**Changelog:**
- 2026-06-14: Not yet configured

---

## Summary

| Status | Count |
|--------|-------|
| ✅ Done | 3 |
| 🔲 Todo | 17 |
| ⏳ Partial | 0 |
| **Total** | **20** |

## Next Actions

1. **Quick wins first:** Context7 MCP, Sequential-Thinking MCP, contexts/dev.md
2. **Then medium:** Hooks strict mode, Governance Capture
3. **Then power:** DevFleet, ECC2 Dashboard

## How to Contribute

Fork this repo, pick a feature, set it up, then update this file:
1. Change status from 🔲 to ✅
2. Add changelog entry with date
3. Add reproduction steps if different from above
4. Submit PR
