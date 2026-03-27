# Project Constitution

This file **only defines project-specific, counter-intuitive constraints that AI wouldn't know**.

> **Inclusion criteria**: If you remove a rule, will AI's default behavior produce incorrect code? Yes -> keep it; No -> remove it.

---

## §1: {core-architecture-constraint}

<!-- Your most critical architectural pattern. Example: "All systems register through ManagerCenter, never instantiate directly" -->

{One-line description}. See `{skill-name}` skill for details.

```{language}
// ✅ Correct
{correct-code}

// ❌ Wrong
{wrong-code}
```

---

## §2: {communication-data-flow-constraint}

<!-- How do modules communicate? Example: "Inter-module communication only through EventCenter, no cross-module direct references" -->

{One-line description}

- {rule-1}
- {rule-2}

---

## §3: {performance-resource-constraint}

<!-- Performance red lines. Delete this section for non-performance-critical projects. Example: "No allocations in hot paths" -->

{One-line description}

- {rule-1}
- {rule-2}
- Rules above apply to hot paths only; cold paths prioritize readability

---

## §4: {tech-stack-constraint}

<!-- "Must use X instead of Y" — AI tends to use what it's most familiar with. -->

- **Non-negotiable**: {must-use-X, never-use-Y}
- **Non-negotiable**: {must-use-X, never-use-Y}

<!-- Add §5-§7 as needed. Recommended total: 4-7 articles. -->

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
