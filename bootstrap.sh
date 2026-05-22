#!/usr/bin/env bash
# =============================================================================
#  Claude Code Boilerplate Bootstrap
#  Run: bash bootstrap.sh [project-name]
#  Creates the full .claude/ productivity scaffold in your project directory.
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'; RESET='\033[0m'
GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; RED='\033[0;31m'

info()    { echo -e "${CYAN}→${RESET} $*"; }
success() { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

# ── Arguments ────────────────────────────────────────────────────────────────
PROJECT_NAME="${1:-my-project}"
TARGET_DIR="$(pwd)"

header "Claude Code Boilerplate"
echo "  Project : ${PROJECT_NAME}"
echo "  Target  : ${TARGET_DIR}"
echo ""

read -rp "Bootstrap here? [y/N] " confirm
[[ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" == "y" ]] || { echo "Aborted."; exit 0; }

# =============================================================================
#  HELPER — write file, create parent dirs automatically
# =============================================================================
write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  cat > "$path" <<'HEREDOC_END'
HEREDOC_END
  # Overwrite with actual content passed via stdin
  cat > "$path"
  success "$path"
}

# We use a different approach: define content inline per file
mf() {                      # make_file path content
  local fpath="$1"; shift
  mkdir -p "$(dirname "$fpath")"
  printf '%s' "$1" > "$fpath"
  success "$fpath"
}

# =============================================================================
#  1. CLAUDE.md  (root — always loaded)
# =============================================================================
header "1/8  CLAUDE.md"

mf "CLAUDE.md" "# ${PROJECT_NAME}

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
\`\`\`
pnpm dev          Start all services (frontend + API)
pnpm test         Run Vitest in watch mode
pnpm test:e2e     Run Playwright suite
pnpm typecheck    tsc --noEmit (run after every edit)
pnpm lint:fix     ESLint + Prettier
pnpm db:push      Prisma migrate dev
pnpm db:seed      Seed development database
pnpm build        Production build
\`\`\`

## Key paths
\`\`\`
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
\`\`\`

## Conventions

### Files and naming
- Components: PascalCase (\`UserCard.tsx\`)
- Utilities: camelCase (\`formatCurrency.ts\`)
- Tests: co-located with source (\`UserCard.test.tsx\`)
- Constants: SCREAMING_SNAKE_CASE in \`src/lib/constants.ts\`

### TypeScript
- Strict mode is on — no \`any\`, use \`unknown\` + type assertion
- Prefer \`const\` arrow functions over \`function\` declarations
- Use \`@/\` path alias for all cross-directory imports
- Export types separately from implementations

### React
- Server components by default; add \`'use client'\` only when needed
- Use the \`cn()\` helper for conditional class merging
- All forms validated with Zod before submission

### API
- Validate all input with Zod schema before touching the database
- Return consistent \`{ data, error }\` shape from all endpoints
- HTTP errors: 400 bad input, 401 unauth, 403 forbidden, 404 not found

### Git
- Conventional commits: \`feat:\`, \`fix:\`, \`chore:\`, \`docs:\`, \`test:\`
- Branch format: \`type/TICKET-short-description\`
- No direct commits to \`main\`

## Never do
- Do NOT edit files in \`src/legacy/\` — deprecated, ships next week
- Do NOT use \`var\` or CommonJS \`require()\`
- Do NOT store secrets in source code — use \`process.env\` only
- Do NOT use \`console.log\` in production code — use the \`logger\` util
- Do NOT install new packages without confirming with the user first
- Do NOT push directly to \`main\` or \`production\`
- Do NOT modify \`prisma/schema.prisma\` without running \`db:push\` after

## Always do
- Run \`pnpm typecheck\` after every file change
- Write or update tests alongside new features
- Add JSDoc comments to all exported functions
- Check \`docs/specs/\` for a spec before implementing a feature
- Use the existing \`logger\` util (\`src/lib/logger.ts\`) for all logging
- Validate environment variables via \`src/lib/env.ts\` before use

## Workflow for larger tasks
1. Read the spec in \`docs/specs/\` if one exists
2. Check for existing utilities/types before creating new ones
3. Confirm approach with user for tasks estimated >30 minutes
4. Make small, focused commits — one logical change per commit
5. Run typecheck + tests before marking a task done
6. If stuck or blocked, stop and ask rather than guess

## Environment setup
Copy \`.env.example\` → \`.env.local\` and fill in values.
See \`docs/architecture/setup.md\` for local database instructions.
"

# =============================================================================
#  2. .claude/settings.json
# =============================================================================
header "2/8  .claude/settings.json"

mf ".claude/settings.json" '{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": [
      "Bash(pnpm *)",
      "Bash(npm *)",
      "Bash(npx *)",
      "Bash(node *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)",
      "Bash(git add *)",
      "Bash(git commit *)",
      "Bash(git checkout *)",
      "Bash(git branch *)",
      "Bash(git pull)",
      "Bash(git push)",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)",
      "Bash(rm *)",
      "Bash(curl -s *)",
      "Bash(docker compose *)",
      "Bash(prisma *)"
    ],
    "deny": [
      "Bash(rm -rf /)",
      "Bash(chmod 777 *)",
      "Bash(sudo *)",
      "Bash(curl * | bash)",
      "Bash(wget * | bash)",
      "Bash(npx * --yes *)"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  },
  "hooks": {
    "PostToolUse": ".claude/hooks/post-tool-use.sh",
    "PreToolUse": ".claude/hooks/pre-tool-use.sh",
    "Notification": ".claude/hooks/notification.sh",
    "Stop": ".claude/hooks/stop.sh"
  }
}
'

# =============================================================================
#  3. HOOKS
# =============================================================================
header "3/8  Hooks"

mf ".claude/hooks/pre-tool-use.sh" '#!/usr/bin/env bash
# PreToolUse hook — runs before every tool call
# Environment: TOOL_NAME, TOOL_INPUT (JSON)
# Exit 1 to BLOCK the tool call; exit 0 to allow.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# ── Block dangerous patterns in Bash calls ────────────────────────────────
if [[ "$TOOL" == "Bash" ]]; then
  CMD=$(echo "$INPUT" | grep -o '"command":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "$INPUT")

  # Block force-deletes of root or src
  if echo "$CMD" | grep -qE "rm -rf (/|~/|\./)$"; then
    echo "BLOCKED: Refusing dangerous rm -rf" >&2
    exit 1
  fi

  # Block piping remote scripts to shell
  if echo "$CMD" | grep -qE "(curl|wget).*(bash|sh)"; then
    echo "BLOCKED: Refusing remote script execution" >&2
    exit 1
  fi

  # Warn before DB destructive ops (don'\''t block, just log)
  if echo "$CMD" | grep -qiE "(drop table|truncate|delete from)"; then
    echo "WARNING: Destructive DB operation detected — proceeding" >&2
  fi
fi

exit 0
'

mf ".claude/hooks/post-tool-use.sh" '#!/usr/bin/env bash
# PostToolUse hook — runs after every tool call
# Environment: TOOL_NAME, TOOL_INPUT (JSON), TOOL_OUTPUT (JSON)

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# ── Auto-typecheck after TypeScript file writes ───────────────────────────
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" || "$TOOL" == "MultiEdit" ]]; then
  FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('\''file_path'\'',d.get('\''path'\'','\'\'')))" 2>/dev/null || true)

  if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
    echo "→ TypeScript file changed, running typecheck..." >&2
    if command -v pnpm &>/dev/null && [[ -f "package.json" ]]; then
      pnpm typecheck --noEmit 2>&1 | tail -20 || true
    fi
  fi
fi

# ── Log tool usage to session log ─────────────────────────────────────────
LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TOOL=$TOOL" >> "$LOG_DIR/session.log"

exit 0
'

mf ".claude/hooks/notification.sh" '#!/usr/bin/env bash
# Notification hook — fires when Claude sends a notification
# Environment: NOTIFICATION_TITLE, NOTIFICATION_MESSAGE

TITLE="${NOTIFICATION_TITLE:-Claude Code}"
MSG="${NOTIFICATION_MESSAGE:-Task update}"

echo "── NOTIFICATION ──────────────────────" >&2
echo "  $TITLE" >&2
echo "  $MSG" >&2
echo "──────────────────────────────────────" >&2

# macOS: uncomment to get native desktop notifications
# osascript -e "display notification \"$MSG\" with title \"$TITLE\""

# Linux (notify-send): uncomment if available
# notify-send "$TITLE" "$MSG" 2>/dev/null || true

exit 0
'

mf ".claude/hooks/stop.sh" '#!/usr/bin/env bash
# Stop hook — runs when Claude finishes a session or task
# Good place for cleanup, summaries, or post-task automation.

LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SESSION ENDED" >> "$LOG_DIR/session.log"
echo "─────────────────────────────────────────────" >> "$LOG_DIR/session.log"

# Optional: print a session summary
TOOL_COUNT=$(grep -c "TOOL=" "$LOG_DIR/session.log" 2>/dev/null || echo 0)
echo "Session complete. Tools used: $TOOL_COUNT" >&2

exit 0
'

chmod +x .claude/hooks/*.sh
success "Hook scripts made executable"

# =============================================================================
#  4. AGENTS
# =============================================================================
header "4/8  Agents"

mf ".claude/agents/reviewer.md" '# Code reviewer agent

## Role
You are a senior code reviewer. Your job is to review diffs and pull requests
for correctness, security, performance, and adherence to project conventions.

## Behaviour
- Be specific: quote the exact lines you are commenting on
- Categorise every comment: [blocker] | [suggestion] | [nit]
- Blockers must be fixed before merge; suggestions are recommended; nits are optional
- Check for: type safety, missing error handling, N+1 queries, missing tests
- Do NOT rewrite working code just for style — only flag real issues
- End every review with a summary: Approved / Approved with suggestions / Changes required

## Output format
```
## Review summary
[overall verdict and 1-sentence summary]

## Comments

### [blocker] src/server/auth.ts:42
[specific issue and why it matters]
Suggestion: [concrete fix]

### [suggestion] src/components/UserCard.tsx:18
[observation]
```

## What to always check
- All user input validated with Zod before use
- No secrets or credentials in code
- Async functions have try/catch or proper error propagation
- New features have corresponding tests
- No `any` types introduced
'

mf ".claude/agents/tester.md" '# Testing agent

## Role
You write comprehensive tests. You are given a file or feature and you produce
the test file that gives confidence the implementation is correct.

## Behaviour
- Co-locate tests next to source files (`*.test.ts` / `*.test.tsx`)
- Use Vitest for unit and integration tests
- Use Playwright for end-to-end tests under `tests/e2e/`
- Follow AAA pattern: Arrange → Act → Assert
- Test behaviour, not implementation details
- Cover: happy path, edge cases, error paths, boundary values
- Mock external services (DB, HTTP) — never hit real endpoints in unit tests
- Keep each test focused: one assertion per logical case

## Stack
- Unit/integration: Vitest + Testing Library (React)
- E2e: Playwright
- DB mocking: use the test DB helper at `src/lib/test-db.ts`
- HTTP mocking: `msw` (Mock Service Worker)

## Output format
Produce the complete test file. No explanation needed — just the code.
Start with imports, then describe blocks, then tests.
'

mf ".claude/agents/docs-writer.md" '# Documentation agent

## Role
You write clear, accurate technical documentation. You are given code, a spec,
or a feature description and you produce the appropriate documentation artifact.

## Behaviour
- Match the existing docs tone (check `docs/` before writing)
- Be concise: every sentence earns its place
- Include working code examples for anything non-trivial
- Document the why, not just the what
- For API docs: method, path, auth, request schema, response schema, errors
- For component docs: props table, usage example, accessibility notes
- Never document internal implementation details in public docs

## Output types
- `docs/specs/FEATURE.md` — spec for a planned feature
- `docs/architecture/DECISION.md` — architecture decision record (ADR)
- `README.md` updates — project-level changes
- JSDoc — inline, for exported functions and types
- `CHANGELOG.md` entries — conventional format
'

mf ".claude/agents/teams/frontend.md" '# Frontend specialist agent

## Role
UI/UX focused implementation. You build React components, pages, and client-side
features. You prioritise accessibility, performance, and visual correctness.

## Stack constraints
- Next.js 14 App Router — server components by default
- Tailwind CSS + shadcn/ui component library
- Use `cn()` helper for conditional classes
- Forms: React Hook Form + Zod resolver
- Data fetching: server components for initial load, SWR for client mutations

## Standards
- All interactive elements keyboard-accessible (WCAG AA minimum)
- Images: always `next/image` with explicit width/height
- No layout shift — reserve space for async content
- Mobile-first breakpoints: sm(640) md(768) lg(1024) xl(1280)
- Prefer CSS variables from `src/styles/tokens.css` over arbitrary values

## Never do
- Do NOT use `useEffect` for data fetching — use server components or SWR
- Do NOT inline event handlers on JSX — extract named functions
- Do NOT hardcode colours — use Tailwind tokens only
'

mf ".claude/agents/teams/backend.md" '# Backend specialist agent

## Role
API and data layer implementation. You build Express routes, database queries,
and background jobs. You prioritise correctness, security, and performance.

## Stack constraints
- Express 4 with TypeScript
- Prisma ORM for all DB access — no raw SQL unless for performance-critical paths
- Zod for all request/response validation
- Authentication: JWT via `src/lib/auth.ts` — never roll your own

## Standards
- Validate input BEFORE any DB call
- Every route must handle errors — use the `asyncHandler` wrapper
- Log with `src/lib/logger.ts` — never `console.log`
- DB queries: always select only needed fields, never `select *`
- Transactions for any multi-step DB operations
- Rate limiting on all public endpoints

## Security checklist (apply to every endpoint)
- [ ] Input validated with Zod
- [ ] Auth checked before data access
- [ ] No user-controlled data in SQL strings
- [ ] Sensitive fields excluded from responses (passwords, tokens)
- [ ] Error messages do not leak internal details
'

mf ".claude/agents/teams/devops.md" '# DevOps agent

## Role
Infrastructure, CI/CD, and deployment tasks. You manage Docker configs,
environment setup, database migrations, and deployment scripts.

## Stack
- Docker + Docker Compose for local and staging
- GitHub Actions for CI/CD
- Railway (staging) / Render (prod)
- PostgreSQL + Redis

## Principles
- Infrastructure as code — no manual console changes
- Secrets via environment variables — never in Dockerfiles or compose files
- Every deployment must be reversible (migrations must have rollback)
- Health checks on every service
- Zero-downtime deploys via rolling restarts

## Deployment checklist
- [ ] Migrations tested on staging first
- [ ] `.env` vars confirmed in target environment
- [ ] Docker image builds cleanly
- [ ] Health endpoint returns 200
- [ ] Rollback plan documented
'

# =============================================================================
#  5. COMMANDS (slash commands)
# =============================================================================
header "5/8  Commands"

mf ".claude/commands/review.md" '# /review

Review the staged changes or the file(s) I specify.

## Instructions
1. Run `git diff --staged` (or `git diff HEAD~1` if nothing staged)
2. Act as the **reviewer agent** (see `.claude/agents/reviewer.md`)
3. Output the structured review with blockers, suggestions, and nits
4. If blockers exist, ask before proceeding
5. Do NOT auto-fix — wait for confirmation on each blocker

## Usage
- `/review` — review staged changes
- `/review src/server/auth.ts` — review specific file
- `/review HEAD~3` — review last 3 commits
'

mf ".claude/commands/test.md" '# /test

Generate or update tests for the file or feature I specify.

## Instructions
1. Read the target file(s) carefully
2. Act as the **tester agent** (see `.claude/agents/tester.md`)
3. Write the complete test file — co-located next to the source
4. Run the tests with `pnpm test [file]` after writing
5. Fix any failures before reporting done

## Usage
- `/test src/lib/formatCurrency.ts` — unit tests for a utility
- `/test src/server/routes/users.ts` — integration tests for a route
- `/test checkout flow` — e2e tests for a user journey
'

mf ".claude/commands/spec.md" '# /spec

Write a feature spec for the feature I describe.

## Instructions
1. Ask me clarifying questions if the feature is ambiguous
2. Act as the **docs-writer agent**
3. Write the spec to `docs/specs/FEATURE-NAME.md`
4. Spec structure:
   - Overview (1 paragraph)
   - User stories (as a... I want... so that...)
   - Acceptance criteria (checklist)
   - Technical approach (schema changes, API changes, component changes)
   - Out of scope (explicit)
   - Open questions

## Usage
- `/spec user notifications` — spec for a new feature
'

mf ".claude/commands/commit.md" '# /commit

Create a well-formatted commit for the current staged changes.

## Instructions
1. Run `git diff --staged` to see what is staged
2. Write a conventional commit message:
   - Format: `type(scope): short description`
   - Types: feat, fix, chore, docs, test, refactor, perf
   - Subject: imperative mood, ≤72 chars, no period
   - Body (if needed): what changed and why, not how
3. Run `git commit -m "..."` with the message
4. Do NOT push unless explicitly asked

## Example output
```
feat(auth): add email verification on signup

Send a confirmation link on registration. Accounts are
inactive until the link is clicked. Adds the
verification_token field to the users table.
```
'

mf ".claude/commands/migrate.md" '# /migrate

Create and run a database migration.

## Instructions
1. Confirm the schema changes needed
2. Edit `prisma/schema.prisma` with the changes
3. Run `pnpm db:push` in development to apply
4. For production migrations, generate with `prisma migrate dev --name [name]`
5. Check the generated SQL in `prisma/migrations/` before applying
6. Update seed file if new required data is needed

## Safety rules
- Never drop a column without confirming data is backed up
- Rename = add new + migrate data + drop old (3 steps, not 1)
- All migrations must be reversible — document rollback steps
'

mf ".claude/commands/debug.md" '# /debug

Systematically debug the issue I describe.

## Instructions
1. Reproduce the issue — ask for steps if not provided
2. Read relevant error messages and stack traces carefully
3. Form a hypothesis — state it explicitly before investigating
4. Check the most likely cause first (do not shotgun)
5. Add targeted logging or use the debugger, not random console.logs
6. Once found: fix, explain root cause, suggest how to prevent recurrence

## Output format
```
## Issue
[what is happening vs what should happen]

## Root cause
[what actually caused it]

## Fix
[what was changed]

## Prevention
[how to avoid this class of bug in future]
```
'

# =============================================================================
#  6. SKILLS
# =============================================================================
header "6/8  Skills"

mf ".claude/skills/create-component/SKILL.md" '---
name: create-component
description: >
  Use this skill when creating a new React component from scratch.
  Covers file structure, TypeScript props interface, accessibility,
  Tailwind styling, and test scaffolding.
---

# Creating a React component

## Steps

### 1. Check if it already exists
```bash
find src/components -name "*.tsx" | xargs grep -l "ComponentName" 2>/dev/null
```

### 2. Create the component file
Location: `src/components/[ComponentName]/index.tsx`

```tsx
import { cn } from "@/lib/utils";

interface ComponentNameProps {
  className?: string;
  // TODO: add props
}

export function ComponentName({ className, ...props }: ComponentNameProps) {
  return (
    <div className={cn("", className)} {...props}>
      {/* content */}
    </div>
  );
}
```

### 3. Export from barrel file
Add to `src/components/index.ts`:
```ts
export { ComponentName } from "./ComponentName";
```

### 4. Scaffold the test
Create `src/components/[ComponentName]/index.test.tsx`:
```tsx
import { render, screen } from "@testing-library/react";
import { ComponentName } from ".";

describe("ComponentName", () => {
  it("renders without crashing", () => {
    render(<ComponentName />);
    // TODO: add assertions
  });
});
```

### 5. Accessibility checklist
- [ ] Interactive elements have accessible labels
- [ ] Focusable elements reachable by keyboard
- [ ] Color is not the only means of conveying information
- [ ] Images have alt text
'

mf ".claude/skills/add-api-route/SKILL.md" '---
name: add-api-route
description: >
  Use this skill when adding a new Express API route.
  Covers file structure, Zod validation, auth middleware,
  error handling, and test setup.
---

# Adding an Express API route

## Steps

### 1. Define Zod schemas first
In `src/server/schemas/[resource].ts`:
```ts
import { z } from "zod";

export const CreateResourceSchema = z.object({
  name: z.string().min(1).max(255),
  // add fields
});

export type CreateResourceInput = z.infer<typeof CreateResourceSchema>;
```

### 2. Create the route handler
In `src/server/routes/[resource].ts`:
```ts
import { Router } from "express";
import { z } from "zod";
import { asyncHandler } from "@/lib/async-handler";
import { requireAuth } from "@/lib/auth";
import { CreateResourceSchema } from "@/server/schemas/[resource]";
import { db } from "@/db";

export const resourceRouter = Router();

resourceRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req, res) => {
    const input = CreateResourceSchema.parse(req.body);

    const result = await db.resource.create({ data: input });

    res.status(201).json({ data: result });
  })
);
```

### 3. Register the router
In `src/server/app.ts`:
```ts
import { resourceRouter } from "./routes/resource";
app.use("/api/resources", resourceRouter);
```

### 4. Write integration tests
```ts
describe("POST /api/resources", () => {
  it("creates resource with valid input", async () => { ... });
  it("returns 400 for invalid input", async () => { ... });
  it("returns 401 when unauthenticated", async () => { ... });
});
```

### 5. Checklist
- [ ] Input validated with Zod before any DB call
- [ ] Auth middleware applied to protected routes
- [ ] asyncHandler wrapper used (handles async errors)
- [ ] Response excludes sensitive fields
- [ ] Tests cover happy path + error cases
'

mf ".claude/skills/db-migration/SKILL.md" '---
name: db-migration
description: >
  Use this skill when making changes to the database schema.
  Covers safe migration patterns, rollback planning, and
  the difference between dev and production workflows.
---

# Database migration

## Dev workflow (fast iteration)
```bash
# 1. Edit prisma/schema.prisma
# 2. Push directly (no migration file):
pnpm db:push

# 3. Regenerate the client:
pnpm prisma generate
```

## Production workflow (tracked migrations)
```bash
# 1. Edit prisma/schema.prisma
# 2. Create a named migration:
pnpm prisma migrate dev --name add_user_verification_token

# 3. Review the generated SQL in prisma/migrations/
# 4. Commit the migration file with your schema change
```

## Safe patterns

### Adding a column
Safe to do directly. If required with no default, add as optional first,
backfill data, then make required.

### Renaming a column
NEVER rename directly — it drops and recreates:
1. Add new column (optional)
2. Write migration script to copy data
3. Update all queries to use new column
4. Remove old column in a follow-up migration

### Removing a column
1. Remove from all queries first
2. Deploy code change
3. Then drop the column in a separate migration

## Rollback
Every migration must have a documented rollback. Add to `docs/migrations/`:
```markdown
## Migration: add_user_verification_token
Rollback: ALTER TABLE users DROP COLUMN verification_token;
```
'

# =============================================================================
#  7. SPECS + ARCHITECTURE (docs/)
# =============================================================================
header "7/8  Docs"

mf "docs/specs/TEMPLATE.md" '# Feature spec: [Feature name]

> Status: Draft | Review | Approved | In Progress | Done
> Author: Mohit Parshar
> Created: [date]

## Overview
One paragraph describing what this feature does and why we are building it.

## User stories
- As a [role], I want [action], so that [benefit].
- As a [role], I want [action], so that [benefit].

## Acceptance criteria
- [ ] [Specific, testable condition]
- [ ] [Specific, testable condition]

## Technical approach

### Schema changes
```prisma
// New models or field additions
```

### API changes
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /api/... | required | ... |

### Component changes
- `ComponentName` — new/modified, does X

## Out of scope
- [Explicitly excluded items]

## Open questions
- [ ] [Unresolved decision]
'

mf "docs/architecture/setup.md" '# Local development setup

## Prerequisites
- Node.js 20+
- pnpm 8+
- Docker Desktop

## First-time setup

```bash
# 1. Clone and install
git clone <repo-url>
cd '"${PROJECT_NAME}"'
pnpm install

# 2. Environment
cp .env.example .env.local
# Fill in the required values (see below)

# 3. Start infrastructure
docker compose up -d

# 4. Database
pnpm db:push
pnpm db:seed

# 5. Start dev servers
pnpm dev
```

## Environment variables
See `.env.example` — all variables are documented there.

Required for local dev:
- `DATABASE_URL` — set automatically by docker compose
- `REDIS_URL` — set automatically by docker compose
- `JWT_SECRET` — any random string locally

## Useful commands
See `CLAUDE.md` for the full command reference.
'

mf "docs/architecture/decisions/ADR-001-template.md" '# ADR-001: [Decision title]

> Date: [YYYY-MM-DD]
> Status: Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
What situation prompted this decision? What forces are at play?

## Decision
What was decided?

## Consequences

### Positive
- [Benefit]

### Negative / trade-offs
- [Cost or limitation]

## Alternatives considered
- **[Option A]** — why not chosen
- **[Option B]** — why not chosen
'

# =============================================================================
#  8. ROOT FILES
# =============================================================================
header "8/8  Root files"

mf ".env.example" '# =============================================================================
#  Environment variables — copy to .env.local and fill in values
#  NEVER commit .env.local or any file with real secrets
# =============================================================================

# Database (docker compose sets this automatically for local dev)
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/'"${PROJECT_NAME}"'_dev"

# Redis
REDIS_URL="redis://localhost:6379"

# Auth
JWT_SECRET="change-me-in-production-use-openssl-rand-base64-32"
JWT_EXPIRES_IN="7d"

# App
NODE_ENV="development"
PORT="3000"
API_PORT="4000"
APP_URL="http://localhost:3000"

# Email (optional for local dev — logs to console if not set)
SMTP_HOST=""
SMTP_PORT=""
SMTP_USER=""
SMTP_PASS=""
FROM_EMAIL="noreply@example.com"

# Stripe (optional for local dev — use test keys)
STRIPE_SECRET_KEY=""
STRIPE_WEBHOOK_SECRET=""
'

mf "Makefile" '.PHONY: setup dev test typecheck lint build clean db-reset

setup:
	pnpm install
	cp -n .env.example .env.local || true
	docker compose up -d
	pnpm db:push
	pnpm db:seed
	@echo "✓ Setup complete. Run make dev to start."

dev:
	pnpm dev

test:
	pnpm test

test-e2e:
	pnpm test:e2e

typecheck:
	pnpm typecheck

lint:
	pnpm lint:fix

build:
	pnpm build

db-reset:
	pnpm prisma migrate reset --force
	pnpm db:seed

clean:
	rm -rf node_modules .next dist
	docker compose down
'

# Only create .gitignore if one doesn'\''t exist
if [[ ! -f ".gitignore" ]]; then
mf ".gitignore" '# Dependencies
node_modules/
.pnp
.pnp.js

# Build outputs
.next/
dist/
out/
build/

# Environment — NEVER commit these
.env
.env.local
.env.*.local
.env.production

# Claude Code — local overrides only (not shared settings)
.claude/settings.local.json
.claude/logs/

# OS
.DS_Store
Thumbs.db

# Editor
.vscode/settings.json
.idea/
*.swp
*.swo

# Testing
coverage/
playwright-report/
test-results/

# Misc
*.log
.turbo/
'
fi

# =============================================================================
#  MCP CONFIG
# =============================================================================
mkdir -p .mcp
mf ".mcp/mcp.json" '{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "."],
      "description": "Read/write project files"
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "GitHub issues, PRs, repos"
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "${DATABASE_URL}"],
      "description": "Query the dev database directly"
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      },
      "description": "Web search for research and debugging"
    }
  }
}
'

# =============================================================================
#  DONE
# =============================================================================
echo ""
echo -e "${BOLD}${GREEN}Bootstrap complete!${RESET}"
echo ""
echo "  Files created:"
find .claude docs .mcp -type f | sort | sed "s/^/    /"
echo "    CLAUDE.md"
echo "    .env.example"
echo "    Makefile"
echo ""
echo -e "${BOLD}Next steps:${RESET}"
echo "  1. Edit CLAUDE.md — fill in your actual tech stack and conventions"
echo "  2. Edit .claude/settings.json — adjust allowed commands for your toolchain"
echo "  3. cp .env.example .env.local && fill in values"
echo "  4. Review .mcp/mcp.json — enable/disable MCP servers as needed"
echo "  5. Add project-specific skills to .claude/skills/"
echo ""
echo -e "  Run ${CYAN}claude${RESET} to start coding."
echo ""
