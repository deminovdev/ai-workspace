#!/bin/bash
# SessionStart hook — выполняется при начале каждой сессии Claude Code.
#
# Делает:
#   1. Сбрасывает состояние circuit-breaker
#   2. Логирует начало сессии
#   3. Предупреждает если MEMORY.md не обновлялся больше 7 дней

HOOK_DATA=$(cat)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="$PROJECT_DIR/modules/hooks/.stop.log"
MEMORY_FILE="$PROJECT_DIR/modules/memory/MEMORY.md"
# ── 1. Сброс circuit-breaker ──────────────────────────────────────────────────
CIRCUIT_STATE="/tmp/claude-circuit-$(basename "$PROJECT_DIR").json"
if [[ -f "$CIRCUIT_STATE" ]]; then
  rm -f "$CIRCUIT_STATE"
fi

# ── 2. Лог начала сессии ──────────────────────────────────────────────────────
echo "[$(date +%H:%M:%S)] Session started" >> "$LOG_FILE"

# ── 3. Проверка свежести MEMORY.md ───────────────────────────────────────────
if [[ -f "$MEMORY_FILE" ]]; then
  last_modified=$(stat -f "%m" "$MEMORY_FILE" 2>/dev/null || stat -c "%Y" "$MEMORY_FILE" 2>/dev/null)
  now=$(date +%s)
  age_days=$(( (now - last_modified) / 86400 ))

  if [[ $age_days -gt 7 ]]; then
    echo "" >&2
    echo "⚠ MEMORY.md не обновлялся $age_days дней — проверь актуальность контекста." >&2
    echo "" >&2
  fi
fi

exit 0
