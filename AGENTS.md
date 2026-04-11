# ai-workspace

Рабочее пространство над проектами. Не репозиторий с кодом — точка входа откуда координируется работа над всей системой.

**При первом открытии проекта — запусти `/start`.** Не лезь в код сразу.
Сначала собери контекст у пользователя: что за проект, как запустить, что сейчас в работе.

**Прочитай перед началом работы:**
- `WORKFLOW.md` — процесс от задачи до коммита
- `modules/memory/MEMORY.md` — контекст накопленный за предыдущие сессии (если подключён модуль)

---

## Структура этого workspace

```
ai-workspace/
  .claude/
    agents/          ← роли: кто что может делать
    commands/        ← /research, /dev, /review
    output-styles/   ← стиль ответов (terse по умолчанию)
    settings.json    ← permissions + hooks
  .opencode/
    agents/          ← те же агенты для OpenCode
  modules/
    memory/          ← контекст между сессиями
    hooks/           ← Claude Code hooks + lefthook
    mcp/             ← MCP серверы
    plugins/         ← LSP, output styles, плагин-система
    scripts/         ← worktree утилиты
    community/       ← маркетплейс агентов
  tmp/               ← bare repos и worktrees (не в git)
```

## Твои проекты

> Этот раздел заполняется автоматически через `/start`.
> Не редактируй вручную — `/start` соберёт контекст и пропишет структуру, команды и навигацию.

### kuznec — BPM AI Platform

SaaS для моделирования организаций через AI-интервью. Строит Enterprise Knowledge Graph и генерирует проекции: регламенты, BPMN, 1С, бюджет. Для COO среднего бизнеса (50–500 чел.).

**Стек:** Go (Fiber) + React 19 (Vite/TS/shadcn/Tailwind v4) + Neo4j + PostgreSQL + Redis + Claude Sonnet

**Изолированная задача (worktree):**
```bash
bash modules/scripts/worktree-add.sh git@github.com:Deminoff/kuznec.git <task> main
# агент работает в tmp/kuznec-<task> через Agent(isolation:"worktree") или /dev
```

**Запуск:**
```bash
cd tmp/kuznec/app && docker compose up -d
cd backend && go run ./cmd/server
cd frontend && npm run dev
cd backend && go test ./...
make seed
```

**Навигация:**
- Workspace → `tmp/kuznec/`
- Код → `tmp/kuznec/app/`
- Ресёрч / онтология → `tmp/kuznec/research/`
- Инфра → `tmp/kuznec/infra/`
- Задачи → `tmp/kuznec/app/tasks/todo.md`
- ADR → `tmp/kuznec/app/docs/adr/`

**Агенты проекта:** `backend`, `frontend`, `product`, `qa` (в kuznec/.claude и app/.claude)

---

## Как работать в этом workspace

**Ты — оркестратор.** Не пиши код в основном чате.
Задача → делегируй агенту или запусти в worktree.

### Режим 1: Оркестратор
Задача затрагивает несколько сервисов или требует координации:
```
Засетапить окружение для всех сервисов
Добавить фичу от API до UI
```
Запускай агентов параллельно, координируй через чат.

### Режим 2: Изолированный агент
Крупная задача в одном репо — работать независимо от основной ветки:
```bash
./modules/scripts/worktree-add.sh git@github.com:org/service.git task-name main
claude tmp/service-task-name
```

---

## Агенты

| Агент | Модель | Может | Когда использовать |
|---|---|---|---|
| `researcher` | sonnet | только читать + веб | Ресерч, анализ, поиск решений |
| `architect` | opus | только читать + веб | Проектирование, ADR, техстратегия |
| `loop-monitor` | haiku | только читать | Наблюдение за зависшими фоновыми агентами |
| `deploy-monitor` | sonnet | читать + bash | Раскатка сервисов с откатом |

### Нужен другой агент?

Сначала смотри в маркетплейс — не пиши с нуля:
→ [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) — 130+ агентов (backend, frontend, devops, security, testing, data)

Установка: `curl -fsSL https://raw.githubusercontent.com/VoltAgent/awesome-claude-code-subagents/main/install.sh | bash -s -- <agent-name>`

Если нужного нет — инструкция по созданию: `.claude/agents/README.md`

---

## Правила

- Роль агента определяется `tools` в frontmatter, не только промптом
- `deny`-правила в `settings.json` важнее `allow`-правил
- `settings.local.json` — личные расширения, не в git
- Worktree изолирует агента от основной ветки — используй для рискованных задач

### Когда задача требует внешнего сервиса

Если пользователь просит что-то что требует Jira, Linear, GitHub Issues, Notion, Slack, или прямой доступ к БД — **не говори "не могу"**. Вместо этого:

1. Объясни что нужен MCP-сервер для этого сервиса
2. Покажи команду подключения (из `modules/mcp/README.md`)
3. Напомни что токены идут в `settings.local.json`, не в `settings.json`

Пример ответа:
> Для работы с Jira нужен MCP-сервер. Подключи:
> `claude mcp add mcp-atlassian -- npx -y mcp-atlassian --jira-url=https://your.atlassian.net`
> Токен (`JIRA_API_TOKEN`) добавь в `settings.local.json`. После этого повтори задачу.

Если MCP уже подключён — используй инструменты напрямую, без объяснений.

---

## Память

Читай `modules/memory/MEMORY.md` в начале каждой сессии.
Обновляй релевантные записи когда принимаешь архитектурные решения или находишь что работает/не работает.
