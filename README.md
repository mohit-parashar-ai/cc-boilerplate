# Claude Code Boilerplate

> One command to scaffold the full `.claude/` productivity stack — context, agents, hooks, skills, slash commands, MCP servers, and docs templates — so Claude Code works at its best from session one.

[![CI](https://github.com/mohitparshar/claude-code-boilerplate/actions/workflows/ci.yml/badge.svg)](https://github.com/mohitparshar/claude-code-boilerplate/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Bash](https://img.shields.io/badge/bash-3%2B-blue)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-lightgrey)

```bash
bash bootstrap.sh my-project
```

Browse every generated file in [`boilerplate/`](./boilerplate) before running anything.

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
| Bash | 3+ | macOS, Linux, WSL all work |
| Claude Code | latest | `npm i -g @anthropic-ai/claude-code` |

No other dependencies. The script is self-contained — only standard Unix tools (`mkdir`, `printf`, `chmod`).

---

## Quick start

```bash
# Option A — run directly
cd your-project
curl -fsSL https://raw.githubusercontent.com/mohitparshar/claude-code-boilerplate/main/bootstrap.sh | bash -s -- my-project

# Option B — download first, review, then run
curl -O https://raw.githubusercontent.com/mohitparshar/claude-code-boilerplate/main/bootstrap.sh
bash bootstrap.sh my-project

# Option C — clone the repo
git clone https://github.com/mohitparshar/claude-code-boilerplate
cd your-project
bash ../claude-code-boilerplate/bootstrap.sh my-project
```

---

## What gets generated

```
your-project/
├── CLAUDE.md                          # Primary context — loaded every session
├── .env.example                       # All env vars documented, no secrets
├── .gitignore                         # Secrets, logs, build output excluded
├── Makefile                           # Common targets: setup, dev, test, build
│
├── .claude/
│   ├── settings.json                  # Permissions, model, hooks wiring
│   │
│   ├── hooks/
│   │   ├── pre-tool-use.sh            # Blocks dangerous commands before execution
│   │   ├── post-tool-use.sh           # Auto-typechecks TypeScript after every write
│   │   ├── notification.sh            # Session notification handler
│   │   └── stop.sh                    # Session-end logger and summary
│   │
│   ├── agents/
│   │   ├── reviewer.md                # Code review — [blocker]/[suggestion]/[nit]
│   │   ├── tester.md                  # Test writer — Vitest + Playwright, AAA
│   │   ├── docs-writer.md             # Specs, ADRs, JSDoc, changelogs
│   │   └── teams/
│   │       ├── frontend.md            # Next.js, Tailwind, accessibility rules
│   │       ├── backend.md             # Express, Zod, security checklist
│   │       └── devops.md              # Docker, CI/CD, deploy checklist
│   │
│   ├── commands/
│   │   ├── review.md                  # /review — review staged changes or a file
│   │   ├── test.md                    # /test   — generate tests for a file
│   │   ├── spec.md                    # /spec   — write a feature spec
│   │   ├── commit.md                  # /commit — conventional commit from staged
│   │   ├── migrate.md                 # /migrate — safe DB migration workflow
│   │   └── debug.md                   # /debug  — systematic root-cause debugging
│   │
│   └── skills/
│       ├── create-component/SKILL.md  # React component scaffold
│       ├── add-api-route/SKILL.md     # Express route + Zod + auth
│       └── db-migration/SKILL.md      # Safe migration patterns
│
├── .mcp/
│   └── mcp.json                       # MCP servers: filesystem, GitHub, postgres, search
│
└── docs/
    ├── specs/
    │   └── TEMPLATE.md                # Feature spec template
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

> **Tip:** For monorepos, add a nested `CLAUDE.md` inside each package. Claude Code merges them hierarchically — root for project-wide rules, package-level for package-specific rules.

---

### `.claude/settings.json`

Controls what Claude is and isn't allowed to do.

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Bash(pnpm *)", "Bash(git *)", "Bash(docker compose *)", "..."],
    "deny":  ["Bash(sudo *)", "Bash(rm -rf /)", "Bash(curl * | bash)", "..."]
  },
  "hooks": { ... }
}
```

**Adjust the `allow` list for your toolchain.** If you use `yarn` instead of `pnpm`, swap it in. A `settings.local.json` (gitignored) lets each developer override settings locally without affecting teammates.

---

### `.claude/hooks/`

Four lifecycle hooks — all executable shell scripts, all wired in `settings.json`.

#### `pre-tool-use.sh`
Runs **before** every tool call. Exit `1` to block the call; exit `0` to allow.

Generated behaviours:
- Blocks `rm -rf` targeting `/`, `~/`, or `./`
- Blocks `curl ... | bash` and `wget ... | bash` patterns
- Warns (without blocking) when destructive SQL is detected

#### `post-tool-use.sh`
Runs **after** every tool call.

Generated behaviours:
- Detects when Claude writes a `.ts` or `.tsx` file → automatically runs `pnpm typecheck`
- Logs every tool call to `.claude/logs/session.log` with a UTC timestamp

This is the auto-typecheck loop: Claude writes a file → hook fires `tsc --noEmit` → errors surface → Claude fixes on the next step. No manual intervention.

#### `notification.sh`
Fires on Claude notification events. Prints to stderr by default. Commented-out lines enable native desktop notifications: `osascript` (macOS) or `notify-send` (Linux).

#### `stop.sh`
Fires when a session ends. Appends a session-end marker and tool-use count to the log.

---

### `.claude/agents/`

Specialist sub-agents Claude invokes for focused tasks. Each is a markdown file defining role, behaviour rules, stack constraints, and output format.

| Agent | Purpose |
|-------|---------|
| `reviewer.md` | Code review with `[blocker]` / `[suggestion]` / `[nit]` tiers + verdict |
| `tester.md` | Test generation — Vitest + Playwright, AAA, co-located files |
| `docs-writer.md` | Specs, ADRs, JSDoc, changelogs — matches existing docs tone |
| `teams/frontend.md` | Next.js, Tailwind, WCAG AA, server-components-first |
| `teams/backend.md` | Express, Zod, integrated security checklist per endpoint |
| `teams/devops.md` | Docker, CI/CD, zero-downtime deploy checklist |

---

### `.claude/commands/`

Type `/command-name` in Claude Code to run them. Each is a markdown file with numbered instructions Claude follows step by step.

| Command | What it does |
|---------|-------------|
| `/review` | Reviews staged changes (or a file/ref you specify) via the reviewer agent |
| `/test` | Generates a co-located test file via the tester agent |
| `/spec` | Writes a feature spec to `docs/specs/FEATURE-NAME.md` |
| `/commit` | Creates a conventional commit message from staged changes |
| `/migrate` | Walks through a safe DB migration with rollback documentation |
| `/debug` | Systematic root-cause debugging — hypothesis first, prevention note at the end |

---

### `.claude/skills/`

How-to guides for multi-step or easy-to-get-wrong tasks. Claude reads the relevant `SKILL.md` before attempting the task.

| Skill | Covers |
|-------|--------|
| `create-component` | Check for duplicates, TypeScript props, barrel export, test scaffold, a11y checklist |
| `add-api-route` | Zod schema first, `asyncHandler`, register router, integration tests, security checklist |
| `db-migration` | Dev `db:push` vs production `migrate dev`, safe rename/remove patterns, rollback docs |

**Adding your own:** Create `.claude/skills/your-skill/SKILL.md`. Claude Code discovers skills automatically. Good candidates: deploy runbooks, complex test setups, code-generation patterns specific to your project.

---

### `.mcp/mcp.json`

MCP server registry — external tools Claude can call during a session.

| Server | What it enables | Needs |
|--------|----------------|-------|
| `filesystem` | Read/write project files | nothing |
| `github` | Issues, PRs, repos | `GITHUB_TOKEN` env var |
| `postgres` | Query dev DB directly | `DATABASE_URL` env var |
| `brave-search` | Web search | `BRAVE_API_KEY` env var |

Remove servers you don't need. Add others from the [MCP server registry](https://github.com/modelcontextprotocol/servers).

---

### `Makefile`

| Target | Command |
|--------|---------|
| `make setup` | Full first-time setup: install, copy env, docker up, migrate, seed |
| `make dev` | Start all dev servers |
| `make test` | Run Vitest |
| `make test-e2e` | Run Playwright |
| `make typecheck` | `tsc --noEmit` |
| `make lint` | ESLint + Prettier |
| `make build` | Production build |
| `make db-reset` | Drop, re-migrate, re-seed |
| `make clean` | Remove build output, stop Docker |

---

## After bootstrapping — 15-minute checklist

1. **Fill in `CLAUDE.md`** — replace all `<!-- TODO -->` sections with your actual stack and conventions
2. **Update `.claude/settings.json`** — swap `pnpm` for your package manager, tighten the deny list
3. **Set up your environment** — `cp .env.example .env.local` and fill in real values
4. **Review `.mcp/mcp.json`** — remove unused servers, add API keys for the ones you need
5. **Customise team agents** — update stack constraints in `.claude/agents/teams/*.md`

---

## Customisation

### Changing the stack
The defaults are TypeScript + Next.js + Express + Prisma. To adapt:

- `CLAUDE.md` → update **Tech stack** and **Key commands**
- `.claude/settings.json` → update `allow` list for your package manager
- `.claude/agents/teams/` → update stack constraints per agent
- `.claude/hooks/post-tool-use.sh` → change the file extension check if not TypeScript
- `.claude/skills/` → replace or add skills for your workflow

### Adding a slash command
Create `.claude/commands/your-command.md`:
```markdown
# /your-command

One-sentence description.

## Instructions
1. Step one
2. Step two

## Usage
- `/your-command arg` — what this does
```
No registration needed — Claude Code picks it up automatically.

### Adding a skill
Create `.claude/skills/your-skill/SKILL.md` with YAML frontmatter:
```markdown
---
name: your-skill
description: >
  Use this skill when [trigger condition].
---

# Skill title

## Steps
...
```

### Per-developer overrides
Add `.claude/settings.local.json` (gitignored) to override `settings.json` locally — different model, personal allow/deny rules, local env vars.

---

## Troubleshooting

**`bad substitution` on line 29**
Run with `bash bootstrap.sh`, not `sh bootstrap.sh`. The script requires bash (any version ≥ 3).

**Hooks not firing**
Check hook scripts are executable:
```bash
chmod +x .claude/hooks/*.sh
```
Verify they are wired in `.claude/settings.json` under the `hooks` key.

**`pnpm typecheck` not found after file write**
The hook checks for `pnpm` and a `package.json`. If you use `npm` or `yarn`, update the check in `.claude/hooks/post-tool-use.sh` line 15.

**MCP server failing to connect**
Ensure the required env vars are set in your shell. Each server is independent — a missing key for one doesn't affect the others.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). All contributions welcome — new agents, commands, skills, hook behaviours, stack variants, bug fixes.

---

## Licence

[MIT](LICENSE)
