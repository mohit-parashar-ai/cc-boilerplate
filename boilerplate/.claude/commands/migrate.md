# /migrate

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
