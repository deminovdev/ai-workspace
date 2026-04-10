# Паттерн: Изолированный агент в Worktree

## Суть

Агент работает в отдельной git-ветке в изолированной директории. Основная ветка остаётся нетронутой пока агент работает. По завершении — ревью и merge.

## Когда применять

- Крупная задача в одном репозитории (больше пары файлов)
- Эксперимент или рефакторинг с риском сломать что-то
- Параллельная работа над несколькими независимыми задачами в одном репо
- Задача займёт больше одной сессии

## Когда НЕ применять

- Задача в нескольких сервисах → [Оркестратор](orchestrator.md)
- Мелкая правка, которую легко откатить
- Нет нормального git history в репо

## Как создать worktree

```bash
./modules/scripts/worktree-add.sh <git-url> <task-name> <base-branch>

# Пример:
./modules/scripts/worktree-add.sh git@github.com:org/backend.git auth-oauth main
# Результат: tmp/backend-auth-oauth на ветке task/auth-oauth
```

Или если репо уже в `tmp/`:

```bash
cd tmp/backend
git worktree add ../backend-auth-oauth -b task/auth-oauth main
```

## Открыть агента в worktree

```bash
claude tmp/backend-auth-oauth
```

Агент видит только содержимое этой директории. Основная директория не затронута.

## Цикл работы

```
1. worktree-add.sh → создаёт tmp/repo-task на ветке task/name
2. claude tmp/repo-task → агент работает изолированно
3. [агент завершил]
4. cw → открыть worktree в IDE
5. cr → запустить ревью (экскурсия / риски / summary)
6. git merge task/name → влить в основную ветку
7. worktree-clean.sh → удалить worktree
```

## Ревью через cr

`cr` запускает claude с контекстом изменений:

```bash
cd tmp/backend-auth-oauth
cr
```

Claude получает:
- git log последних 10 коммитов
- diff всех изменений
- готовые команды: "экскурсия", "риски", "тест", "summary"

## Параллельная работа

Несколько worktrees живут одновременно:

```
tmp/
  backend-auth-oauth/     ← агент A работает
  backend-rate-limit/     ← агент B работает
  frontend-new-ui/        ← агент C работает
```

`cw` — выбор через fzf, видишь последний коммит каждого агента.

## Очистка

```bash
./modules/scripts/worktree-clean.sh tmp/backend-auth-oauth
```

Скрипт проверяет:
- Есть ли несохранённые изменения — спросит подтверждение
- Есть ли незапушенные коммиты — предупредит
- Только после этого удалит worktree и ветку

## Именование

Рекомендуемый формат: `tmp/<repo>-<task>`, ветка `task/<task>`.

Это позволяет:
- Понять по имени директории что за задача
- `cw` и `cr` показывают осмысленные имена
- Легко фильтровать через `git branch --list 'task/*'`

## Bare repos (опционально)

Если работаешь с репо часто — держи bare clone, добавляй worktrees без сетевых запросов:

```bash
# Один раз
git clone --bare git@github.com:org/backend.git tmp/.bare/backend

# Потом быстро
git -C tmp/.bare/backend worktree add ../../tmp/backend-new-task -b task/new-task main
```

`sync-all.sh` обновляет все bare repos одной командой.
