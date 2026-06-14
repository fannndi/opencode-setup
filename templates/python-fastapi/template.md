# Template: Python FastAPI

## Stack
- **Language:** Python
- **Framework:** FastAPI
- **Database:** PostgreSQL + SQLAlchemy
- **Auth:** OAuth2 + JWT
- **Validation:** Pydantic v2

## Project Structure

```
app/
├── main.py
├── config.py
├── dependencies.py
├── models/
│   └── [entity].py
├── schemas/
│   └── [entity].py
├── api/
│   └── v1/
│       └── [resource].py
├── crud/
│   └── [entity].py
├── services/
│   └── [entity]_service.py
└── utils/
    └── security.py
tests/
├── conftest.py
├── test_api/
├── test_crud/
└── test_services/
alembic/
├── versions/
└── env.py
```

## Docs Structure

```
docs/
├── api/
│   ├── endpoints.md             # API endpoints
│   ├── auth.md                  # OAuth2 + JWT
│   └── validation.md            # Pydantic schemas
├── database/
│   ├── schema.md                # SQLAlchemy models
│   ├── migrations.md            # Alembic
│   └── indexing.md               # Query optimization
└── deployment/
    └── docker.md                # Docker setup
```

## Skills to Load

- `python-patterns` — Python patterns
- `python-testing` — pytest
- `fastapi-patterns` — FastAPI patterns
- `tdd-workflow` — TDD
- `security-review` — Security
- `coding-standards` — Standards
- `verification-loop` — Verification

## Rules

- `common` — Universal
- `python` — Python conventions

## Agents

| Agent | Use |
|-------|-----|
| tdd-guide | Write tests first |
| code-reviewer | Review Python code |
| security-reviewer | JWT + API security |
| python-reviewer | Python-specific review |
| database-reviewer | SQL queries |
