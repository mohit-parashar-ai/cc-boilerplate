# Example: Next.js SaaS (NexTask)

This example shows how to configure Claude Code for a **multi-tenant SaaS
monorepo** built with Next.js 14, tRPC, Prisma, and Stripe billing.

> **→ [Full setup guide](../SETUP.md#nextjs-saas-nextask)** — step-by-step instructions to run this project locally with Claude Code.

## What makes this example interesting

**Multi-tenant safety hooks** — the `pre-tool-use.sh` hook warns when Claude
writes a Prisma query that might be missing a `workspaceId` filter, catching
the most common and costly mistake in multi-tenant apps before the code is run.

**Prisma auto-regeneration** — the `post-tool-use.sh` hook detects changes to
`schema.prisma` and automatically runs `prisma generate` so the TypeScript
types stay in sync without a manual step.

**Domain-specific agents** — beyond the generic reviewer/tester, this example
adds a `trpc.md` agent that knows the three-tier procedure system
(`publicProcedure` / `protectedProcedure` / `workspaceProcedure`) and enforces
correct usage, and a `billing.md` agent that knows the full Stripe webhook
event set and safety rules.

**Monorepo-aware settings** — `settings.json` adds `turbo *` to the allow list
and disables Turbo telemetry via env injection.

**Real spec** — `docs/specs/billing-subscriptions.md` shows what a
production-quality feature spec looks like: schema changes, API changes,
component plan, acceptance criteria, open questions.

## Files in this example

```
CLAUDE.md                              Project context — multi-tenant model explained
.env.example                           All env vars with descriptions
.claude/
  settings.json                        Permissions + Stripe CLI + Turbo allowed
  hooks/
    pre-tool-use.sh                    Blocks Stripe key exposure, warns on missing workspaceId
    post-tool-use.sh                   Auto-runs prisma generate on schema changes
  agents/
    trpc.md                            tRPC procedure types, router template, client usage
    billing.md                         Stripe webhooks, feature gating, test commands
  skills/
    create-trpc-router/SKILL.md        Step-by-step: schema → router → merge → client
docs/
  specs/billing-subscriptions.md      Real feature spec for the billing module
```

## Key things to adapt for your project

- Replace the multi-tenant `workspaceId` pattern with your own data scoping model
- Update OAuth provider list in `.env.example` for your auth setup
- Swap Stripe price IDs and plan names in `billing.md`
- Add your own domain-specific agents for the parts of your stack that need them
