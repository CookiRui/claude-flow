---
description: 将 claude-flow 模板升级到最新版本
argument-hint: [--force]
---

# /upgrade

将当前项目的 claude-flow 配置升级到最新模板版本。检测新文件、变更文件，并安全合并更新，不覆盖用户自定义内容。

## 阶段 1：发现

1. 确定 claude-flow 源目录：
   - 检查 `node_modules/claude-autosolve/template/` 是否存在（npm 安装）
   - 检查是否设置了 `CLAUDE_FLOW_PATH` 环境变量
   - 如果都没找到，询问用户路径

2. 列出源 `template/` 目录中的所有文件。

3. 对每个模板文件进行分类：

| 状态 | 条件 | 操作 |
|------|------|------|
| **新增** | 文件存在于 template/ 但不在项目中 | 将被添加 |
| **未变更** | 文件同时存在，内容相同 | 跳过 |
| **仅上游变更** | 文件同时存在，用户版本匹配旧模板版本 | 可安全更新 |
| **用户已修改** | 文件同时存在，用户已自定义 | 显示差异，询问用户 |
| **仅用户** | 文件存在于项目但不在模板中 | 保持不变 |

4. 输出摘要表：
   ```
   /upgrade 扫描结果：

   新增（将添加）：
     + .claude/agents/feature-builder.md
     + .claude/hooks/protect-files.sh

   安全更新（仅上游变更）：
     ↑ .claude/commands/deep-task.md

   冲突（你修改过 + 上游也变更了）：
     ⚠ .claude/constitution.md — 需要审查

   未变更（跳过）：
     = .claude/skills/tdd/SKILL.md
   ```

5. 在做任何变更前询问用户确认。如果传入了 `--force` 参数，跳过新增和安全更新的确认（冲突仍需确认）。

## 阶段 2：应用

按状态处理每个文件：

- **新增**：从模板复制到项目。如需要则创建父目录。
- **安全更新**：用新版本替换。简要说明变更内容。
- **冲突**：显示并排或统一差异。让用户选择：
  - (a) 保留我的 — 跳过此文件
  - (b) 采用上游 — 用模板版本覆盖
  - (c) 合并 — 手动应用特定部分（AI 辅助）
- **未变更 / 仅用户**：跳过。

## 阶段 3：升级后

1. 列出所有变更。
2. 如果添加了新命令，说明："新增可用命令：/command-name"
3. 如果添加了新 agent，说明："新增可用 agent：agent-name"
4. 如果宪法治理规则有变更，标记需要审查。
5. 建议：`git add .claude/ && git commit -m "chore: 升级 claude-flow 模板"`

## 注意事项

- 永远不删除模板中不存在的用户文件。
- 永远不在未获得明确确认的情况下覆盖用户自定义内容。
- scripts/ 目录也会被检查（persistent-solve.py、repo-map.py、lint-feedback.sh）。
- 如果用户在 .claude/skills/ 中有模板里不存在的文件，那些是自定义技能，应保持不变。
