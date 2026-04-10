# claude-flow

Structured project cognition + autonomous execution framework for Claude Code.

## Installation

```bash
# Add marketplace
/plugin marketplace add CookiRui/claude-flow

# Install
/plugin install claude-flow@claude-flow

# Initialize project-level config
/claude-flow:init
```

## What's Included

### Skills (9)

| Skill | Description |
|-------|-------------|
| `/claude-flow:tdd` | TDD enforcement: RED-GREEN-REFACTOR cycle |
| `/claude-flow:verification` | Pre-completion verification: 5-dimension checklist |
| `/claude-flow:brainstorming` | Design exploration: Socratic requirements refinement |
| `/claude-flow:deep-task <goal>` | 8-layer autonomous engine: complexity routing → DAG decomposition → parallel agents → 3-level verification → meta-learning |
| `/claude-flow:bug-fix <desc>` | Structured diagnosis → regression test → fix → solidify learnings |
| `/claude-flow:feature-plan-creator <name>` | Requirements → technical plan → micro-task breakdown (≤5 min each) |
| `/claude-flow:autosolve <goal>` | Persistent DAG scheduler with kanban visualization |
| `/claude-flow:init` | Analyze codebase, generate project-level config (constitution, rules, CLAUDE.md) |
| `/claude-flow:upgrade` | Upgrade plugin and project-level configuration |

### Agents (3)

| Agent | Description |
|-------|-------------|
| `feature-builder` | Autonomous feature implementation in isolated worktree, TDD-driven, delivers PR |
| `code-reviewer` | Adversarial read-only review: 6 dimensions, severity-ranked findings |
| `test-writer` | Adversarial test writer: boundary, null, error path, concurrency, stress tests |

### Hooks (5)

| Hook | Event | Purpose |
|------|-------|---------|
| `protect-files.sh` | PreToolUse (Edit/Write) | Block edits to protected paths (.env, config dirs) |
| `validate-bash.sh` | PreToolUse (Bash) | Block irreversible git commands (force push, reset --hard) |
| `lint-feedback.sh` | PostToolUse (Edit/Write) | Auto-detect linter, run on changed files, feed errors back |
| `reinject-context.sh` | SessionStart | Restore constitution + session state after compaction |
| `pre-compact.sh` | PreCompact | Save session state before context compression |

### CLI Tools (bin/)

| Script | Purpose |
|--------|---------|
| `persistent-solve.py` | Multi-session DAG scheduler with budget tracking |
| `repo-map.py` | Multi-level code map generator (L0/L1/L2) |
| `scope-loader.py` | Module-scoped rule loader for context injection |
| `lint-feedback.sh` | Bidirectional lint feedback loop |

## Setup

After installing the plugin, run `/claude-flow:init` in your project to generate:
- `CLAUDE.md` — project architecture overview
- `.claude/constitution.md` — project-specific constraints AI must follow
- `.claude/rules/*.md` — coding style, git workflow, security rules
- `.claudeignore` — files to exclude from AI context
- `REVIEW.md` — code review standards

The plugin provides a built-in generic constitution that activates immediately. Running `/claude-flow:init` replaces it with project-specific rules for better results.

## Links

- [GitHub](https://github.com/CookiRui/claude-flow)
- [Documentation](https://github.com/CookiRui/claude-flow/tree/master/docs)
