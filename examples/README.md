# Examples

Each example is a complete, working `.claude/` configuration for a real-world
project type. Browse them to see how the boilerplate is adapted in practice —
different stacks, different agents, different hook rules, different skills.

**→ [SETUP.md](./SETUP.md)** — full step-by-step instructions to run either example project locally with Claude Code fully configured.

---

## Available examples

### [`nextjs-saas/`](./nextjs-saas)
**Multi-tenant SaaS app** — Next.js 14, tRPC, Prisma, Stripe billing

Highlights:
- Pre-tool hook warns when Prisma queries are missing `workspaceId` (multi-tenant safety)
- Post-tool hook auto-regenerates Prisma client on `schema.prisma` changes
- `trpc.md` agent enforces the three-tier procedure system (`publicProcedure` / `protectedProcedure` / `workspaceProcedure`)
- `billing.md` agent knows all 5 Stripe webhook events and safety rules
- `create-trpc-router` skill: schema → router → merge → client in one workflow
- Real billing feature spec with schema changes, API surface, and open questions

**Good reference for:** TypeScript monorepos, SaaS data scoping, payment integrations

---

### [`python-api/`](./python-api)
**ML-powered async API** — FastAPI, SQLAlchemy 2 (async), Celery, scikit-learn

Highlights:
- Pre-tool hook blocks edits to committed Alembic migration files
- Post-tool hook runs `ruff` + `mypy` automatically on every Python file write
- `sqlalchemy.md` agent enforces async ORM patterns and the repository layer
- `celery-tasks.md` agent knows idempotency patterns, retry config, and when to use tasks vs inline
- `create-endpoint` skill: Pydantic schemas → repository → handler → pytest tests
- Real async migration spec (sync endpoint → Celery task) with polling + webhook delivery

**Good reference for:** Python APIs, async patterns, ML pipelines, background job systems

---

## How to use these examples

These are reference configurations — not runnable projects. Each directory contains:

- `CLAUDE.md` — filled-in context file for that project type
- `.claude/settings.json` — toolchain-specific permissions
- `.claude/hooks/` — lifecycle hooks tuned for the stack
- `.claude/agents/` — domain-specific sub-agents
- `.claude/skills/` — how-to guides for common tasks
- `docs/specs/` — example feature specs
- `.env.example` — documented environment variables

**To adapt one for your project:**
1. Copy the `.claude/` directory into your project
2. Replace `CLAUDE.md` with your actual project context
3. Update `settings.json` allow/deny lists for your toolchain
4. Edit agent files to match your stack and conventions
5. Extend or replace skills with your own how-to guides

---

## Contributing an example

Good examples are for **real project archetypes** — not toy demos. A strong example has:

- A `CLAUDE.md` that reflects real production conventions (not generic advice)
- Hooks that enforce domain-specific rules (not just the default dangerous-command blocks)
- At least one domain agent that a generic reviewer/tester couldn't replace
- At least one skill for a task that's genuinely tricky or multi-step in that stack
- A real-looking feature spec in `docs/specs/`

See [CONTRIBUTING.md](../CONTRIBUTING.md) for how to submit.
