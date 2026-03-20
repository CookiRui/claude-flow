#!/bin/bash
# reinject-context.sh — SessionStart hook that reinjects key context after compaction
#
# Usage: Configure as a Claude Code SessionStart Hook
#   .claude/settings.json:
#   {
#     "hooks": {
#       "SessionStart": [
#         { "matcher": "compact", "command": "bash .claude/hooks/reinject-context.sh" }
#       ]
#     }
#   }
#
# How it works:
#   1. Fires when Claude Code starts a new session after a /compact operation
#   2. Cats the project constitution so Claude re-reads the core rules
#   3. Cats the current WIP file (if it exists) so Claude recovers in-flight work
#   4. Prints a brief summary line so Claude knows the context was reinjected
#
# Output goes to stdout — Claude Code reads it and incorporates it into context.

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION — replace {placeholder} values for your project
# ---------------------------------------------------------------------------

# Path to the project constitution (relative to repo root)
CONSTITUTION_FILE=".claude/constitution.md"

# Path to the current work-in-progress notes (relative to repo root)
WIP_FILE=".claude-flow/wip.md"

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    echo "========================================================"
    echo "  Context Reinjection — post-compaction restore"
    echo "========================================================"
    echo ""

    # Reinject constitution
    if [ -f "$CONSTITUTION_FILE" ]; then
        echo "--- [constitution: $CONSTITUTION_FILE] ---"
        cat "$CONSTITUTION_FILE"
        echo ""
    else
        echo "[reinject-context] WARNING: $CONSTITUTION_FILE not found — skipping." >&2
    fi

    # Reinject WIP if present
    if [ -f "$WIP_FILE" ]; then
        echo "--- [wip: $WIP_FILE] ---"
        cat "$WIP_FILE"
        echo ""
    fi

    echo "========================================================"
    echo "  Context reinjected. Resume work from the WIP above."
    echo "========================================================"
}

main "$@"
