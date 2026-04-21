---
description: 安装 OpenAI 官方 codex-plugin-cc，在 Claude Code 内直接调用 Codex 做代码审查 / 任务委托
argument-hint:
---

# /install-codex

在 Claude Code 里安装 [OpenAI 官方 codex-plugin-cc](https://github.com/openai/codex-plugin-cc)。安装后可以直接把代码审查 / 任务委托给 Codex，不用切工具。

## 步骤 1 —— 确认最新安装命令

使用 **WebFetch** 抓取 `https://github.com/openai/codex-plugin-cc` 的 README，从中提取实际的安装命令。如果 README 里的命令与下方默认值不同，以 README 为准，并提示用户存在差异。

**默认值（兜底）**：

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex-plugin-cc
```

如果 WebFetch 失败（断网 / 私有仓库 / 超时），就用默认值，并提示用户去仓库 README 再核对一次。

## 步骤 2 —— 把命令交给用户执行

`/plugin marketplace add` 和 `/plugin install` 是 **Claude Code 的内置斜杠命令**，Claude 无法替用户执行。按顺序打印给用户，由用户自己在 Claude Code 里输入：

```
请在 Claude Code 中依次执行：

1. /plugin marketplace add openai/codex-plugin-cc
2. /plugin install codex-plugin-cc

安装完成后如有提示，重启 Claude Code。
```

如果用户已经添加过 `openai/codex-plugin-cc` marketplace，只需要执行第 2 步。

## 步骤 3 —— 简要说明插件能力（可选）

如果抓到的 README 包含插件提供的斜杠命令、工具或使用示例，用 ≤ 5 条要点总结一下，让用户知道装完后有什么可用。**不要编造**，只总结 README 实际写了的内容。

## 故障排查

- **marketplace add 失败** → 运行 `/plugin marketplace list` 看是否已经注册过。
- **install 报 "plugin not found"** → marketplace 没添加成功，或插件名改了，回去查 README。
- **装上了但命令没出现** → 重启 Claude Code。

## 说明

- 这个命令只打印指引，不改项目里的任何文件。
- 插件运行在 Claude Code 内部，不需要额外安装 Codex CLI。
