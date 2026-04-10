---
name: ai-workspace project memory
description: Контекст по самому workspace — структура, философия, как улучшать
type: project
---

ai-workspace — конфигурационный слой над проектами пользователя. Не репозиторий с кодом, а оркестрационная точка: агенты с enforced permissions, хуки, скрипты, память между сессиями.

**Why:** Пользователь создал этот workspace сам и продолжает его развивать. Код хранится в `tmp/` как worktree-клоны проектов.

**How to apply:** При улучшении workspace — понимать что это мета-инструмент. Изменения здесь влияют на поведение Claude во всех проектах. Быть консервативным с deny-правилами в `settings.json`.

---

**Стек:** Bash, Markdown, JSON. Без компилируемого кода.

**Ключевые файлы:**
- `.claude/settings.json` — глобальные permissions + hooks (в git)
- `.claude/settings.local.json` — личные расширения (не в git)
- `.claude/agents/` — роли агентов с enforced tools
- `.claude/commands/` — /start, /research, /dev, /review
- `modules/hooks/` — PreToolUse, PostToolUse, Stop, Notification, PreCompact
- `modules/scripts/` — worktree-add, worktree-clean, install-shell-tools
- `modules/memory/` — этот файл и другие записи памяти
- `AGENTS.md` — контекст-файл (читается Claude Code и OpenCode)

**Запуск:**
```bash
cp .claude/settings.local.json.example .claude/settings.local.json
claude .
# /start — подключить новый проект
```

**Архитектурные принципы:**
- `deny`-правила в `settings.json` важнее `allow` — не обходить
- `tools` в frontmatter агента — enforced, не suggestion
- `settings.local.json` — личное, не коммитить
- `tmp/` — worktrees и клоны, не в git
