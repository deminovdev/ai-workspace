#!/bin/bash
# Circuit Breaker — останавливает спираль ошибок агента.
#
# Два режима (передать как $1):
#   --record   PostToolUse: фиксирует успех или ошибку инструмента
#   --check    PreToolUse:  блокирует если порог ошибок превышен
#
# Настройка через env:
#   CLAUDE_CIRCUIT_BREAKER_MAX=3   # максимум последовательных ошибок (дефолт)
#   CLAUDE_CIRCUIT_BREAKER_RESET=1 # сбросить счётчик вручную (любой non-empty)
#
# Подключение в .claude/settings.json:
#   PostToolUse: bash circuit-breaker.sh --record  (matcher: "" = все инструменты)
#   PreToolUse:  bash circuit-breaker.sh --check   (matcher: "" = все инструменты)

MODE="${1:---check}"
MAX_FAILURES="${CLAUDE_CIRCUIT_BREAKER_MAX:-3}"
STATE_FILE="/tmp/claude-circuit-$(basename "$PWD").json"

# Ручной сброс
if [[ -n "${CLAUDE_CIRCUIT_BREAKER_RESET:-}" ]]; then
  echo '{"failures": 0, "last_reset": "manual"}' > "$STATE_FILE"
  echo "circuit-breaker: сброшен" >&2
  exit 0
fi

# Инициализация state
if [[ ! -f "$STATE_FILE" ]]; then
  echo '{"failures": 0}' > "$STATE_FILE"
fi

read_failures() {
  python3 -c "
import json
try:
    d = json.load(open('$STATE_FILE'))
    print(d.get('failures', 0))
except:
    print(0)
" 2>/dev/null || echo 0
}

write_failures() {
  local count="$1"
  local reason="$2"
  python3 -c "
import json, time
with open('$STATE_FILE', 'w') as f:
    json.dump({'failures': $count, 'updated': time.time(), 'reason': '$reason'}, f)
" 2>/dev/null
}

# ─── --check: PreToolUse — блокировать если порог достигнут ─────────────────

if [[ "$MODE" == "--check" ]]; then
  # Читаем stdin (обязательно для PreToolUse хуков)
  TOOL_DATA=$(cat)

  failures=$(read_failures)

  if [[ "$failures" -ge "$MAX_FAILURES" ]]; then
    echo "" >&2
    echo "╔══════════════════════════════════════════════════════╗" >&2
    echo "║  circuit-breaker: ОТКРЫТ                             ║" >&2
    echo "╠══════════════════════════════════════════════════════╣" >&2
    printf "║  %d последовательных ошибок — работа остановлена.    ║\n" "$failures" >&2
    echo "║                                                      ║" >&2
    echo "║  Диагностируй причину, затем сбрось счётчик:         ║" >&2
    echo "║  CLAUDE_CIRCUIT_BREAKER_RESET=1 bash circuit-breaker.sh" >&2
    echo "║  или удали: /tmp/claude-circuit-$(basename "$PWD").json" >&2
    echo "╚══════════════════════════════════════════════════════╝" >&2
    echo "" >&2
    exit 2
  fi

  exit 0
fi

# ─── --record: PostToolUse — фиксируем результат инструмента ────────────────

if [[ "$MODE" == "--record" ]]; then
  TOOL_DATA=$(cat)

  # Определяем: ошибка или успех
  IS_ERROR=$(python3 -c "
import sys, json

try:
    d = json.load(sys.stdin)
except:
    print('false')
    sys.exit(0)

response = d.get('tool_response', {})

# Bash: ненулевой exit code
exit_code = response.get('exit_code', 0)
if isinstance(exit_code, int) and exit_code != 0:
    print('true')
    sys.exit(0)

# Любой инструмент: явная ошибка в ответе
if response.get('error') or response.get('is_error'):
    print('true')
    sys.exit(0)

# Строковый ответ с признаками ошибки
output = str(response.get('output', '') or response.get('content', ''))
error_markers = ['Error:', 'error:', 'FAILED', 'No such file', 'Permission denied', 'command not found']
if any(m in output for m in error_markers) and exit_code != 0:
    print('true')
    sys.exit(0)

print('false')
" <<< "$TOOL_DATA" 2>/dev/null || echo "false")

  current=$(read_failures)

  if [[ "$IS_ERROR" == "true" ]]; then
    new_count=$((current + 1))
    write_failures "$new_count" "error"
    if [[ "$new_count" -ge "$MAX_FAILURES" ]]; then
      echo "circuit-breaker: $new_count/$MAX_FAILURES ошибок — цепь разомкнётся на следующем вызове" >&2
    else
      echo "circuit-breaker: $new_count/$MAX_FAILURES ошибок" >&2
    fi
  else
    if [[ "$current" -gt 0 ]]; then
      write_failures 0 "success"
      echo "circuit-breaker: сброс (было $current ошибок)" >&2
    fi
  fi

  exit 0
fi

echo "Использование: $0 --check | --record" >&2
exit 1
