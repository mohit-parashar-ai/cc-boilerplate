# Changelog

All notable changes to this project will be documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [1.0.0] — 2025-05-22

### Added
- `bootstrap.sh` — single-command scaffold for the full `.claude/` productivity stack
- `CLAUDE.md` — 8-section project context template (stack, commands, paths, conventions, never/always, workflow)
- `.claude/settings.json` — permissions allowlist/denylist + hooks wiring
- `.claude/hooks/pre-tool-use.sh` — blocks dangerous shell patterns before execution
- `.claude/hooks/post-tool-use.sh` — auto-runs `pnpm typecheck` after TypeScript file writes
- `.claude/hooks/notification.sh` — session notification handler with macOS/Linux native alert stubs
- `.claude/hooks/stop.sh` — session-end logger and summary
- `.claude/agents/reviewer.md` — code review agent with structured [blocker]/[suggestion]/[nit] output
- `.claude/agents/tester.md` — test generation agent (Vitest + Playwright, AAA pattern)
- `.claude/agents/docs-writer.md` — documentation agent (specs, ADRs, JSDoc, changelogs)
- `.claude/agents/teams/frontend.md` — UI specialist (Next.js, Tailwind, a11y rules)
- `.claude/agents/teams/backend.md` — API specialist (Express, Zod, security checklist)
- `.claude/agents/teams/devops.md` — DevOps specialist (Docker, CI/CD, deploy checklist)
- `.claude/commands/review.md` — `/review` slash command
- `.claude/commands/test.md` — `/test` slash command
- `.claude/commands/spec.md` — `/spec` slash command
- `.claude/commands/commit.md` — `/commit` slash command
- `.claude/commands/migrate.md` — `/migrate` slash command
- `.claude/commands/debug.md` — `/debug` slash command
- `.claude/skills/create-component/SKILL.md` — React component scaffold skill
- `.claude/skills/add-api-route/SKILL.md` — Express route skill
- `.claude/skills/db-migration/SKILL.md` — safe DB migration skill
- `.mcp/mcp.json` — MCP server registry (filesystem, GitHub, postgres, brave-search)
- `docs/specs/TEMPLATE.md` — feature spec template
- `docs/architecture/setup.md` — local dev setup guide
- `docs/architecture/decisions/ADR-001-template.md` — ADR template
- `.env.example` — documented environment variables
- `Makefile` — common dev targets
- `.gitignore` — secrets, logs, build output excluded
- CI workflow — shellcheck + bootstrap test on Ubuntu and macOS
- Release workflow — auto-zip and publish on version tag
