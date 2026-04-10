# tmp/

Рабочая директория для bare repos и worktrees агентов.

Не коммитится (кроме этого файла). Добавь в `.gitignore`:
```
tmp/*
!tmp/.gitkeep
!tmp/README.md
```

## Структура

```
tmp/
  backend.git/          ← bare repo (скачан один раз)
  backend-task-1/       ← worktree агента 1
  backend-task-2/       ← worktree агента 2
  frontend.git/
  frontend-refactor/
```

## Как использовать

### 1. Создать worktree для задачи

```bash
./modules/scripts/worktree-add.sh git@github.com:org/backend.git my-task main
```

Создаст `tmp/backend.git` (если нет) и `tmp/backend-my-task/`.

### 2. Открыть в Claude Code

```bash
claude tmp/backend-my-task
```

Или запустить агента из основного workspace:
```
Agent(isolation: "worktree") → работает в изолированной копии
```

### 3. Обновить репки в начале дня

```bash
./modules/scripts/sync-all.sh
```

### 4. Удалить worktree после завершения

```bash
./modules/scripts/worktree-clean.sh backend my-task
```

## Почему bare repo, а не обычный clone

Обычный `git clone` скачивает всю историю + создаёт рабочую копию.
Bare clone скачивает только объекты, без рабочей копии.

Worktrees создаются из bare repo мгновенно — они разделяют объектное хранилище.
10 агентов на одном репо = 1 скачивание, 10 лёгких worktrees.
