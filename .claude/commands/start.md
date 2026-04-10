Ты помогаешь подключить проект к ai-workspace. Действуй по шагам.

## Шаг 1 — Найди проект (один вопрос)

Спроси пользователя:

> Откуда подключаем проект?
> 1. Локальный путь (уже есть на диске или в tmp/)
> 2. Git URL (https или ssh — склонирую в tmp/)
> 3. SSH — подключусь к серверу и прочитаю нужное

Жди ответа. Не задавай других вопросов пока не получишь его.

## Шаг 2 — Разведка (без вопросов)

После ответа — автоматически собери контекст:

### Если вариант 1 (локальный путь):
- Прочитай верхушку файловой системы проекта (ls 2 уровня)
- Найди и прочитай: `CLAUDE.md`, `AGENTS.md`, `README.md` (что есть)
- Найди маркерные файлы стека (glob по корню и src/):

| Файл | Стек |
|---|---|
| `go.mod` | Go |
| `package.json` | Node.js / npm / yarn / pnpm |
| `Cargo.toml` | Rust |
| `pyproject.toml`, `requirements.txt`, `setup.py` | Python |
| `*.csproj`, `*.sln`, `global.json` | C# / .NET |
| `pom.xml` | Java / Maven |
| `build.gradle`, `build.gradle.kts` | Java / Kotlin / Gradle |
| `Gemfile` | Ruby |
| `composer.json` | PHP |
| `Makefile` | дополнительно к выше |
| `docker-compose.yml`, `Dockerfile` | Docker |

- По находкам определи: стек, как запустить, структуру

### Если вариант 2 (git URL):
- Скажи пользователю что клонируешь: `git clone <url> tmp/<repo-name> --depth=1`
- После клонирования — сделай то же что для варианта 1

### Если вариант 3 (SSH):
- Спроси: `user@host и путь к проекту?`
- Прочитай через SSH: `ssh user@host "find /path -maxdepth 2 -type f | head -50"` и ключевые файлы
- По результату определи стек

### Детект внешних сервисов (для MCP):
Ищи в `.env.example`, `.env.sample`, `docker-compose.yml`, `README`, конфигах:

| Сигнал | MCP который понадобится |
|---|---|
| `JIRA_`, `atlassian`, jira-url | Jira / Confluence |
| `LINEAR_API_KEY`, `LINEAR_` | Linear |
| `.github/` директория, `GITHUB_TOKEN` | GitHub (встроен в Claude Code) |
| `NOTION_TOKEN`, `NOTION_` | Notion |
| `SLACK_BOT_TOKEN`, `SLACK_` | Slack |
| `DATABASE_URL` с postgres, `POSTGRES_` | PostgreSQL MCP |
| Kubernetes/Helm/Terraform конфиги | деплой-инструменты |
| PaaS-специфика (Heroku, Railway, Fly.io) | их CLI через Bash |

Запомни что нашёл — используешь в шаге 5.

## Шаг 3 — Расскажи что нашёл

Выдай краткий отчёт (без markdown-заголовков, просто текстом):

- Что за проект (из README/CLAUDE.md одной фразой)
- Стек (языки, фреймворки, БД)
- Как запустить (команды из Makefile/docker-compose)
- Есть ли уже CLAUDE.md или AGENTS.md

Спроси: **"Всё верно? Можно настраивать workspace?"**

## Шаг 4 — Настрой workspace

После подтверждения — выполни всё автоматически:

### AGENTS.md
Заполни или обнови секцию "Твои проекты":
- Название, описание, для кого
- Как запустить (точные команды)
- Структура директорий (реальная, из файловой системы)
- Навигация: код / инфра / доки / промпты / задачи

### settings.local.json
Создай или обнови разрешения под найденный стек. Добавляй **только то, что нашёл** — и покажи пользователю таблицу "нашёл → добавил":

| Найден файл | Добавляю разрешения |
|---|---|
| `go.mod` | `Bash(go build:*)`, `Bash(go test:*)`, `Bash(go run:*)`, `Bash(go mod:*)` |
| `package.json` + lock-файл npm | `Bash(npm run:*)`, `Bash(npm install:*)`, `Bash(npx:*)` |
| `package.json` + `yarn.lock` | `Bash(yarn:*)` |
| `package.json` + `pnpm-lock.yaml` | `Bash(pnpm:*)` |
| `Cargo.toml` | `Bash(cargo build:*)`, `Bash(cargo test:*)`, `Bash(cargo run:*)`, `Bash(cargo clippy:*)` |
| `pyproject.toml` / `requirements.txt` | `Bash(python:*)`, `Bash(pip:*)`, `Bash(pytest:*)` |
| `pyproject.toml` + `uv` | `Bash(uv run:*)`, `Bash(uv sync:*)` |
| `*.csproj` / `*.sln` / `global.json` | `Bash(dotnet build:*)`, `Bash(dotnet test:*)`, `Bash(dotnet run:*)`, `Bash(dotnet restore:*)` |
| `pom.xml` | `Bash(mvn:*)` |
| `build.gradle` / `build.gradle.kts` | `Bash(./gradlew:*)` |
| `Gemfile` | `Bash(bundle exec:*)`, `Bash(rails:*)`, `Bash(rake:*)` |
| `composer.json` | `Bash(composer:*)`, `Bash(php:*)` |
| `Makefile` | `Bash(make:*)` |
| `docker-compose.yml` / `Dockerfile` | `Bash(docker compose:*)`, `Bash(docker build:*)`, `Bash(docker logs:*)` |

После записи покажи итоговый список добавленных разрешений одной таблицей — пользователь должен видеть что именно и зачем прописано.

### modules/memory/project_<name>.md
Создай файл памяти проекта если не существует:
- Что за проект, стек, как запустить
- Добавь ссылку в `modules/memory/MEMORY.md`

## Шаг 5 — Итог с объяснениями

Выдай список сделанного и предложения (опционально — с объяснением зачем):

**Сделано:**
- [список]

**Предлагаю добавить (по желанию):**

- LSP плагин для <стек> — go-to-definition и find-references, Claude навигирует за 50ms вместо grep за 45 сек
  ```
  claude plugin install <name>@claude-plugins-official --scope project
  ```

- macOS уведомления — спроси хочет ли пользователь получать уведомление когда агент завершил задачу. Если да:
  ```
  brew install vjeantet/tap/alerter
  ```
  После установки alerter сам запросит разрешение через системный диалог macOS. Без него уведомления работают, но ненадёжно на macOS 15+.

- Shell tools (`cw` + `cr`) — если ещё не установлены, предложи:
  - `cw` — выбор worktree через fzf, открывает в IDE с готовым `.claude-review.md`
  - `cr` — запускает claude-ревью с контекстом: git log, diff, готовые команды ("экскурсия", "риски", "summary")
  - Спроси: какую IDE используешь? (GoLand / Cursor / VS Code / другую)
  - Установка одной командой:
    ```
    bash modules/scripts/install-shell-tools.sh --ide <ide>
    ```
  - После установки: `source ~/.zshrc`

- Git-конфигурация для IDE — если проект новый и IDE известна:
  - Проверь есть ли `.gitconfig` или `.git/config` с настройками IDE
  - Для GoLand: предложи включить `core.editor` и `.gitignore` для `.idea/`
  - Для VS Code: предложи `.vscode/` в `.gitignore`
  - Спроси нужно ли настроить — не делай автоматически

- Агент `backend` или `frontend` под проект — изолированный агент с правами на запись только в нужной директории

- MCP-серверы (если нашёл сигналы в шаге 2):
  Показывай только то что реально обнаружено. Формат:
  ```
  Нашёл JIRA_URL → можно подключить Jira MCP:
  claude mcp add mcp-atlassian -- npx -y mcp-atlassian --jira-url=$JIRA_URL
  Токен добавь в settings.local.json.
  
  Нашёл .github/ → GitHub MCP уже встроен в Claude Code, включи через:
  claude mcp add github
  ```
  Полный список серверов: `modules/mcp/README.md`

**Как начать работу:**
```
/research <вопрос>   — ресёрч по архитектуре
/dev <задача>        — изолированный агент для реализации
cw                   — открыть worktree в IDE
cr                   — ревью изменений агента
```
