**Хуки в Claude Code: что это и зачем**

Claude Code умеет запускать shell-команды в ключевые моменты своей работы. Хук — это bash-скрипт, который выполняется автоматически: до вызова инструмента, после, при старте сессии, при завершении.

Настраиваются в `.claude/settings.json`:

```
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "bash ./notify.sh" }] }
    ]
  }
}
```

Доступные события:

`SessionStart` — начало новой сессии
`SessionEnd` — завершение сессии
`Stop` — агент закончил отвечать
`Notification` — Claude ждёт ответа или разрешения
`PreToolUse` — до вызова инструмента (можно заблокировать через exit 2)
`PostToolUse` — после вызова инструмента
`PreCompact` — перед сжатием контекста

`PreToolUse` с `exit 2` — блокирующий: выполнение инструмента не произойдёт. Единственный способ программно остановить агента.

---

**Что я использую в своём workspace**

В [ai-workspace](https://github.com/deminovdev/ai-workspace) у меня 10 хуков в четырёх группах.

**Уведомления**

`Notification → notification.sh`
Когда Claude ждёт ответа — macOS-баннер. CLI сам по себе уведомлений не показывает, поэтому нужен хук. Приоритет: `alerter` → `terminal-notifier` → `osascript`. Дополнительно: звук, лог, Telegram.

`Stop → stop.sh`
Когда агент завершил задачу — ещё одно уведомление. Полезно для длинных фоновых задач.

**Защита от петель**

`PreToolUse + PostToolUse → circuit-breaker.sh`
Агент может уйти в петлю: одна ошибка порождает следующую. Circuit breaker считает последовательные ошибки и блокирует выполнение после трёх подряд. Сбрасывается при следующем успешном вызове или вручную.

`PreToolUse (Bash) → velocity-governor.sh`
Ограничение по токенам в минуту. Защищает от сжигания API-квоты при параллельных агентах. Дефолт: 50k TPM.

**Коммиты**

`PreToolUse (Bash) → commit-guard.sh`
Блокирует `git commit` если в сообщении есть атрибуция AI: Co-Authored-By: Claude, 🤖 Generated with, ID модели. Коммиты остаются чистыми.

**Сессия и память**

`SessionStart → session-start.sh`
Сбрасывает circuit breaker, логирует старт, предупреждает если MEMORY.md не обновлялся больше 7 дней.

`SessionEnd → session-end.sh`
Пишет в sessions.log: timestamp, коммиты за последний час, git diff --stat.

`PreCompact → pre-compact.sh`
Перед сжатием контекста сохраняет данные сессии в modules/memory/ — чтобы контекст не терялся безвозвратно.

`PostToolUse (Write) → post-tool-use.sh`
Заглушка для автоформатирования после записи файла. Внутри закомментированные вызовы gofmt, biome, ruff — раскомментируй под свой стек.

---

Весь код: github.com/deminovdev/ai-workspace
