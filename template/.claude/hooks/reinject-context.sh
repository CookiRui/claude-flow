#!/bin/bash
# reinject-context.sh — SessionStart hook that reinjects key context after compaction
#
# Usage: Configure as a Claude Code SessionStart Hook
#   .claude/settings.json:
#   {
#     "hooks": {
#       "SessionStart": [
#         { "matcher": "", "command": "bash .claude/hooks/reinject-context.sh" }
#       ]
#     }
#   }
#
# How it works:
#   1. Fires when Claude Code starts a new session (new session or after /compact)
#   2. Cats the project constitution so Claude re-reads the core rules
#   3. Detects and displays session-state/active.md for work-in-progress recovery
#   4. Falls back to legacy .claude-flow/wip.md if session-state not found
#
# Output goes to stdout — Claude Code reads it and incorporates it into context.

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION — replace {placeholder} values for your project
# ---------------------------------------------------------------------------

# Path to the project constitution (relative to repo root)
CONSTITUTION_FILE=".claude/constitution.md"

# Path to the session state file (relative to repo root)
SESSION_STATE_FILE=".claude-flow/session-state/active.md"

# Legacy WIP file path (for backward compatibility)
WIP_FILE=".claude-flow/wip.md"

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    echo "========================================================"
    echo "  Context Reinjection — session restore"
    echo "========================================================"
    echo ""

    # --- Reinject constitution ---
    if [ -f "$CONSTITUTION_FILE" ]; then
        echo "--- [constitution: $CONSTITUTION_FILE] ---"
        cat "$CONSTITUTION_FILE"
        echo ""
    else
        echo "[reinject-context] WARNING: $CONSTITUTION_FILE not found — skipping." >&2
    fi

    # --- Session state recovery ---
    if [ -f "$SESSION_STATE_FILE" ]; then
        echo "=== SESSION STATE DETECTED ==="
        echo "Previous work-in-progress found at: $SESSION_STATE_FILE"
        echo ""
        TOTAL_LINES=$(wc -l < "$SESSION_STATE_FILE" 2>/dev/null | tr -d ' ')
        if [ "$TOTAL_LINES" -gt 50 ]; then
            head -50 "$SESSION_STATE_FILE"
            echo "  ... ($TOTAL_LINES total lines — read the full file to continue)"
        else
            cat "$SESSION_STATE_FILE"
        fi
        echo ""
        echo "=== ACTION: Read $SESSION_STATE_FILE fully, then resume from the next incomplete item. ==="
    elif [ -f "$WIP_FILE" ]; then
        # Legacy fallback: use old wip.md if session-state not found
        echo "--- [wip: $WIP_FILE] ---"
        cat "$WIP_FILE"
        echo ""
        echo "[hint] Consider migrating to $SESSION_STATE_FILE for structured session recovery."
    else
        echo "[session-state] No active session state found. Starting fresh."
    fi

    echo ""
    echo "========================================================"
    echo "  Context reinjected. Resume work from the state above."
    echo "========================================================"
}

main "$@"
