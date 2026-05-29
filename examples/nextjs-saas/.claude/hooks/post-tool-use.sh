#!/usr/bin/env bash
# PostToolUse hook — NexTask SaaS
# Auto-typechecks TypeScript and logs Prisma schema changes.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" || "$TOOL" == "MultiEdit" ]]; then
  FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',d.get('path','')))" 2>/dev/null || true)

  # Typecheck on TypeScript file changes
  if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
    echo "→ TypeScript changed, running typecheck..." >&2
    if command -v pnpm &>/dev/null; then
      pnpm typecheck 2>&1 | tail -20 || true
    fi
  fi

  # Auto-regenerate Prisma client after schema change
  if [[ "$FILE" == *"schema.prisma" ]]; then
    echo "→ Prisma schema changed, regenerating client..." >&2
    pnpm --filter @nexttask/db prisma generate 2>&1 | tail -5 || true
  fi
fi

# Log to session log
mkdir -p .claude/logs
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TOOL=$TOOL" >> .claude/logs/session.log

exit 0
