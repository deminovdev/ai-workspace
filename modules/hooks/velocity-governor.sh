#!/bin/bash
# PreToolUse hook — ограничение скорости запросов (TPM).
# Защищает от сжигания API-квоты фоновыми агентами.
#
# Hookdata из stdin содержит tool_name и tool_input.
# Токены считаются приблизительно по размеру входных данных.
#
# Настройка через env:
#   CLAUDE_VELOCITY_MAX_TPM=50000  # токенов в минуту (дефолт)

MAX_TPM="${CLAUDE_VELOCITY_MAX_TPM:-50000}"
STATE_FILE="/tmp/claude-velocity-$(basename "$PWD").json"
WINDOW=60

now=$(date +%s)

# Читаем данные вызова инструмента для оценки токенов
HOOK_DATA=$(cat)
# Грубая оценка: 1 токен ≈ 4 символа
CALL_TOKENS=$(echo "$HOOK_DATA" | wc -c | tr -d ' ')
CALL_TOKENS=$(( CALL_TOKENS / 4 ))
[ "$CALL_TOKENS" -lt 1 ] && CALL_TOKENS=1

# Инициализация state
if [ ! -f "$STATE_FILE" ]; then
  echo "{\"window_start\": $now, \"tokens\": 0}" > "$STATE_FILE"
fi

window_start=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d['window_start'])" 2>/dev/null || echo "$now")
tokens=$(python3 -c "import json; d=json.load(open('$STATE_FILE')); print(d['tokens'])" 2>/dev/null || echo "0")
elapsed=$((now - window_start))

# Новое окно — сброс счётчика
if [ "$elapsed" -ge "$WINDOW" ]; then
  echo "{\"window_start\": $now, \"tokens\": $CALL_TOKENS}" > "$STATE_FILE"
  exit 0
fi

new_tokens=$((tokens + CALL_TOKENS))

# Проверяем лимит
if [ "$new_tokens" -ge "$MAX_TPM" ]; then
  wait=$((WINDOW - elapsed))
  echo "Velocity limit: $new_tokens/$MAX_TPM TPM. Waiting ${wait}s..." >&2
  sleep "$wait"
  echo "{\"window_start\": $(date +%s), \"tokens\": $CALL_TOKENS}" > "$STATE_FILE"
  exit 0
fi

# Инкрементируем счётчик
python3 -c "
import json
with open('$STATE_FILE', 'w') as f:
    json.dump({'window_start': $window_start, 'tokens': $new_tokens}, f)
" 2>/dev/null

exit 0
