#!/bin/bash
# protect-files.sh — PreToolUse 钩子，对受保护路径的编辑进行警告/阻止
#
# 用法：配置为 Claude Code 的 PreToolUse 钩子
#   .claude/settings.json:
#   {
#     "hooks": {
#       "PreToolUse": [
#         { "matcher": "Edit",  "command": "bash .claude/hooks/protect-files.sh" },
#         { "matcher": "Write", "command": "bash .claude/hooks/protect-files.sh" }
#       ]
#     }
#   }
#
# 工作原理：
#   1. 从 stdin 读取工具输入的 JSON 以提取 file_path
#   2. 将路径与硬保护和软保护的模式列表进行匹配
#   3. 硬匹配 -> 向 stderr 输出错误并以退出码 2 退出（Claude Code 阻止该工具调用）
#   4. 软匹配 -> 向 stderr 输出警告并以退出码 0 退出（Claude Code 允许但会看到警告）
#
# Claude Code 提供的环境变量：
#   CLAUDE_TOOL_NAME — 被调用的工具名称（Edit、Write 等）
#   stdin            — 包含工具输入参数的 JSON 对象

set -euo pipefail

# ---------------------------------------------------------------------------
# 配置——为你的项目替换 {placeholder} 值
# ---------------------------------------------------------------------------

# 硬保护：Claude Code 被阻止编辑这些路径。
# 添加不应被自动修改的模式（glob 风格的前缀匹配）。
HARD_PROTECTED=(
    "{protected-config-dir}"     # 例如 "ProjectSettings/"
    ".env"
    ".env.local"
    ".env.production"
)

# 软保护：Claude Code 会收到警告但允许继续。
# 添加生成/派生产物的模式，手动编辑有风险。
SOFT_PROTECTED=(
    "{protected-generated-dir}"  # 例如 "build/" 或 "dist/"
    "node_modules/"
    "__pycache__/"
    "*.lock"
)

# ---------------------------------------------------------------------------
# 辅助函数
# ---------------------------------------------------------------------------

# 从 stdin 的 JSON 中提取 "file_path" 的值。
# 仅使用 sed/awk（标准 POSIX 工具）——不需要 jq。
extract_file_path() {
    # 先捕获完整的 stdin 以便只读取一次
    local input
    input=$(cat)

    # 尝试简单的模式匹配："file_path": "some/path"
    echo "$input" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
}

# 如果 $1 匹配提供数组中的任一模式则返回 0。
matches_any() {
    local path="$1"
    shift
    local pattern
    for pattern in "$@"; do
        # 跳过从未被替换的占位符条目
        if [[ "$pattern" == "{"*"}" ]]; then
            continue
        fi

        # Glob / 前缀匹配
        case "$path" in
            $pattern*) return 0 ;;
        esac

        # 同时匹配路径中间包含该模式的情况（用于中间路径目录）
        case "$path" in
            */$pattern*) return 0 ;;
        esac
    done
    return 1
}

# ---------------------------------------------------------------------------
# 主逻辑
# ---------------------------------------------------------------------------

main() {
    local file_path
    file_path=$(extract_file_path)

    if [ -z "$file_path" ]; then
        # 输入中无 file_path——无需检查
        exit 0
    fi

    # 硬保护检查
    if matches_any "$file_path" "${HARD_PROTECTED[@]}"; then
        echo "[protect-files] 已阻止：'${file_path}' 匹配硬保护模式。" >&2
        echo "[protect-files] 如果此编辑是有意为之，请手动编辑该文件。" >&2
        exit 2
    fi

    # 软保护检查
    if matches_any "$file_path" "${SOFT_PROTECTED[@]}"; then
        echo "[protect-files] 警告：'${file_path}' 位于软保护（生成文件）路径中。" >&2
        echo "[protect-files] 继续执行，但请确认此编辑是有意为之。" >&2
        exit 0
    fi

    exit 0
}

main "$@"
