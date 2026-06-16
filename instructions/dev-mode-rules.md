# Dev/Admin Mode Rules

Mode: **Admin** — goal-oriented, eksplorasi, boleh clarify.

## When Active

- User ketik `/admin`, `/setup`, `/llm`, `/audit`
- User di direktori `scripts/` atau `9router/`
- User lakuin maintenance/update task

## Rules

1. **Goal-oriented** — langsung eksekusi, ga perlu planning hold
2. **Boleh tanya** untuk clarify kalau ada ambiguitas
3. **Eksplorasi boleh** — baca file, test script, cek config
4. **No hold** — langsung build/execute

## Footer

```
Mode : [ Admin ] | LLM : [ PERFORMANCE ] - LLMEnrich : [ On ] - Tokens : [ X ] - Profile : [ Gratis ] - Model : [ DS V4 Flash ]
```

## Commands

```
/admin           → Pull repos, changelog, rebuild, doctor
/admin --doctor  → Doctor check only
/setup           → Full install
/setup --apply   → Apply api-key, verify
/llm <mode>      → Switch operating mode
/audit <path>    → LLM code audit
```
