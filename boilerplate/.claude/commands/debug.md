# /debug

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
