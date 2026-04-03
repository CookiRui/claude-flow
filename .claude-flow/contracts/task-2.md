# Contract: task-2

## Inputs
- persistent_solve(goal, ..., dry_run=True) entry point in scripts/persistent-solve.py:2080
- main() argparse with --dry-run flag in scripts/persistent-solve.py:2408-2410
- _run_dag_mode(dry_run=bool) receives the flag at scripts/persistent-solve.py:2127
- plan_dag(goal, budget) -> RecursiveDAG planning phase at scripts/persistent-solve.py:934-946
- recursive_plan(goal, budget, ...) -> RecursiveDAG recursive planning at scripts/persistent-solve.py:1147-1226
- RecursiveDAG.to_kanban_dict() for plan output rendering at scripts/persistent-solve.py

## Outputs
- tests/test_dry_run.py with pytest test class verifying --dry-run behavior
- Assertion: execute_dag (line 1790) is never called when dry_run=True
- Assertion: execute_recursive_dag (line 1873) is never called when dry_run=True
- Assertion: plan output (kanban tree or plan summary) is printed to stdout

## Constraints
- Python stdlib only — no external test dependencies beyond pytest (Constitution §3)
- Must mock run_claude_session or plan_dag/recursive_plan to avoid real Claude API calls
- Must follow existing test patterns in tests/test_persistent_solve.py (helper _make_tasks, RecursiveDAG construction)
- Test must import from scripts/persistent-solve.py which uses hyphenated filename — requires importlib workaround
- --dry-run flag is wired in argparse but execution-skip logic is NOT yet implemented in _run_dag_mode; test will initially fail (RED phase of TDD)
- Test must verify both code paths: dag mode (execute_dag) and recursive mode (execute_recursive_dag) are skipped
- Commit message must follow type(scope): description format (git-workflow Rule 1)
