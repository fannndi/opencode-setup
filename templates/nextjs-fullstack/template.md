# Template: Next.js Fullstack

## Stack
- **Language:** TypeScript
- **Framework:** Next.js 14+ (App Router)
- **Database:** Prisma + PostgreSQL
- **Auth:** NextAuth.js
- **Styling:** Tailwind CSS

## Project Structure

```
app/
├── layout.tsx
├── page.tsx
├── (auth)/
│   ├── login/
│   │   └── page.tsx
│   └── register/
│       └── page.tsx
├── (dashboard)/
│   ├── layout.tsx
│   └── page.tsx
├── api/
│   └── [resource]/
│       └── route.ts
components/
├── ui/
├── forms/
└── layout/
lib/
├── prisma.ts
├── auth.ts
└── utils.ts
prisma/
├── schema.prisma
└── migrations/
```

## Docs Structure

```
docs/
├── frontend/
│   ├── architecture.md          # Next.js App Router
│   ├── components.md            # Component library
│   ├── state-management.md      # Server/Client components
│   └── styling.md               # Tailwind config
├── backend/
│   ├── api-routes.md            # API design
│   ├── auth.md                  # NextAuth setup
│   └── prisma.md                # ORM patterns
└── database/
    ├── schema.md                # Prisma schema
    └── seeding.md               # Database seeding
```

## Skills to Load

- `frontend-patterns` — React/Next.js patterns
- `backend-patterns` — API patterns
- `nextjs-turbopack` — Turbopack
- `tdd-workflow` — TDD
- `security-review` — Security
- `coding-standards` — Standards
- `verification-loop` — Verification

## Rules

- `common` — Universal
- `typescript` — TypeScript
- `web` — Web conventions
- `react` — React patterns

## Agents

| Agent | Use |
|-------|-----|
| tdd-guide | Write tests first |
| code-reviewer | Review React code |
| security-reviewer | Auth + API security |
| build-error-resolver | Fix build errors |
| database-reviewer | Prisma/SQL |
