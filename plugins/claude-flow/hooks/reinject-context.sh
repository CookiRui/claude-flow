#!/bin/bash
# reinject-context.sh — SessionStart hook that reinjects key context after compaction
#
# Plugin version: reads project-level constitution and session state.
# Falls back gracefully if project-level files don't exist.
#
# Output goes to stdout — Claude Code reads it and incorporates it into context.

set -euo pipefail

CONSTITUTION_FILE=".claude/constitution.md"
SESSION_STATE_FILE=".claude-flow/session-state/active.md"
WIP_FILE=".claude-flow/wip.md"

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
    fi

    # --- Inject L0 code map (if generated) ---
    L0_FILE=".repo-map/L0.md"
    if [ -f "$L0_FILE" ]; then
        echo "--- [code-map L0: $L0_FILE] ---"
        cat "$L0_FILE"
        echo ""
    fi

    # --- Inject module-scoped rules (if scope-loader available and session state has active files) ---
    if [ -f "$SESSION_STATE_FILE" ]; then
        ACTIVE_FILES=$(grep -A 50 "## Active Files" "$SESSION_STATE_FILE" 2>/dev/null \
            | grep "^- " | sed 's/^- //' | sed 's/ (.*//' | tr '\n' ',' | sed 's/,$//')
        if [ -n "$ACTIVE_FILES" ]; then
            # Try scope-loader from PATH (plugin bin/) or project scripts/
            SCOPE_OUTPUT=""
            if command -v scope-loader.py &>/dev/null; then
                SCOPE_OUTPUT=$(scope-loader.py --files "$ACTIVE_FILES" --format inject 2>/dev/null || true)
            elif [ -f "scripts/scope-loader.py" ]; then
                SCOPE_OUTPUT=$(python scripts/scope-loader.py --files "$ACTIVE_FILES" --format inject 2>/dev/null || true)
            fi
            if [ -n "$SCOPE_OUTPUT" ]; then
                echo "$SCOPE_OUTPUT"
                echo ""
            fi
        fi
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
