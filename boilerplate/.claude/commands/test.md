# /test

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
