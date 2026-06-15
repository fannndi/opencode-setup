---
description: "Parallel execution pattern — dispatch independent task agents, batch by domain, merge results, avoid dependency conflicts."
---

# Parallel Execution Rule

## Kapan

- 3+ file independent (gak saling share dependency)
- Edit massal (rename, refactor batch)
- Review paralel + fix paralel
- Research + implementasi bareng

## Batasan

- Max 4 agents paralel (context window limit)
- Wajib ada merge step setelah semua selesai — cek conflict
- File dependen JANGAN diparallel (A depends on B → A nunggu B)
- GPU 1 LLM — parallelism = file ops, bukan LLM parallel

## Workflow Pattern

```
1. Identify independent files → group by domain
2. Each group independent? → Dispatch agent per group
3. Wait all results (via task tool)
4. Merge + conflict check
5. Consistency verify
```

## Contoh Perintah

```
"edit 3 hooks paralel — masing-masing tambah Invoke-LLMEnrich"
"batch fix 5 scripts — semua pake Get-OperatingMode di awal"
"research + implement bareng — cari library + tulis test"
```

## Merge Check

Setelah semua agent selesai, lakukan:

```powershell
git diff --stat          # Cek conflict scope
git diff --check         # Cek merge conflict markers
foreach file in changed: # Verify logic konsisten
```

Jika conflict: solve manual, jangan paksa merge.
