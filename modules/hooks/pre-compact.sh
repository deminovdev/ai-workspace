#!/bin/bash
# PreCompact hook — сохранить контекст перед сжатием.
# Claude Code вызывает этот скрипт когда контекст достигает лимита.
# Скрипт получает данные сессии через stdin (JSON).
#
# Подключение в .claude/settings.json:
# "hooks": { "PreCompact": [{"command": "bash modules/hooks/pre-compact.sh"}] }

MEMORY_DIR="modules/memory"
SESSION_LOG="$MEMORY_DIR/session-$(date +%Y%m%d-%H%M%S).md"

# Читаем контекст сессии из stdin
SESSION_DATA=$(cat)

# Сохраняем сырой контекст (можно заменить на LLM-summary)
mkdir -p "$MEMORY_DIR"
cat > "$SESSION_LOG" <<EOF
---
name: Session $(date +%Y-%m-%d)
description: Автосейв перед сжатием контекста
type: project
date: $(date -u +%Y-%m-%dT%H:%M:%SZ)
---

$SESSION_DATA
EOF

echo "Memory saved: $SESSION_LOG" >&2
