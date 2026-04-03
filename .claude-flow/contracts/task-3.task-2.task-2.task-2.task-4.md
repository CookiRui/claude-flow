# Contract: task-3.task-2.task-2.task-2.task-4

## Inputs
- _run_dag_mode function from scripts/persistent-solve.py with parameters: goal, max_rounds, max_time, budget (BudgetTracker), start_time, skip_clarify, kanban, kanban_path, dry_run
- BudgetTracker class from scripts/persistent-solve.py for budget parameter
- plan_dag function (must be mockable to return a synthetic RecursiveDAG)
- RecursiveDAG and RecursiveTask classes for building synthetic test fixtures
- KanbanState.save() writes JSON with 'summary' and 'tree' keys derived from RecursiveDAG.to_kanban_dict()

## Outputs
- Test function in tests/test_dry_run.py asserting kanban JSON file is written with valid structure
- Validates kanban JSON contains 'summary' key (dict with total, done, failed, running, pending, total_cost_usd)
- Validates kanban JSON contains 'tree' key (list of task node dicts)

## Constraints
- Must use tempfile directory for kanban_path to avoid polluting the working tree
- Must call _run_dag_mode with dry_run=True and kanban=True
- Must mock plan_dag to return a synthetic DAG (avoid real Claude API calls)
- Must read and json.loads() the output file, not just check file existence
- Must assert both 'summary' and 'tree' top-level keys exist in parsed JSON
- Python standard library only (no external test dependencies beyond pytest)
- Test file is tests/test_dry_run.py — extend existing file, do not create a new one
- _run_dag_mode requires positional args: goal, max_rounds, max_time, budget, start_time — all must be supplied
