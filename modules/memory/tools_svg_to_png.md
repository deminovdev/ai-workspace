---
name: SVG to PNG on macOS
description: Как конвертировать SVG в PNG без белых артефактов на macOS
type: reference
---

`qlmanage` (встроен) добавляет белый фон за прозрачными областями SVG — не использовать для иконок с rounded corners и прозрачностью.

**Решение: `resvg`** — Rust бинарь, нет runtime-зависимостей, корректная прозрачность.

```bash
brew install resvg
resvg input.svg output.png --width 1024 --height 1024
```

**Why:** qlmanage использует PDF-фреймворк Apple, который некорректно обрабатывает alpha-channel в SVG. resvg рендерит напрямую, сохраняет прозрачность.
