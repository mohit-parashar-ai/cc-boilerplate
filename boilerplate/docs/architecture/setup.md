# Local development setup

## Prerequisites
- Node.js 20+
- pnpm 8+
- Docker Desktop

## First-time setup

```bash
# 1. Clone and install
git clone <repo-url>
cd my-project
pnpm install

# 2. Environment
cp .env.example .env.local
# Fill in the required values (see below)

# 3. Start infrastructure
docker compose up -d

# 4. Database
pnpm db:push
pnpm db:seed

# 5. Start dev servers
pnpm dev
```

## Environment variables
See `.env.example` — all variables are documented there.

Required for local dev:
- `DATABASE_URL` — set automatically by docker compose
- `REDIS_URL` — set automatically by docker compose
- `JWT_SECRET` — any random string locally

## Useful commands
See `CLAUDE.md` for the full command reference.
