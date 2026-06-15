---
description: "Enforce modular architecture — short, compatible, efficient, easy-maintain code. Every file one job, every function one reason."
---

# Modular Code Rule

## Principles

1. **Single Responsibility** — setiap file/function satu tanggung jawab. Max 50 lines per function, 500 per file.

2. **Short & Compatible** — kode minimal tanpa bloat. Prefer standard library over dependencies. Cross-platform.

3. **Efficient** — O(n) over O(n²). Avoid premature optimization, no hidden perf traps.

4. **Easy Maintenance** — naming jelas, logic lurus. If need comment to explain → refactor.

## Structure Pattern

```
project/
├── core/          # Business logic (no framework coupling)
├── adapters/      # External integrations (DB, API, filesystem)
├── modules/       # Fitur per domain (self-contained)
└── shared/        # Utilities cross-module
```

## Anti-Patterns

- **God objects**: satu file handle semuanya → split.
- **Deep coupling**: Module A call internal Module B langsung → use interface.
- **Copy-paste reuse**: extract to shared.
- **Zombie code**: fitur unused still there → delete.
- **Hidden side effects**: function ubah global state tanpa kasih tau.
