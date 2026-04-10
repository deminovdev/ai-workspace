# hooks

Два типа хуков: **Claude Code hooks** (основное) и **git hooks** через lefthook (опционально).

---

## Claude Code hooks

Срабатывают во время AI-сессии. Автоматизируют рутину без ручных команд.

### Типы

| Хук | Когда | Пример использования |
|---|---|---|
| `PreCompact` | Перед сжатием контекста | Сохранить ключевые решения в память |
| `Stop` | Когда агент завершил работу | Уведомление, лог выполненного |
| `PostToolUse` | После использования инструмента | Lint/format после правки файла |
| `PreToolUse` | Перед использованием инструмента | Валидация опасных bash-команд |
| `Notification` | На уведомления Claude | Системные алерты |

### Подключение

В `.claude/settings.json` добавь секцию `hooks`:

```json
{
  "hooks": {
    "PreCompact": [
      {"command": "bash modules/hooks/pre-compact.sh"}
    ],
    "Stop": [
      {"command": "bash modules/hooks/stop.sh"}
    ],
    "PostToolUse": [
      {
        "matcher": {"tool_name": "Write"},
        "command": "bash modules/hooks/post-tool-use.sh"
      }
    ],
    "PreToolUse": [
      {
        "matcher": {"tool_name": "Bash"},
        "command": "bash modules/hooks/pre-tool-use.sh"
      }
    ]
  }
}
```

### Примеры

- `pre-compact.sh` — сохраняет контекст сессии в `modules/memory/` перед сжатием
- `stop.sh` — логирует завершение задачи, опционально отправляет уведомление
- `post-tool-use.sh` — запускает lint после записи файла
- `pre-tool-use.sh` — блокирует опасные паттерны в bash-командах

---

## Git hooks (опционально)

`lefthook.yml` — шаблон для lint/test на pre-commit и pre-push.

```bash
brew install lefthook
cp modules/hooks/lefthook.yml ./lefthook.yml
lefthook install
```

Раскомментируй нужные блоки под свой стек (Go, TypeScript, Python).
