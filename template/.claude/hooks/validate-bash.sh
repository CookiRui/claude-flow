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
#
# How it works:
#   1. Reads the tool input JSON from stdin to extract the command
#   2. Checks the command against blocked patterns (exit 2) and warned patterns (exit 0 + stderr)
#   3. Blocked = irreversible git ops; Warned = rm -rf (often legitimate, just needs attention)
#
# Environment provided by Claude Code:
#   CLAUDE_TOOL_NAME — name of the tool being called (Bash)
#   stdin            — JSON object with the tool's input parameters

set -euo pipefail

# ---------------------------------------------------------------------------
# COMMAND PATTERNS
# ---------------------------------------------------------------------------

# BLOCKED (exit 2): irreversible git operations that can destroy history or uncommitted work
BLOCKED_PATTERNS=(
    'git\s+reset\s+--hard'          # destroys uncommitted work
    'git\s+clean\s+(-[a-zA-Z]*f|--force)' # deletes untracked files
    'git\s+push\s+(-[a-zA-Z]*f|--force)'  # rewrites remote history
    'git\s+push\s+--force-with-lease'      # still rewrites history
    'git\s+checkout\s+\.'           # discards all unstaged changes
    'git\s+restore\s+\.'            # discards all unstaged changes
    'git\s+branch\s+-D'             # force-delete branch without merge check
    '{blocked-command-pattern}'     # project-specific (placeholder)
)

# WARNED (exit 0, stderr message): potentially destructive but often legitimate
WARNED_PATTERNS=(
    'rm\s+(-[a-zA-Z]*f|-[a-zA-Z]*r|--force|--recursive)' # rm -rf, rm -f
    'rm\s+-[a-zA-Z]*r[a-zA-Z]*f'                          # rm -rf (flag order variant)
    '{warned-command-pattern}'      # project-specific (placeholder)
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
        # Skip placeholder entries that were never replaced
        if [[ "$pattern" == "{"*"}" ]]; then
            continue
        fi

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
        if [[ "$pattern" == "{"*"}" ]]; then
            continue
        fi

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
