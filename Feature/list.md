# Feature Inventory — ECC + 9Router

**Last Updated:** 2026-06-14
**Total Components:** 600+

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| Skills | 270 | Domain knowledge and workflow modules |
| Agents | 64 | Specialized AI assistants |
| Commands | 84 | Slash commands for workflows |
| Hooks | 20+ | Automated behaviors |
| Rules | 20 packs | Language/framework conventions |
| MCP Servers | 29 | External tool integrations |
| Install Profiles | 7 | Pre-configured setups |
| Project Stacks | 20 | Auto-detected project types |
| Contexts | 3 | Behavioral overrides |
| Localizations | 9 | Supported languages |

---

## 1. Skills (270)

### Language Skills (29)

| Skill | Language | Purpose |
|-------|----------|---------|
| `python-patterns` | Python | Pythonic idioms, PEP 8, type hints |
| `python-testing` | Python | pytest, TDD, fixtures, mocking |
| `pytorch-patterns` | Python | PyTorch training pipelines, models |
| `golang-patterns` | Go | Idiomatic Go patterns |
| `golang-testing` | Go | Table-driven tests, benchmarks |
| `rust-patterns` | Rust | Ownership, traits, concurrency |
| `rust-testing` | Rust | Unit/integration tests, property-based |
| `kotlin-patterns` | Kotlin | Coroutines, null safety, DSL |
| `kotlin-testing` | Kotlin | Kotest, MockK, coroutine testing |
| `kotlin-coroutines-flows` | Kotlin | Flow operators, StateFlow |
| `kotlin-exposed-patterns` | Kotlin | Exposed ORM, DSL queries |
| `kotlin-ktor-patterns` | Kotlin | Ktor server, routing, plugins |
| `java-coding-standards` | Java | Spring Boot, Quarkus standards |
| `jpa-patterns` | Java | JPA/Hibernate, entity design |
| `cpp-coding-standards` | C++ | C++ Core Guidelines |
| `cpp-testing` | C++ | GoogleTest, CTest |
| `perl-patterns` | Perl | Modern Perl 5.36+ idioms |
| `perl-security` | Perl | Taint mode, input validation |
| `perl-testing` | Perl | Test2::V0, coverage |
| `dotnet-patterns` | C#/.NET | DI, async/await, patterns |
| `csharp-testing` | C#/.NET | xUnit, FluentAssertions |
| `fsharp-testing` | F# | FsUnit, FsCheck |
| `swift-actor-persistence` | Swift | Thread-safe persistence |
| `swift-concurrency-6-2` | Swift | @concurrent, MainActor |
| `swift-protocol-di-testing` | Swift | Protocol-based DI |
| `swiftui-patterns` | Swift | @Observable, navigation |
| `dart-flutter-patterns` | Dart | BLoC, Riverpod, GoRouter |
| `tinystruct-patterns` | Java | tinystruct framework |
| `prisma-patterns` | TypeScript | Prisma ORM patterns |

### Framework Skills (42)

| Skill | Framework | Purpose |
|-------|-----------|---------|
| `react-patterns` | React | Hooks, server/client, Suspense |
| `react-performance` | React | 70+ performance rules |
| `react-testing` | React | RTL, Vitest, MSW |
| `frontend-patterns` | React/Next.js | State management, UI |
| `frontend-a11y` | React | WCAG, ARIA, keyboard nav |
| `frontend-design-direction` | Web | Design direction |
| `frontend-slides` | HTML | Presentations |
| `motion-foundations` | React | Tokens, springs, SSR |
| `motion-advanced` | React | Drag, gestures, SVG |
| `motion-patterns` | React | Modal, toast, stagger |
| `motion-ui` | React | UI motion system |
| `nextjs-turbopack` | Next.js | Turbopack, FS caching |
| `nuxt4-patterns` | Nuxt | Hydration, SSR |
| `backend-patterns` | Node.js | API, DB, caching |
| `django-patterns` | Django | DRF, ORM, signals |
| `django-celery` | Django | Async tasks, beat |
| `django-security` | Django | Auth, CSRF, XSS |
| `django-tdd` | Django | pytest-django, factory_boy |
| `django-verification` | Django | Migrations, security |
| `laravel-patterns` | Laravel | Eloquent, queues, events |
| `laravel-plugin-discovery` | Laravel | LaraPlugins.io |
| `laravel-security` | Laravel | Auth, Eloquent safety |
| `laravel-tdd` | Laravel | PHPUnit, Pest |
| `laravel-verification` | Laravel | Static analysis |
| `springboot-patterns` | Spring Boot | Layered architecture |
| `springboot-security` | Spring Boot | JWT, RBAC |
| `springboot-tdd` | Spring Boot | JUnit 5, Mockito |
| `springboot-verification` | Spring Boot | Build, security |
| `quarkus-patterns` | Quarkus | CDI, Panache |
| `quarkus-security` | Quarkus | JWT/OIDC |
| `quarkus-tdd` | Quarkus | REST Assured |
| `quarkus-verification` | Quarkus | Native compilation |
| `nestjs-patterns` | NestJS | Modules, guards |
| `fastapi-patterns` | FastAPI | Pydantic, async |
| `vite-patterns` | Vite | Config, HMR, SSR |
| `mcp-server-patterns` | MCP | Tools, resources |
| `compose-multiplatform-patterns` | Compose | KMP state, nav |
| `android-clean-architecture` | Android | UseCases, repos |
| `liquid-glass-design` | iOS 26 | Glass material |
| `angular-developer` | Angular | Signals, DI, routing |
| `flutter-dart-code-review` | Flutter | Widget review |
| `ui-to-vue` | Vue | Screenshot to components |

### Workflow Skills (41)

| Skill | Purpose |
|-------|---------|
| `tdd-workflow` | Test-driven development |
| `verification-loop` | Build, type, lint, test |
| `e2e-testing` | Playwright patterns |
| `eval-harness` | AI regression testing |
| `santa-method` | Adversarial verification |
| `strategic-compact` | Context compaction |
| `continuous-learning-v2` | Instinct extraction |
| `search-first` | Research before coding |
| `code-tour` | Codebase walkthroughs |
| `codebase-onboarding` | Project onboarding |
| `coding-standards` | Cross-project conventions |
| `error-handling` | Typed errors, boundaries |
| `hexagonal-architecture` | Ports & Adapters |
| `architecture-decision-records` | ADR management |
| `blueprint` | Multi-session plans |
| `plan-orchestrate` | Step decomposition |
| `intent-driven-development` | Acceptance criteria |
| `inherit-legacy-style` | Legacy style preservation |
| `rules-distill` | Extract rules from skills |
| `dynamic-workflow-mode` | Adaptive harnesses |
| `parallel-execution-optimizer` | Concurrent execution |
| `safety-guard` | Destructive op prevention |
| `recursive-decision-ledger` | Decision tracking |
| `team-builder` | Agent team composition |
| `benchmark` | Performance baselines |
| `benchmark-optimization-loop` | Recursive optimization |
| `data-throughput-accelerator` | ETL acceleration |
| `iterative-retrieval` | Progressive refinement |
| `content-hash-cache-pattern` | SHA-256 caching |
| `context-budget` | Token optimization |
| `token-budget-advisor` | Response depth control |
| `agentic-engineering` | Agent development |
| `ai-first-engineering` | AI team practices |
| `orch-add-feature` | Feature orchestration |
| `orch-build-mvp` | MVP orchestration |
| `orch-change-feature` | Behavior change |
| `orch-fix-defect` | Bug fix orchestration |
| `orch-pipeline` | Pipeline engine |
| `orch-refine-code` | Refactor orchestration |
| `regex-vs-llm-structured-text` | Parsing decisions |

### Domain Skills (77)

#### Security & Compliance (12)
| Skill | Domain |
|-------|--------|
| `security-review` | Security checklist |
| `security-scan` | Config scanning |
| `security-bounty-hunter` | Bug bounty |
| `hipaa-compliance` | HIPAA |
| `healthcare-phi-compliance` | PHI/PII |
| `defi-amm-security` | Solidity AMM |
| `llm-trading-agent-security` | Trading agents |
| `evm-token-decimals` | EVM tokens |
| `nodejs-keccak256` | Ethereum hashing |
| `prediction-market-risk-review` | Market risk |
| `ai-regression-testing` | AI testing |
| `production-audit` | Prod readiness |

#### DevOps & Infrastructure (7)
| Skill | Purpose |
|-------|---------|
| `docker-patterns` | Docker/Compose |
| `kubernetes-patterns` | K8s workloads |
| `deployment-patterns` | CI/CD, rollback |
| `database-migrations` | Schema changes |
| `postgres-patterns` | PostgreSQL |
| `mysql-patterns` | MySQL/MariaDB |
| `redis-patterns` | Redis caching |

#### Content & Marketing (8)
| Skill | Purpose |
|-------|---------|
| `article-writing` | Long-form content |
| `brand-voice` | Voice consistency |
| `content-engine` | Multi-platform content |
| `crosspost` | Cross-posting |
| `social-publisher` | 13 platforms |
| `marketing-campaign` | Campaign planning |
| `seo` | SEO optimization |
| `research-ops` | Research workflows |

#### Business & Finance (8)
| Skill | Purpose |
|-------|---------|
| `market-research` | Market analysis |
| `investor-materials` | Pitch decks |
| `investor-outreach` | VC outreach |
| `finance-billing-ops` | Revenue/pricing |
| `customer-billing-ops` | Subscriptions |
| `lead-intelligence` | Lead scoring |
| `connections-optimizer` | Network pruning |
| `social-graph-ranker` | Graph analysis |

#### Healthcare & Science (9)
| Skill | Purpose |
|-------|---------|
| `healthcare-cdss-patterns` | Clinical decisions |
| `healthcare-emr-patterns` | EMR/EHR |
| `healthcare-eval-harness` | Patient safety |
| `scientific-db-pubmed-database` | PubMed |
| `scientific-db-uspto-database` | USPTO patents |
| `scientific-pkg-gget` | Bioinformatics |
| `scientific-thinking-literature-review` | Literature review |
| `scientific-thinking-scholar-evaluation` | Paper evaluation |
| `accessibility` | WCAG 2.2 |

#### Supply Chain (7)
| Skill | Purpose |
|-------|---------|
| `logistics-exception-management` | Freight exceptions |
| `carrier-relationship-management` | Carrier mgmt |
| `returns-reverse-logistics` | Returns processing |
| `customs-trade-compliance` | Customs docs |
| `inventory-demand-planning` | Demand forecasting |
| `production-scheduling` | Manufacturing |
| `quality-nonconformance` | Quality control |

#### Networking & Homelab (10)
| Skill | Purpose |
|-------|---------|
| `cisco-ios-patterns` | Cisco IOS |
| `netmiko-ssh-automation` | SSH automation |
| `network-bgp-diagnostics` | BGP troubleshooting |
| `network-config-validation` | Config validation |
| `network-interface-health` | Interface diagnostics |
| `homelab-network-readiness` | Network readiness |
| `homelab-network-setup` | Network planning |
| `homelab-pihole-dns` | Pi-hole DNS |
| `homelab-vlan-segmentation` | VLAN segmentation |
| `homelab-wireguard-vpn` | WireGuard VPN |

#### Prediction Markets (6)
| Skill | Purpose |
|-------|---------|
| `prediction-market-oracle-research` | Oracle signals |
| `ito-basket-compare` | Basket comparison |
| `ito-data-atlas-agent` | Data atlas |
| `ito-market-intelligence` | Market intel |
| `ito-trade-planner` | Trade planning |
| `make-interfaces-feel-better` | UI polish |

#### Other Domain (8)
| Skill | Purpose |
|-------|---------|
| `git-workflow` | Git conventions |
| `github-ops` | GitHub automation |
| `knowledge-ops` | Knowledge mgmt |
| `email-ops` | Email workflows |
| `messages-ops` | Messaging |
| `project-flow-ops` | GitHub/Linear |
| `unified-notifications-ops` | Notifications |
| `google-workspace-ops` | Google Workspace |

### Tool Skills (31)

#### AI Gateway (10)
| Skill | Purpose |
|-------|---------|
| `9router` | 9Router setup |
| `9router-chat` | Chat/code gen |
| `9router-embeddings` | Vector embeddings |
| `9router-image` | Image generation |
| `9router-stt` | Speech-to-text |
| `9router-tts` | Text-to-speech |
| `9router-web-fetch` | URL to markdown |
| `9router-web-search` | Web search |
| `exa-search` | Neural search |
| `fal-ai-media` | fal.ai generation |

#### Development Tools (8)
| Skill | Purpose |
|-------|---------|
| `documentation-lookup` | Context7 docs |
| `bun-runtime` | Bun runtime |
| `flox-environments` | Nix environments |
| `jira-integration` | Jira workflows |
| `nutrient-document-processing` | Doc processing |
| `mcp-server-patterns` | MCP servers |
| `ui-demo` | Demo videos |
| `windows-desktop-e2e` | Windows E2E |

#### Media & Video (4)
| Skill | Purpose |
|-------|---------|
| `manim-video` | Animated explainers |
| `remotion-video-creation` | React video |
| `video-editing` | Video editing |
| `videodb` | Video database |

#### Other Tools (9)
| Skill | Purpose |
|-------|---------|
| `browser-qa` | Browser testing |
| `canary-watch` | Deploy monitoring |
| `click-path-audit` | Click auditing |
| `codehealth-mcp` | CodeScene |
| `config-gc` | Config cleanup |
| `design-system` | Design systems |
| `ecc-guide` | ECC features |
| `ios-icon-gen` | iOS icons |
| `uncloud` | Uncloud cluster |

### Meta/Template Skills (50)

| Skill | Purpose |
|-------|---------|
| `agent-architecture-audit` | Agent diagnostics |
| `agent-eval` | Agent comparison |
| `agent-harness-construction` | Harness design |
| `agent-introspection-debugging` | Self-debugging |
| `agent-payment-x402` | Agent payments |
| `agent-sort` | ECC install plan |
| `agentic-os` | Multi-agent OS |
| `autonomous-agent-harness` | Autonomous agents |
| `autonomous-loops` | Loop patterns |
| `ck` | Project memory |
| `claude-devfleet` | Fleet orchestration |
| `compose-multiplatform-patterns` | KMP patterns |
| `configure-ecc` | ECC installer |
| `cost-aware-llm-pipeline` | Cost optimization |
| `cost-tracking` | Token tracking |
| `council` | Multi-voice decisions |
| `customs-trade-compliance` | Trade compliance |
| `data-scraper-agent` | Data collection |
| `database-migrations` | Schema migrations |
| `dashboard-builder` | Monitoring dashboards |
| `defi-amm-security` | DeFi security |
| `deep-research` | Deep research |
| `documentation-lookup` | Live docs |
| `ecc-tools-cost-audit` | ECC cost audit |
| `energy-procurement` | Energy procurement |
| `enterprise-agent-ops` | Enterprise ops |
| `evm-token-decimals` | EVM decimals |
| `flox-environments` | Flox environments |
| `gan-style-harness` | GAN harness |
| `gateguard` | Fact-forcing gate |
| `hookify-rules` | Hook creation |
| `intent-driven-development` | Acceptance criteria |
| `inventory-demand-planning` | Demand planning |
| `llm-trading-agent-security` | Trading security |
| `logistics-exception-management` | Logistics |
| `nanoclaw-repl` | NanoClaw REPL |
| `nodejs-keccak256` | Keccak256 |
| `openclaw-persona-forge` | Persona creation |
| `opens-source-pipeline` | OSS pipeline |
| `orch-*` | Orchestration (6 skills) |
| `parallel-execution-optimizer` | Parallel execution |
| `plan-orchestrate` | Plan orchestration |
| `prediction-market-risk-review` | Risk review |
| `production-scheduling` | Production |
| `prompt-optimizer` | Prompt optimization |
| `quality-nonconformance` | Quality control |
| `recursive-decision-ledger` | Decision tracking |
| `regex-vs-llm-structured-text` | Parsing decisions |
| `returns-reverse-logistics` | Returns |
| `rules-distill` | Rules extraction |
| `safety-guard` | Safety patterns |
| `skill-comply` | Skill compliance |
| `skill-scout` | Skill discovery |
| `skill-stocktake` | Skill inventory |
| `token-budget-advisor` | Token budget |
| `visa-doc-translate` | Visa translation |
| `workspace-surface-audit` | Workspace audit |

---

## 2. Agents (64)

### Core Agents (12)
| Agent | Purpose |
|-------|---------|
| `planner` | Implementation planning |
| `architect` | System design |
| `code-reviewer` | Code quality |
| `security-reviewer` | Vulnerability detection |
| `tdd-guide` | Test-driven development |
| `build-error-resolver` | Build errors |
| `e2e-runner` | E2E testing |
| `refactor-cleaner` | Dead code cleanup |
| `doc-updater` | Documentation |
| `harness-optimizer` | Config tuning |
| `loop-operator` | Autonomous loops |
| `docs-lookup` | Documentation |

### Language/Build Reviewers (32)
| Agent | Language |
|-------|----------|
| `cpp-reviewer` | C/C++ |
| `cpp-build-resolver` | C/C++ |
| `csharp-reviewer` | C# |
| `dart-build-resolver` | Dart |
| `django-reviewer` | Django |
| `django-build-resolver` | Django |
| `fastapi-reviewer` | FastAPI |
| `flutter-reviewer` | Flutter |
| `fsharp-reviewer` | F# |
| `go-reviewer` | Go |
| `go-build-resolver` | Go |
| `java-reviewer` | Java |
| `java-build-resolver` | Java |
| `kotlin-reviewer` | Kotlin |
| `kotlin-build-resolver` | Kotlin |
| `php-reviewer` | PHP |
| `python-reviewer` | Python |
| `pytorch-build-resolver` | PyTorch |
| `react-reviewer` | React |
| `react-build-resolver` | React |
| `rust-reviewer` | Rust |
| `rust-build-resolver` | Rust |
| `swift-reviewer` | Swift |
| `swift-build-resolver` | Swift |
| `typescript-reviewer` | TypeScript |
| `database-reviewer` | PostgreSQL |
| `mle-reviewer` | ML pipelines |

### Domain/Workflow Agents (20)
| Agent | Domain |
|-------|--------|
| `chief-of-staff` | Multi-agent coord |
| `code-explorer` | Codebase nav |
| `code-simplifier` | Code simplification |
| `comment-analyzer` | Comment quality |
| `conversation-analyzer` | Session analysis |
| `performance-optimizer` | Performance |
| `pr-test-analyzer` | PR test coverage |
| `silent-failure-hunter` | Silent failures |
| `type-design-analyzer` | Type design |
| `gan-evaluator` | GAN evaluation |
| `gan-generator` | GAN generation |
| `gan-planner` | GAN planning |
| `harmonyos-app-resolver` | HarmonyOS |
| `healthcare-reviewer` | Healthcare |
| `homelab-architect` | Home lab |
| `marketing-agent` | Marketing |
| `network-architect` | Network |
| `network-config-reviewer` | Network config |
| `network-troubleshooter` | Network debug |
| `seo-specialist` | SEO |
| `a11y-architect` | Accessibility |

---

## 3. Commands (84)

### Core Commands (20)
| Command | Purpose |
|---------|---------|
| `plan` | Implementation plan |
| `tdd` | TDD workflow |
| `code-review` | Code review |
| `security` | Security review |
| `build-fix` | Fix build errors |
| `e2e` | E2E tests |
| `refactor-clean` | Remove dead code |
| `orchestrate` | Multi-agent |
| `learn` | Extract patterns |
| `checkpoint` | Save progress |
| `verify` | Verification loop |
| `eval` | Evaluation |
| `update-docs` | Update docs |
| `update-codemaps` | Update codemaps |
| `test-coverage` | Coverage analysis |
| `setup-pm` | Package manager |
| `analyze-project` | Project detection |
| `start-free` | Daily workflow (free) |
| `start-go` | Daily workflow (go) |
| `skill-create` | Generate skills |

### Language-Specific Commands (24)
| Command | Language |
|---------|----------|
| `go-review` | Go |
| `go-test` | Go |
| `go-build` | Go |
| `cpp-review` | C++ |
| `cpp-test` | C++ |
| `cpp-build` | C++ |
| `kotlin-review` | Kotlin |
| `kotlin-test` | Kotlin |
| `kotlin-build` | Kotlin |
| `python-review` | Python |
| `react-review` | React |
| `react-test` | React |
| `react-build` | React |
| `rust-review` | Rust |
| `rust-test` | Rust |
| `rust-build` | Rust |
| `flutter-review` | Flutter |
| `flutter-test` | Flutter |
| `flutter-build` | Flutter |
| `fastapi-review` | FastAPI |
| `gradle-build` | Gradle |
| `gan-build` | GAN |
| `gan-design` | GAN |

### Orchestration Commands (12)
| Command | Purpose |
|---------|---------|
| `orch-add-feature` | New feature |
| `orch-build-mvp` | Build MVP |
| `orch-change-feature` | Change behavior |
| `orch-fix-defect` | Fix bug |
| `orch-refine-code` | Refactor |
| `multi-backend` | Multi-backend |
| `multi-execute` | Multi-execute |
| `multi-frontend` | Multi-frontend |
| `multi-plan` | Multi-plan |
| `multi-workflow` | Multi-workflow |
| `santa-loop` | Santa method |
| `plan-orchestrate` | Plan orchestration |

### PRP Commands (5)
| Command | Purpose |
|---------|---------|
| `prp-commit` | PRP commit |
| `prp-implement` | PRP implement |
| `prp-plan` | PRP plan |
| `prp-pr` | PRP PR |
| `prp-prd` | PRP PRD |

### Hook Commands (4)
| Command | Purpose |
|---------|---------|
| `hookify` | Create hook |
| `hookify-configure` | Configure hook |
| `hookify-help` | Hook help |
| `hookify-list` | List hooks |

### Instinct Commands (3)
| Command | Purpose |
|---------|---------|
| `instinct-export` | Export instincts |
| `instinct-import` | Import instincts |
| `instinct-status` | View instincts |

### Other Commands (16)
| Command | Purpose |
|---------|---------|
| `aside` | Quick note |
| `auto-update` | Update ECC |
| `cost-report` | Cost report |
| `ecc-guide` | ECC guide |
| `evolve` | Evolve code |
| `feature-dev` | Feature dev |
| `harness-audit` | Harness audit |
| `jira` | Jira integration |
| `loop-start` | Start loop |
| `loop-status` | Loop status |
| `model-route` | Model routing |
| `pm2` | PM2 process |
| `pr` | Create PR |
| `projects` | List projects |
| `promote` | Promote code |
| `prune` | Prune unused |

---

## 4. Hooks (20+)

### PreToolUse (8)
| Hook | Purpose |
|------|---------|
| `pre:bash:dispatcher` | Bash preflight |
| `pre:write:doc-file-warning` | Doc file warning |
| `pre:edit-write:suggest-compact` | Compact suggestion |
| `pre:observe:continuous-learning` | Learning capture |
| `pre:governance-capture` | Governance events |
| `pre:config-protection` | Config protection |
| `pre:mcp-health-check` | MCP health |
| `pre:edit-write:gateguard-fact-force` | GateGuard |

### PostToolUse (11)
| Hook | Purpose |
|------|---------|
| `post:bash:dispatcher` | Bash postflight |
| `post:quality-gate` | Quality checks |
| `post:edit:design-quality-check` | Design quality |
| `post:edit:accumulator` | Edit batching |
| `post:edit:console-warn` | Console warning |
| `post:governance-capture` | Governance |
| `post:session-activity-tracker` | Activity tracking |
| `post:observe:continuous-learning` | Learning |
| `post:ecc-metrics-bridge` | Metrics |
| `post:ecc-context-monitor` | Context monitor |
| `post:mcp-health-check` | MCP failure tracking |

### Stop (6)
| Hook | Purpose |
|------|---------|
| `stop:format-typecheck` | Format + typecheck |
| `stop:check-console-log` | Console.log check |
| `stop:session-end` | Session persist |
| `stop:evaluate-session` | Session eval |
| `stop:cost-tracker` | Cost tracking |
| `stop:desktop-notify` | Desktop notify |

### Lifecycle (3)
| Hook | Purpose |
|------|---------|
| `session:start` | Load context |
| `pre:compact` | Save state |
| `session:end:marker` | End marker |

---

## 5. Rules (20 Packs)

| Pack | Language/Framework |
|------|-------------------|
| `common` | Universal conventions |
| `typescript` | TypeScript/JavaScript |
| `angular` | Angular |
| `python` | Python |
| `golang` | Go |
| `rust` | Rust |
| `java` | Java |
| `kotlin` | Kotlin |
| `swift` | Swift |
| `csharp` | C# |
| `fsharp` | F# |
| `cpp` | C/C++ |
| `php` | PHP |
| `ruby` | Ruby |
| `perl` | Perl |
| `dart` | Dart/Flutter |
| `react` | React |
| `web` | Web/Frontend |
| `arkts` | HarmonyOS/ArkTS |

---

## 6. MCP Servers (29)

| Server | Purpose |
|--------|---------|
| `nexus` | Cost/privacy proxy |
| `jira` | Jira tracking |
| `github` | GitHub PRs/issues |
| `firecrawl` | Web scraping |
| `supabase` | Database ops |
| `memory` | Persistent memory |
| `omega-memory` | Semantic memory |
| `longhand` | Session history |
| `sequential-thinking` | Chain-of-thought |
| `vercel` | Vercel deploy |
| `railway` | Railway deploy |
| `cloudflare-docs` | Cloudflare docs |
| `cloudflare-workers-builds` | Workers builds |
| `cloudflare-workers-bindings` | Workers bindings |
| `cloudflare-observability` | Observability |
| `clickhouse` | Analytics |
| `exa-web-search` | Web search |
| `parallel-search` | LLM search |
| `context7` | Live docs |
| `codescene` | Code health |
| `magic` | UI components |
| `filesystem` | File ops |
| `playwright` | Browser automation |
| `fal-ai` | Media generation |
| `browserbase` | Cloud browser |
| `browser-use` | AI browser |
| `devfleet` | Multi-agent |
| `token-optimizer` | Token reduction |
| `laraplugins` | Laravel plugins |
| `confluence` | Confluence |
| `evalview` | AI regression |
| `squish` | Local memory |

---

## 7. Install Profiles (7)

| Profile | Modules | Description |
|---------|---------|-------------|
| `minimal` | 5 | Low-context, no hooks |
| `opencode` | 3 | Default OpenCode |
| `core` | 6 | Minimal baseline |
| `developer` | 9 | Default engineering |
| `security` | 7 | Security-heavy |
| `research` | 9 | Research/content |
| `full` | 22 | Complete ECC |

---

## 8. Project Stacks (20)

| Stack | Indicators | Skills |
|-------|-----------|--------|
| `typescript` | tsconfig.json | coding-standards, tdd-workflow, verification-loop |
| `javascript` | package.json | coding-standards, tdd-workflow, verification-loop |
| `react` | package.json (react) | frontend-patterns, react-* |
| `nextjs` | next.config.* | frontend-patterns, backend-patterns |
| `golang` | go.mod | golang-patterns, golang-testing |
| `python` | pyproject.toml | python-patterns, python-testing |
| `rust` | Cargo.toml | rust-patterns, rust-testing |
| `java` | pom.xml | java-coding-standards |
| `springboot` | pom.xml (spring-boot) | springboot-* |
| `kotlin` | build.gradle.kts | kotlin-patterns, kotlin-testing |
| `swift` | Package.swift | swiftui-patterns, swift-concurrency-6-2 |
| `dart-flutter` | pubspec.yaml | dart-flutter-patterns |
| `php-laravel` | composer.json | laravel-patterns, laravel-tdd |
| `ruby` | Gemfile | tdd-workflow, verification-loop |
| `csharp-dotnet` | *.csproj | dotnet-patterns, csharp-testing |
| `cpp` | CMakeLists.txt | cpp-coding-standards, cpp-testing |
| `perl` | cpanfile | perl-patterns, perl-testing |
| `django` | manage.py | django-patterns, django-tdd |
| `android` | AndroidManifest.xml | android-clean-architecture, kotlin-patterns |
| `docker` | Dockerfile | docker-patterns, deployment-patterns |

---

## 9. Contexts (3)

| Context | Mode | Purpose |
|---------|------|---------|
| `dev.md` | Active | Write code first |
| `research.md` | Exploration | Read widely |
| `review.md` | Review | Severity checklist |

---

## 10. Localizations (9)

| Language | Directory |
|----------|-----------|
| Japanese | `docs/ja-JP/` |
| Simplified Chinese | `docs/zh-CN/` |
| Traditional Chinese | `docs/zh-TW/` |
| Korean | `docs/ko-KR/` |
| Brazilian Portuguese | `docs/pt-BR/` |
| Russian | `docs/ru/` |
| Turkish | `docs/tr/` |
| Vietnamese | `docs/vi-VN/` |
| German | `docs/de-DE/` |

---

## How to Use This

### For analyze-project

The `analyze-project` command uses this inventory to:
1. Detect project stack
2. Load appropriate skills
3. Apply relevant rules
4. Configure agents

### For Manual Setup

```powershell
# Pick skills from this list
# Add to opencode.jsonc instructions:
"instructions": [
  "C:/path/to/ecc/skills/dart-flutter-patterns/SKILL.md",
  "C:/path/to/ecc/skills/tdd-workflow/SKILL.md"
]
```

### For Custom Stacks

If your stack isn't listed:
1. Find relevant skills in Skill/skill-list.md
2. Add to `analyze-project.ps1` indicators
3. Create custom stack entry
