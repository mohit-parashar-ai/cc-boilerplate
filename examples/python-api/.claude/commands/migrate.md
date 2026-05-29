# /migrate

Generate and apply an Alembic database migration.

## Instructions
1. Confirm the model changes needed (what fields/tables are being added/changed)
2. Ensure `app/db/models/__init__.py` imports the model (Alembic needs to see it)
3. Generate the migration:
   ```bash
   make migrate-new
   # Prompts for a description — use snake_case: add_score_to_detections
   ```
4. Review the generated file in `alembic/versions/` — verify the `upgrade()` and `downgrade()` functions look correct
5. Apply to dev database:
   ```bash
   make migrate
   ```
6. Test the downgrade:
   ```bash
   make migrate-down
   make migrate     # re-apply
   ```
7. Commit the migration file alongside the model change in the same commit

## Safety rules
- NEVER edit a committed migration file — create a new revision instead
- ALWAYS verify `downgrade()` is correct before committing
- For destructive changes (dropping columns): add a deprecation migration first,
  then a removal migration in a separate PR after confirming no code reads the column

## Usage
- `/migrate` — interactive, asks what changed
- `/migrate add score column to Detection model`
