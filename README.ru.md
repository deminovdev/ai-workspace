# ai-workspace

**Работай над проектами, а не внутри них.**

Слой workspace превращает Claude Code из автодополнения в команду. Агенты с реальными ограничениями по правам работают параллельно в разных репозиториях. Ты координируешь.

[English version →](README.md)

---

## Проблема

Обычный сценарий: открываешь репо, запускаешь `claude`, работаешь внутри него. Claude видит только это репо.

Реальные задачи так не устроены. "Добавить фичу" — это endpoint в бэкенде, страница во фронте, миграция в базе. "Засетапить staging" — 12 сервисов и несколько конфигов. Claude, запущенный внутри одного репо, не видит систему целиком.

## Паттерн

```
ai-workspace/          ← Claude открытый здесь видит всё
  .claude/
    agents/            ← роли с ограниченными правами
    settings.json      ← deny-правила для всего workspace
  modules/
    hooks/             ← PreToolUse, Stop, PreCompact
    scripts/           ← утилиты для worktree
    memory/            ← контекст между сессиями
  tmp/                 ← worktrees для параллельной работы агентов
  AGENTS.md            ← контекстный файл (читают Claude Code и OpenCode)
```

Claude, открытый в корне workspace, видит все проекты в `tmp/`. Агенты с ограниченным списком `tools` не могут выйти за пределы своих прав — не по просьбе, а по архитектуре.

## Два режима

**Оркестратор** — задача затрагивает несколько сервисов:
```
Засетапить staging для всех сервисов
Добавить авторизацию end-to-end: endpoint + страница + миграция
```
Основной чат координирует. Агенты работают параллельно.

**Изолированный агент** — крупная задача в одном репо, основная ветка остаётся чистой:
```bash
./modules/scripts/worktree-add.sh git@github.com:org/backend.git feature-auth main
claude tmp/backend-feature-auth
```

## Быстрый старт

```bash
git clone https://github.com/deminovdev/ai-workspace
cd ai-workspace

# Личные настройки (git push, ssh-ключи, MCP-токены)
cp .claude/settings.local.json.example .claude/settings.local.json

# Подключи первый проект
claude .
# Затем: /start
```

`/start` определяет проект автоматически — читает `CLAUDE.md` / `AGENTS.md` если они есть, определяет стек по `Makefile` / `go.mod` / `package.json`, настраивает права.

## Что включено

| | |
|---|---|
| **Агенты** | `researcher` (поиск в вебе, только чтение), `architect` (проектирование, ADR), `loop-monitor` (watchdog), `deploy-monitor` (раскатка с откатом) |
| **Хуки** | `commit-guard` (блокирует упоминания AI-моделей в коммитах), `velocity-governor` (TPM-лимит для фоновых агентов), `stop` (лог сессий) |
| **Скрипты** | `worktree-add`, `worktree-clean`, `sync-all`, `shell-tools` (`cw`/`cr`) |
| **Память** | Файловый контекст, сохраняется между сессиями |
| **Команды** | `/start`, `/research`, `/dev`, `/review` |

## Права агентов — это архитектура

`tools` в frontmatter агента — это не подсказка, это ограничение, которое применяет Claude Code.

```markdown
---
name: researcher
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

У `researcher` нет `Write` и `Edit`. Он физически не может изменить файл. Добавляй своих агентов — кидай `.md` в `.claude/agents/`.

## Права и безопасность

`settings.json` — базовые правила, коммитятся в git:
- Разрешено: чтение, поиск, `git status/log/diff`, worktree
- Запрещено: `rm -rf`, `git push --force`, `git reset --hard`

`settings.local.json` — личные расширения, не в git:
- `git push`, `ssh`, `curl`, токены MCP-серверов

Deny-правила важнее allow-правил. Начинай с ограничений — расширяй по необходимости.

## Shell-инструменты

```bash
# Выбор worktree через fzf, открывает в IDE, генерирует контекст ревью
cw

# Запуск ревью-сессии с git-контекстом и готовыми командами
cr  # "экскурсия", "риски", "summary", "тест"

# Установка
bash modules/scripts/install-shell-tools.sh --ide goland  # или cursor, code
```

## Совместимость

Работает с Claude Code и OpenCode. `AGENTS.md` читают оба инструмента. Агенты продублированы в `.claude/agents/` и `.opencode/agents/` с разным frontmatter.

---

## Документация

- [Инструкция по установке](SETUP.md)
- [Паттерн: оркестратор](docs/patterns/orchestrator.md)
- [Паттерн: изолированный агент](docs/patterns/worktree-agent.md)
- [Паттерн: loop monitor](docs/patterns/loop-monitor.md)
- [Workflow](WORKFLOW.md)
