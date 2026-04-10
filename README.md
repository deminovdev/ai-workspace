# ai-workspace

**Work above your projects, not inside them.**

A workspace layer that turns Claude Code from an autocomplete into a team. Agents with enforced permissions run in parallel across repositories. You orchestrate.

[Русская версия →](README.ru.md)

---

## The problem

Typical setup: open a repo, run `claude`, work inside it. Claude sees only that repo.

Real tasks don't work that way. "Add a feature" touches the backend, frontend, and database. "Set up staging" means 12 services and a dozen config files. Claude locked inside one repo doesn't see the system.

## The pattern

```
ai-workspace/          ← Claude opened here sees everything
  .claude/
    agents/            ← roles with enforced permissions
    settings.json      ← deny rules for the whole workspace
  modules/
    hooks/             ← PreToolUse, Stop, PreCompact
    scripts/           ← worktree utilities
    memory/            ← context between sessions
  tmp/                 ← worktrees for parallel agent work
  AGENTS.md            ← context file (Claude Code + OpenCode)
```

Claude opened at the workspace root sees all projects in `tmp/`. Agents with narrow `tools` lists can't exceed their permissions — not by instruction, but by enforcement.

## Two modes

**Orchestrator** — task spans multiple services:
```
Set up staging for all services
Add auth end-to-end: backend endpoint + frontend page + migration
```
Main chat coordinates. Agents work in parallel.

**Isolated agent** — large task in one repo, keep main branch clean:
```bash
./modules/scripts/worktree-add.sh git@github.com:org/backend.git feature-auth main
claude tmp/backend-feature-auth
```

## Quick start

```bash
git clone https://github.com/deminov/ai-workspace
cd ai-workspace

# Personal settings (git push, ssh keys, MCP tokens)
cp .claude/settings.local.json.example .claude/settings.local.json

# Connect your first project
claude .
# Then run: /start
```

`/start` detects your project automatically — reads existing `CLAUDE.md` / `AGENTS.md`, infers stack from `Makefile` / `go.mod` / `package.json`, configures permissions.

## What's included

| | |
|---|---|
| **Agents** | `researcher` (web search, read-only), `architect` (design, ADR), `loop-monitor` (watchdog), `deploy-monitor` (rollout with rollback) |
| **Hooks** | `commit-guard` (blocks AI co-authorship in commits), `velocity-governor` (TPM rate limiting for background agents), `stop` (session log) |
| **Scripts** | `worktree-add`, `worktree-clean`, `sync-all`, `shell-tools` (`cw`/`cr`) |
| **Memory** | File-based context that persists across sessions |
| **Commands** | `/start`, `/research`, `/dev`, `/review` |

## Agent permissions are architecture

An agent's `tools` frontmatter is enforced by Claude Code — it's not a suggestion.

```markdown
---
name: researcher
tools: Read, Grep, Glob, WebSearch, WebFetch
---
```

`researcher` has no `Write` or `Edit`. It physically cannot modify a file. Add your own agents by dropping a `.md` into `.claude/agents/`.

## Shell tools

```bash
# Pick a worktree via fzf, open in IDE, generate review context
cw

# Start a review session with git context + ready-made commands
cr  # "tour", "risks", "summary", "test"

# Install
bash modules/scripts/install-shell-tools.sh --ide goland  # or cursor, code
```

## Compatibility

Works with Claude Code and OpenCode. `AGENTS.md` is read by both. Agents are mirrored in `.claude/agents/` and `.opencode/agents/` with different frontmatter.

---

## Docs

- [Setup guide](SETUP.md)
- [Orchestrator pattern](docs/patterns/orchestrator.md)
- [Worktree agent pattern](docs/patterns/worktree-agent.md)
- [Loop monitor pattern](docs/patterns/loop-monitor.md)
- [Workflow](WORKFLOW.md)
