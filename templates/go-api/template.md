# Template: Go API

## Stack
- **Language:** Go
- **Framework:** Standard library / Gin / Fiber
- **Database:** PostgreSQL
- **Auth:** JWT

## Project Structure

```
cmd/
├── server/
│   └── main.go
internal/
├── config/
│   └── config.go
├── handler/
│   └── [resource].go
├── middleware/
│   └── auth.go
├── model/
│   └── [entity].go
├── repository/
│   └── [entity]_repo.go
├── service/
│   └── [entity]_service.go
└── utils/
    └── response.go
migrations/
├── 001_initial.up.sql
└── 001_initial.down.sql
```

## Docs Structure

```
docs/
├── api/
│   ├── endpoints.md             # API endpoints
│   ├── auth.md                  # Authentication
│   └── error-handling.md        # Error responses
├── database/
│   ├── schema.md                # Database schema
│   ├── migrations.md            # Migration strategy
│   └── indexing.md               # Index optimization
└── deployment/
    └── docker.md                # Docker setup
```

## Skills to Load

- `golang-patterns` — Go patterns
- `golang-testing` — Go testing
- `tdd-workflow` — TDD
- `security-review` — Security
- `coding-standards` — Standards
- `verification-loop` — Verification

## Rules

- `common` — Universal
- `golang` — Go conventions

## Agents

| Agent | Use |
|-------|-----|
| tdd-guide | Write tests first |
| code-reviewer | Review Go code |
| security-reviewer | JWT + API security |
| go-reviewer | Go-specific review |
| go-build-resolver | Fix Go build errors |
| database-reviewer | SQL queries |
