---
description: Запустить architect для ревью архитектурных изменений (read-only)
user-invocable: true
context: fork
---

Запусти агента `architect` для ревью текущих изменений:

$ARGUMENTS

Агент смотрит `git diff`, оценивает архитектурные решения, указывает на проблемы.
Только чтение — ничего не правит.
