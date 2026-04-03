#!/bin/bash
# reinject-context.sh — SessionStart hook that reinjects key context after compaction

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
    else
        echo "[reinject-context] WARNING: $CONSTITUTION_FILE not found — skipping." >&2
    fi

    # --- Inject L0 code map ---
    L0_FILE=".repo-map/L0.md"
    if [ -f "$L0_FILE" ]; then
        echo "--- [code-map L0: $L0_FILE] ---"
        cat "$L0_FILE"
        echo ""
    fi

    # --- Inject module-scoped rules (if session state has active files) ---
    if [ -f "$SESSION_STATE_FILE" ]; then
        ACTIVE_FILES=$(grep -A 50 "## Active Files" "$SESSION_STATE_FILE" 2>/dev/null \
            | grep "^- " | sed 's/^- //' | sed 's/ (.*//' | tr '\n' ',' | sed 's/,$//')
        if [ -n "$ACTIVE_FILES" ]; then
            SCOPE_OUTPUT=$(python scripts/scope-loader.py --files "$ACTIVE_FILES" --format inject 2>/dev/null || true)
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
