# Contract: task-3.task-2

## Inputs
- scripts/persistent-solve.py: _run_dag_mode(goal, max_rounds, max_time, budget, start_time, skip_clarify, recursive, kanban, kanban_path, verify_level, dry_run) — the function under test
- scripts/persistent-solve.py: plan_dag(goal, budget) -> RecursiveDAG — must be patched to return a synthetic DAG
- scripts/persistent-solve.py: execute_dag(dag, goal, budget, kanban_state, kanban_path) — must be patched to verify it is NOT called
- scripts/persistent-solve.py: RecursiveTask dataclass — needed to construct synthetic tasks (fields: id, description, acceptance_criteria, dependencies, files, status, complexity, depth, children, parent)
- scripts/persistent-solve.py: RecursiveDAG class — container with .tasks dict and .summary() method
- scripts/persistent-solve.py: BudgetTracker — required positional arg for _run_dag_mode; must be constructable or mocked
- scripts/persistent-solve.py: KanbanState — instantiated internally when kanban=True; writes JSON via .save(path)

## Outputs
- tests/test_dry_run.py: pytest-discoverable test module with ≥1 test function
- Assertion: plan_dag called ≥1 time (dry_run still plans)
- Assertion: execute_dag call_count == 0 (dry_run skips execution)
- Assertion: kanban JSON file exists at tmp_path after dry_run with kanban=True

## Constraints
- Module must be imported via importlib (not direct import) because scripts/ is not a package
- Must patch plan_dag at module level (importlib-loaded module attribute) to return a synthetic RecursiveDAG with ≥1 RecursiveTask
- Must patch execute_dag at module level to a MagicMock and assert call_count==0
- Call _run_dag_mode with dry_run=True, recursive=False, skip_clarify=True, kanban=True, kanban_path=str(tmp_path/'kanban.json')
- BudgetTracker must be real or mocked with .can_afford() -> True and .remaining() -> float
- No external dependencies allowed (Constitution §3) — only pytest + stdlib
- kanban_path must use tmp_path fixture (pytest) so no filesystem side-effects leak
- start_time must be a recent float (time.time()) so the elapsed-time circuit breaker doesn't trigger
- max_rounds ≥ 1 and max_time large enough that the loop body executes at least once
