#!/bin/bash
# Создать worktree из bare repo.
# Если bare repo ещё нет — клонирует его.
#
# Использование:
#   ./worktree-add.sh <repo-url> <task-name> [branch]
#
# Пример:
#   ./worktree-add.sh git@github.com:org/service.git my-task main

set -e

REPO_URL="$1"
TASK_NAME="$2"
BRANCH="${3:-main}"

if [ -z "$REPO_URL" ] || [ -z "$TASK_NAME" ]; then
  echo "Usage: $0 <repo-url> <task-name> [branch]"
  exit 1
fi

# Имя репо из URL (без .git)
REPO_NAME=$(basename "$REPO_URL" .git)
BARE_DIR="tmp/${REPO_NAME}.git"
WORKTREE_DIR="tmp/${REPO_NAME}-${TASK_NAME}"

# Клонировать bare repo если ещё нет
if [ ! -d "$BARE_DIR" ]; then
  echo "Cloning bare repo: $REPO_URL → $BARE_DIR"
  git clone --bare "$REPO_URL" "$BARE_DIR"
else
  echo "Bare repo exists: $BARE_DIR"
fi

# Создать worktree на новой ветке от базовой
TASK_BRANCH="task/${TASK_NAME}"
echo "Creating worktree: $WORKTREE_DIR (branch: $TASK_BRANCH from $BRANCH)"
git -C "$BARE_DIR" worktree add -b "$TASK_BRANCH" "../${WORKTREE_DIR}" "$BRANCH"

echo ""
echo "Ready: $WORKTREE_DIR"
echo "Open with: claude $WORKTREE_DIR"
