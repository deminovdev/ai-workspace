#!/bin/bash
# PreToolUse hook — блокирует git commit с упоминанием AI-моделей в авторстве.
#
# Перехватывает любой Bash-вызов git commit и проверяет сообщение на:
# - Co-Authored-By: Claude / Anthropic
# - Co-Authored-By: GPT / OpenAI
# - Generated with Claude Code
# - 🤖 Generated with
# - any model ID patterns (claude-*, gpt-*, gemini-*)
#
# Возврат exit 2 = блок без возможности обойти (blocking).

TOOL_DATA=$(cat)
COMMAND=$(echo "$TOOL_DATA" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('tool_input', {}).get('command', ''))
" 2>/dev/null)

# Хук активен только для git commit
if ! echo "$COMMAND" | grep -qE 'git\s+commit'; then
  exit 0
fi

# Паттерны которые блокируем
BLOCKED_PATTERNS=(
  "[Cc]o-[Aa]uthored-[Bb]y:.*[Cc]laude"
  "[Cc]o-[Aa]uthored-[Bb]y:.*[Aa]nthropic"
  "[Cc]o-[Aa]uthored-[Bb]y:.*[Oo]pen[Aa][Ii]"
  "[Cc]o-[Aa]uthored-[Bb]y:.*GPT"
  "[Cc]o-[Aa]uthored-[Bb]y:.*[Gg]emini"
  "Generated with \[Claude"
  "Generated with Claude"
  "🤖 Generated with"
  "noreply@anthropic\.com"
  "claude-opus"
  "claude-sonnet"
  "claude-haiku"
  "gpt-4"
  "gpt-3"
  "gemini-"
)

for PATTERN in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$PATTERN"; then
    echo "" >&2
    echo "╔══════════════════════════════════════════════════════╗" >&2
    echo "║  commit-guard: BLOCKED                               ║" >&2
    echo "╠══════════════════════════════════════════════════════╣" >&2
    echo "║  Найдено упоминание AI-модели в commit message.      ║" >&2
    echo "║  Паттерн: $PATTERN" >&2
    echo "║                                                      ║" >&2
    echo "║  Убери строки вида:                                  ║" >&2
    echo "║    Co-Authored-By: Claude ...                        ║" >&2
    echo "║    🤖 Generated with [Claude Code]                   ║" >&2
    echo "╚══════════════════════════════════════════════════════╝" >&2
    echo "" >&2
    exit 2
  fi
done

exit 0
