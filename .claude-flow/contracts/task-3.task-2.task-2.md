# Contract: task-3.task-2.task-2

## Inputs
- scripts/persistent-solve.py module loadable via importlib with hyphenated filename
- RecursiveDAG and RecursiveTask dataclasses from persistent-solve (id, description, acceptance_criteria, dependencies, files, status fields)
- BudgetTracker class with max_dollars constructor parameter
- _run_dag_mode function accepting goal, budget, max_seconds/max_rounds/max_time, skip_clarify, dry_run, kanban, kanban_path keyword args
- plan_dag function (patchable on module) returning a RecursiveDAG
- execute_dag function (patchable on module) for execution verification
- KanbanState class with update_from_dag(dag) and save(path) methods
- clarify_goal function (patchable on module) for skip_clarify bypass

## Outputs
- tests/test_dry_run.py discoverable by pytest with ≥1 passing test
- Assertion: plan_dag.called is True after dry_run=True invocation
- Assertion: execute_dag.call_count == 0 after dry_run=True invocation
- Assertion: tmp_path/'kanban.json' exists and contains valid JSON when kanban=True + dry_run=True

## Constraints
- Module loading must use importlib.import_module('persistent-solve') due to hyphenated filename
- sys.path must include scripts/ directory before import
- All external calls (plan_dag, execute_dag, clarify_goal, subprocess) must be mocked — no real Claude API calls
- Synthetic DAG must contain at least one RecursiveTask with all required fields (id, description, acceptance_criteria, dependencies, files)
- Python standard library only — no external test dependencies beyond pytest (Constitution §3)
- kanban JSON test requires _run_dag_mode called with kanban=True and kanban_path=str(tmp_path/'kanban.json')
- _run_dag_mode signature requires max_rounds, max_time, start_time positional-style args in addition to goal and budget
- KanbanState.save writes JSON to disk — must either use real KanbanState or mock the file write and verify independently
