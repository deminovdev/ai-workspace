#!/bin/bash
# Удалить worktree после завершения задачи.
# Проверяет незакоммиченные изменения и спрашивает подтверждение.
#
# Использование:
#   ./worktree-clean.sh <repo-name> <task-name>
#
# Пример:
#   ./worktree-clean.sh service my-task

set -e

REPO_NAME="$1"
TASK_NAME="$2"

if [ -z "$REPO_NAME" ] || [ -z "$TASK_NAME" ]; then
  echo "Usage: $0 <repo-name> <task-name>"
  exit 1
fi

BARE_DIR="tmp/${REPO_NAME}.git"
WORKTREE_DIR="tmp/${REPO_NAME}-${TASK_NAME}"

if [ ! -d "$WORKTREE_DIR" ]; then
  echo "Worktree not found: $WORKTREE_DIR"
  exit 1
fi

# Проверяем незакоммиченные изменения
UNCOMMITTED=$(git -C "$WORKTREE_DIR" status --porcelain 2>/dev/null)
UNPUSHED=$(git -C "$WORKTREE_DIR" log "@{u}.." --oneline 2>/dev/null || echo "")

if [ -n "$UNCOMMITTED" ] || [ -n "$UNPUSHED" ]; then
  echo "WARNING: $WORKTREE_DIR has unsaved work:"
  [ -n "$UNCOMMITTED" ] && echo "  Uncommitted changes:" && git -C "$WORKTREE_DIR" status --short
  [ -n "$UNPUSHED" ]    && echo "  Unpushed commits:" && echo "$UNPUSHED"
  echo ""
  read -r -p "Remove anyway? [y/N] " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Cancelled."
    exit 0
  fi
fi

echo "Removing worktree: $WORKTREE_DIR"
git -C "$BARE_DIR" worktree remove "../${WORKTREE_DIR}" --force

echo "Done."
