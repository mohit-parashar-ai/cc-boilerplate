#!/usr/bin/env bash
# PreToolUse hook — Helios Python API
# Enforces safety rules specific to this service.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

if [[ "$TOOL" == "Bash" ]]; then
  CMD=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" 2>/dev/null <<< "$INPUT" || echo "$INPUT")

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

  # Block editing committed Alembic migrations
  if echo "$CMD" | grep -qE "alembic/versions/.*\.py"; then
    echo "BLOCKED: Do not edit committed Alembic migration files. Create a new revision instead." >&2
    exit 1
  fi

  # Warn on raw SQL in Python files (should use SQLAlchemy ORM)
  if echo "$CMD" | grep -qiE 'execute\("(SELECT|INSERT|UPDATE|DELETE)'; then
    echo "WARNING: Raw SQL detected — use SQLAlchemy ORM via the repository layer" >&2
  fi
fi

# Warn on direct writes to committed migration files
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" ]]; then
  FILE=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',d.get('path','')))" 2>/dev/null <<< "$INPUT" || true)
  if echo "$FILE" | grep -qE "alembic/versions/[a-f0-9]+_.*\.py"; then
    echo "BLOCKED: Do not edit committed Alembic migration files. Create a new revision instead." >&2
    exit 1
  fi
fi

exit 0
