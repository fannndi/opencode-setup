# Scripts — Referensi

## Daftar Scripts (42 file)

### LLM Pipeline (Local GPU Preprocessing)

| Script | Fungsi |
|--------|--------|
| `llm-adapter.ps1` | Ollama API wrapper: Invoke-LLM, Invoke-LLMEnrich, Invoke-LLMChunk, failure logging, `num_gpu=99`, thinking field fallback |
| `llm-mode.ps1` | 3-mode toggle (eco/balanced/performance) + auto VRAM management (upload/unload) |
| `llm-preprocess.ps1` | Universal input pipeline: stack → skill → feature → memory → knowledge → intent → route |
| `intent-compiler.ps1` | Natural language → structured JSON spec (dual path: LLM + regex) |
| `skill-router.ps1` | Select 3-10 skills from 270 by intent + stack (LLM or regex) |
| `llm-audit.ps1` | Multi-mode code audit (quality/security/perf) with chunking + loop mode |
| `llm-benchmark.ps1` | Benchmark harness: 5 scenarios, 3 rounds, pass@k metrics |
| `llm-feedback.ps1` | Analyze failure log → LLM recommendations → auto-config |
| `llm-evolve.ps1` | Auto-adjust Timeout/Temperature/Model from usage stats |

### Agent Layer

| Script | Platform | Fungsi |
|--------|----------|--------|
| `agent-core.ps1` | Win | Stack detection, intent classification, skill auto-loader, session resume |
| `task-queue.ps1` | Win | Autonomous DAG execution — decompose goal → dependency resolve → execute |
| `agent-dashboard.ps1` | Win | System overview: health, sessions, LLM usage, model status |
| `tool-creator.ps1` | Win | Template-based script/command generator |

### Infrastructure & Daily

| Script | Platform | Fungsi |
|--------|----------|--------|
| `setup.ps1` / `.sh` | Both | Full setup (clone + install + config) |
| `install.ps1` / `.sh` | Both | Quick re-apply config |
| `clone.ps1` / `.sh` | Both | Clone ECC + 9Router |
| `sync.ps1` / `.sh` | Both | Sync changelog |
| `start.ps1` / `.sh` | Both | Daily workflow (session-aware) + `$env:OLLAMA_KEEP_ALIVE = "-1"` |
| `auto-start.ps1` | Win | Chain semua workflow 1 command |
| `full-start.ps1` | Win | Start → code-analyze → ready |
| `admin-update.ps1` | Win | Update ECC/9Router + doctor |
| `analyze-project.ps1` / `.sh` | Both | Deteksi stack + load skills |
| `project-skills.ps1` | Win | Lihat skills yang cocok |
| `research.ps1` / `.sh` | Both | Web search + AI ringkasan |
| `generate-prd.ps1` | Win | Ide → PRD otomatis |
| `wizard.ps1` | Win | Panduan interaktif pemula |
| `quality-gate.ps1` | Win | Verify fixes, track iterations |
| `token-tracker.ps1` | Win | Token usage + session stats |
| `memory.ps1` | Win | Simpan/baca memori session |
| `session-manager.ps1` | Win | Session management |
| `template-loader.ps1` / `.sh` | Both | Load project template |
| `create.ps1` | Win | Generate boilerplate |
| `project-resolve.ps1` | Win | Active project resolution + slug management |

### Hooks (Auto-Trigger)

| Hook | Trigger | Action |
|------|---------|--------|
| `self-heal.ps1` | After Edit/Write | Check types → LLM suggest fix |
| `eval-gate.ps1` | After editing test files | Auto-run tests → LLM analyze |
| `instinct-extract.ps1` | Session end | Session log → LLM pattern extraction → save to knowledge |
| `proactive-research.ps1` | Before Edit/Write | Unknown library detection → LLM research → save |

## llm-adapter.ps1

Ollama API wrapper dengan `num_gpu=99` untuk 100% GPU. Function utama:

| Function | Input | Output |
|----------|-------|--------|
| `Invoke-LLM` | Prompt, Model, System | Response object |
| `Invoke-LLMEnrich` | Text, Context | Enriched text |
| `Invoke-LLMChunk` | Large text | Chunked results |
| `Get-OperatingMode` | — | eco/balanced/performance |
| `Get-GPUInfo` | — | nvidia-smi data |

Auto-logging ke `.opencode/llm-usage.jsonl` + sesi token counter.

## llm-mode.ps1

3-mode operating system toggle.

```powershell
.\scripts\llm-mode.ps1 eco          # Unload VRAM, 0 GPU
.\scripts\llm-mode.ps1 balanced     # qwen3:1.7b-s GPU ~1.5GB
.\scripts\llm-mode.ps1 performance  # qwen2.5-coder:3b-s GPU ~2GB
.\scripts\llm-mode.ps1 status       # Cek mode + VRAM + model
```

Ollama mode file: `.opencode/llm-mode.json`

## intent-compiler.ps1

Natural language → structured JSON spec.

```powershell
.\scripts\intent-compiler.ps1 -Query "buat CRUD penduduk desa" -Mode on
```

Dual path: LLM (qwen3, JSON kaya) / Regex (instant, dasar).
Auto-fallback ke regex kalo LLM timeout/gagal.

Output JSON: `domain`, `module`, `features`, `validation`, `roles`, `security`, `stack_hint`, `crud_entities`, `estimated_hours`, `confidence`.

## skill-router.ps1

Select 3-10 relevant ECC skills dari intent.

```powershell
.\scripts\skill-router.ps1 -Query "PHP MySQL web desa" -Mode auto
```

LLM path: pilih skills by reasoning.
Regex path: match keyword by stack/domain.

## setup.ps1 / setup.sh

Full setup dari nol.

```powershell
.\scripts\setup.ps1
```

**Yang dilakukan:**
1. Pre-flight checks (Node.js, npm, git)
2. Clone ECC + 9Router repos
3. Install dependencies
4. Build OpenCode plugin
5. Generate config
6. Copy rules
7. Set environment variables
8. Start 9Router

## install.ps1 / install.sh

Quick re-apply config.

```powershell
.\scripts\install.ps1 -Profile gratis
.\scripts\install.ps1 -Profile go
```

**Opsi:**
- `-Profile gratis|go` — Pilih profile
- `-SyncFirst` — Sync changelog dulu

## start.ps1 / start.sh

Daily workflow. Session-aware + auto-heal + auto-update.

```powershell
.\scripts\start.ps1 -Profile gratis
.\scripts\start.ps1 -Profile go
```

**Yang dilakukan:**
1. Set `$env:OLLAMA_KEEP_ALIVE = "-1"` (model stay di VRAM)
2. Self-healing check (9Router, ECC, plugin, session)
3. Auto-update (pull ECC/9Router, rebuild plugin)
4. Check repos
5. Sync changelog
6. Test models
7. Apply profile
8. Save session

## Lihat Juga

- [Commands](01-commands.md) — Referensi commands
- [LLM Pipeline](../02-architecture/05-llm-pipeline.md) — Detail arsitektur preprocessing
- [Daily Workflow](03-daily-workflow.md) — Rutinitas harian

