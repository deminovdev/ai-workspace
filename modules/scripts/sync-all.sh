#!/bin/bash
# Обновить все bare repos в tmp/.
# Запускать в начале рабочего дня.

set -e

BARE_REPOS=$(find tmp -maxdepth 1 -name "*.git" -type d 2>/dev/null)

if [ -z "$BARE_REPOS" ]; then
  echo "No bare repos found in tmp/"
  exit 0
fi

for REPO in $BARE_REPOS; do
  echo "Syncing $REPO..."
  git -C "$REPO" fetch --all --prune
done

echo ""
echo "All repos synced."
