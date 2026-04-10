#!/usr/bin/env bash
# Устанавливает AI Workspace shell tools (cw, cr) в ~/.zshrc
#
# Использование:
#   bash modules/scripts/install-shell-tools.sh
#   bash modules/scripts/install-shell-tools.sh --ide cursor
#   bash modules/scripts/install-shell-tools.sh --uninstall

set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLS_FILE="$WORKSPACE_DIR/modules/scripts/shell-tools.sh"
ZSHRC="${ZDOTDIR:-$HOME}/.zshrc"
MARKER="# ai-workspace shell tools"

usage() {
  echo "Использование: $0 [--ide goland|cursor|code|idea|webstorm] [--uninstall]"
  exit 1
}

# ─── Аргументы ───────────────────────────────────────────────────────────────

IDE="goland"
UNINSTALL=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide) IDE="$2"; shift 2 ;;
    --uninstall) UNINSTALL=true; shift ;;
    --help|-h) usage ;;
    *) echo "Неизвестный аргумент: $1"; usage ;;
  esac
done

# ─── Деинсталляция ───────────────────────────────────────────────────────────

if $UNINSTALL; then
  if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
    # Удаляем блок между маркерами
    sed -i.bak "/$MARKER/,/$MARKER end/d" "$ZSHRC"
    echo "✓ ai-workspace shell tools удалены из $ZSHRC"
  else
    echo "ai-workspace shell tools не были установлены"
  fi
  exit 0
fi

# ─── Проверки ────────────────────────────────────────────────────────────────

if [[ ! -f "$TOOLS_FILE" ]]; then
  echo "Ошибка: не найден $TOOLS_FILE" >&2
  exit 1
fi

# fzf обязателен для cw
if ! command -v fzf &>/dev/null; then
  echo "⚠ fzf не установлен. Установи: brew install fzf"
  echo "  cw будет недоступен без fzf."
fi

# Проверяем IDE
case "$IDE" in
  goland|idea|webstorm|cursor|code) ;;
  *) echo "Неизвестная IDE: $IDE. Варианты: goland, idea, webstorm, cursor, code"; exit 1 ;;
esac

# ─── Установка ───────────────────────────────────────────────────────────────

# Убираем старую установку если есть
if grep -q "$MARKER" "$ZSHRC" 2>/dev/null; then
  sed -i.bak "/$MARKER/,/$MARKER end/d" "$ZSHRC"
  echo "→ Обновляю существующую установку"
fi

cat >> "$ZSHRC" <<EOF

$MARKER
export AI_WORKSPACE_IDE="$IDE"
export AI_WORKSPACE_TMP="$WORKSPACE_DIR/tmp"
source "$TOOLS_FILE"
$MARKER end
EOF

echo "✓ Установлено в $ZSHRC"
echo ""
echo "  IDE: $IDE"
echo "  Worktrees: $WORKSPACE_DIR/tmp"
echo "  Tools: cw (worktree picker), cr (review session)"
echo ""
echo "  Перезагрузи шелл: source $ZSHRC"
