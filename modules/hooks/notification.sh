#!/bin/bash
# Notification hook — перехватывает уведомления Claude Code и форвардит в macOS.
#
# Приоритет инструментов:
#   1. alerter      — brew install vjeantet/tap/alerter  (рекомендуется)
#   2. terminal-notifier — brew install terminal-notifier (заброшен, Sequoia ломается)
#   3. osascript    — встроен, но ненадёжен из subprocess
#
# При первом запуске alerter сам запросит разрешение через системный диалог macOS.
#
# Каналы (включай через env в settings.local.json):
#   CLAUDE_NOTIFY_MACOS=1      — macOS уведомление (дефолт: включено)
#   CLAUDE_NOTIFY_SOUND=1      — звук (дефолт: выключено)
#   CLAUDE_NOTIFY_LOG=1        — писать в лог (дефолт: включено)
#   CLAUDE_NOTIFY_TELEGRAM=1   — Telegram (нужен TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID)

HOOK_DATA=$(cat)

MESSAGE=$(echo "$HOOK_DATA" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('message', d.get('title', 'Claude Code'))[:200])
except:
    print('Claude Code')
" 2>/dev/null || echo "Claude Code")

TITLE=$(echo "$HOOK_DATA" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('title', 'ai-workspace')[:100])
except:
    print('ai-workspace')
" 2>/dev/null || echo "ai-workspace")

# ── macOS уведомление ──────────────────────────────────────────────────────────

notify_macos() {
  local title="$1" msg="$2"

  if command -v alerter &>/dev/null; then
    local icon_arg=""
    local custom_icon="${CLAUDE_PROJECT_DIR}/modules/hooks/icon.png"
    [[ -f "$custom_icon" ]] && icon_arg="--app-icon $custom_icon"
    alerter --title "$title" --message "$msg" --timeout 8 $icon_arg 2>/dev/null &
    return 0
  fi

  if command -v terminal-notifier &>/dev/null; then
    terminal-notifier -title "$title" -message "$msg" 2>/dev/null &
    return 0
  fi

  # osascript fallback — передаём через env чтобы избежать проблем с экранированием
  NOTIFY_TITLE="$title" NOTIFY_MSG="$msg" \
    osascript -e 'display notification (system attribute "NOTIFY_MSG") with title (system attribute "NOTIFY_TITLE")' \
    2>/dev/null || true

  # Если ничего не установлено — подсказка при первом запуске
  local hint_file="/tmp/claude-notify-hint-shown"
  if [[ ! -f "$hint_file" ]]; then
    touch "$hint_file"
    echo "" >&2
    echo "ai-workspace: для надёжных уведомлений установи alerter:" >&2
    echo "  brew install vjeantet/tap/alerter" >&2
    echo "(после этого macOS сам запросит разрешение при первом уведомлении)" >&2
    echo "" >&2
  fi
}

# Уведомлять только когда реально нужен ответ пользователя
should_notify() {
  local msg="$1"
  [[ "$msg" == *"waiting for your input"* ]] && return 0
  [[ "$msg" == *"needs your permission"* ]] && return 0
  return 1
}

if [[ "${CLAUDE_NOTIFY_MACOS:-1}" == "1" ]] && should_notify "$MESSAGE"; then
  notify_macos "$TITLE" "$MESSAGE"
fi

# ── Звук ──────────────────────────────────────────────────────────────────────
if [[ "${CLAUDE_NOTIFY_SOUND:-0}" == "1" ]]; then
  afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &
fi

# ── Лог ───────────────────────────────────────────────────────────────────────
LOG_FILE="${CLAUDE_PROJECT_DIR}/modules/hooks/.notify.log"
if [[ "${CLAUDE_NOTIFY_LOG:-1}" == "1" ]] && [[ -d "$(dirname "$LOG_FILE")" ]]; then
  echo "[$(date +%H:%M:%S)] $TITLE: $MESSAGE" >> "$LOG_FILE"
fi

# ── Telegram ──────────────────────────────────────────────────────────────────
if [[ "${CLAUDE_NOTIFY_TELEGRAM:-0}" == "1" ]]; then
  if [[ -n "${TELEGRAM_BOT_TOKEN:-}" && -n "${TELEGRAM_CHAT_ID:-}" ]]; then
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
      -d "chat_id=${TELEGRAM_CHAT_ID}" \
      -d "text=*${TITLE}*: ${MESSAGE}" \
      -d "parse_mode=Markdown" \
      >/dev/null 2>&1 &
  fi
fi

exit 0
