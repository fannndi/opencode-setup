# Commands — Referensi

## Command Utama

| Command | Agent | Fungsi |
|---------|-------|--------|
| `/plan` | planner | Buat rencana implementasi |
| `/tdd` | tdd-guide | Jalankan TDD workflow |
| `/code-review` | code-reviewer | Review kode |
| `/security-scan` | security-reviewer | Security review (OWASP) |
| `/build-fix` | build-error-resolver | Fix build errors |
| `/e2e` | e2e-runner | E2E testing |
| `/verify` | — | Verification loop |

## Workflow Commands

| Command | Fungsi |
|---------|--------|
| `/analyze-project` | Deteksi stack project |
| `/start-free` | Daily workflow (gratis) |
| `/start-go` | Daily workflow (go) |

## Language-Specific

| Command | Bahasa |
|---------|--------|
| `/go-review` | Go code review |
| `/go-test` | Go TDD |
| `/go-build` | Fix Go build errors |

## Development Commands

| Command | Fungsi |
|---------|--------|
| `/orchestrate` | Multi-agent workflow |
| `/learn` | Extract patterns |
| `/checkpoint` | Save progress |
| `/eval` | Evaluation |
| `/skill-create` | Generate skills |

## Contoh Penggunaan

### Buat Rencana

```
/plan tambahkan fitur autentikasi dengan JWT
```

### TDD

```
/tdd buat function untuk menghitung total harga
```

### Code Review

```
/code-review src/api/auth.ts
```

### Security Review

```
/security-scan src/api/users.ts
```

### Fix Build Error

```
/build-fix error: Type 'string' is not assignable to type 'number'
```

## Cara Kerja

1. User ketik command di OpenCode
2. OpenCode load command template
3. Template panggil agent spesifik
4. Agent eksekusi dengan skills yang sesuai
5. Hasil ditampilkan ke user

## Lihat Juga

- [Scripts](02-scripts.md) — Script automation
- [Daily Workflow](03-daily-workflow.md) — Rutinitas harian
- [Analyze Project](04-analyze-project.md) — Deteksi stack
