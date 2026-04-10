# scripts

Утилиты для управления bare repos и worktrees.

## Установка

```bash
chmod +x modules/scripts/*.sh
```

## Использование

### worktree-add.sh — создать worktree для задачи

```bash
./modules/scripts/worktree-add.sh <repo-url> <task-name> [branch]

# Пример
./modules/scripts/worktree-add.sh git@github.com:org/backend.git refactor-auth main
# → создаст tmp/backend.git (если нет) + tmp/backend-refactor-auth/
```

Bare repo клонируется один раз. Повторные вызовы создают новые worktrees без повторного скачивания.

### worktree-clean.sh — удалить worktree после завершения

```bash
./modules/scripts/worktree-clean.sh <repo-name> <task-name>

# Пример
./modules/scripts/worktree-clean.sh backend refactor-auth
```

### sync-all.sh — обновить все bare repos

```bash
./modules/scripts/sync-all.sh
```

Запускать в начале дня. Обновляет все `tmp/*.git` через `git fetch --all --prune`.
Worktrees подхватывают обновления автоматически — они разделяют объектное хранилище с bare repo.

---

## Если нужно больше

Эти скрипты покрывают базовый сценарий: один разработчик, несколько параллельных задач.

Для команды или сложной оркестрации (leader + worker агенты, автоматический merge при pass тестов):
→ [nwiizo/ccswarm](https://github.com/nwiizo/ccswarm) — Rust, git worktree оркестрация, координация агентов
