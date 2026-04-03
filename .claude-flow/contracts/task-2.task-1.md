# Contract: task-2.task-1

## Inputs
- persistent-solve.py module importable via importlib (hyphenated filename)
- _run_dag_mode function with dry_run: bool parameter (line 2140)
- plan_dag function (line 934) returning RecursiveDAG
- execute_dag function (line 1790) called inside _run_dag_mode
- RecursiveDAG class (line 93) and RecursiveTask class for building synthetic DAGs
- BudgetTracker class for constructing budget argument
- clarify_goal function (called in _run_dag_mode unless skip_clarify=True)

## Outputs
- tests/test_dry_run.py file with pytest-compatible test suite
- Test fixture producing a synthetic RecursiveDAG with at least one task
- Test asserting execute_dag.call_count == 0 when dry_run=True
- Importlib-based import pattern consistent with existing test_persistent_solve.py

## Constraints
- Must use importlib.import_module('persistent-solve') due to hyphenated filename
- Must mock plan_dag to return synthetic RecursiveDAG (avoid real Claude API calls)
- Must mock execute_dag to capture whether it was called
- Must mock clarify_goal or pass skip_clarify=True to avoid API calls during planning
- Must pass skip_clarify=True and provide valid BudgetTracker and timing args to _run_dag_mode
- No external dependencies — only stdlib + pytest (per Constitution §3)
- Production code _run_dag_mode currently lacks dry_run guard — test will fail RED until guard is added
- sys.path manipulation needed to import from scripts/ directory
