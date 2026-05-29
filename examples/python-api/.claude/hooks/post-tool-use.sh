#!/usr/bin/env bash
# PostToolUse hook — Helios Python API
# Auto-runs mypy + ruff after Python file changes.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" || "$TOOL" == "MultiEdit" ]]; then
  FILE=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',d.get('path','')))" 2>/dev/null <<< "$INPUT" || true)

  if [[ "$FILE" == *.py ]]; then
    echo "→ Python file changed, running ruff + mypy..." >&2

    # Ruff lint (fast — runs first)
    if command -v ruff &>/dev/null; then
      ruff check "$FILE" 2>&1 | head -20 || true
    fi

    # Mypy type check on the changed file
    if command -v mypy &>/dev/null; then
      mypy "$FILE" --ignore-missing-imports 2>&1 | tail -15 || true
    fi
  fi

  # Warn if a new model was added without a migration
  if [[ "$FILE" == "app/db/models/"*.py ]]; then
    echo "→ DB model changed — remember to run 'make migrate-new' to generate a migration" >&2
  fi
fi

# Log tool usage
mkdir -p .claude/logs
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TOOL=$TOOL" >> .claude/logs/session.log

exit 0
