# Helios — ML-Powered Analytics API

## What this is
Helios is a REST API that ingests event streams, runs ML inference for anomaly
detection, and serves analytics dashboards. Python 3.12, FastAPI, PostgreSQL,
Celery for async jobs, Redis for queues and caching. Used internally by 3
product teams via API key authentication.

## Current focus
Migrating the anomaly detection pipeline from a synchronous endpoint to an
async Celery task. Work is in `app/tasks/anomaly.py` and
`app/api/v1/endpoints/detections.py`.

## Tech stack
Language:    Python 3.12
Framework:   FastAPI 0.111 (async throughout)
Database:    PostgreSQL 16 via SQLAlchemy 2 (async) + Alembic migrations
Cache:       Redis 7 via aioredis
Queue:       Celery 5 with Redis broker
ML:          scikit-learn 1.4, numpy, pandas — models in `app/ml/models/`
Auth:        API key (SHA-256 hashed, stored in DB) + optional JWT for internal
Testing:     pytest + pytest-asyncio, httpx AsyncClient, factory-boy fixtures
Linting:     ruff (lint + format) — replaces black + isort + flake8
Types:       mypy in strict mode
Deploy:      Docker → Kubernetes (GKE) via Helm charts in `infra/helm/`
CI:          GitHub Actions — lint, typecheck, test, build, deploy

## Key commands
```
make dev              Start FastAPI dev server (uvicorn --reload)
make test             Run pytest suite
make test-cov         Run pytest with coverage report
make typecheck        mypy app/ --strict
make lint             ruff check app/ && ruff format --check app/
make lint-fix         ruff check --fix app/ && ruff format app/
make migrate          alembic upgrade head
make migrate-new      alembic revision --autogenerate -m "description"
make migrate-down     alembic downgrade -1
make worker           Start Celery worker (separate terminal)
make worker-beat      Start Celery beat scheduler
make shell            Open IPython shell with app context
make db-reset         Drop, recreate, and seed dev database
```

## Key paths
```
app/
  api/v1/endpoints/   Route handlers — one file per resource
  api/v1/schemas/     Pydantic request/response models
  api/deps.py         FastAPI dependency injection (db, auth, redis)
  core/config.py      Pydantic settings — reads from env
  core/security.py    API key hashing and validation
  db/models/          SQLAlchemy ORM models
  db/repository/      Data access layer — all queries live here
  ml/models/          Trained model loaders and inference wrappers
  ml/features/        Feature engineering pipelines
  tasks/              Celery task definitions
  workers/            Celery app config and beat schedule

tests/
  conftest.py         Fixtures: async client, db session, factories
  api/                Endpoint integration tests
  unit/               Unit tests for services and utilities

alembic/
  versions/           Migration files — never edit committed ones

infra/
  helm/               Kubernetes Helm charts
  docker/             Dockerfiles for api, worker, beat
```

## Architecture patterns (important)

### Dependency injection
All shared resources (DB session, Redis, current API key) are FastAPI
dependencies defined in `app/api/deps.py`. Never instantiate these directly
inside a route handler — always inject them.

```python
@router.get("/events")
async def list_events(
    db: AsyncSession = Depends(get_db),
    api_key: APIKey = Depends(get_api_key),
):
```

### Repository pattern
All database access goes through repository classes in `app/db/repository/`.
Route handlers never write raw SQLAlchemy queries — they call repository methods.

```python
# Good
events = await event_repo.list_by_org(db, org_id=api_key.org_id, limit=100)

# Bad — raw query in a route handler
result = await db.execute(select(Event).where(...))
```

### Pydantic schemas
- Request bodies: `app/api/v1/schemas/[resource].py` — `ResourceCreate`, `ResourceUpdate`
- Responses: `ResourceRead`, `ResourceList` (never return ORM models directly)
- Internal: `ResourceInternal` for data not exposed to API consumers

### Async everywhere
- All route handlers are `async def`
- All DB calls use `await` (SQLAlchemy async session)
- All Redis calls use `await` (aioredis)
- CPU-bound ML inference goes to Celery tasks — never block the event loop

## Conventions

### Files and naming
- Endpoints: snake_case, one file per resource (`events.py`, `detections.py`)
- Models: PascalCase (`Event`, `Detection`)
- Schemas: `ResourceVerb` pattern (`EventCreate`, `EventRead`)
- Repositories: `ResourceRepository` class in `resource_repo.py`
- Tasks: descriptive verbs (`run_anomaly_detection`, `send_alert_email`)

### Python style
- Type annotations on every function signature — mypy strict must pass
- Pydantic v2 models only — no v1 compat shims
- f-strings for string formatting
- `pathlib.Path` not `os.path`
- Raise `HTTPException` in route handlers, domain exceptions in services

### API design
- Versioned under `/api/v1/`
- Plural resource names: `/events`, `/detections`, `/api-keys`
- Consistent response envelope: `{"data": ..., "meta": {...}}`
- Errors: `{"error": {"code": "...", "message": "...", "detail": ...}}`
- Pagination: cursor-based via `?cursor=` and `?limit=` (max 500)

## Never do
- NEVER write raw SQL — use SQLAlchemy ORM via the repository layer
- NEVER run ML inference synchronously in a route handler — use Celery tasks
- NEVER store plaintext API keys — always SHA-256 hash before storing
- NEVER use `print()` — use `structlog` (`from app.core.logging import logger`)
- NEVER skip `await` on async functions — mypy should catch this
- NEVER edit committed Alembic migration files — create a new revision instead
- NEVER hardcode environment-specific values — use `app/core/config.py`

## Always do
- Run `make typecheck` and `make lint` before any commit
- Write repository methods for all new DB queries
- Add pytest fixtures to `tests/conftest.py` for new models
- Use `factory_boy` factories for test data — not raw dicts
- Document all public endpoints with docstrings (auto-generates OpenAPI docs)
- Add field descriptions to Pydantic schemas (shows in Swagger UI)

## Workflow for larger tasks
1. Check `docs/specs/` for an existing spec
2. For new endpoints: schema → repository → endpoint → tests
3. For Celery tasks: define task → add to beat schedule if periodic → test with `task.apply()`
4. For ML changes: validate on test dataset first, document accuracy metrics
5. Run `make typecheck && make test` before marking done
6. For migrations: always test `upgrade` and `downgrade` before committing

## Environment setup
```bash
cp .env.example .env
docker compose up -d          # postgres + redis
make migrate && make seed
make dev                      # in one terminal
make worker                   # in another terminal
```
