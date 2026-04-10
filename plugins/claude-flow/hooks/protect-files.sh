#!/bin/bash
# protect-files.sh — PreToolUse hook that warns/blocks edits to protected paths
#
# Plugin version: reads project-specific config from .claude-flow/protected-files.json
# if it exists, otherwise uses sensible defaults.
#
# Environment provided by Claude Code:
#   CLAUDE_TOOL_NAME — name of the tool being called (Edit, Write, …)
#   stdin            — JSON object with the tool's input parameters

set -euo pipefail

# ---------------------------------------------------------------------------
# CONFIGURATION — load from project config or use defaults
# ---------------------------------------------------------------------------

CONFIG_FILE=".claude-flow/protected-files.json"

# Default hard-protected paths (always blocked)
DEFAULT_HARD=('.env' '.env.local' '.env.production' '.env.staging')

# Default soft-protected paths (warn but allow)
DEFAULT_SOFT=('node_modules/' '__pycache__/' '*.lock' 'vendor/' 'dist/' 'build/')

# Load project-specific config if it exists
if [ -f "$CONFIG_FILE" ]; then
    # Extract hard-protected patterns from JSON
    HARD_JSON=$(sed -n 's/.*"hard"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' "$CONFIG_FILE" 2>/dev/null || true)
    SOFT_JSON=$(sed -n 's/.*"soft"[[:space:]]*:[[:space:]]*\[\([^]]*\)\].*/\1/p' "$CONFIG_FILE" 2>/dev/null || true)

    if [ -n "$HARD_JSON" ]; then
        IFS=',' read -ra HARD_PROTECTED <<< "$(echo "$HARD_JSON" | sed 's/"//g' | tr -d ' ')"
    else
        HARD_PROTECTED=("${DEFAULT_HARD[@]}")
    fi

    if [ -n "$SOFT_JSON" ]; then
        IFS=',' read -ra SOFT_PROTECTED <<< "$(echo "$SOFT_JSON" | sed 's/"//g' | tr -d ' ')"
    else
        SOFT_PROTECTED=("${DEFAULT_SOFT[@]}")
    fi
else
    HARD_PROTECTED=("${DEFAULT_HARD[@]}")
    SOFT_PROTECTED=("${DEFAULT_SOFT[@]}")
fi

# ---------------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------------

extract_file_path() {
    local input
    input=$(cat)
    echo "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

matches_any() {
    local path="$1"
    shift
    local pattern
    for pattern in "$@"; do
        [ -z "$pattern" ] && continue
        case "$path" in
            $pattern*) return 0 ;;
        esac
        case "$path" in
            */$pattern*) return 0 ;;
        esac
    done
    return 1
}

# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

main() {
    local file_path
    file_path=$(extract_file_path)

    if [ -z "$file_path" ]; then
        exit 0
    fi

    if matches_any "$file_path" "${HARD_PROTECTED[@]}"; then
        echo "[protect-files] BLOCKED: '${file_path}' matches a hard-protected pattern." >&2
        echo "[protect-files] If this edit is intentional, edit the file manually." >&2
        exit 2
    fi

    if matches_any "$file_path" "${SOFT_PROTECTED[@]}"; then
        echo "[protect-files] WARNING: '${file_path}' is in a soft-protected (generated) path." >&2
        echo "[protect-files] Proceeding, but verify this edit is intentional." >&2
        exit 0
    fi

    exit 0
}

main "$@"
