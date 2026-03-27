#!/bin/bash
# pre-compact.sh — PreCompact hook that dumps session state before context compression
#
# Usage: Configure as a Claude Code PreCompact Hook
#   .claude/settings.json:
#   {
#     "hooks": {
#       "PreCompact": [
#         { "matcher": "", "hooks": [{ "type": "command", "command": "bash .claude/hooks/pre-compact.sh" }] }
#       ]
#     }
#   }
#
# How it works:
#   1. Fires right before Claude Code compresses the conversation context
#   2. Outputs the current session state file so it survives summarization
#   3. Lists git working tree changes (unstaged/staged/untracked)
#   4. Prints recovery instructions that persist into the compacted summary
#
# Output goes to stdout — injected into the conversation right before compaction,
# ensuring critical state is included in the compressed summary.

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION — replace {placeholder} values for your project
# ---------------------------------------------------------------------------

SESSION_STATE_FILE=".claude-flow/session-state/active.md"

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    echo "=== SESSION STATE BEFORE COMPACTION ==="
    echo "Timestamp: $(date 2>/dev/null || echo 'unknown')"

    # --- Active session state file ---
    if [ -f "$SESSION_STATE_FILE" ]; then
        echo ""
        echo "## Active Session State (from $SESSION_STATE_FILE)"
        STATE_LINES=$(wc -l < "$SESSION_STATE_FILE" 2>/dev/null | tr -d ' ')
        if [ "$STATE_LINES" -gt 100 ] 2>/dev/null; then
            head -n 100 "$SESSION_STATE_FILE"
            echo "... (truncated — $STATE_LINES total lines, showing first 100)"
        else
            cat "$SESSION_STATE_FILE"
        fi
    else
        echo ""
        echo "## No active session state file found"
        echo "Consider maintaining $SESSION_STATE_FILE for better recovery."
        echo "See constitution.md §Session State Protocol for the format."
    fi

    # --- Files modified this session ---
    echo ""
    echo "## Files Modified (git working tree)"

    CHANGED=$(git diff --name-only 2>/dev/null || true)
    STAGED=$(git diff --staged --name-only 2>/dev/null || true)
    UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null || true)

    if [ -n "$CHANGED" ]; then
        echo "Unstaged changes:"
        echo "$CHANGED" | while read -r f; do echo "  - $f"; done
    fi
    if [ -n "$STAGED" ]; then
        echo "Staged changes:"
        echo "$STAGED" | while read -r f; do echo "  - $f"; done
    fi
    if [ -n "$UNTRACKED" ]; then
        echo "New untracked files:"
        echo "$UNTRACKED" | while read -r f; do echo "  - $f"; done
    fi
    if [ -z "$CHANGED" ] && [ -z "$STAGED" ] && [ -z "$UNTRACKED" ]; then
        echo "  (no uncommitted changes)"
    fi

    # --- Recovery instructions ---
    echo ""
    echo "## Recovery Instructions"
    echo "After compaction, read $SESSION_STATE_FILE to recover full working context."
    echo "Then read any files listed above that are being actively worked on."
    echo "=== END SESSION STATE ==="
}

main "$@"
