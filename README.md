# Claude Code Boilerplate

A one-command scaffold that wires up the full `.claude/` productivity stack — context, agents, hooks, skills, slash commands, MCP servers, and docs templates — so Claude Code works at its best from the first session.

```bash
bash bootstrap.sh my-project
```

---

## Why this exists

Claude Code is only as good as the context it has. Out of the box it knows nothing about your project — your stack, your conventions, what files to never touch, how you like commits written. This boilerplate solves that by generating a complete, opinionated `.claude/` directory alongside supporting docs and config files, all pre-wired and ready to customise.

After running the script, Claude will:

- Know your stack, commands, and conventions before writing a single line
- Auto-run `typecheck` after every TypeScript edit and self-correct
- Block dangerous shell commands before they execute
- Have specialist agents for reviewing, testing, and writing docs
- Respond to slash commands like `/review`, `/commit`, and `/debug`
- Follow step-by-step skills for repetitive tasks like adding a route or migrating a DB

---

## Requirements

| Tool | Version | Notes |
|------|---------|-------|
| Bash | any | macOS, Linux, WSL all work |
| Claude Code | latest | `npm i -g @anthropic-ai/claude-code` |

No other dependencies. The script is self-contained and only uses standard Unix tools (`mkdir`, `printf`, `chmod`).

---

## Usage

```bash
# 1. Download the script
curl -O https://raw.githubusercontent.com/your-org/claude-code-boilerplate/main/bootstrap.sh

# 2. Run it inside your project directory
cd your-project
bash bootstrap.sh your-project-name

# 3. Confirm the prompt — it bootstraps in the current directory
Bootstrap here? [y/N] y
```

The project name is optional — it defaults to `my-project` and is used to stamp `CLAUDE.md`, `setup.md`, and the example `DATABASE_URL`.

---

## What gets generated

```
your-project/
├── CLAUDE.md                          # Primary context file — loaded every session
├── .env.example                       # All env vars documented, no secrets
├── .gitignore                         # Secrets, logs, build output excluded
├── Makefile                           # Common commands: setup, dev, test, build
│
├── .claude/
│   ├── settings.json                  # Permissions, model, hooks wiring
│   │
│   ├── hooks/
│   │   ├── pre-tool-use.sh            # Runs before every tool call — blocks dangerous commands
│   │   ├── post-tool-use.sh           # Runs after every tool call — auto-typechecks TS files
│   │   ├── notification.sh            # Fires on Claude notifications — log / desktop alert
│   │   └── stop.sh                    # Fires at session end — writes session summary to log
│   │
│   ├── agents/
│   │   ├── reviewer.md                # Code review — structured [blocker]/[suggestion]/[nit]
│   │   ├── tester.md                  # Test writer — Vitest + Playwright, AAA pattern
│   │   ├── docs-writer.md             # Documentation — specs, ADRs, JSDoc, changelogs
│   │   └── teams/
│   │       ├── frontend.md            # UI specialist — Next.js, Tailwind, a11y rules
│   │       ├── backend.md             # API specialist — Express, Zod, security checklist
│   │       └── devops.md              # Infra specialist — Docker, CI/CD, deploy checklist
│   │
│   ├── commands/
│   │   ├── review.md                  # /review — review staged changes or a specific file
│   │   ├── test.md                    # /test  — generate tests for a file or feature
│   │   ├── spec.md                    # /spec  — write a feature spec to docs/specs/
│   │   ├── commit.md                  # /commit — conventional commit from staged changes
│   │   ├── migrate.md                 # /migrate — safe DB migration workflow
│   │   └── debug.md                   # /debug — systematic root-cause debugging
│   │
│   └── skills/
│       ├── create-component/SKILL.md  # How to scaffold a React component end-to-end
│       ├── add-api-route/SKILL.md     # How to add an Express route with Zod + auth
│       └── db-migration/SKILL.md      # Safe migration patterns — dev vs prod workflows
│
├── .mcp/
│   └── mcp.json                       # MCP server registry (filesystem, GitHub, postgres, search)
│
└── docs/
    ├── specs/
    │   └── TEMPLATE.md                # Feature spec template — overview, stories, ACs, approach
    └── architecture/
        ├── setup.md                   # Local dev setup guide
        └── decisions/
            └── ADR-001-template.md    # Architecture Decision Record template
```

---

## File-by-file reference

### `CLAUDE.md`

The most important file. Loaded automatically at the start of every Claude Code session. Think of it as the onboarding document Claude reads before touching anything.

Sections generated:

| Section | What to fill in |
|---------|----------------|
| **What this is** | One paragraph — what the project does, who uses it |
| **Current focus** | What is actively being built right now |
| **Tech stack** | Your actual languages, frameworks, libraries, deploy targets |
| **Key commands** | The exact commands Claude should run to dev/test/build |
| **Key paths** | Where important directories and files live |
| **Conventions** | Naming, code style, git format |
| **Never do** | Explicit prohibitions — the most expensive mistakes, pre-empted |
| **Always do** | Standards that apply to every file change |
| **Workflow** | How to work on larger tasks autonomously |

All `<!-- TODO -->` sections are clearly marked. Filling them in takes about 10 minutes and is the highest-leverage thing you can do after bootstrapping.

> **Tip:** For monorepos, add a nested `CLAUDE.md` inside each package directory. Claude Code merges them hierarchically — the root one for project-wide rules, package-level ones for package-specific rules.

---

### `.claude/settings.json`

Controls what Claude is and isn't allowed to do.

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Bash(pnpm *)", "Bash(git *)", "Bash(docker compose *)", ...],
    "deny":  ["Bash(sudo *)", "Bash(rm -rf /)", "Bash(curl * | bash)", ...]
  },
  "hooks": { ... }
}
```

**Adjust the `allow` list for your toolchain.** If you use `yarn` instead of `pnpm`, swap it in. If you use `go` or `cargo`, add them. The deny list is intentionally conservative — `sudo`, piped remote scripts, and dangerous deletes are blocked by default.

A `settings.local.json` (gitignored) can override settings for your personal machine without affecting teammates.

---

### `.claude/hooks/`

Four lifecycle hooks, all executable shell scripts.

#### `pre-tool-use.sh`
Runs **before** every tool call. Exit `1` to block the call; exit `0` to allow.

Generated behaviours:
- Blocks `rm -rf` targeting root or `~/`
- Blocks `curl ... | bash` and `wget ... | bash` patterns
- Logs a warning (without blocking) when destructive SQL is detected

Add your own rules here — for example, blocking writes to a `src/legacy/` directory or requiring confirmation before `git push`.

#### `post-tool-use.sh`
Runs **after** every tool call. Used for validation and logging.

Generated behaviours:
- Detects when Claude writes a `.ts` or `.tsx` file and automatically runs `pnpm typecheck`
- Logs every tool call to `.claude/logs/session.log` with a UTC timestamp

This is why the "auto-typecheck" loop works — Claude writes a file, the hook fires `tsc --noEmit`, the errors surface immediately, Claude fixes them on the next step. No manual intervention.

#### `notification.sh`
Fires when Claude sends a notification event. Prints to stderr by default. Two commented-out lines let you enable native desktop notifications — `osascript` for macOS, `notify-send` for Linux.

#### `stop.sh`
Fires when a Claude session ends. Appends a session-end marker and tool-use count to the session log. A good place to add cleanup, post-session summaries, or automated reporting.

---

### `.claude/agents/`

Specialist sub-agents Claude can invoke for focused tasks. Each is a markdown file defining a role, behaviour rules, stack constraints, and output format.

#### `reviewer.md`
A senior code reviewer. Structures every review with three tiers:
- `[blocker]` — must be fixed before merge
- `[suggestion]` — recommended improvement
- `[nit]` — optional polish

Always ends with a verdict: **Approved**, **Approved with suggestions**, or **Changes required**. Called by the `/review` command.

#### `tester.md`
Writes comprehensive test files. Enforces the AAA (Arrange → Act → Assert) pattern, co-location with source files, and mocking of external services. Called by the `/test` command.

#### `docs-writer.md`
Produces specs, ADRs, JSDoc, changelogs, and README updates. Matches the existing docs tone before writing. Called by the `/spec` command.

#### `teams/frontend.md`
UI/UX specialist with hard constraints for the generated stack: server components by default, `cn()` for class merging, `next/image` always, WCAG AA accessibility. Swap out the stack details for your own framework.

#### `teams/backend.md`
API specialist with an integrated security checklist applied to every endpoint: Zod validation, auth before DB access, no `select *`, transactions for multi-step operations.

#### `teams/devops.md`
Infrastructure specialist with a deployment checklist: staging-first migrations, health checks, zero-downtime deploys, rollback plan documented.

---

### `.claude/commands/`

Slash commands — type `/command-name` in Claude Code to execute them. Each is a markdown file with step-by-step instructions that Claude follows.

| Command | What it does |
|---------|-------------|
| `/review` | Reviews staged changes (or a file/ref you specify) using the reviewer agent |
| `/test` | Generates a co-located test file for the file or feature you specify |
| `/spec` | Writes a feature spec to `docs/specs/FEATURE-NAME.md` |
| `/commit` | Creates a conventional commit message from staged changes and runs `git commit` |
| `/migrate` | Walks through a safe DB migration — dev vs prod workflows, rollback steps |
| `/debug` | Systematic root-cause debugging — hypothesis first, targeted investigation, prevention note |

---

### `.claude/skills/`

How-to guides for tasks that involve multiple steps, specific tools, or easy-to-get-wrong sequences. Claude reads the relevant `SKILL.md` before attempting the task rather than guessing.

#### `create-component/SKILL.md`
Full React component scaffold: check for existing components first, create with TypeScript props interface, export from barrel file, scaffold the test, accessibility checklist.

#### `add-api-route/SKILL.md`
Express route workflow: define Zod schema first, create handler with `asyncHandler` wrapper, register router, write integration tests, security checklist.

#### `db-migration/SKILL.md`
Safe migration patterns: dev `db:push` vs production `migrate dev`, column rename in three steps (never directly), column removal in two deploys, rollback documentation.

**Adding your own skills:** Create `.claude/skills/your-skill-name/SKILL.md`. Claude Code discovers skills automatically. Good candidates: deployment runbooks, complex test setups, code generation patterns specific to your project.

---

### `.mcp/mcp.json`

MCP (Model Context Protocol) server registry. Defines external tools Claude can use during a session.

| Server | What it enables |
|--------|----------------|
| `filesystem` | Read/write project files via MCP protocol |
| `github` | Query issues, PRs, repos — needs `GITHUB_TOKEN` env var |
| `postgres` | Run queries directly against your dev database — needs `DATABASE_URL` |
| `brave-search` | Web search for research and debugging — needs `BRAVE_API_KEY` |

Disable servers you don't need by removing them from the `mcpServers` object. Add others from the [MCP server registry](https://github.com/modelcontextprotocol/servers).

---

### `docs/specs/TEMPLATE.md`

Feature spec template. Copy to `docs/specs/YOUR-FEATURE.md` before implementing a feature. The `/spec` command writes here automatically.

Sections: Overview, User stories, Acceptance criteria, Technical approach (schema + API + component changes), Out of scope, Open questions.

Having a spec in place before Claude starts coding is the single biggest reduction in wasted tokens and incorrect implementations.

---

### `docs/architecture/`

`setup.md` — local development setup guide. Pre-filled with the steps for the generated stack (clone, install, copy env, docker compose, db:push, seed, dev). Update with your actual repo URL and any extra steps.

`decisions/ADR-001-template.md` — Architecture Decision Record template. Copy and number sequentially for each significant technical decision. Sections: Context, Decision, Consequences (positive + trade-offs), Alternatives considered.

---

### `Makefile`

Convenience targets that wrap the underlying `pnpm` commands. Claude can call `make setup`, `make test`, `make build`, etc.

| Target | Command |
|--------|---------|
| `make setup` | Full first-time setup: install, copy env, docker up, db migrate, seed |
| `make dev` | Start all dev servers |
| `make test` | Run Vitest |
| `make test-e2e` | Run Playwright |
| `make typecheck` | `tsc --noEmit` |
| `make lint` | ESLint + Prettier |
| `make build` | Production build |
| `make db-reset` | Drop, re-migrate, and re-seed the dev database |
| `make clean` | Remove `node_modules`, build output, stop Docker |

---

### `.env.example`

Documented environment variable template. All variables are present with descriptions and safe example values. No real secrets — ever.

Copy to `.env.local` to get started:
```bash
cp .env.example .env.local
```

The `.gitignore` excludes `.env.local`, `.env`, `.env.*.local`, and `.env.production` — all real env files are blocked from being committed.

---

### `.gitignore`

Pre-configured to exclude:
- `node_modules/`, build output (`.next/`, `dist/`)
- All real env files (`.env.local`, `.env.production`, etc.)
- Claude Code local overrides (`.claude/settings.local.json`)
- Claude session logs (`.claude/logs/`)
- OS files (`.DS_Store`, `Thumbs.db`)
- Editor configs (`*.swp`, `.idea/`)
- Test output (`coverage/`, `playwright-report/`)

Only created if no `.gitignore` already exists in the project directory.

---

## After bootstrapping — the 15-minute checklist

These are the only things you need to do before starting your first Claude Code session:

1. **Fill in `CLAUDE.md`** — replace all `<!-- TODO -->` sections with your actual stack and conventions. This is the highest-leverage 10 minutes.

2. **Update `.claude/settings.json`** — swap `pnpm` for `yarn`/`npm` if needed, add your build tool, tighten or loosen the deny list.

3. **Set up your environment** — `cp .env.example .env.local` and fill in real values.

4. **Review `.mcp/mcp.json`** — remove servers you don't need, add API keys for the ones you do.

5. **Customise agent personas** — open the team agent files in `.claude/agents/teams/` and update the stack section to match your actual framework and libraries.

---

## Customisation guide

### Changing the stack
The boilerplate defaults to TypeScript + Next.js + Express + Prisma. To adapt it:

- `CLAUDE.md` → update the **Tech stack** and **Key commands** sections
- `.claude/settings.json` → update the `allow` list for your package manager and build tools
- `.claude/agents/teams/frontend.md` and `backend.md` → update stack constraints
- `.claude/hooks/post-tool-use.sh` → change the file extension check if not using TypeScript
- `.claude/skills/` → replace or add skills for your actual workflow

### Adding a new slash command
Create `.claude/commands/your-command.md` with:
```markdown
# /your-command

One-sentence description.

## Instructions
1. Step one
2. Step two
...
```
Claude Code picks it up automatically — no registration needed.

### Adding a new skill
Create `.claude/skills/your-skill/SKILL.md` with a YAML frontmatter block:
```markdown
---
name: your-skill
description: >
  Use this skill when [trigger condition].
  Covers [what it handles].
---

# Your skill title

## Steps
...
```
Reference it in `CLAUDE.md` under "Key paths" so Claude knows it exists.

### Team-specific settings
Each team member can have a `.claude/settings.local.json` (gitignored) that overrides `settings.json` locally — different model, personal allow/deny rules, local env vars — without affecting the shared config.

---

## Troubleshooting

**`bad substitution` on line 29**
Your system shell is bash 3 (common on macOS). Make sure you're running with `bash bootstrap.sh`, not `sh bootstrap.sh`. The script requires bash (any version).

**Hooks not firing**
Check that the hook scripts are executable:
```bash
chmod +x .claude/hooks/*.sh
```
Then confirm they are wired in `.claude/settings.json` under the `hooks` key.

**`pnpm typecheck` not found in post-tool-use hook**
The hook checks for `pnpm` and a `package.json` before running. If your project uses `npm` or `yarn`, update the check on line 15 of `post-tool-use.sh`.

**MCP servers failing to connect**
Ensure the required env vars are set (`GITHUB_TOKEN`, `DATABASE_URL`, `BRAVE_API_KEY`). Each server is independent — a failing server doesn't block the others.

---

## Contributing

The script is a single self-contained bash file. To add a new section:

1. Add a `header "N/8  Section name"` call in order
2. Use `mf "path/to/file" 'content'` to write each file
3. Update the file tree in this README
4. Test with `bash bootstrap.sh test-project` in a temp directory

---

## Licence

MIT — use, modify, and redistribute freely.
