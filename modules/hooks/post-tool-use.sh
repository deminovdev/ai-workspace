#!/bin/bash
# PostToolUse hook — выполняется после использования инструмента.
# Получает данные через stdin: tool_name, file_path и т.д.
#
# Подключение в .claude/settings.json:
# "hooks": {
#   "PostToolUse": [{
#     "matcher": {"tool_name": "Write"},
#     "command": "bash modules/hooks/post-tool-use.sh"
#   }]
# }

# Читаем данные инструмента
TOOL_DATA=$(cat)
FILE_PATH=$(echo "$TOOL_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Lint по типу файла (раскомментируй нужное)
case "$FILE_PATH" in
  *.go)
    # gofmt -w "$FILE_PATH"
    # golangci-lint run "$FILE_PATH"
    ;;
  *.ts|*.tsx)
    # biome format --write "$FILE_PATH"
    ;;
  *.py)
    # ruff format "$FILE_PATH"
    ;;
esac

exit 0
