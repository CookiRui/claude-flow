---
description: Autonomous 8-layer deep execution engine for complex tasks
argument-hint: <goal description>
---

# /deep-task

Autonomous execution engine. Classifies complexity, decomposes into DAG, executes in parallel with Agent tool, verifies at three levels, and captures learnings.

## Phase 0: Complexity Classification

Classify the goal before doing anything else:

| Question | Yes | No |
|----------|-----|----|
| Only 1 file, no dependencies, auto-verifiable? | → **S** | ↓ |
| 2-5 files, clear acceptance criteria? | → **M** | ↓ |
| Cross-module or architecture decision? | → **L** | ↓ |
| Needs product/strategic judgment? | → **XL** | Use L |

Output your classification and reasoning.

### S — Fast Path

1. Execute directly
2. L1 self-check
3. `git commit -m "checkpoint: {description}"`
4. **Done. Stop here.**

### M — Standard Path

1. Decompose into 2-5 linear sub-tasks, each with acceptance criteria
2. Execute sequentially:
   - Execute sub-task
   - `git commit -m "checkpoint: {task}"`
   - L1 self-check
3. L2 verification on critical path (if any)
4. **Done. Stop here.**

### L/XL — Full Engine (continue to Phase 1)

---

## Phase 1: Goal Review (NO code changes)

1. **Check for existing WIP**: Read `.claude-flow/wip.md`. If it exists and matches this goal, resume from Phase 3 with the existing DAG.

2. **Assess feasibility**:
   - Is the goal physically possible?
   - Is it clear enough to decompose? If ambiguous → `AskUserQuestion` to clarify.
   - Are there hidden tradeoffs? If yes → notify user.
   - Confidence < 0.3 → present options and let user decide direction.

3. **Build context**:
   - Read constitution (`.claude/constitution.md`)
   - Run `python scripts/repo-map.py --format md --no-refs` if available (generates code map)
   - Load relevant Skills

4. **Plan model routing**:
   - Editing/simple tasks → `Agent(model="haiku")`
   - Search/analysis tasks → `Agent(model="sonnet")`
   - Architecture decisions → keep in main context (current model)

5. Output: refined goal statement + feasibility assessment.
   - **XL only**: `AskUserQuestion` — must wait for user confirmation before Phase 2.

---

## Phase 2: DAG Decomposition

Break the goal into a DAG (Directed Acyclic Graph) of sub-tasks.

Each sub-task must have:
- **ID**: short identifier (e.g., `T1`, `T2a`)
- **Description**: what to do
- **Acceptance criteria**: machine-verifiable condition (test passes / compiles / behavior observable)
- **Dependencies**: list of task IDs that must complete first
- **Model**: `haiku` (edits), `sonnet` (analysis), or `main` (architecture)
- **Files**: which files to create/modify

Format:
```
- T1: Set up data models → `src/models.py` | Done: types defined, imports work | Deps: none | Model: haiku
- T2: Implement core logic → `src/service.py` | Done: unit tests pass | Deps: T1 | Model: sonnet
- T3: Add API endpoint → `src/routes.py` | Done: endpoint responds | Deps: T2 | Model: haiku
- T4: Integration tests → `tests/` | Done: all tests pass | Deps: T2, T3 | Model: sonnet
```

### Decomposition Pre-Check

Before proceeding, verify:
- [ ] **Coverage**: all sub-tasks done = original goal achieved?
- [ ] **Independence**: boundaries between tasks are clear?
- [ ] **Verifiable**: each acceptance criterion can be checked automatically?
- [ ] **Granularity**: each task ≤ 5 minutes? If not, split further.
- [ ] **Dependencies**: DAG is acyclic and correctly ordered?

**XL tasks**: present DAG via `AskUserQuestion`, must wait for confirmation.

---

## Phase 3: Parallel Execution Loop

```
while ready_tasks exist:
    1. Get ready tasks (all dependencies met)
    2. Group by conflict (tasks touching same files = conflict)
    3. Non-conflicting → launch in PARALLEL via multiple Agent() calls in ONE message
    4. Conflicting → execute SEQUENTIALLY
    5. After each batch:
       a. Verify completed tasks (L1)
       b. Run regression check on previously completed tasks
       c. git commit -m "checkpoint: {task-id} {description}"
       d. If regression fails → git revert → replan with constraint
       e. Update DAG status
```

### Agent Call Format

For each sub-task, launch:
```
Agent(
  model="{task.model}",
  prompt="Execute this task:\n{task.description}\n\nAcceptance criteria: {task.criteria}\n\nFiles to modify: {task.files}\n\nIMPORTANT:\n- Read the constitution first (.claude/constitution.md)\n- Follow TDD if this involves functional code\n- Only modify the specified files\n- Verify acceptance criteria before finishing"
)
```

Launch **multiple Agent calls in a single message** for parallel execution.

### Anti-Loop Rules

- Same strategy fails twice → MUST switch approach
- 3 consecutive failures on one task → escalate:
  - Confidence 0.3-0.5 → `AskUserQuestion` with 2-3 options
  - Confidence < 0.3 → save WIP, present full handoff

### Failure Salvage

When a sub-task fails, before discarding:
- What hypotheses were eliminated?
- What code/data is reusable?
- How does this narrow the solution space?

Record salvage in the DAG status for future attempts.

---

## Phase 4: Three-Level Verification

### L1 — Self-Check (during Phase 3, per sub-task)
Each Agent verifies its own acceptance criteria. Already done in execution loop.

### L2 — Adversarial Review (after all sub-tasks complete)

Launch a dedicated Agent:
```
Agent(
  model="sonnet",
  prompt="You are a strict code reviewer. Here is the full diff of changes:\n\n{git diff from start}\n\nCheck:\n1. Are edge cases handled?\n2. What implicit assumptions could break?\n3. Any integration risks with other modules?\n4. Constitution compliance (read .claude/constitution.md)?\n\nOnly flag real issues, not style nitpicks. Output a list of issues or 'PASS'."
)
```

If issues found → fix → re-run L2.

### L3 — End-to-End (final gate)
1. Run full test suite
2. Check original goal's acceptance criteria
3. Constitution compliance audit (article by article)
4. If all pass → proceed to Phase 5
5. If fail → fix → re-verify from L1

---

## Phase 5: Meta-Learning

Analyze the execution trace and save insights:

1. What was the actual complexity vs. estimated? (Was S/M/L/XL correct?)
2. Which strategies worked? Which failed?
3. Any new patterns worth remembering?
4. How accurate were the time/effort estimates?

Write to `memory/meta_{domain}.md`:
```markdown
---
name: meta_{domain}
description: Meta-strategy for {domain} tasks
type: feedback
---

## {Domain} Tasks

### Best Strategies
- {insight} (validated: {date})

### Pitfalls
- {what failed and why}

### Verification Level
- Recommend L{N}, because {reason}
```

If the file exists, update it. If not, create it.

---

## Escalation Summary

| Confidence | Action |
|-----------|--------|
| > 0.8 | Proceed silently |
| 0.5–0.8 | Notify user of approach, continue |
| 0.3–0.5 | `AskUserQuestion` with 2-3 options |
| < 0.3 | Save WIP to `.claude-flow/wip.md`, full handoff |

---

## Prohibited Actions

- Do not skip Phase 0 complexity classification
- Do not run L/XL tasks through S/M fast path
- Do not use `Agent(model="opus")` for simple edits (cost waste)
- Do not skip L2 verification for L/XL tasks
- Do not commit without passing L1 check
- Do not proceed past XL decomposition without user confirmation
- Do not declare complete before L3 verification for L/XL tasks
- Do not repeat a failed strategy more than twice
