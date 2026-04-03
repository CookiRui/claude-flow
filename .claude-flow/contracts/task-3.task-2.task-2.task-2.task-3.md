# Contract: task-3.task-2.task-2.task-2.task-3

## Inputs
- Module `scripts/persistent-solve.py` importable via importlib (hyphenated filename)
- `_run_dag_mode(goal, max_rounds, max_time, budget, start_time, skip_clarify, recursive, kanban, kanban_path, verify_level, dry_run)` function signature
- `plan_dag(goal, budget) -> RecursiveDAG` callable on the module object for @patch.object
- `execute_dag(dag, goal, budget, ...)` callable on the module object for @patch.object
- `clarify_goal(goal, budget)` callable on the module object (patched or bypassed via skip_clarify=True)
- `RecursiveDAG(tasks=[...])` and `RecursiveTask(id, description, acceptance_criteria, dependencies, files)` constructors for fixture
- `BudgetTracker(max_dollars=float)` constructor for creating a budget instance

## Outputs
- Test file `tests/test_dry_run.py` with class `TestDryRun` containing `test_dry_run_skips_execution`
- Assertion that `plan_dag` is called exactly once when `dry_run=True`
- Assertion that `execute_dag.call_count == 0` when `dry_run=True`

## Constraints
- Must use `@patch.object(ps, ...)` to mock `plan_dag` and `execute_dag` on the imported module, not on local references
- Must pass `skip_clarify=True` to avoid needing a mock for `clarify_goal` (or also patch it)
- All required positional args of `_run_dag_mode` must be provided: goal, max_rounds, max_time, budget, start_time
- Zero external dependencies — only stdlib + pytest (per Constitution §3)
- Module import uses `importlib.import_module('persistent-solve')` due to hyphen in filename
- mock_plan_dag.return_value must be a valid RecursiveDAG so downstream code doesn't crash before the dry_run guard
- Decorator order: bottom @patch is first positional arg to test method, then fixture last (pytest convention)
