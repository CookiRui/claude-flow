# Project Constitution (Generic — claude-flow plugin default)

> This is a generic constitution provided by the claude-flow plugin.
> Run `/claude-flow:init` to generate a project-specific version with concrete constraints.

---

## §1: Skill Enforcement

When a task matches a Skill's trigger conditions, the Skill must be loaded and followed:
- Adding/modifying functional behavior → load `tdd` skill
- Task about to be declared complete → load `verification` skill
- Complex multi-step task → load `deep-task` skill

---

## §2: TDD is Mandatory

All new functional code must follow RED-GREEN-REFACTOR. No exceptions except pure config/docs changes.

```
// ✅ Correct — test first
1. Write failing test
2. Write minimal implementation to pass
3. Refactor while keeping green

// ❌ Wrong — implement first, add tests later
1. Write implementation
2. Write tests that match implementation (rubber-stamp tests)
```

---

## §3: Pre-Completion Verification

Before declaring any feature or bug fix "complete", the `verification` skill checklist must pass:
- All tests pass (zero failures)
- No TODO/FIXME/HACK in committed code
- Edge cases handled
- No unnecessary dependencies introduced

---

## §Session State Protocol

**The file is the memory, not the conversation.** Conversations are ephemeral — they get compacted, crash, or end. The file `.claude-flow/session-state/active.md` persists across all of these.

### When to update

Update `active.md` after each significant milestone:
- A task step is completed (code written, test passed, file committed)
- An architectural or design decision is made
- Switching focus to a different task or subtask

### Rules

1. **Create on task start** — When starting a non-trivial task (3+ steps), create `active.md` immediately.
2. **Update incrementally** — Update after each milestone, not in batch.
3. **Delete on task completion** — When the task is fully done and committed, delete `active.md`.
4. **Keep it concise** — Target 20-50 lines. This is a checkpoint, not a log.

---

## Governance

This constitution has the highest priority, superseding any `CLAUDE.md` or single-session instructions.

### Enforcement Protocol

1. **Skill mandatory loading** — When a task matches a Skill's trigger conditions, the Skill must be loaded and followed.
2. **Subagent constraint inheritance** — Subagents must first read this constitution and relevant Skills before execution.
3. **Confirmation gates cannot be skipped** — Steps marked "must wait for user confirmation" must not be skipped.
4. **Pre-completion verification** — Before declaring any feature or bug fix "complete", the `verification` skill checklist must be executed.
5. **Violation handling** — If committed code violates the constitution, immediately flag and fix it.
