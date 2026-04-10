# community

Готовые агенты, скиллы и хуки от комьюнити. Не изобретай велосипед.

## Где искать

| Ресурс | Что там |
|---|---|
| [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Курируемый список: агенты, скиллы, хуки, команды |
| [wshobson/agents](https://github.com/wshobson/agents) | 182 готовых агента под разные задачи |
| [OpenCode agents](https://opencode.ai/docs/agents/) | Агенты для OpenCode |

## Как подключить агента

1. Найди агента в любом из репозиториев выше
2. Скопируй `.md` файл в `.claude/agents/` (или `.opencode/agents/`)
3. Убедись что frontmatter корректный:

```markdown
---
name: имя-агента
description: Одна строка — когда использовать этого агента
model: sonnet
tools: Read, Grep, Glob, Edit, Write, Bash
---

# Промпт агента...
```

4. Перезапусти Claude Code — агент появится автоматически

## Как подключить скилл

Скилл = slash-команда (`/название`). Файл кладётся в `.claude/commands/`:

```bash
cp some-skill.md .claude/commands/my-skill.md
```

Вызов: `/my-skill аргументы`

## Как подключить хук

Хук — скрипт который запускается в момент события. Пример в `modules/hooks/`.

1. Добавь скрипт в `modules/hooks/`
2. Пропиши в `.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [{"command": "bash modules/hooks/my-hook.sh"}]
  }
}
```

## Вклад в комьюнити

Если написал агента который работает хорошо — сделай PR в [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code).
