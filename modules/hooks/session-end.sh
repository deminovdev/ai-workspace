#!/bin/bash
# SessionEnd hook — выполняется при завершении сессии Claude Code.
#
# Пишет в modules/memory/sessions.log:
#   - timestamp
#   - git commits сделанные за сессию
#   - git diff --stat (что изменилось)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="$PROJECT_DIR/modules/memory/sessions.log"
HOOK_DATA=$(cat)

# ── Дата и время ──────────────────────────────────────────────────────────────
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# ── Git контекст ──────────────────────────────────────────────────────────────
GIT_LOG=""
GIT_STAT=""

if git -C "$PROJECT_DIR" rev-parse --git-dir &>/dev/null 2>&1; then
  # Коммиты за последний час
  GIT_LOG=$(git -C "$PROJECT_DIR" log --oneline --since="1 hour ago" 2>/dev/null | head -10)
  # Что изменилось (unstaged + staged)
  GIT_STAT=$(git -C "$PROJECT_DIR" diff --stat HEAD 2>/dev/null | tail -1)
fi

# ── Запись ────────────────────────────────────────────────────────────────────
{
  echo ""
  echo "── $TIMESTAMP ──────────────────────────────────────────"
  if [[ -n "$GIT_LOG" ]]; then
    echo "commits:"
    echo "$GIT_LOG" | sed 's/^/  /'
  fi
  if [[ -n "$GIT_STAT" ]]; then
    echo "changes: $GIT_STAT"
  fi
} >> "$LOG_FILE"

exit 0
