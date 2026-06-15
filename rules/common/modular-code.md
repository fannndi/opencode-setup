---
description: "Enforce modular architecture — short, compatible, efficient, easy-maintain code. Every file one job, every function one reason."
---

# Modular Code Rule

## Principles

1. **Single Responsibility** — setiap file/function satu tanggung jawab. Max 50 lines per function, 500 per file.

2. **Short & Compatible** — kode minimal tanpa bloat. Prefer standard library over dependencies. Cross-platform.

3. **Efficient** — O(n) over O(n²). Avoid premature optimization, no hidden perf traps.

4. **Easy Maintenance** — naming jelas, logic lurus. If need comment to explain → refactor.

5. **Context-Fit** — max ~1000 chars per file (soft), 1500 chars (hard max).
   Tiap file harus muat dalam LLM context window (balanced: 1500 tokens, performance: 800 tokens).
   Jika >1500 chars: wajib split ke sub-file atau sub-modul.

## Structure Pattern

```
project/
├── core/          # Business logic (no framework coupling)
├── adapters/      # External integrations (DB, API, filesystem)
├── modules/       # Fitur per domain (self-contained)
│   └── auth/
│       ├── login.ps1      # satu fungsi login
│       ├── logout.ps1     # satu fungsi logout
│       ├── register.ps1   # satu fungsi register
│       ├── test/
│       │   ├── login.test.ps1
│       │   └── logout.test.ps1
│       └── index.ps1      # . source semua, export functions
└── shared/        # Utilities cross-module
```

## Dependency Tracking

Tiap file harus annotate:

```powershell
# Requires: module/user/validate.ps1 (Validate-Email)
# Exports: Login-Attempt
```

## File Limits

- Max 5 sub-file per direktori. Jika >5, grouping ke sub-direktori.
- Tiap direktori wajib punya `index.ps1` yang . source semua file di dalamnya.
- Boilerplate helper: `create-function.ps1` generates template otomatis.

## Anti-Patterns

- **God objects**: satu file handle semuanya → split.
- **Deep coupling**: Module A call internal Module B langsung → use interface.
- **Copy-paste reuse**: extract to shared.
- **Zombie code**: fitur unused still there → delete.
- **Hidden side effects**: function ubah global state tanpa kasih tau.
