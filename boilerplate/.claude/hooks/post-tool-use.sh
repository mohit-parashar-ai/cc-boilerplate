#!/usr/bin/env bash
# PostToolUse hook — runs after every tool call
# Environment: TOOL_NAME, TOOL_INPUT (JSON), TOOL_OUTPUT (JSON)

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# ── Auto-typecheck after TypeScript file writes ───────────────────────────
if [[ "$TOOL" == "Write" || "$TOOL" == "Edit" || "$TOOL" == "MultiEdit" ]]; then
  FILE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',d.get('path','')))" 2>/dev/null || true)

  if [[ "$FILE" == *.ts || "$FILE" == *.tsx ]]; then
    echo "→ TypeScript file changed, running typecheck..." >&2
    if command -v pnpm &>/dev/null && [[ -f "package.json" ]]; then
      pnpm typecheck --noEmit 2>&1 | tail -20 || true
    fi
  fi
fi

# ── Log tool usage to session log ─────────────────────────────────────────
LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] TOOL=$TOOL" >> "$LOG_DIR/session.log"

exit 0
