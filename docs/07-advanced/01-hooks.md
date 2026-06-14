# Hooks — Sistem Otomasi

## Apa Itu Hook?

Hook adalah kode yang otomatis jalan saat event tertentu terjadi. Contoh:
- Sebelum bash command → cek keamanan
- Sesudah edit file → format otomatis
- Saat session mulai → load context

## Jenis Hook

### PreToolUse (Sebelum Tool)

| Hook | Fungsi |
|------|--------|
| `pre:bash:dispatcher` | Cek bash command sebelum jalan |
| `pre:config-protection` | Blok modifikasi config |
| `pre:governance-capture` | Capture governance events |
| `pre:mcp-health-check` | Cek MCP server health |

### PostToolUse (Sesudah Tool)

| Hook | Fungsi |
|------|--------|
| `post:quality-gate` | Quality check sesudah edit |
| `post:edit:accumulator` | Batch edits untuk format |
| `post:edit:console-warn` | Warn jika ada console.log |
| `post:ecc-context-monitor` | Monitor context usage |

### Stop (Sesudah Response)

| Hook | Fungsi |
|------|--------|
| `stop:format-typecheck` | Format + typecheck semua file |
| `stop:check-console-log` | Cek console.log |
| `stop:cost-tracker` | Track token usage |
| `stop:desktop-notify` | Desktop notification |

### Lifecycle

| Hook | Fungsi |
|------|--------|
| `session:start` | Load context saat mulai |
| `pre:compact` | Save state sebelum compact |
| `session:end:marker` | Tanda session selesai |

## Konfigurasi

Hook diaktifkan via environment variable:

```powershell
# Standard (default)
[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'standard', 'User')

# Strict (semua guardrails aktif)
[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'strict', 'User')

# Minimal (hanya essential)
[Environment]::SetEnvironmentVariable('ECC_HOOK_PROFILE', 'minimal', 'User')
```

## Disable Hook

```powershell
# Disable specific hook
[Environment]::SetEnvironmentVariable('ECC_DISABLED_HOOKS', 'gateguard-fact-force', 'User')
```

## Lihat Juga

- [Architecture](../02-architecture/01-overview.md) — Overview
- [MCP](02-mcp.md) — MCP servers
