# Contributing

Contributions are welcome — new agents, commands, skills, hook behaviours, stack variants, and bug fixes all add value.

## Ground rules

- Every change to `bootstrap.sh` must be tested on both macOS and Linux
- Generated JSON files must remain valid JSON
- Hook scripts must pass `shellcheck -S warning`
- If you add a new generated file, document it in the README file tree and file-by-file reference
- Keep `bootstrap.sh` as a single self-contained file — no external dependencies

## Development setup

```bash
git clone https://github.com/mohitparshar/claude-code-boilerplate
cd claude-code-boilerplate
```

Test your changes:
```bash
mkdir -p /tmp/test && cp bootstrap.sh /tmp/test && cd /tmp/test
echo "y" | bash bootstrap.sh test-project
```

Lint:
```bash
shellcheck -S warning bootstrap.sh
shellcheck -S warning boilerplate/.claude/hooks/*.sh
```

## Adding a new slash command

1. Add a `mf ".claude/commands/your-command.md"` block to `bootstrap.sh` in section 5
2. Follow the existing format: title, one-sentence description, numbered instructions, usage examples
3. Reference it in the README commands table
4. Add it to CHANGELOG.md under `### Added`

## Adding a new skill

1. Add a `mf ".claude/skills/your-skill/SKILL.md"` block to `bootstrap.sh` in section 6
2. Include YAML frontmatter with `name` and `description`
3. Structure: numbered steps, code examples, a checklist at the end
4. Reference it in the README
5. Add it to CHANGELOG.md

## Adding a new agent

1. Add a `mf ".claude/agents/your-agent.md"` block to `bootstrap.sh` in section 4
2. Sections: Role, Behaviour (bullet rules), Output format (concrete example), Stack constraints
3. Reference it in the README
4. If it pairs with a command, update the command to call it by name

## Commit style

Conventional commits:
```
feat: add /deploy slash command
fix: bash 3 compatibility in pre-tool-use hook
docs: add troubleshooting entry for WSL
chore: update CI to actions/checkout@v4
```

## Pull requests

Fill in the PR template. All CI checks must pass before merge.
