# my-project

## What this is
<!-- TODO: one paragraph describing what this project does and who uses it -->
Example: A TypeScript monorepo — Next.js frontend, Express API, PostgreSQL.

## Current focus
<!-- TODO: what is actively being worked on right now? -->
Example: Building out the user authentication flow.

## Tech stack
<!-- TODO: fill in your actual stack -->
Language:   TypeScript 5.x (strict mode)
Frontend:   Next.js 14, Tailwind CSS, shadcn/ui
Backend:    Express 4, Zod validation
Database:   PostgreSQL via Prisma ORM
Cache:      Redis (ioredis)
Testing:    Vitest (unit), Playwright (e2e)
Deploy:     Docker → Railway (staging), Render (prod)

## Key commands
```
pnpm dev          Start all services (frontend + API)
pnpm test         Run Vitest in watch mode
pnpm test:e2e     Run Playwright suite
pnpm typecheck    tsc --noEmit (run after every edit)
pnpm lint:fix     ESLint + Prettier
pnpm db:push      Prisma migrate dev
pnpm db:seed      Seed development database
pnpm build        Production build
```

## Key paths
```
src/app/           Next.js pages and layouts
src/components/    Shared React components
src/lib/           Utilities and helpers
src/server/        Express routes and middleware
src/db/            Prisma schema and query helpers
src/types/         Shared TypeScript interfaces
docs/specs/        Feature specs — READ before implementing
docs/architecture/ System design and ADRs
.claude/agents/    Specialist sub-agents
.claude/skills/    How-to guides for complex tasks
```

## Conventions

### Files and naming
- Components: PascalCase (`UserCard.tsx`)
- Utilities: camelCase (`formatCurrency.ts`)
- Tests: co-located with source (`UserCard.test.tsx`)
- Constants: SCREAMING_SNAKE_CASE in `src/lib/constants.ts`

### TypeScript
- Strict mode is on — no `any`, use `unknown` + type assertion
- Prefer `const` arrow functions over `function` declarations
- Use `@/` path alias for all cross-directory imports
- Export types separately from implementations

### React
- Server components by default; add `'use client'` only when needed
- Use the `cn()` helper for conditional class merging
- All forms validated with Zod before submission

### API
- Validate all input with Zod schema before touching the database
- Return consistent `{ data, error }` shape from all endpoints
- HTTP errors: 400 bad input, 401 unauth, 403 forbidden, 404 not found

### Git
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`
- Branch format: `type/TICKET-short-description`
- No direct commits to `main`

## Never do
- Do NOT edit files in `src/legacy/` — deprecated, ships next week
- Do NOT use `var` or CommonJS `require()`
- Do NOT store secrets in source code — use `process.env` only
- Do NOT use `console.log` in production code — use the `logger` util
- Do NOT install new packages without confirming with the user first
- Do NOT push directly to `main` or `production`
- Do NOT modify `prisma/schema.prisma` without running `db:push` after

## Always do
- Run `pnpm typecheck` after every file change
- Write or update tests alongside new features
- Add JSDoc comments to all exported functions
- Check `docs/specs/` for a spec before implementing a feature
- Use the existing `logger` util (`src/lib/logger.ts`) for all logging
- Validate environment variables via `src/lib/env.ts` before use

## Workflow for larger tasks
1. Read the spec in `docs/specs/` if one exists
2. Check for existing utilities/types before creating new ones
3. Confirm approach with user for tasks estimated >30 minutes
4. Make small, focused commits — one logical change per commit
5. Run typecheck + tests before marking a task done
6. If stuck or blocked, stop and ask rather than guess

## Environment setup
Copy `.env.example` → `.env.local` and fill in values.
See `docs/architecture/setup.md` for local database instructions.
