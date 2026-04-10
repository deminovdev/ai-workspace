# plugins

Claude Code имеет официальную систему плагинов. Плагин — это папка с компонентами:
агенты, хуки, MCP серверы, LSP серверы, output styles, slash-команды.

**Официальный маркетплейс:** [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official)

Установка: `claude plugin install <name>@claude-plugins-official --scope project`

---

## LSP плагины

Дают Claude навигацию по коду: go-to-definition, find-references, диагностика.
Вместо grep за 45 секунд — LSP-запрос за 50ms.

Перед установкой убедись что language server бинарь установлен:

### Go
```bash
go install golang.org/x/tools/gopls@latest
claude plugin install gopls-lsp@claude-plugins-official --scope project
```

### TypeScript / JavaScript
```bash
npm install -g typescript-language-server typescript
claude plugin install typescript-lsp@claude-plugins-official --scope project
```

### Другие стеки
```bash
# Python
pip install pyright
claude plugin install pyright-lsp@claude-plugins-official --scope project

# Rust
# Установи rust-analyzer: https://rust-analyzer.github.io
claude plugin install rust-lsp@claude-plugins-official --scope project
```

Плагины с `--scope project` записываются в `enabledPlugins` в `.claude/settings.json` —
этот файл коммитится в git и вся команда получает плагин автоматически.
Кеш плагинов хранится глобально в `~/.claude/plugins/cache/`, не в репозитории.

---

## Output styles

Кастомизируют тон и стиль ответов Claude. Хранятся в `.claude/output-styles/*.md`.

В ai-workspace уже есть пример: `.claude/output-styles/terse.md` — краткий инженерный стиль.

Подключение через `/config` → Settings → Output style.

Коллекция готовых стилей от комьюнити:
[awesome-claude-code-output-styles](https://github.com/hesreallyhim/awesome-claude-code-output-styles-that-i-really-like)

---

## Создать свой плагин

Плагин = директория со структурой:
```
my-plugin/
  agents/          ← агенты
  hooks/
    hooks.json     ← Claude Code hooks
  output-styles/   ← стили ответов
  .mcp.json        ← MCP серверы
  .lsp.json        ← LSP серверы
```

Опубликовать: PR в [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official).
