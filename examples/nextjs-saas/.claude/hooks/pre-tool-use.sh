#!/usr/bin/env bash
# PreToolUse hook — NexTask SaaS
# Blocks dangerous patterns and enforces multi-tenant safety.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

if [[ "$TOOL" == "Bash" ]]; then
  CMD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null || echo "$INPUT")

  # Block dangerous deletes
  if echo "$CMD" | grep -qE "rm -rf (/|~/)$"; then
    echo "BLOCKED: Refusing dangerous rm -rf" >&2
    exit 1
  fi

  # Block remote script execution
  if echo "$CMD" | grep -qE "(curl|wget).*(bash|sh)"; then
    echo "BLOCKED: Refusing remote script execution" >&2
    exit 1
  fi

  # Block Stripe key exposure
  if echo "$CMD" | grep -qiE "stripe.*(key|secret)"; then
    echo "BLOCKED: Refusing Stripe key exposure command" >&2
    exit 1
  fi

  # Warn on cross-workspace queries (no workspaceId filter)
  if echo "$CMD" | grep -qiE "prisma\.(task|project|member)\.(find|update|delete)" && \
     ! echo "$CMD" | grep -q "workspaceId"; then
    echo "WARNING: Prisma query may be missing workspaceId filter — verify multi-tenant safety" >&2
  fi
fi

# Warn before touching the Prisma schema
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',d.get('path','')))" 2>/dev/null || true)
  if [[ "$FILE" == *"schema.prisma" ]]; then
    echo "WARNING: Modifying Prisma schema — remember to run 'pnpm db:push' after" >&2
  fi
fi

exit 0
