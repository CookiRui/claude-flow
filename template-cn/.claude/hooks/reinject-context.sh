#!/bin/bash
# reinject-context.sh — SessionStart 钩子，在压缩后重新注入关键上下文
#
# 用法：配置为 Claude Code 的 SessionStart 钩子
#   .claude/settings.json:
#   {
#     "hooks": {
#       "SessionStart": [
#         { "matcher": "compact", "command": "bash .claude/hooks/reinject-context.sh" }
#       ]
#     }
#   }
#
# 工作原理：
#   1. 在 /compact 操作后 Claude Code 启动新会话时触发
#   2. 输出项目宪法内容使 Claude 重新读取核心规则
#   3. 输出当前 WIP 文件（如存在）使 Claude 恢复进行中的工作
#   4. 打印简短摘要行使 Claude 知道上下文已被重新注入
#
# 输出到 stdout——Claude Code 读取并将其纳入上下文。

set -euo pipefail

# ---------------------------------------------------------------------------
# 配置——为你的项目替换 {placeholder} 值
# ---------------------------------------------------------------------------

# 项目宪法的路径（相对于仓库根目录）
CONSTITUTION_FILE=".claude/constitution.md"

# 当前进行中工作笔记的路径（相对于仓库根目录）
WIP_FILE=".claude-flow/wip.md"

# ---------------------------------------------------------------------------
# 主逻辑
# ---------------------------------------------------------------------------

main() {
    echo "========================================================"
    echo "  上下文重新注入——压缩后恢复"
    echo "========================================================"
    echo ""

    # 重新注入宪法
    if [ -f "$CONSTITUTION_FILE" ]; then
        echo "--- [宪法: $CONSTITUTION_FILE] ---"
        cat "$CONSTITUTION_FILE"
        echo ""
    else
        echo "[reinject-context] 警告：$CONSTITUTION_FILE 未找到——跳过。" >&2
    fi

    # 重新注入 WIP（如存在）
    if [ -f "$WIP_FILE" ]; then
        echo "--- [进行中工作: $WIP_FILE] ---"
        cat "$WIP_FILE"
        echo ""
    fi

    echo "========================================================"
    echo "  上下文已重新注入。请从上方的 WIP 继续工作。"
    echo "========================================================"
}

main "$@"
