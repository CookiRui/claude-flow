#!/usr/bin/env python3
"""Tests for --dry-run flag in scripts/persistent-solve.py."""

import sys
import os
from unittest.mock import patch, MagicMock

import pytest

# Allow importing from scripts/
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "scripts"))
from importlib import import_module

# Import the module (filename has a hyphen, so use importlib)
ps = import_module("persistent-solve")

RecursiveDAG = ps.RecursiveDAG
RecursiveTask = ps.RecursiveTask
BudgetTracker = ps.BudgetTracker
_run_dag_mode = ps._run_dag_mode
execute_dag = ps.execute_dag
plan_dag = ps.plan_dag
clarify_goal = ps.clarify_goal


# ============================================================
# Helpers
# ============================================================

def _make_synthetic_dag() -> RecursiveDAG:
    """Build a minimal RecursiveDAG with one task for testing."""
    task = RecursiveTask(
        id="t1",
        description="test task",
        acceptance_criteria="done",
        dependencies=[],
        files=["dummy.py"],
    )
    dag = RecursiveDAG(tasks=[task])
    return dag


# ============================================================
# Dry-run tests
# ============================================================

class TestDryRun:
    """Verify that --dry-run plans but never executes."""

    @patch.object(ps, "execute_dag")
    @patch.object(ps, "plan_dag")
    def test_dry_run_skips_execution(self, mock_plan_dag, mock_execute_dag):
        """When dry_run=True, plan_dag is called but execute_dag is NOT."""
        synthetic_dag = _make_synthetic_dag()
        mock_plan_dag.return_value = synthetic_dag

        budget = BudgetTracker(max_dollars=1.0)

        _run_dag_mode(
            goal="test goal",
            budget=budget,
            max_seconds=60,
            skip_clarify=True,
            dry_run=True,
        )

        mock_plan_dag.assert_called_once()
        assert mock_execute_dag.call_count == 0, (
            "execute_dag must not be called when dry_run=True"
        )
