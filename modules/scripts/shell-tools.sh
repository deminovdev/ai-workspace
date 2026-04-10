#!/usr/bin/env zsh
# AI Workspace Shell Tools
# Подключи в ~/.zshrc: source /path/to/ai-workspace/modules/scripts/shell-tools.sh
#
# Инструменты:
#   cw — выбор worktree через fzf, открывает в IDE
#   cr — запуск claude с контекстом изменений (review session)

# ─── Конфигурация ────────────────────────────────────────────────────────────

# IDE для открытия worktree. Варианты: goland, idea, webstorm, cursor, code
AI_WORKSPACE_IDE="${AI_WORKSPACE_IDE:-goland}"

# Корень где лежат worktrees (по умолчанию tmp/ в родительской директории workspace)
AI_WORKSPACE_TMP="${AI_WORKSPACE_TMP:-${${(%):-%x}:h:h}/tmp}"

# ─── cw — Worktree Picker ────────────────────────────────────────────────────

cw() {
  local tmp_dir="${AI_WORKSPACE_TMP}"

  if [[ ! -d "$tmp_dir" ]]; then
    echo "cw: директория worktrees не найдена: $tmp_dir" >&2
    echo "    установи AI_WORKSPACE_TMP или создай tmp/" >&2
    return 1
  fi

  # Собираем список worktrees: <имя> | <последний коммит>
  local selection
  selection=$(
    for d in "$tmp_dir"/*/; do
      [[ -d "$d/.git" || -f "$d/.git" ]] || continue
      local name="${d:t}"
      local last_commit
      last_commit=$(git -C "$d" log -1 --pretty="%s" 2>/dev/null || echo "—")
      printf "%-30s  %s\n" "$name" "$last_commit"
    done | fzf \
      --prompt="worktree> " \
      --height=40% \
      --reverse \
      --no-info \
      --preview="git -C ${tmp_dir}/{1} log --oneline -10 2>/dev/null" \
      --preview-window=right:50%
  )

  [[ -z "$selection" ]] && return 0

  local chosen_name
  chosen_name=$(echo "$selection" | awk '{print $1}')
  local chosen_path="${tmp_dir}/${chosen_name}"

  if [[ ! -d "$chosen_path" ]]; then
    echo "cw: директория не найдена: $chosen_path" >&2
    return 1
  fi

  # Генерируем контекст для review
  local review_file="${chosen_path}/.claude-review.md"
  {
    echo "# Review context: ${chosen_name}"
    echo ""
    echo "## Git log (последние 10 коммитов)"
    echo '```'
    git -C "$chosen_path" log --oneline -10 2>/dev/null
    echo '```'
    echo ""
    echo "## Изменённые файлы"
    echo '```'
    git -C "$chosen_path" diff --stat HEAD~1 2>/dev/null || git -C "$chosen_path" status --short 2>/dev/null
    echo '```'
    echo ""
    echo "## Diff"
    echo '```diff'
    git -C "$chosen_path" diff HEAD~1 2>/dev/null || git -C "$chosen_path" diff 2>/dev/null
    echo '```'
  } > "$review_file"

  echo "→ Открываю $chosen_name в $AI_WORKSPACE_IDE"
  case "$AI_WORKSPACE_IDE" in
    goland)  goland "$chosen_path" &>/dev/null & ;;
    idea)    idea "$chosen_path" &>/dev/null & ;;
    webstorm) webstorm "$chosen_path" &>/dev/null & ;;
    cursor)  cursor "$chosen_path" ;;
    code)    code "$chosen_path" ;;
    *)       echo "cw: неизвестная IDE: $AI_WORKSPACE_IDE" >&2; return 1 ;;
  esac
}

# ─── cr — Review Session ─────────────────────────────────────────────────────

cr() {
  local context_file=".claude-review.md"

  # Если не в worktree — ищем .claude-review.md в текущей папке
  if [[ ! -f "$context_file" ]]; then
    # Генерируем на месте
    {
      echo "# Review context: $(basename "$PWD")"
      echo ""
      echo "## Git log (последние 10 коммитов)"
      echo '```'
      git log --oneline -10 2>/dev/null
      echo '```'
      echo ""
      echo "## Изменённые файлы"
      echo '```'
      git diff --stat HEAD~1 2>/dev/null || git status --short 2>/dev/null
      echo '```'
      echo ""
      echo "## Diff"
      echo '```diff'
      git diff HEAD~1 2>/dev/null || git diff 2>/dev/null
      echo '```'
    } > "$context_file"
  fi

  # Системный промпт с готовыми командами
  local system_prompt
  system_prompt=$(cat <<'PROMPT'
Ты делаешь код-ревью агентской работы. Контекст изменений — в файле .claude-review.md в текущей директории.

Готовые команды для пользователя:
- "экскурсия" — последовательный разбор всех изменений с пояснениями, рисками и архитектурными замечаниями
- "тест" — предложи тест-кейсы для изменённой логики, проверь покрытие
- "риски" — только баги, проблемы безопасности и edge cases
- "summary" — короткая выжимка для PR description (3-5 пунктов)

Начни с: прочитай .claude-review.md и выдай одну строку — что за изменения и насколько они рискованные.
PROMPT
)

  local tmp_prompt
  tmp_prompt=$(mktemp /tmp/cr-system-XXXXXX.md)
  echo "$system_prompt" > "$tmp_prompt"

  echo "→ Запускаю review session в $(basename "$PWD")"
  claude --append-system-prompt-file "$tmp_prompt"

  rm -f "$tmp_prompt"
}
