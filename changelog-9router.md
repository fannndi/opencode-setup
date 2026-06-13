# 9Router Changelog

**Repo:** https://github.com/fannndi/9router
**Current SHA:** `23da7b1` (2026-06-13 15:42)
**Version:** v0.4.80
**Last Sync:** 2026-06-14

---

## Ringkasan

- RTK Token Saver (-20-40% input tokens)
- Caveman Mode (-65% output tokens)
- 3-tier auto-fallback (subscription → cheap → free)
- 40+ providers, 100+ models
- Support: Claude Code, Codex, Cursor, OpenCode, Cline, Copilot, Antigravity
- Docker + VPS deployment ready

---

## Commits (50 terakhir)

### 2026-06-13

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `23da7b1` | decolua | Update ChangeLog | |
| `515e2cc` | decolua | v0.4.77 (2026-06-13) — Major release | ⚡ |
| `05e483c` | decolua | fix(provider-topology): update label assignment to include nodeName | |
| `d652300` | saurabh321gupta | fix(cerebras,mistral): strip unsupported client_metadata | |
| `0c7c9de` | decolua | fix(security): re-auth on DB export/import + SSRF guard | ⚡ |
| `e6bac77` | Phuc Le | fix(siliconflow): update baseUrl .cn -> .com | |
| `b33cbb0` | Ngô Tấn Tài | feat(vercel-ai-gateway): support embeddings, images and credit usage | |
| `d9b0300` | Giang Truong Vu | fix(gemini-to-openai): route unsigned thought parts to reasoning_content | |
| `564f2ec` | weimaozhen | fix(usage-stats): avoid partial stats on initial SSE race | |
| `b40e96d` | Fadjrir Herlambang | feat(provider): add MiMo Free no-auth provider | ⚡ |
| `0aaa5ab` | weimaozhen | fix(claude-to-openai): strip Anthropic billing header | |
| `bbc204b` | zocomputer | fix: use export default in proxy.js for Next.js 16 | |
| `9406bd1` | Duong Thai Hoa Tong | feat(vertex): support ADC authorized_user credential | |
| `b977bf7` | hodtien | fix(anthropic-compatible): send Bearer auth for third-party gateways | |
| `b309261` | decolua | enhance Kiro profile ARN resolution | ⚡ |

### 2026-06-08

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `4443903` | decolua | fix: add normalization for Claude passthrough bodies | |
| `f8b73fa` | decolua | feat(cowork): re-enable Claude Cowork with preset-only stdio MCP | |
| `7648c34` | decolua | fix(auth): real client IP rate-limiting + remote default-password guard | ⚡ |
| `c572c68` | minhnhat166 | fix(github): proactively refresh missing/expired Copilot token | |
| `24a4f08` | Stefan Pirker | fix(tunnel): detect system-installed Tailscale via dual-socket probe | |
| `8e31b5f` | Kris | docs(readme): add Indonesian 9Router tutorial video | |
| `8962e46` | Quoc Nguyen | feat(providers/codex): bulk add accounts via JSON | |
| `b2aa08a` | Delcado19 | fix(copilot): add mappable gpt-5-mini/gpt-5.4-nano slots | |
| `f8c5922` | decolua | fix(kiro): auto-resolve profileArn to prevent 403 on IDC login | ⚡ |
| `c24efe8` | thienpv | feat(kiro): enable multi-endpoint failover for GenerateAssistantResponse | ⚡ |
| `dd5c575` | joutvhu | fix(mitm): update Kiro API endpoint to runtime.us-east-1.kiro.dev | |
| `289214a` | decolua | fix(tunnel): make tailscale probes non-blocking | |
| `c5815ad` | Mr. Nasıl | fix(commandcode): force stream=true in transformRequest | |
| `137a25e` | decolua | fix(qoder): increase timeouts for reasoning models | |
| `51cbe65` | Sutarto Jordan Chrisfivo | fix(dashboard): show explicit kind="llm" combos | |

### 2026-06-06

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `827e5c3` | decolua | v0.4.71 (2026-06-06) | ⚡ |
| `48c37e0` | decolua | feat(endpoint): implement locale-based visibility for wenyan caveman levels | ⚡ |
| `9caea88` | decolua | fix(codex): harden streaming timeouts + Responses terminal events | |
| `f161b29` | decolua | refactor(dashboard): reorganize menu actions | |
| `293cf40` | decolua | fix(tunnel): skip virtual interfaces to prevent false netchange watchdog | |
| `c785051` | Claude Code | fix(claude): forced tool_choice 400 on cc/ OAuth route | |
| `64f5842` | decolua | feat(i18n): add endpoint exposure notice across multiple languages | |
| `0477922` | arden1601 | feat(caveman): add wenyan classical Chinese levels and sync upstream prompts | ⚡ |
| `2be00e2` | Delcado19 | fix(proxy): raise Next client body limit to 128MB (configurable) | |
| `4fc02e6` | Farhan Usman | fix(minimax): echo reasoning_content on follow-up turns | |
| `8ad9554` | Simon Shi | fix(kiro): handle 400 on tool-bearing history without client tools | |
| `281f292` | decolua | test(translator): add data-driven coverage | |
| `4758a00` | decolua | docs: add Russian README | |
| `0850f0a` | Giao Ho | fix(mitm): Kiro binary EventStream crash + add models & TTS tool filtering | |
| `c233c7c` | Kevin Le | fix(codex): durable OAuth refresh lifecycle | |
| `38b73bf` | Delcado19 | fix(antigravity): passthrough tab-autocomplete + mark default agent slot mandatory | |
| `61d5466` | therunnas | fix(qoder): allow qmodel_latest model key | |
| `e6c09aa` | AbdoKnbGit | feat(antigravity): add gemini-3.5-flash-extra-low (Low) model | |
| `40cfa63` | Mr_NoboDy | feat(xiaomi-tokenplan): add Claude-native MiMo V2.5 Pro alias | |
| `3dda651` | Delcado19 | fix(kiro): add mappable "auto" model slot for Kiro agent mode | |

---

## Opencode-Related Changes

Commits yang mempengaruhi OpenCode setup:

| SHA | Date | Message |
|-----|------|---------|
| `515e2cc` | 2026-06-13 | v0.4.77 — MiMo Free provider, Vertex ADC, Kiro failover |
| `0c7c9de` | 2026-06-13 | fix(security): re-auth on DB export/import + SSRF guard |
| `b40e96d` | 2026-06-13 | feat(provider): add MiMo Free no-auth provider |
| `b309261` | 2026-06-13 | enhance Kiro profile ARN resolution |
| `7648c34` | 2026-06-08 | fix(auth): real client IP rate-limiting + remote default-password guard |
| `f8c5922` | 2026-06-08 | fix(kiro): auto-resolve profileArn to prevent 403 |
| `c24efe8` | 2026-06-08 | feat(kiro): enable multi-endpoint failover |
| `827e5c3` | 2026-06-06 | v0.4.71 — Caveman wenyan levels, Codex hardening |
| `48c37e0` | 2026-06-06 | feat(endpoint): locale-based visibility for caveman levels |
| `0477922` | 2026-06-06 | feat(caveman): add wenyan classical Chinese levels |

---

## Release Notes

### v0.4.77 (2026-06-13)

**Features:**
- Vercel AI Gateway: support embeddings, images and credit usage
- MiMo Free: no-auth provider (baru!)
- Vertex: support ADC authorized_user credential
- Cowork: re-enable Claude Cowork with preset-only stdio MCP
- Codex: bulk add accounts via JSON
- Kiro: enable multi-endpoint failover for GenerateAssistantResponse

**Fixes:**
- Security: re-auth on DB export/import + SSRF guard on web fetch
- Auth: real client IP rate-limiting + remote default-password guard
- Cerebras/Mistral: strip unsupported client_metadata
- SiliconFlow: update baseUrl .cn → .com
- Gemini-to-OpenAI: route unsigned thought parts to reasoning_content
- Claude-to-OpenAI: strip Anthropic billing header
- Anthropic-compatible: send Bearer auth for third-party gateways
- GitHub Copilot: refresh missing/expired token on models discovery
- Kiro: auto-resolve profileArn to prevent 403 on IDC login
- Tunnel: detect system-installed Tailscale via dual-socket probe
- Dashboard: show provider node name in topology

### v0.4.71 (2026-06-06)

**Features:**
- Caveman: add wenyan classical Chinese levels
- Endpoint: locale-based visibility for caveman levels

**Fixes:**
- Codex: harden streaming timeouts + Responses terminal events
- Tunnel: skip virtual interfaces to prevent false netchange watchdog
- Claude: forced tool_choice 400 on cc/ OAuth route
- Proxy: raise Next client body limit to 128MB

---

## Catatan

- SHA `23da7b1` adalah commit terakhir di fork kamu
- Sisanya dari upstream (decolua/9router)
- Update: `git pull` di folder `9router/` untuk sync ke terbaru
- Dashboard: http://localhost:20128/dashboard (password: 123456)
