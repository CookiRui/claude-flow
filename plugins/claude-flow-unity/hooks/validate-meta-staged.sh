#!/usr/bin/env bash
# validate-meta-staged.sh — PreToolUse hook: Block git commit if .meta files are
# missing from the staging area (Unity asset integrity check)
#
# Plugin version: uses UNITY_ASSETS_DIR env var or defaults to "Assets".
#
# Exit codes:
#   0  — all .meta files accounted for, or no relevant files staged
#   2  — .meta files missing from staging area (commit blocked)

set -euo pipefail

ASSETS_DIR="${UNITY_ASSETS_DIR:-Assets}"

# Extract the "command" field from the tool input JSON on stdin
input=$(cat)
command=$(echo "$input" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)

[ -z "$command" ] && exit 0

# Only trigger on git commit commands
if ! echo "$command" | grep -qEi 'git\s+commit'; then
  exit 0
fi

# Get staged files under Assets/ by change type
staged_acr=$(git diff --cached --name-only --diff-filter=ACR -- "$ASSETS_DIR/" 2>/dev/null || true)
staged_del=$(git diff --cached --name-only --diff-filter=D -- "$ASSETS_DIR/" 2>/dev/null || true)

# Quick exit: nothing staged under Assets/
if [ -z "$staged_acr" ] && [ -z "$staged_del" ]; then
  exit 0
fi

# Full staged file list for lookup
all_staged=$(git diff --cached --name-only -- "$ASSETS_DIR/" 2>/dev/null || true)

missing=()

# Check 1: New/Copied/Renamed files must have .meta staged or already tracked
while IFS= read -r file; do
  [ -z "$file" ] && continue
  [[ "$file" == *.meta ]] && continue

  meta="${file}.meta"

  if echo "$all_staged" | grep -qxF "$meta"; then
    continue
  fi

  if git ls-files --error-unmatch "$meta" >/dev/null 2>&1; then
    continue
  fi

  missing+=("  - ${meta}  (for: ${file})")
done <<< "$staged_acr"

# Check 2: New parent directories need .meta
checked_dirs=""
while IFS= read -r file; do
  [ -z "$file" ] && continue
  [[ "$file" == *.meta ]] && continue

  dir=$(dirname "$file")
  while [ "$dir" != "$ASSETS_DIR" ] && [ "$dir" != "." ]; do
    if echo "$checked_dirs" | grep -qxF "$dir"; then
      break
    fi
    checked_dirs="${checked_dirs}${dir}
"

    if ! git ls-tree --name-only HEAD -- "$dir" >/dev/null 2>&1 || [ -z "$(git ls-tree --name-only HEAD -- "$dir" 2>/dev/null)" ]; then
      dir_meta="${dir}.meta"

      if ! echo "$all_staged" | grep -qxF "$dir_meta"; then
        if ! git ls-files --error-unmatch "$dir_meta" >/dev/null 2>&1; then
          missing+=("  - ${dir_meta}  (new directory)")
        fi
      fi
    fi

    dir=$(dirname "$dir")
  done
done <<< "$staged_acr"

# Check 3: Deleted files — .meta should also be staged for deletion
while IFS= read -r file; do
  [ -z "$file" ] && continue
  [[ "$file" == *.meta ]] && continue

  meta="${file}.meta"

  if echo "$staged_del" | grep -qxF "$meta"; then
    continue
  fi

  if git ls-files --error-unmatch "$meta" >/dev/null 2>&1; then
    missing+=("  - ${meta}  (orphaned: $(basename "$file") deleted but .meta remains)")
  fi
done <<< "$staged_del"

# Report
if [ ${#missing[@]} -eq 0 ]; then
  exit 0
fi

echo "BLOCKED: ${#missing[@]} .meta file(s) missing from staging area:" >&2
echo "" >&2
for item in "${missing[@]}"; do
  echo "$item" >&2
done
echo "" >&2
echo "Fix: git add <missing .meta files>" >&2
echo "Or:  git add ${ASSETS_DIR}/**/*.meta" >&2

exit 2
