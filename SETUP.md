# Setup

## Prerequisites

- [Claude Code](https://claude.ai/code) installed (`claude` CLI available)
- `git` 2.5+ (worktree support)
- `fzf` for shell tools: `brew install fzf`
- A project to connect (local path, git URL, or SSH access)

**Для macOS уведомлений (рекомендуется):**
```bash
brew install vjeantet/tap/alerter
```
При первом запуске alerter сам запросит разрешение через системный диалог macOS.
Без alerter уведомления работают через osascript — менее надёжно на macOS 15+.

Optional but recommended:
- GoLand / Cursor / VS Code for `cw` IDE integration
- [OpenCode](https://opencode.ai) if you want dual-tool compatibility

---

## 1. Clone

```bash
git clone https://github.com/deminov/ai-workspace
cd ai-workspace
```

---

## 2. Personal settings

```bash
cp .claude/settings.local.json.example .claude/settings.local.json
```

Edit `settings.local.json` to add permissions you need personally but don't want committed to git:

```json
{
  "permissions": {
    "allow": [
      "Bash(git push:*)",
      "Bash(ssh:*)",
      "Bash(curl:*)"
    ]
  }
}
```

> `settings.json` is committed — shared rules for the workspace.
> `settings.local.json` is gitignored — your personal extensions.

---

## 3. Connect your project

Open workspace in Claude Code:

```bash
claude .
```

Then run `/start`. It will:

1. Ask where your project is (local path / git URL / SSH)
2. Read the project automatically — detects stack, finds existing `CLAUDE.md`/`AGENTS.md`
3. Show what it found and ask for confirmation
4. Configure `AGENTS.md`, `settings.local.json`, memory file

If your project is already in `tmp/`:

```
/start
> 1  (local path)
> tmp/your-project
```

If you're cloning fresh:

```
/start
> 2  (git URL)
> git@github.com:org/repo.git
```

---

## 4. Shell tools (optional)

`cw` and `cr` — worktree picker and review session launcher.

```bash
bash modules/scripts/install-shell-tools.sh --ide goland
source ~/.zshrc
```

Options:
- `--ide goland` / `--ide cursor` / `--ide code` / `--ide idea` / `--ide webstorm`
- `--uninstall` — removes the block from `~/.zshrc`

After install:
- `cw` — pick a worktree via fzf, opens in IDE, generates `.claude-review.md`
- `cr` — starts a claude session with git context; say "tour", "risks", "summary", or "test"

---

## 5. LSP plugins (optional)

Gives Claude navigation: go-to-definition, find-references, diagnostics. Much faster than grep.

```bash
# Go
go install golang.org/x/tools/gopls@latest
claude plugin install gopls-lsp@claude-plugins-official --scope project

# TypeScript
npm install -g typescript-language-server typescript
claude plugin install typescript-lsp@claude-plugins-official --scope project

# Python
pip install pyright
claude plugin install pyright-lsp@claude-plugins-official --scope project
```

---

## 6. Add your own agents

Drop a `.md` file in `.claude/agents/`:

```markdown
---
name: backend
description: Go developer — implementation, refactoring, tests
model: sonnet
tools: Read, Grep, Glob, Edit, Write, Bash
---

You work on the backend service in tmp/your-project/backend/.
Write idiomatic Go. Run tests before finishing.
```

The `tools` list is enforced — the agent can only use what's listed. Start narrow, expand as needed.

For OpenCode compatibility, duplicate the file in `.opencode/agents/` with OpenCode-compatible frontmatter.

---

## 7. Working with worktrees

Worktrees let agents work on isolated branches without re-cloning:

```bash
# Add a worktree for a task
./modules/scripts/worktree-add.sh git@github.com:org/repo.git task-name main
# Creates: tmp/repo-task-name on branch task/task-name

# Open agent in isolation
claude tmp/repo-task-name

# Clean up when done (checks for uncommitted changes first)
./modules/scripts/worktree-clean.sh tmp/repo-task-name
```

---

## File layout reference

```
ai-workspace/
  .claude/
    settings.json               ← committed, shared workspace rules
    settings.local.json         ← gitignored, personal extensions
    settings.local.json.example ← template
    agents/
      researcher.md             ← read-only, web search
      architect.md              ← read-only, design + ADR
      loop-monitor.md           ← read-only, watchdog
      deploy-monitor.md         ← bash + read, rollout monitoring
    commands/
      start.md                  ← /start
      research.md               ← /research
      dev.md                    ← /dev
      review.md                 ← /review
  .opencode/
    agents/                     ← same agents, OpenCode frontmatter
  modules/
    hooks/
      commit-guard.sh           ← blocks AI co-authorship in commits
      velocity-governor.sh      ← TPM rate limiting
      pre-tool-use.sh           ← dangerous command blocking
      stop.sh                   ← session log
      pre-compact.sh            ← pre-compaction snapshot
      post-tool-use.sh          ← post-write hook
    memory/
      MEMORY.md                 ← index of memory files
    scripts/
      worktree-add.sh           ← create isolated worktree
      worktree-clean.sh         ← remove worktree safely
      sync-all.sh               ← pull updates in all worktrees
      shell-tools.sh            ← cw + cr functions
      install-shell-tools.sh    ← installs cw/cr to ~/.zshrc
    mcp/                        ← MCP server navigation
    plugins/                    ← LSP plugin docs
  tmp/                          ← worktrees (gitignored)
  AGENTS.md                     ← workspace context map
  WORKFLOW.md                   ← task-to-commit process
```
