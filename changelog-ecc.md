# ECC Changelog

**Repo:** https://github.com/fannndi/ECC
**Current SHA:** `7b39012` (2026-06-13 23:49)
**Version:** v2.0.0
**Last Sync:** 2026-06-14

---

## Ringkasan

- 64 agents
- 262 skills
- 84 command shims
- 12+ bahasa (TS, Python, Go, Java, Kotlin, Rust, C++, Perl, PHP)
- Support: Claude Code, Codex, Cursor, OpenCode, Gemini, Zed, Copilot

---

## Commits (50 terakhir)

### 2026-06-13

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `7b39012` | fannndi | feat: add caveman mode + 9Router token optimization | ⚡ |
| `d2c1d31` | fannndi | add: fanndi portable ECC setup (gratis + go profiles) | ⚡ |

### 2026-06-11

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `5b173d2` | Affaan Mustafa | chore: sync package-lock with package.json (CI drift) | |
| `7777656` | Affaan Mustafa | fix: context-size /compact trigger, Codex marketplace plugin path, live README badges | ⚡ |
| `fec84fc` | dependabot | chore(deps): bump rusqlite from 0.32.1 to 0.40.1 in /ecc2 | |
| `1481aa7` | dependabot | chore(deps): bump crossterm from 0.28.1 to 0.29.0 in /ecc2 | |
| `6c39cde` | Affaan Mustafa | fix(assets): replace hero brand mark with website coral circuit mark | |
| `42fe8c3` | Affaan Mustafa | fix(ecc2): port webhook sender to ureq 3 Agent API | |
| `77195eb` | dependabot | chore(deps): bump ureq from 2.12.1 to 3.3.0 in /ecc2 | |
| `75b5d64` | Affaan Mustafa | docs: sync skill count to 262 after config-gc skill landed | |
| `16be4a6` | dependabot | chore(deps): bump sha2 from 0.10.9 to 0.11.0 in /ecc2 | |
| `967940f` | Affaan Mustafa | docs: restore hero banner with ECC wordmark, v2.0.0 badge | |
| `e4a0062` | tongshu2023 | docs(zh-CN): translate ecc-guide and parallel-execution-optimizer skills | |
| `66ad878` | tongshu2023 | feat(skills): add config-gc skill | ⚡ |
| `6da4490` | legeZZZ | docs(zh-CN): add Chinese translation of SKILL-DEVELOPMENT-GUIDE | |
| `6626e80` | Affaan Mustafa | chore: pin rust toolchain to 1.96 for edition2024 deps | |
| `6319c7d` | Affaan Mustafa | fix: stability batch — hook stdin truncation, Codex exa TOML, Stop hook JSON, GateGuard repetition | ⚡ |

### 2026-06-10

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `3bdb4a5` | Affaan Mustafa | docs: restore on-brand ECC header, consolidate sponsor placement | |
| `3aab460` | dependabot | chore(deps): bump the cargo-minor-and-patch group | |
| `7ccc65f` | dependabot | chore(deps-dev): bump the npm-minor-and-patch group | |
| `d71ffd5` | dependabot | chore(deps): bump actions/setup-node | |

### 2026-06-09

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `c888d2b` | ECC Test | docs: update Greptile sponsor placement | |
| `ff768db` | Affaan Mustafa | feat(mcp): single-connector default set + connector policy | ⚡ |
| `8ad4151` | ECC Test | ci: remove copilot code-review surface | |
| `29edd57` | ECC Test | release: 2.0.0 — the agent harness operating system | ⚡ |
| `3e30f1a` | ECC Test | ci: harden workflows and sponsor code review config | |
| `10c303e` | ECC Test | ci: harden release announce checkout | |
| `4f69955` | ECC Test | docs: fix README markdownlint spacing | |
| `3c5bcc2` | ECC Test | security: harden advisory intake and dependency coverage | |
| `8ee5946` | ECC Test | docs: refresh sponsor and readme surface | |

### 2026-06-08

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `edebcc8` | Affaan Mustafa | feat(discord): release -> #announcements auto-post + pin + GitHub Discussions | |

### 2026-06-07

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `90dfd95` | David W Miller | feat: add orch-* orchestrator skill family | ⚡ |
| `e755c5f` | Affaan Mustafa | fix: make plugin hooks run on Node 21+ and green the suite under modern Node | ⚡ |
| `eef31ad` | Andrew Barnes | fix(codex): update bundled defaults to GPT 5.5 | |
| `06c376a` | elmochilyas | feat(skills): add laravel-security, laravel-tdd, and php-reviewer agent | |
| `66e28b5` | V Karthikeyan Nair | feat(skills): add fastapi-patterns skill | |
| `d2dfca2` | fxdv | docs: fix renamed-repo links, drop stale assessment artifacts | |
| `8eedcff` | fxdv | fix(commands): resolve active plugin root in /instinct-status | ⚡ |
| `d7dcd10` | zucchini | docs: add Urdu (ur) README translation | |
| `6a40469` | Tom Cruise Missile | feat: Cursor-independent ECC memory via ECC_AGENT_DATA_HOME | ⚡ |
| `81c9150` | Infinity_Block | fix(docs): sync marketplace add URL across translated READMEs | |
| `0781209` | Adna Salković | feat(skills): add codehealth-mcp skill and CodeScene MCP config | |
| `154d0c7` | Matt H | feat(mcp): add parallel-search server catalog entry | |
| `1e5fa96` | Farzul Nizam Zolkifli | fix(context-monitor): make cost warnings informational, not commands | |
| `ff1bfa1` | Andrea Cavallo | feat: add intent-driven-development skill | |
| `ac0f11c` | Santiago González Siordia | docs: add Spanish (es) translation | |
| `28b78dd` | linsy | feat: add inherit-legacy-style — prevent AI code style drift in legacy code | |
| `4ad5756` | Vu Thanh Tai | feat: expand Kiro adapter to full language coverage | ⚡ |
| `4b3a269` | Zhao73 | docs: fix typos in security guide | |
| `80c63c8` | satoshi-takano-bloom | feat(desktop-notify): route OSC 9 notifications through Ghostty | |

### 2026-06-06

| SHA | Author | Message | Opencode? |
|-----|--------|---------|-----------|
| `6a40469` | Tom Cruise Missile | feat: Cursor-independent ECC memory via ECC_AGENT_DATA_HOME | ⚡ |

---

## Opencode-Related Changes

Commutes yang mempengaruhi OpenCode setup:

| SHA | Date | Message |
|-----|------|---------|
| `7b39012` | 2026-06-13 | feat: add caveman mode + 9Router token optimization |
| `d2c1d31` | 2026-06-13 | add: fanndi portable ECC setup (gratis + go profiles) |
| `7777656` | 2026-06-11 | fix: context-size /compact trigger, Codex marketplace plugin path |
| `66ad878` | 2026-06-11 | feat(skills): add config-gc skill |
| `6319c7d` | 2026-06-11 | fix: stability batch — hook stdin truncation, Codex exa TOML |
| `ff768db` | 2026-06-09 | feat(mcp): single-connector default set + connector policy |
| `29edd57` | 2026-06-09 | release: 2.0.0 — the agent harness operating system |
| `90dfd95` | 2026-06-07 | feat: add orch-* orchestrator skill family |
| `e755c5f` | 2026-06-07 | fix: make plugin hooks run on Node 21+ |
| `8eedcff` | 2026-06-07 | fix(commands): resolve active plugin root in /instinct-status |
| `6a40469` | 2026-06-07 | feat: Cursor-independent ECC memory via ECC_AGENT_DATA_HOME |
| `4ad5756` | 2026-06-07 | feat: expand Kiro adapter to full language coverage |

---

## Catatan

- SHA `7b39012` dan `d2c1d31` adalah commit fannndi (fork kamu)
- Sisanya dari upstream (affaan-m/ECC)
- Update: `git pull` di folder `ecc/` untuk sync ke terbaru
