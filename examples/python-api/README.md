# Example: Python FastAPI + Celery (Helios)

This example shows how to configure Claude Code for a **Python async API service**
built with FastAPI, SQLAlchemy 2 (async), Celery, and a machine learning inference
pipeline.

> **→ [Full setup guide](../SETUP.md#python-api-helios)** — step-by-step instructions to run this project locally with Claude Code.

## What makes this example interesting

**Python-specific hook checks** — `pre-tool-use.sh` blocks edits to committed
Alembic migration files (the most common and irreversible Python DB mistake) and
warns when raw SQL strings appear in Python files.

**Ruff + mypy auto-check** — `post-tool-use.sh` runs `ruff check` and `mypy`
on every Python file write, surfacing type errors and lint violations inline
without a manual step. The hook also reminds about migrations when a SQLAlchemy
model file changes.

**Domain-specific agents** — `sqlalchemy.md` knows the async session patterns,
repository layer, and Alembic rules. `celery-tasks.md` knows when to use tasks
vs inline processing, idempotency patterns, and retry configuration.

**Async-first patterns** — The skill and agents are written for SQLAlchemy 2's
async API — `await db.execute(select(...))`, not the legacy `db.query()` API.

**Real async migration spec** — `docs/specs/async-anomaly-detection.md` shows
a realistic API architecture change spec with a new Celery task, polling endpoint,
webhook delivery, and open questions.

## Files in this example

```
CLAUDE.md                                Project context — architecture patterns explained
.env.example                             All env vars including Celery broker URLs
.claude/
  settings.json                          Permissions for make, python, pytest, ruff, mypy, alembic
  hooks/
    pre-tool-use.sh                      Blocks Alembic migration edits, warns on raw SQL
    post-tool-use.sh                     Auto-runs ruff + mypy, warns on model changes
  agents/
    sqlalchemy.md                        Async ORM patterns, repository template, migration rules
    celery-tasks.md                      Task template, when to use tasks, idempotency patterns
  skills/
    create-endpoint/SKILL.md             Schema → repository → handler → tests workflow
  commands/
    migrate.md                           /migrate — Alembic-aware migration workflow
docs/
  specs/async-anomaly-detection.md       Real spec: sync → async pipeline migration
```

## Key things to adapt for your project

- Change `make *` commands in `settings.json` to your actual Makefile targets
- Update the ML model paths in `.env.example` and `CLAUDE.md`
- If using a different ORM (Tortoise, SQLModel, etc.), update the SQLAlchemy agent
- Add your own domain agents for complex subsystems (e.g. ML pipeline, auth layer)
- The Alembic hook path in `pre-tool-use.sh` assumes `alembic/versions/` — update if different
