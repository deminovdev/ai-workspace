#!/bin/bash
# PreToolUse hook — выполняется перед использованием инструмента.
# Возврат non-zero кода блокирует выполнение инструмента.
# Получает данные через stdin: tool_name, command и т.д.
#
# Подключение в .claude/settings.json:
# "hooks": {
#   "PreToolUse": [{
#     "matcher": {"tool_name": "Bash"},
#     "command": "bash modules/hooks/pre-tool-use.sh"
#   }]
# }

TOOL_DATA=$(cat)
COMMAND=$(echo "$TOOL_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null)

# Блокируем опасные паттерны (дополняй по необходимости)
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "dd if="
  "> /dev/sd"
  "mkfs"
)

for PATTERN in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$PATTERN"; then
    echo "Blocked: dangerous command pattern detected: $PATTERN" >&2
    exit 1
  fi
done

exit 0
