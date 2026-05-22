#!/usr/bin/env bash
# Notification hook — fires when Claude sends a notification
# Environment: NOTIFICATION_TITLE, NOTIFICATION_MESSAGE

TITLE="${NOTIFICATION_TITLE:-Claude Code}"
MSG="${NOTIFICATION_MESSAGE:-Task update}"

echo "── NOTIFICATION ──────────────────────" >&2
echo "  $TITLE" >&2
echo "  $MSG" >&2
echo "──────────────────────────────────────" >&2

# macOS: uncomment to get native desktop notifications
# osascript -e "display notification \"$MSG\" with title \"$TITLE\""

# Linux (notify-send): uncomment if available
# notify-send "$TITLE" "$MSG" 2>/dev/null || true

exit 0
