# Contract: write-tests

## Inputs
- scripts/task-stats.py must exist with: main() using argparse, --json flag for JSON output, reads .claude-flow/kanban.json, prints summary (total, done, failed, pending, cost), exits non-zero on missing file
- .claude-flow/kanban.json schema: {goal, start_time, updated_at, summary: {total, done, failed, running, pending, total_cost_usd, phase}, tree: {task-id: {status, ...}}}
- Existing test conventions from tests/ (sys.path.insert for scripts/, importlib for hyphenated names, pytest fixtures, class-based grouping)

## Outputs
- tests/test_task_stats.py: pytest test suite covering 5 scenarios — default text output, --json output, missing kanban file (non-zero exit), empty kanban tree, mixed task statuses
- CI-green signal: all tests pass via `pytest tests/test_task_stats.py`

## Constraints
- Python standard library only (Constitution §3) — tests may use pytest but no other external deps
- Must import scripts/task-stats.py via importlib (hyphenated filename, same pattern as test_dry_run.py)
- Tests must not depend on real .claude-flow/kanban.json — use tmp_path or mock to supply fixture data
- Missing-file test must assert non-zero exit code (CLI Rules: fail-fast with non-zero exit)
- JSON output test must verify parseable JSON with expected keys (total, done, failed, pending, total_cost_usd)
- Edge case: empty tree {} must produce zero counts without error
- Edge case: mixed statuses tree must correctly tally each status category
