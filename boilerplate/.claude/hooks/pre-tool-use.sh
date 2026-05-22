#!/usr/bin/env bash
# PreToolUse hook — runs before every tool call
# Environment: TOOL_NAME, TOOL_INPUT (JSON)
# Exit 1 to BLOCK the tool call; exit 0 to allow.

TOOL="${TOOL_NAME:-}"
INPUT="${TOOL_INPUT:-}"

# ── Block dangerous patterns in Bash calls ────────────────────────────────
if [[ "$TOOL" == "Bash" ]]; then
  CMD=$(echo "$INPUT" | grep -o command:[^]*' | cut -d' -f4 2>/dev/null || echo "$INPUT")

  # Block force-deletes of root or src
  if echo "$CMD" | grep -qE "rm -rf (/|~/|\./)$"; then
    echo "BLOCKED: Refusing dangerous rm -rf" >&2
    exit 1
  fi

  # Block piping remote scripts to shell
  if echo "$CMD" | grep -qE "(curl|wget).*(bash|sh)"; then
    echo "BLOCKED: Refusing remote script execution" >&2
    exit 1
  fi

  # Warn before DB destructive ops (don't block, just log)
  if echo "$CMD" | grep -qiE "(drop table|truncate|delete from)"; then
    echo "WARNING: Destructive DB operation detected — proceeding" >&2
  fi
fi

exit 0
