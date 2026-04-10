# Pattern Registry

Паттерны из комьюнити Claude Code. Не дублируем — только ссылки + применение.

Наши оригинальные паттерны с полной документацией:
→ [Orchestrator](orchestrator.md) · [Worktree Agent](worktree-agent.md) · [Loop Monitor](loop-monitor.md)

---

## Multi-agent координация

### SPARC
5-фазный фреймворк: Specification → Pseudocode → Architecture → Refinement → Completion.
17 специализированных режимов агентов под весь lifecycle задачи.
→ [ruvnet/sparc](https://github.com/ruvnet/sparc) · [ruvnet/ruflo](https://github.com/ruvnet/ruflo)

### RIPER-5
Research → Innovate → Plan → Execute → Review со строгими апрув-гейтами между фазами.
Агент не может перейти к следующей фазе без явного ОК — блокирует "нырнуть в код без плана".
→ [tony/claude-code-riper-5](https://github.com/tony/claude-code-riper-5)

### Three Explorers + Critic (Mixture of Agents)
3 агента независимо атакуют задачу разными подходами, 4-й (critic) синтезирует итог.
Оверхед 3-4x по токенам — оправдан на архитектурных решениях без "правильного" ответа.
→ [MindStudio: Multi-Agent Architecture](https://www.mindstudio.ai/blog/claude-code-ultra-plan-multi-agent-architecture)

### Agent Debate
Агенты активно опровергают теории друг друга (научный дебат) — выживает устойчивая гипотеза.
→ [MindStudio: Agent Chat Rooms](https://www.mindstudio.ai/blog/agent-chat-rooms-multi-agent-debate-claude-code) · [Claude Code Docs: Agent Teams](https://code.claude.com/docs/en/agent-teams)

### Swarm Topology (Leader + Workers)
Leader планирует и нарезает задачи. Workers получают изолированные worktrees.
Merge только при pass тестов.
→ [paddo.dev: Claude Code Swarm](https://paddo.dev/blog/claude-code-hidden-swarm/) · [nwiizo/ccswarm](https://github.com/nwiizo/ccswarm)

### Ralph Wiggum / RDD (Ruvnet-Driven Development)
Автономный loop: агент запускается итеративно пока не выполнит спецификацию.
Intelligent exit detection — сам определяет когда задача закрыта.
⚠ Экспериментальный — требует аккуратной спецификации критериев выхода.
→ [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)

---

## Контекст и память

### Campaign Persistence
Состояние агентов сохраняется в markdown-файлах между сессиями.
`/do continue` подхватывает с места остановки — лечит "смерть контекста" при длинных задачах.
→ [SethGammon/Citadel](https://github.com/SethGammon/Citadel)

### Discovery Relay (Wave Pattern)
2-3 агента в параллельных worktrees. Находки сжимаются в ~500-токен бриф и передаются в следующую волну.
Решает проблему передачи контекста между агентами без раздувания промптов.
→ [SethGammon/Citadel](https://github.com/SethGammon/Citadel)

### Context Injection / Briefing
Оркестратор читает артефакты предыдущих агентов и инжектирует только релевантный контекст в нового.
Не весь контекст — только нужное. Агент не "не знает" что делали предыдущие.
→ [Medium: Context Amnesia Fix](https://medium.com/@ilyas.ibrahim/the-4-step-protocol-that-fixes-claude-codes-context-amnesia-c3937385561c)

### Three-Layer Memory Architecture
Session memory (текущий контекст) + Project memory (CLAUDE.md) + Auto memory (MEMORY.md).
→ [MindStudio: Memory Architecture](https://www.mindstudio.ai/blog/claude-code-source-leak-memory-architecture) · [skillsplayground.com](https://skillsplayground.com/guides/claude-code-memory/)

### Context Tiering (Hot / Warm / Cold)
Компактный индекс — всегда в контексте. Тематические файлы — по требованию. Транскрипты — только при поиске.
→ [12 Agentic Harness Patterns](https://generativeprogrammer.com/p/12-agentic-harness-patterns-from)

---

## Безопасность и контроль

### Circuit Breaker
Лимит последовательных ошибок агента (обычно 3) — останавливает спираль провалов.
Claude Code внутри использует 20 таких констант. Дополняет Velocity Governor: тот по TPM, этот по failure count.
→ [Inside Claude Code](https://newsletter.victordibia.com/p/inside-claude-code)

### PreToolUse Hook Gate
Хук с 4 исходами: allow / deny / ask / defer. Плюс возможность модифицировать tool input до выполнения.
→ [Claude Code Hooks Docs](https://code.claude.com/docs/en/hooks) · [kornysietsma/claude-code-permissions-hook](https://github.com/kornysietsma/claude-code-permissions-hook)

### DontAsk Mode
Всё не в allowlist автоматически блокируется — без промптов пользователю.
Для CI/CD pipelines где нет интерактива.
→ [Claude Code: Permission Modes](https://code.claude.com/docs/en/permission-modes)

### Plan Mode (Read-Only Agent)
Агент только читает и планирует — zero write access. Review без риска изменений.
→ [Claude Code: Permission Modes](https://code.claude.com/docs/en/permission-modes)

---

## CI/CD и автоматизация

### Headless CI Agent
`claude -p` + `--output-format stream-json` + `--allowedTools` — неинтерактивный агент в GitHub Actions.
→ [Claude Code GitHub Actions Docs](https://code.claude.com/docs/en/github-actions) · [Angelo Lima: CI/CD Guide](https://angelo-lima.fr/en/claude-code-cicd-headless-en/)

### PR Multi-Agent Review
При открытии PR запускаются параллельные агенты-ревьюеры, находят баги, ранжируют по важности, постят inline comments.
→ [lilting.ch: Multi-Agent PR Review](https://lilting.ch/en/articles/claude-code-multi-agent-pr-review)

---

## Коллекции паттернов (агрегаторы)

| Ресурс | Что внутри |
|---|---|
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Curated list: агенты, команды, воркфлоу, CLAUDE.md примеры |
| [VoltAgent/awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents) | Готовые subagent конфиги под разные задачи |
| [12 Agentic Harness Patterns](https://generativeprogrammer.com/p/12-agentic-harness-patterns-from) | Паттерны управления контекстом, tool loading, memory |
| [AddyOsmani: The Code Agent Orchestra](https://addyosmani.com/blog/code-agent-orchestra/) | Обзор multi-agent архитектур |
| [Shipyard: Multi-agent 2026](https://shipyard.build/blog/claude-code-multi-agent/) | State of the art на начало 2026 |
