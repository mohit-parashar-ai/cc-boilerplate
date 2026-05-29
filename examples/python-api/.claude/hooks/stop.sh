#!/usr/bin/env bash
# Stop hook — Helios Python API

mkdir -p .claude/logs
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] SESSION ENDED" >> .claude/logs/session.log

TOOL_COUNT=$(grep -c "TOOL=" .claude/logs/session.log 2>/dev/null || echo 0)
echo "Session complete. Tools used: $TOOL_COUNT" >&2

exit 0
