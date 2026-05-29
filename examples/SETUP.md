# Examples setup guide

Step-by-step instructions for running both example projects locally with
Claude Code fully configured.

- [Next.js SaaS (NexTask)](#nextjs-saas-nextask)
- [Python API (Helios)](#python-api-helios)
- [Verifying Claude Code is wired up](#verifying-claude-code-is-wired-up)
- [Troubleshooting](#troubleshooting)

---

## Next.js SaaS (NexTask)

A multi-tenant SaaS project management app — Next.js 14, tRPC, Prisma, Stripe.

### Prerequisites

Install these before starting. Run the check command next to each to verify.

| Tool | Version | Check | Install |
|------|---------|-------|---------|
| Node.js | 20+ | `node --version` | [nodejs.org](https://nodejs.org) |
| pnpm | 8+ | `pnpm --version` | `npm i -g pnpm` |
| Docker Desktop | latest | `docker --version` | [docker.com](https://docker.com) |
| Stripe CLI | latest | `stripe --version` | [stripe.com/docs/stripe-cli](https://stripe.com/docs/stripe-cli) |
| Claude Code | latest | `claude --version` | `npm i -g @anthropic-ai/claude-code` |
| Git | any | `git --version` | pre-installed on most systems |

---

### Step 1 — Get the project files

**Option A — bootstrap a fresh project using the script:**

```bash
mkdir nextask && cd nextask
curl -O https://raw.githubusercontent.com/mohitparshar/claude-code-boilerplate/main/bootstrap.sh
bash bootstrap.sh nextask
```

**Option B — copy the example config into an existing Next.js project:**

```bash
cd your-existing-project
cp -r path/to/examples/nextjs-saas/.claude .
cp path/to/examples/nextjs-saas/CLAUDE.md .
cp path/to/examples/nextjs-saas/.env.example apps/web/.env.example
```

---

### Step 2 — Set up environment variables

```bash
cp apps/web/.env.example apps/web/.env.local
```

Open `apps/web/.env.local` and fill in the following. Items marked **required**
must be set before the app will start. Items marked *optional* can be skipped
for initial local development.

#### AUTH_SECRET — **required**

Generate a secure random value:

```bash
openssl rand -base64 32
```

Paste the output as the value of `AUTH_SECRET`.

#### AUTH_URL — **required**

Leave as-is for local development:

```
AUTH_URL="http://localhost:3000"
```

#### Google OAuth — *optional for local dev*

If you want Google login working locally:

1. Go to [console.developers.google.com](https://console.developers.google.com)
2. Create a new project or select an existing one
3. Navigate to **APIs & Services → Credentials → Create Credentials → OAuth client ID**
4. Application type: **Web application**
5. Authorised redirect URI: `http://localhost:3000/api/auth/callback/google`
6. Copy the Client ID and Client Secret into `AUTH_GOOGLE_ID` and `AUTH_GOOGLE_SECRET`

> Skip this and use magic link email login instead if you don't need Google OAuth right now.

#### GitHub OAuth — *optional for local dev*

1. Go to [github.com/settings/developers](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Homepage URL: `http://localhost:3000`
4. Authorization callback URL: `http://localhost:3000/api/auth/callback/github`
5. Copy the Client ID and Client Secret into `AUTH_GITHUB_ID` and `AUTH_GITHUB_SECRET`

#### Stripe — *optional, required only for billing features*

1. Create a free account at [stripe.com](https://stripe.com)
2. Make sure you are in **Test mode** (toggle in the top-left of the dashboard)
3. Go to **Developers → API keys**
4. Copy the **Secret key** (`sk_test_...`) into `STRIPE_SECRET_KEY`
5. Copy the **Publishable key** (`pk_test_...`) into `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY`
6. Leave `STRIPE_WEBHOOK_SECRET` blank for now — it is set in Step 5

#### Resend (email) — *optional*

1. Create a free account at [resend.com](https://resend.com)
2. Go to **API Keys → Create API Key**
3. Copy the key into `RESEND_API_KEY`

> Without a Resend key, magic link emails are logged to the console instead of delivered.

---

### Step 3 — Start infrastructure

Make sure Docker Desktop is running, then start the database and cache:

```bash
docker compose up -d
```

Verify both containers are running:

```bash
docker compose ps
```

Expected output:

```
NAME                STATUS
nextask-postgres    running
nextask-redis       running
```

> Wait about 15 seconds after this command before continuing — PostgreSQL needs
> time to finish initialising.

---

### Step 4 — Install dependencies and set up the database

Install all workspace packages:

```bash
pnpm install
```

This may take 1–2 minutes on the first run. Once complete, push the Prisma
schema to the database and seed it with demo data:

```bash
pnpm db:push
pnpm db:seed
```

`db:push` creates all tables. `db:seed` creates a demo workspace, two user
accounts, and sample projects so you have data to work with immediately.

To inspect the database visually at any time:

```bash
pnpm db:studio
```

Opens Prisma Studio at [http://localhost:5555](http://localhost:5555).

---

### Step 5 — Start Stripe webhook forwarding *(skip if not using billing)*

In a **separate terminal**, run:

```bash
pnpm stripe:listen
```

The output will include a line like:

```
> Ready! Your webhook signing secret is whsec_abc123...
```

Copy that value and paste it into `apps/web/.env.local` as `STRIPE_WEBHOOK_SECRET`.

Keep this terminal running while developing billing features. You can test
webhook events in another terminal:

```bash
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_failed
```

---

### Step 6 — Start the development server

```bash
pnpm dev
```

Turborepo starts the Next.js frontend and the tRPC API together.

| Service | URL |
|---------|-----|
| Frontend | [http://localhost:3000](http://localhost:3000) |
| API | [http://localhost:4000](http://localhost:4000) |
| Prisma Studio | [http://localhost:5555](http://localhost:5555) *(when running)* |

Log in using one of the seeded accounts. Check `packages/db/prisma/seed.ts`
for the email addresses and passwords created by `db:seed`.

---

### Step 7 — Open Claude Code

In the project root (same directory as `CLAUDE.md`):

```bash
claude
```

See [Verifying Claude Code is wired up](#verifying-claude-code-is-wired-up) below.

---

### Useful commands (day-to-day)

```bash
pnpm dev              # Start all services
pnpm test             # Run Vitest in watch mode
pnpm test:e2e         # Run Playwright (needs dev server running)
pnpm typecheck        # tsc --noEmit across all packages
pnpm lint:fix         # ESLint + Prettier
pnpm db:push          # Apply schema changes to dev DB
pnpm db:seed          # Re-seed the database
pnpm db:studio        # Open Prisma Studio
pnpm build            # Production build
```

---

---

## Python API (Helios)

An ML-powered analytics API — FastAPI, SQLAlchemy 2 (async), Celery, scikit-learn.

### Prerequisites

| Tool | Version | Check | Install |
|------|---------|-------|---------|
| Python | 3.12+ | `python3 --version` | [python.org](https://python.org) |
| uv | latest | `uv --version` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| Docker Desktop | latest | `docker --version` | [docker.com](https://docker.com) |
| make | any | `make --version` | pre-installed on macOS/Linux |
| Claude Code | latest | `claude --version` | `npm i -g @anthropic-ai/claude-code` |
| Git | any | `git --version` | pre-installed on most systems |

> `uv` is strongly recommended over plain `pip` — it is 10–100× faster.
> If you prefer pip, every `uv` command below has a pip equivalent noted.

---

### Step 1 — Get the project files

**Option A — bootstrap a fresh project:**

```bash
mkdir helios && cd helios
curl -O https://raw.githubusercontent.com/mohitparshar/claude-code-boilerplate/main/bootstrap.sh
bash bootstrap.sh helios
```

**Option B — copy the example config into an existing Python project:**

```bash
cd your-existing-project
cp -r path/to/examples/python-api/.claude .
cp path/to/examples/python-api/CLAUDE.md .
cp path/to/examples/python-api/.env.example .env.example
```

---

### Step 2 — Set up environment variables

```bash
cp .env.example .env
```

Open `.env` and fill in the following.

#### API_KEY_SALT — **required**

Generate a secure random value:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Paste the output as the value of `API_KEY_SALT`.

#### DATABASE_URL and REDIS_URL — **pre-filled**

The values in `.env.example` are pre-configured to match the Docker Compose
services. Leave them unchanged for local development:

```
DATABASE_URL="postgresql+asyncpg://postgres:postgres@localhost:5432/helios_dev"
SYNC_DATABASE_URL="postgresql+psycopg2://postgres:postgres@localhost:5432/helios_dev"
REDIS_URL="redis://localhost:6379/0"
CELERY_BROKER_URL="redis://localhost:6379/1"
CELERY_RESULT_BACKEND="redis://localhost:6379/2"
```

#### MODEL_PATH — **required if using ML inference**

Points to a trained scikit-learn model file. For initial setup without a trained
model, set to any path — the app will start but inference endpoints will return
a 503 until a model file exists at that path:

```
MODEL_PATH="app/ml/models/anomaly_v2.pkl"
MODEL_THRESHOLD="0.85"
```

#### SENTRY_DSN — *optional*

Leave blank for local development. Error tracking is disabled when this is empty.

---

### Step 3 — Start infrastructure

Make sure Docker Desktop is running, then start PostgreSQL and Redis:

```bash
docker compose up -d
```

Verify both containers are healthy:

```bash
docker compose ps
```

Expected output:

```
NAME               STATUS
helios-postgres    running
helios-redis       running
```

---

### Step 4 — Create the virtual environment and install dependencies

```bash
# With uv (recommended)
uv venv
source .venv/bin/activate       # macOS / Linux
# .venv\Scripts\activate        # Windows

uv pip install -r requirements.txt
```

```bash
# With pip (alternative)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Verify the install:

```bash
python3 -c "import fastapi, sqlalchemy, celery; print('Dependencies OK')"
```

---

### Step 5 — Run database migrations

Apply all Alembic migrations to create the database tables:

```bash
make migrate
```

This runs `alembic upgrade head`. You should see output listing each migration
revision being applied.

Seed the database with sample organisations, API keys, and events:

```bash
make seed
```

Verify the connection and schema:

```bash
python3 -c "
from app.db.session import SyncSessionLocal
from app.db.models import *
with SyncSessionLocal() as db:
    print('Database connected and schema OK')
"
```

---

### Step 6 — Start the API server

In your **first terminal**:

```bash
make dev
```

This runs `uvicorn app.main:app --reload`. The API starts at
[http://localhost:8000](http://localhost:8000).

Open the interactive API docs:

| URL | Description |
|-----|-------------|
| [http://localhost:8000/docs](http://localhost:8000/docs) | Swagger UI — try endpoints interactively |
| [http://localhost:8000/redoc](http://localhost:8000/redoc) | ReDoc — clean reference docs |
| [http://localhost:8000/api/v1/health](http://localhost:8000/api/v1/health) | Health check endpoint |

---

### Step 7 — Start the Celery worker

In a **second terminal** (with the virtualenv activated):

```bash
make worker
```

The worker processes async tasks — ML inference jobs, email delivery, data
aggregation. The API server can run without it, but endpoints that dispatch
tasks will queue them without processing until the worker is running.

To also start the beat scheduler for periodic tasks:

```bash
make worker-beat
```

---

### Step 8 — Get a seeded API key

All API endpoints require an API key. Print the keys created by `make seed`:

```bash
python3 scripts/print_keys.py
```

Use the key in requests:

```bash
# Health check (no auth required)
curl http://localhost:8000/api/v1/health

# Authenticated request
curl -H "X-API-Key: YOUR_KEY_HERE" http://localhost:8000/api/v1/events
```

Or paste the key into the **Authorize** button in the Swagger UI at
[http://localhost:8000/docs](http://localhost:8000/docs).

---

### Step 9 — Run the test suite and linters

Before opening Claude Code, verify the baseline is clean:

```bash
make test          # pytest — all tests should pass
make typecheck     # mypy app/ --strict
make lint          # ruff check + ruff format --check
```

---

### Step 10 — Open Claude Code

In the project root (same directory as `CLAUDE.md`):

```bash
claude
```

See [Verifying Claude Code is wired up](#verifying-claude-code-is-wired-up) below.

---

### Useful commands (day-to-day)

```bash
make dev           # Start FastAPI server (uvicorn --reload)
make worker        # Start Celery worker
make test          # Run pytest suite
make test-cov      # pytest with coverage report
make typecheck     # mypy app/ --strict
make lint          # ruff check + format check
make lint-fix      # ruff --fix + format
make migrate       # alembic upgrade head
make migrate-new   # alembic revision --autogenerate -m "description"
make migrate-down  # alembic downgrade -1
make shell         # IPython shell with app context
make db-reset      # Drop, recreate, and re-seed dev database
```

---

---

## Verifying Claude Code is wired up

Run these checks after opening Claude Code in either project to confirm every
layer of the configuration is active.

### 1. CLAUDE.md is being read

Paste this prompt into Claude Code without any other context:

```
What is this project, what stack does it use, and what are the key commands?
```

Claude should answer accurately from `CLAUDE.md` — including the correct
framework names, package manager, and commands. If it gives generic answers
or says it doesn't know, the `CLAUDE.md` file may not be in the working
directory.

### 2. Slash commands are available

Type `/` and look for the commands defined in `.claude/commands/`:

```
/review     /test     /spec     /commit     /migrate     /debug
```

They should appear as autocomplete suggestions. Run `/review` — Claude should
follow the step-by-step instructions in the command file, not improvise.

### 3. Hooks are firing

Create or edit any file in the project, then check the terminal output.

**Next.js project** — after writing a `.ts` or `.tsx` file you should see:

```
→ TypeScript changed, running typecheck...
```

**Python project** — after writing a `.py` file you should see:

```
→ Python file changed, running ruff + mypy...
```

If hook output does not appear, check that the hook scripts are executable:

```bash
chmod +x .claude/hooks/*.sh
```

And confirm the hooks are wired in `.claude/settings.json`:

```json
"hooks": {
  "PostToolUse": ".claude/hooks/post-tool-use.sh",
  "PreToolUse": ".claude/hooks/pre-tool-use.sh"
}
```

### 4. Agents are accessible

Ask Claude to use a specific agent:

```
# Next.js
Review this tRPC router using the reviewer agent.

# Python
Add an endpoint following the create-endpoint skill.
```

Claude should reference the agent's rules (procedure types for tRPC, repository
pattern for Python) rather than making up its own approach.

### 5. Session log is being written

After running a few commands, check the session log exists:

```bash
cat .claude/logs/session.log
```

Each line should be a timestamped tool call. This confirms the `post-tool-use`
and `stop` hooks are both executing.

---

## Troubleshooting

### `bad substitution` when running bootstrap.sh

You are running the script with `sh` instead of `bash`:

```bash
# Wrong
sh bootstrap.sh

# Correct
bash bootstrap.sh
```

---

### Docker containers not starting

Check Docker Desktop is running, then:

```bash
docker compose down
docker compose up -d
docker compose logs postgres    # inspect startup errors
```

If port 5432 is already in use by a local PostgreSQL installation:

```bash
# Find what is using the port
lsof -i :5432

# Change the docker compose port mapping in docker-compose.yml:
# "5433:5432"  instead of  "5432:5432"
# Then update DATABASE_URL to use port 5433
```

---

### `pnpm db:push` fails with connection error

PostgreSQL needs ~15 seconds after `docker compose up -d` to finish
initialising. Wait and retry:

```bash
sleep 15 && pnpm db:push
```

---

### Hooks not triggering in Claude Code

1. Check hooks are executable: `chmod +x .claude/hooks/*.sh`
2. Verify `settings.json` has the `hooks` object (not inside `permissions`)
3. Make sure you are running `claude` from the project root where `CLAUDE.md` lives
4. On Windows/WSL: confirm the hook shebangs use `#!/usr/bin/env bash`

---

### `mypy` or `ruff` not found in post-tool-use hook (Python)

The hook runs in a new shell that may not have the virtualenv activated. Fix by
using the full path to the venv binaries:

```bash
# In .claude/hooks/post-tool-use.sh, replace:
ruff check "$FILE"
mypy "$FILE"

# With:
.venv/bin/ruff check "$FILE"
.venv/bin/mypy "$FILE" --ignore-missing-imports
```

---

### Stripe webhook secret not being picked up

1. Ensure `pnpm stripe:listen` is running in a separate terminal
2. Copy the `whsec_...` value printed at startup into `STRIPE_WEBHOOK_SECRET` in `.env.local`
3. Restart the dev server (`Ctrl+C` then `pnpm dev`) so it picks up the new env value

---

### Alembic migration blocked by pre-tool-use hook

The hook blocks edits to **committed** migration files in `alembic/versions/`.
This is intentional — editing a committed migration is almost always the wrong
move. Instead, create a new revision:

```bash
make migrate-new
# Enter a description like: fix_nullable_column_in_events
```

---

### Port conflicts

| Service | Default port | Change in |
|---------|-------------|-----------|
| Next.js frontend | 3000 | `apps/web/package.json` dev script |
| tRPC API | 4000 | `apps/api/package.json` dev script |
| FastAPI | 8000 | `APP_PORT` in `.env` |
| PostgreSQL | 5432 | `docker-compose.yml` port mapping |
| Redis | 6379 | `docker-compose.yml` port mapping |
| Prisma Studio | 5555 | `pnpm db:studio` flag `--port` |
