# MCP — Model Context Protocol

## Apa Itu MCP?

MCP adalah protocol untuk menghubungkan AI dengan tools eksternal. 9Router mendukung MCP untuk integrasi dengan berbagai layanan.

## MCP Server yang Tersedia

### Paling Berguna

| Server | Fungsi | Auth |
|--------|--------|------|
| `context7` | Live docs lookup | Tidak |
| `sequential-thinking` | Chain-of-thought | Tidak |
| `memory` | Persistent memory | Tidak |
| `playwright` | Browser automation | Tidak |
| `github` | GitHub PRs/issues | Token |
| `jira` | Jira tracking | Token |

### Full List

| Server | Fungsi |
|--------|--------|
| `nexus` | Cost/privacy proxy |
| `firecrawl` | Web scraping |
| `supabase` | Database ops |
| `omega-memory` | Semantic memory |
| `longhand` | Session history |
| `vercel` | Vercel deploy |
| `railway` | Railway deploy |
| `clickhouse` | Analytics |
| `exa-web-search` | Web search |
| `parallel-search` | LLM search |
| `codescene` | Code health |
| `magic` | UI components |
| `filesystem` | File ops |
| `fal-ai` | Media generation |
| `browserbase` | Cloud browser |
| `devfleet` | Multi-agent |
| `token-optimizer` | Token reduction |
| `confluence` | Confluence |
| `evalview` | AI regression |

## Cara Pakai

MCP server dikonfigurasi di `mcp-configs/mcp-servers.json`.

### Contoh: Context7

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp@latest"]
  }
}
```

### Contoh: Playwright

```json
{
  "playwright": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-playwright"]
  }
}
```

## Lihat Juga

- [Hooks](01-hooks.md) — Sistem hook
- [Architecture](../02-architecture/01-overview.md) — Overview
