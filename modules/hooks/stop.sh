#!/bin/bash
# Stop hook — выполняется когда агент завершил работу.
#
# Подключение в .claude/settings.json:
#   "Stop": [{"hooks": [{"type": "command", "command": "bash \"${CLAUDE_PROJECT_DIR}/modules/hooks/stop.sh\""}]}]

LOG_FILE="${CLAUDE_PROJECT_DIR}/modules/hooks/.stop.log"
WORKSPACE=$(basename "${CLAUDE_PROJECT_DIR:-$PWD}")

# Лог
if [ -d "$(dirname "$LOG_FILE")" ]; then
  echo "[$(date +%H:%M:%S)] Agent stopped" >> "$LOG_FILE"
fi

# macOS уведомление
osascript -e "display notification \"Агент завершил задачу\" with title \"$WORKSPACE\"" 2>/dev/null || true

exit 0
