# Contract: task-3.task-3

## Inputs
- ps.recursive_plan(goal, budget) -> RecursiveDAG with .tasks attribute
- ps._run_dag_mode(goal, budget, max_seconds/max_rounds/start_time, skip_clarify, dry_run, recursive, kanban) callable
- ps.RecursiveDAG dataclass with .tasks dict and .summary() method
- ps.RecursiveTask dataclass with fields: id, description, acceptance_criteria, dependencies, files, status, children
- ps.BudgetTracker(max_dollars) for budget tracking
- ps.execute_recursive_dag(dag, goal, budget, kanban_state, kanban_path) callable (to verify NOT called)
- ps.KanbanState class with .update_from_dag() and .save(path) methods

## Outputs
- A pytest test method test_recursive_dry_run_skips_execution in TestDryRun class in tests/test_dry_run.py
- Asserts recursive_plan called >= 1 time
- Asserts execute_recursive_dag call_count == 0
- Asserts kanban JSON file exists on disk after dry-run with kanban=True

## Constraints
- Must patch ps.recursive_plan to return a synthetic RecursiveDAG (not call real Claude API)
- Must call _run_dag_mode with dry_run=True, recursive=True, skip_clarify=True
- _run_dag_mode requires positional args: goal, max_rounds, max_time, budget, start_time — all must be supplied
- Synthetic RecursiveDAG.tasks must be a dict (keyed by id) since recursive mode uses dag.tasks.values()
- kanban=True and a tmp kanban_path required to verify kanban JSON file creation
- Must also patch execute_recursive_dag to ensure it is not called (not just check absence of side effects)
- No external dependencies allowed — only stdlib + pytest (Constitution §3)
- Test must live in tests/test_dry_run.py alongside existing TestDryRun class
