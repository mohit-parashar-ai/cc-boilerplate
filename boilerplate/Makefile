.PHONY: setup dev test typecheck lint build clean db-reset

setup:
	pnpm install
	cp -n .env.example .env.local || true
	docker compose up -d
	pnpm db:push
	pnpm db:seed
	@echo "✓ Setup complete. Run make dev to start."

dev:
	pnpm dev

test:
	pnpm test

test-e2e:
	pnpm test:e2e

typecheck:
	pnpm typecheck

lint:
	pnpm lint:fix

build:
	pnpm build

db-reset:
	pnpm prisma migrate reset --force
	pnpm db:seed

clean:
	rm -rf node_modules .next dist
	docker compose down
