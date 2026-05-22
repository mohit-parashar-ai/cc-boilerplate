# /commit

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
