#!/bin/bash
# validate-bash.sh — PreToolUse hook that blocks dangerous shell commands
#
# Usage: Configure as a Claude Code PreToolUse Hook
#   .claude/settings.json:
#   {
#     "hooks": {
#       "PreToolUse": [
#         { "matcher": "Bash", "hooks": [{ "type": "command", "command": "bash .claude/hooks/validate-bash.sh" }] }
#       ]
#     }
#   }

set -euo pipefail

# ---------------------------------------------------------------------------
# COMMAND PATTERNS
# ---------------------------------------------------------------------------

# BLOCKED (exit 2): irreversible git operations that can destroy history or uncommitted work
BLOCKED_PATTERNS=(
    'git\s+reset\s+--hard'
    'git\s+clean\s+(-[a-zA-Z]*f|--force)'
    'git\s+push\s+(-[a-zA-Z]*f|--force)'
    'git\s+push\s+--force-with-lease'
    'git\s+checkout\s+\.'
    'git\s+restore\s+\.'
    'git\s+branch\s+-D'
)

# WARNED (exit 0, stderr message): potentially destructive but often legitimate
WARNED_PATTERNS=(
    'rm\s+(-[a-zA-Z]*f|-[a-zA-Z]*r|--force|--recursive)'
    'rm\s+-[a-zA-Z]*r[a-zA-Z]*f'
)

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

extract_command() {
    local input
    input=$(cat)
    echo "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    local cmd
    cmd=$(extract_command)

    if [ -z "$cmd" ]; then
        exit 0
    fi

    # Hard block: irreversible git operations
    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if echo "$cmd" | grep -qE "$pattern"; then
            echo "[validate-bash] BLOCKED: irreversible git command detected." >&2
            echo "[validate-bash] Pattern matched: $pattern" >&2
            echo "[validate-bash] Command: $cmd" >&2
            echo "[validate-bash] If this is intentional, run the command manually in your terminal." >&2
            exit 2
        fi
    done

    # Soft warn: potentially destructive but often legitimate
    for pattern in "${WARNED_PATTERNS[@]}"; do
        if echo "$cmd" | grep -qE "$pattern"; then
            echo "[validate-bash] WARNING: potentially destructive command." >&2
            echo "[validate-bash] Command: $cmd" >&2
            echo "[validate-bash] Proceeding — verify the target path is correct." >&2
            exit 0
        fi
    done

    exit 0
}

main "$@"
