# ECC — Everything Claude Code

## Apa Itu ECC?

ECC (Everything Claude Code) adalah kumpulan knowledge base yang membuat OpenCode menjadi asisten coding yang lebih pintar.

## Komponen ECC

### Skills (270)

Knowledge base per bahasa/framework. Setiap skill berisi:
- Best practices
- Code patterns
- Anti-patterns
- Contoh kode

**Kategori:**

| Kategori | Jumlah | Contoh |
|----------|--------|--------|
| Language | 29 | python-patterns, golang-patterns |
| Framework | 42 | react-patterns, django-patterns |
| Workflow | 41 | tdd-workflow, verification-loop |
| Domain | 77 | security-review, api-design |
| Tool | 31 | 9router-*, docker-patterns |
| Meta | 50 | blueprint, orchestration |

### Agents (64)

AI assistant spesialis yang bisa dipanggil via command.

| Agent | Fungsi |
|-------|--------|
| planner | Perencanaan implementasi |
| architect | Desain arsitektur |
| code-reviewer | Review kode |
| security-reviewer | Review keamanan |
| tdd-guide | Test-driven development |
| build-error-resolver | Fix build errors |
| e2e-runner | E2E testing |
| refactor-cleaner | Cleanup kode |
| doc-updater | Update dokumentasi |

### Commands (84)

Perintah slash yang tersedia di OpenCode.

| Command | Fungsi |
|---------|--------|
| `/plan` | Buat rencana implementasi |
| `/tdd` | Jalankan TDD workflow |
| `/code-review` | Review kode |
| `/security-scan` | Security review |
| `/build-fix` | Fix build errors |
| `/verify` | Verification loop |
| `/analyze-project` | Deteksi stack project |
| `/start-free` | Daily workflow (gratis) |
| `/start-go` | Daily workflow (go) |

### Hooks (20+)

Otomasi yang jalan sebelum/sesudah tool execution.

| Hook | Kapan |
|------|-------|
| `pre:bash:dispatcher` | Sebelum bash command |
| `post:quality-gate` | Sesudah edit file |
| `stop:format-typecheck` | Sesudah response selesai |
| `session:start` | Saat session dimulai |

### Rules (20 pack)

Konvensi coding per bahasa/framework.

| Pack | Bahasa |
|------|--------|
| `common` | Universal |
| `typescript` | TypeScript/JavaScript |
| `python` | Python |
| `golang` | Go |
| `rust` | Rust |
| `dart` | Dart/Flutter |
| `react` | React |
| `java` | Java |
| `kotlin` | Kotlin |
| `swift` | Swift |

## Cara Kerja

1. OpenCode mendeteksi project type
2. Load skills yang sesuai
3. Agent membantu berdasarkan skills
4. Commands memudahkan aksi

## Lihat Juga

- [Overview](01-overview.md) — Arsitektur lengkap
- [Skill Selection](../05-skills/01-skill-selection.md) — Cara memilih skills
- [Features](../06-catalogs/01-features.md) — Katalog lengkap
