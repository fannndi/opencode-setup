---
description: Universal — preprocess input, then execute with enriched context
---

# Go

Universal development command: input → preprocess → enriched context → execute.

## Flow

```powershell
.\scripts\llm-preprocess.ps1 -Query "$ARGUMENTS"
```

Preprocessor akan:
1. Detect stack project (file scanning)
2. Match skill index (270 skills) → recommend relevant
3. Match feature index (600+ features) → suggest reuse
4. Search memory (related sessions)
5. Search knowledge (patterns)
6. Intent compile → structured spec
7. Skill route → 5-10 relevant skills

Output enriched context siap pakai.

## Eco Mode (LLM OFF)

Tanpa LLM tetap kerja — pake regex fallback.

## Task

$ARGUMENTS
