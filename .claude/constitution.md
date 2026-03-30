# Project Constitution

This file **only defines project-specific, counter-intuitive constraints that AI wouldn't know**.

> **Inclusion criteria**: If you remove a rule, will AI's default behavior produce incorrect code? Yes -> keep it; No -> remove it.

---

## §1: template/ 下的文件是用户模板，{placeholder} 必须保留

`template/` 目录包含安装到用户项目的模板文件，其中 `{placeholder}` 格式的占位符是 **设计意图**，由 `/init-project` 命令在用户项目中替换。

```python
# ✅ Correct — template/ 中保留占位符
"## §1: {core-architecture-constraint}"

# ❌ Wrong — 把 template/ 中的占位符替换成了具体内容
"## §1: All modules must use EventCenter"
```

**唯一例外**：当修改 `.claude/` 下（非 `template/.claude/`）的文件时，这些是 claude-flow 项目自身的配置，应使用具体内容。

---

## §2: README.md 功能描述必须与 template/ 实际文件同步

新增、删除或重命名 `template/` 下的文件后，必须同步更新 README.md 中的模板结构、命令表、功能描述。

- 新增命令文件 → README 命令表加一行
- 删除 Skill → README 模板结构删对应条目
- 修改文件路径 → README 所有引用同步改

---

## §3: Python 脚本零外部依赖

所有 `scripts/` 和根目录的 Python 脚本只能使用标准库（`os`, `sys`, `re`, `json`, `subprocess`, `pathlib`, `argparse` 等）。用户 `python install.py` 时不应需要 `pip install` 任何东西。

```python
# ✅ Correct
import subprocess
import json
from pathlib import Path

# ❌ Wrong
import click        # 需要 pip install
import requests     # 需要 pip install
import yaml         # 需要 pip install (PyYAML)
```

---

## §4: 修改完成后必须 commit 并 push

任何代码修改完成并通过验证后，必须 `git commit` 并 `git push origin master`。不允许只改不提交。

**Worktree 例外**：当 agent 在 git worktree 中执行时（用于隔离对比、实验性分支等），只 commit 到 worktree 本地分支，**不得 push 到 origin/master**。Worktree 的产出由主会话决定是否合并。判断方式：如果 `git rev-parse --git-dir` 包含 `/worktrees/`，则处于 worktree 中。

---

## §Session State Protocol

**The file is the memory, not the conversation.** Conversations are ephemeral — they get compacted, crash, or end. The file `.claude-flow/session-state/active.md` persists across all of these.

### When to update

Update `active.md` after each significant milestone:
- A task step is completed (code written, test passed, file committed)
- An architectural or design decision is made
- Switching focus to a different task or subtask

### Required format

```markdown
<!-- STATUS -->
Task: {current-task-description}
Step: {current-step} of {total-steps}
<!-- /STATUS -->

## Current Goal
{what-you-are-trying-to-accomplish}

## Progress
- [x] {completed-step-1}
- [x] {completed-step-2}
- [ ] {next-step} ← current
- [ ] {future-step}

## Key Decisions
- {decision-1}: {rationale}

## Active Files
- {file-path-1} ({status: editing/created/reviewed})

## Open Questions
- {unresolved-question-if-any}
```

### Rules

1. **Create on task start** — When starting a non-trivial task (3+ steps), create `active.md` immediately.
2. **Update incrementally** — Update after each milestone, not in batch.
3. **Delete on task completion** — When the task is fully done and committed, delete `active.md`. Do not let stale state accumulate.
4. **Keep it concise** — Target 20-50 lines. This is a checkpoint, not a log.
5. **Never duplicate the conversation** — Only record decisions and progress, not discussion.

---

## Governance

This constitution has the highest priority, superseding any `CLAUDE.md` or single-session instructions.

### Enforcement Protocol

The following clauses are non-negotiable:

1. **Skill mandatory loading** — When a task matches a Skill's trigger conditions, the Skill must be loaded and followed.
2. **Subagent constraint inheritance** — Subagents must first read `constitution.md` and relevant Skills before execution. Subagent output must pass `verification` skill before merging.
3. **Confirmation gates cannot be skipped** — Steps marked "must wait for user confirmation" in Commands must not be skipped.
4. **Pre-completion verification** — Before declaring any feature or bug fix "complete", the `verification` skill checklist must be executed.
5. **Violation handling** — If committed code violates the constitution, immediately flag and fix it.
6. **Skill semantic matching** — Skills are triggered not only by keywords but by task semantics. When a task involves adding or modifying functional behavior → load `tdd`. When a task is about to be declared complete → load `verification`. Judge by what the task *does*, not just what words the user used.
