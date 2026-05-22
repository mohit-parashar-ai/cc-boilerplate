---
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
