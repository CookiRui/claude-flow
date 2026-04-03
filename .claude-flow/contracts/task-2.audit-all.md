# Contract: task-2.audit-all

## Inputs
- scripts/kanban-viewer.html — the single-file HTML implementation to audit (838 lines)
- docs/persistent-solve-v2/plan.md §3.4 KanbanState + §5.5 kanban.json schema — canonical data contract defining goal, start_time, updated_at, summary{total,done,failed,running,pending,total_cost_usd}, tree[]{id,description,status,complexity,cost_usd,commit,children}
- docs/persistent-solve-v2/plan.md §5.5 terminal tree output spec — expected display format with [status] id: description ($cost) commit
- 7-feature list derived from checkpoint history: (1a) recursive tree rendering, (1b) status color badges, (1c) summary bar, (1d) auto-refresh, (1e) drag-drop file loading, (1f) dark/light theme, (1g) collapsible subtrees

## Outputs
- Per-feature checklist (7 sections) with pass/fail for each expected behavior
- For each discrepancy: line number in kanban-viewer.html, expected behavior per spec, actual behavior observed
- Severity classification per issue (e.g., data field missing vs. cosmetic mismatch)
- Summary count: total issues found, grouped by feature

## Constraints
- Audit is read-only — no code modifications, only analysis output
- Line numbers must reference the current file state (838 lines), not historical versions
- Spec authority is docs/persistent-solve-v2/plan.md kanban.json schema; the HTML must render ALL fields defined there
- The kanban.json uses 'commit' as key name but the HTML reads 'commit_hash' (line 578) — this kind of field-name mismatch is a primary audit target
- The kanban.json spec includes 'complexity', 'start_time', 'updated_at' fields that may or may not be rendered — must check each
- Constitution §2 applies: if the audit finds the viewer diverges from spec, README.md must also be checked for consistency
- Single-file constraint: kanban-viewer.html must remain a valid standalone HTML file (no build step, no external deps)
