#!/usr/bin/env bash
# Stop hook — runs when Claude finishes a session or task
# Good place for cleanup, summaries, or post-task automation.

LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"

echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SESSION ENDED" >> "$LOG_DIR/session.log"
echo "─────────────────────────────────────────────" >> "$LOG_DIR/session.log"

# Optional: print a session summary
TOOL_COUNT=$(grep -c "TOOL=" "$LOG_DIR/session.log" 2>/dev/null || echo 0)
echo "Session complete. Tools used: $TOOL_COUNT" >&2

exit 0
