# /review

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
