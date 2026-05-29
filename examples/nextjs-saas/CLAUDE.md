# NexTask — SaaS Project Management App

## What this is
NexTask is a multi-tenant SaaS app for engineering teams to track projects,
sprints, and tasks. Next.js 14 frontend, tRPC API, PostgreSQL, Stripe billing.
B2B product — each customer is a "workspace" with multiple users and projects.

## Current focus
Building the billing module — Stripe subscription tiers (Free / Pro / Team).
The workspace settings page is in progress at `src/app/(app)/settings/billing/`.

## Tech stack
Language:    TypeScript 5.x (strict mode)
Frontend:    Next.js 14 App Router, Tailwind CSS, shadcn/ui, Framer Motion
API:         tRPC v11 (no REST — all type-safe RPC)
Database:    PostgreSQL 16 via Prisma ORM 5
Auth:        Auth.js v5 (next-auth) — Google + GitHub OAuth + magic link
Billing:     Stripe (subscriptions, webhooks, customer portal)
Email:       Resend + React Email templates
Cache:       Upstash Redis (rate limiting + session cache)
Testing:     Vitest (unit/integration), Playwright (e2e)
Deploy:      Vercel (frontend), Railway (postgres + redis)
Monorepo:    pnpm workspaces — apps/web, apps/docs, packages/db, packages/ui

## Key commands
```
pnpm dev              Start web app + tRPC dev server (turbo)
pnpm dev --filter web Start only the web app
pnpm test             Run Vitest (watch mode)
pnpm test:e2e         Run Playwright suite (needs dev server running)
pnpm typecheck        tsc --noEmit across all packages
pnpm lint:fix         ESLint + Prettier across all packages
pnpm db:push          Prisma migrate dev (packages/db)
pnpm db:seed          Seed with demo workspace + users
pnpm db:studio        Open Prisma Studio on :5555
pnpm build            Build all apps and packages
pnpm stripe:listen    Forward Stripe webhooks to localhost (needs Stripe CLI)
```

## Key paths
```
apps/web/                     Main Next.js application
apps/web/src/app/             App Router pages and layouts
apps/web/src/app/(auth)/      Auth pages — login, register, verify
apps/web/src/app/(app)/       Authenticated app shell
apps/web/src/app/(app)/[workspaceSlug]/  Per-workspace routes
apps/web/src/components/      Shared React components
apps/web/src/lib/             Client-side utilities
apps/web/src/server/          tRPC routers and procedures

packages/db/                  Prisma schema, migrations, query helpers
packages/db/prisma/schema.prisma  Source of truth for data model
packages/ui/                  Shared design system components
packages/ui/src/components/   Badge, Button, Card, Dialog, etc.

docs/specs/                   Feature specs — READ before implementing
docs/architecture/            System diagrams, data model docs
.claude/agents/               Specialist sub-agents
.claude/skills/               How-to guides for complex tasks
```

## Multi-tenant data model (critical — read this)
Every piece of user data is scoped to a `Workspace`. The data access pattern is:

```
User → WorkspaceMember → Workspace → (Projects, Tasks, etc.)
```

- Always filter queries by `workspaceId` — never return cross-workspace data
- Get the current workspace from `ctx.workspace` in tRPC procedures (injected by middleware)
- The workspace slug is in the URL: `/:workspaceSlug/projects`
- Workspace owners have role `OWNER`, admins `ADMIN`, everyone else `MEMBER`
- Check `ctx.member.role` before any write operation — don't just check auth

## Conventions

### Files and naming
- tRPC routers: `src/server/routers/[resource].ts` — one router per resource
- React components: PascalCase, co-located with their stories and tests
- Server actions: `src/app/(app)/[feature]/actions.ts`
- Zod schemas: defined in `packages/db/src/schemas/[resource].ts` and imported everywhere

### TypeScript
- No `any` — use `unknown` + type assertion or proper generics
- Use `@/` for `apps/web/src` imports, `@nexttask/db` for DB package
- All tRPC inputs validated with Zod — the schema is the contract
- Derive types from Prisma: `Prisma.TaskGetPayload<{ include: ... }>`

### tRPC
- Procedures: `publicProcedure` for unauth, `protectedProcedure` for auth, `workspaceProcedure` for workspace-scoped
- Always use `workspaceProcedure` for anything inside `/(app)/[workspaceSlug]/`
- Mutations invalidate their own query key via `utils.[router].[query].invalidate()`

### Database
- All relations use UUID primary keys
- Soft delete via `deletedAt` timestamp — never hard delete user data
- Indexes on all foreign keys and any field used in WHERE clauses
- Use `packages/db/src/helpers/` for common query patterns

### Git
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `test:`
- Branch: `type/TICKET-short-desc` (e.g. `feat/NXT-142-billing-page`)
- PR description must link the Linear ticket

## Never do
- NEVER query across workspaces — every DB query must include `workspaceId`
- NEVER use `publicProcedure` for anything that touches user or workspace data
- NEVER hard-delete records — use soft delete (`deletedAt`)
- NEVER commit Stripe secret keys or webhook secrets — use env vars
- NEVER use `useEffect` for data fetching — use tRPC queries or server components
- NEVER modify `packages/db/prisma/schema.prisma` without running a migration
- NEVER skip role checks on write operations

## Always do
- Run `pnpm typecheck` after every file change
- Check `docs/specs/` for a spec before starting a feature
- Add the `workspaceId` filter to every Prisma query
- Write Zod schemas in `packages/db/src/schemas/` — not inline in routers
- Test Stripe webhooks locally with `pnpm stripe:listen` before pushing
- Use `packages/ui/` components before building new ones from scratch

## Workflow for larger tasks
1. Check `docs/specs/` for an existing spec
2. Check Linear for the ticket — note acceptance criteria
3. Confirm data model impact (schema changes?) before coding
4. For billing work: test with Stripe test mode keys, verify webhook handling
5. Run full typecheck + test suite before marking done
6. Multi-tenant safety check: did every new query include `workspaceId`?

## Environment setup
```bash
cp apps/web/.env.example apps/web/.env.local
docker compose up -d        # postgres + redis
pnpm db:push && pnpm db:seed
pnpm stripe:listen &        # separate terminal
pnpm dev
```

See `docs/architecture/setup.md` for OAuth app setup (Google, GitHub).
