# mcp

Навигация по популярным MCP серверам. Конфиги у всех разные — здесь только ссылки и описания.

## Как подключить

**Claude Code** — в `~/.claude/mcp.json` или через `claude mcp add`.
**OpenCode** — секция `mcp` в `opencode.json`.

## Популярные серверы

### Трекеры задач
| Сервер | Репо | Что даёт |
|---|---|---|
| Jira | [github.com/sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) | Читать/создавать задачи, комментарии |
| Linear | [github.com/linear/linear-mcp](https://github.com/linear/linear-mcp) | Issues, projects, cycles |
| GitHub | встроен в Claude Code | PRs, issues, actions |

### Документация и знания
| Сервер | Репо | Что даёт |
|---|---|---|
| Notion | [github.com/makenotion/notion-mcp-server](https://github.com/makenotion/notion-mcp-server) | Читать/писать страницы |
| Confluence | [github.com/sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) | Читать документацию |

### Инфраструктура
| Сервер | Репо | Что даёт |
|---|---|---|
| Filesystem | встроен | Расширенный доступ к файлам |
| Docker | [github.com/ckreiling/mcp-server-docker](https://github.com/ckreiling/mcp-server-docker) | Управление контейнерами |
| PostgreSQL | [github.com/crystaldba/postgres-mcp](https://github.com/crystaldba/postgres-mcp) | Запросы к БД |

### Поиск
| Сервер | Репо | Что даёт |
|---|---|---|
| Brave Search | [официальный](https://github.com/modelcontextprotocol/servers/tree/main/src/brave-search) | Веб-поиск |

## Конфиг в settings.local.json

MCP с токенами — только в `settings.local.json`, не в git:

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@sooperset/mcp-atlassian"],
      "env": {
        "JIRA_URL": "https://your-org.atlassian.net",
        "JIRA_TOKEN": "your-token"
      }
    }
  }
}
```
