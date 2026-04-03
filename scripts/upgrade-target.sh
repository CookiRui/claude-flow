#!/bin/bash
# upgrade-target.sh — 将 claude-flow 最新模板增量同步到目标项目
#
# 用法: bash scripts/upgrade-target.sh <target-dir>
# 示例: bash scripts/upgrade-target.sh E:/Work/UnityClaudeFlow
#
# 策略:
#   - NEW 文件: 直接复制
#   - UPSTREAM_ONLY 变更: 直接覆盖（用户未定制）
#   - USER_MODIFIED: 跳过，输出提示让用户手动决定
#   - USER_ONLY: 不动

set -euo pipefail

# ---------------------------------------------------------------------------
# 参数检查
# ---------------------------------------------------------------------------
if [ $# -lt 1 ]; then
    echo "Error: --target is required but was not provided."
    echo "Usage: bash scripts/upgrade-target.sh <target-dir>"
    echo "  <target-dir>: path to the project directory to upgrade (required)"
    exit 1
fi

TARGET="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../template" && pwd)"

if [ ! -d "$TARGET/.claude" ]; then
    echo "Error: $TARGET/.claude does not exist. Is this a claude-flow project?"
    exit 1
fi

echo "============================================"
echo "  claude-flow Upgrade"
echo "  Template: $TEMPLATE_DIR"
echo "  Target:   $TARGET"
echo "============================================"
echo ""

ADDED=0
UPDATED=0
SKIPPED=0
MANUAL=()

# ---------------------------------------------------------------------------
# 辅助函数
# ---------------------------------------------------------------------------
copy_new() {
    local rel="$1"
    local src="$TEMPLATE_DIR/$rel"
    local dst="$TARGET/$rel"
    local dir
    dir="$(dirname "$dst")"
    mkdir -p "$dir"
    cp "$src" "$dst"
    echo "  + [NEW]     $rel"
    ADDED=$((ADDED + 1))
}

copy_update() {
    local rel="$1"
    local reason="$2"
    cp "$TEMPLATE_DIR/$rel" "$TARGET/$rel"
    echo "  ↑ [UPDATE]  $rel  ($reason)"
    UPDATED=$((UPDATED + 1))
}

skip_user_modified() {
    local rel="$1"
    local note="$2"
    echo "  = [SKIP]    $rel  (user-modified: $note)"
    SKIPPED=$((SKIPPED + 1))
}

flag_manual() {
    local rel="$1"
    local note="$2"
    echo "  ⚠ [MANUAL]  $rel  — $note"
    MANUAL+=("$rel: $note")
}

# ---------------------------------------------------------------------------
# 1. NEW files — 模板有、目标没有
# ---------------------------------------------------------------------------
echo "── Phase 1: New files ──"

# brainstorming skill
if [ ! -d "$TARGET/.claude/skills/brainstorming" ]; then
    mkdir -p "$TARGET/.claude/skills/brainstorming"
    cp "$TEMPLATE_DIR/.claude/skills/brainstorming/SKILL.md" "$TARGET/.claude/skills/brainstorming/SKILL.md"
    echo "  + [NEW]     .claude/skills/brainstorming/SKILL.md"
    ADDED=$((ADDED + 1))
else
    echo "  = [EXISTS]  .claude/skills/brainstorming/ (already present)"
fi

echo ""

# ---------------------------------------------------------------------------
# 2. UPSTREAM_ONLY — 用户未定制，可安全覆盖
# ---------------------------------------------------------------------------
echo "── Phase 2: Upstream-only updates ──"

# feature-plan-creator.md — 目标缺少 Phase 2.5
if [ -f "$TARGET/.claude/commands/feature-plan-creator.md" ]; then
    if ! grep -q "Phase 2.5" "$TARGET/.claude/commands/feature-plan-creator.md" 2>/dev/null; then
        copy_update ".claude/commands/feature-plan-creator.md" "added Phase 2.5 Plan Review Loop"
    else
        echo "  = [SKIP]    .claude/commands/feature-plan-creator.md (already has Phase 2.5)"
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# 3. USER_MODIFIED — 需要人工 review 的差异
# ---------------------------------------------------------------------------
echo "── Phase 3: User-modified files (manual review needed) ──"

# bug-fix.md — 上游增加了 hypothesis-verification loop
if [ -f "$TARGET/.claude/commands/bug-fix.md" ]; then
    if ! grep -q "Hypothesis" "$TARGET/.claude/commands/bug-fix.md" 2>/dev/null; then
        flag_manual ".claude/commands/bug-fix.md" \
            "upstream added Hypothesis-Verification Loop (Phase 1 expanded to 5 steps). Review diff and merge manually."
    else
        echo "  = [OK]      .claude/commands/bug-fix.md (already has hypothesis flow)"
    fi
fi

# settings.json — 目标缺少 validate-bash.sh hook
if [ -f "$TARGET/.claude/settings.json" ]; then
    if ! grep -q "validate-bash.sh" "$TARGET/.claude/settings.json" 2>/dev/null; then
        flag_manual ".claude/settings.json" \
            "missing PreToolUse hook for validate-bash.sh. Add this block to hooks.PreToolUse array:
        {
          \"matcher\": \"Bash\",
          \"hooks\": [
            { \"type\": \"command\", \"command\": \"bash .claude/hooks/validate-bash.sh\" }
          ]
        }"
    else
        echo "  = [OK]      .claude/settings.json (validate-bash.sh hook present)"
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# 4. 文件完整性检查
# ---------------------------------------------------------------------------
echo "── Phase 4: Integrity checks ──"

# 检查目标的 deep-task.md 是否与上游一致
if [ -f "$TARGET/.claude/commands/deep-task.md" ]; then
    if diff -q "$TEMPLATE_DIR/.claude/commands/deep-task.md" "$TARGET/.claude/commands/deep-task.md" > /dev/null 2>&1; then
        echo "  ✓ deep-task.md — identical to upstream"
    else
        echo "  ⚠ deep-task.md — differs from upstream (check if intentional)"
    fi
fi

# 检查 upgrade.md
if [ -f "$TARGET/.claude/commands/upgrade.md" ]; then
    if diff -q "$TEMPLATE_DIR/.claude/commands/upgrade.md" "$TARGET/.claude/commands/upgrade.md" > /dev/null 2>&1; then
        echo "  ✓ upgrade.md — identical to upstream"
    else
        echo "  ⚠ upgrade.md — differs from upstream"
    fi
fi

# 检查 _template skill
if [ -f "$TARGET/.claude/skills/_template/SKILL.md" ]; then
    if diff -q "$TEMPLATE_DIR/.claude/skills/_template/SKILL.md" "$TARGET/.claude/skills/_template/SKILL.md" > /dev/null 2>&1; then
        echo "  ✓ skills/_template — identical to upstream"
    else
        echo "  ⚠ skills/_template — differs from upstream"
    fi
fi

echo ""

# ---------------------------------------------------------------------------
# 总结
# ---------------------------------------------------------------------------
echo "============================================"
echo "  Upgrade Summary"
echo "============================================"
echo "  Added:   $ADDED files"
echo "  Updated: $UPDATED files"
echo "  Skipped: $SKIPPED files (user-modified)"
echo ""

if [ ${#MANUAL[@]} -gt 0 ]; then
    echo "  ⚠ Manual actions required:"
    for item in "${MANUAL[@]}"; do
        echo "    - $item"
    done
    echo ""
fi

echo "  Next steps:"
echo "    cd $TARGET"
echo "    git add .claude/"
echo "    git commit -m 'chore: upgrade claude-flow templates'"
echo "============================================"
