# Claude Code 与 Codex 在大型项目中的工作流差异，以及 `claude-flow-mega` 的双模式改造方向

## 问题背景

这个项目当前明显是围绕 Claude Code 设计的，核心思路包括：

- `CLAUDE.md`
- `.claude/commands`
- `.claude/skills`
- `.claude/hooks`
- 规则分层与渐进式披露

但如果目标不只是服务 Claude Code，而是进一步兼容 Codex 这类更偏 agent runtime 的工作流，那么就需要回答两个问题：

1. Codex 在没有 `CLAUDE.md` 式渐进披露时，如何处理大型项目？
2. 现有项目结构怎样调整，才能同时适配 Claude Code 和 Codex？

## 一、Claude Code 和 Codex 的本质差异

### 1. Claude Code 更强调“预定义的项目内操作系统”

Claude Code 的强项是把项目经验沉淀为显式结构：

- 项目总入口：`CLAUDE.md`
- 规则层：constitution / rules
- 能力层：skills
- 流程层：commands
- 防护层：hooks

这套机制的目标是：让模型进入项目后，不需要每次重新摸索工作方式，而是沿着项目定义好的路径执行。

### 2. Codex 更强调“任务驱动的即时上下文装配”

Codex 类工作流通常不依赖固定的 `CLAUDE.md` 式入口来工作。它处理大型项目，更多依赖：

- 文件搜索
- 符号搜索
- 局部读取
- 测试与命令反馈
- 多轮缩小范围
- 必要时的子任务并行

它不是先获得整个项目的系统说明，而是先找到当前任务最相关的局部上下文，再逐步扩展认知范围。

## 二、如果没有渐进式披露，Codex 如何处理大型项目

### 1. 搜索优先，而不是全量预读

Codex 处理大型项目时，通常先做这些动作：

- 找入口文件
- 找调用链
- 找关键类型 / schema / config
- 找相关测试
- 找影响面

然后只读取与当前任务相关的文件，而不是预先加载一整套项目文档。

### 2. 任务驱动的局部上下文组装

例如一个“修改登录逻辑”的任务，Codex 会逐步收集：

- 登录入口
- service / controller
- types / schema
- 认证中间件
- 相关测试
- 配置项

也就是说，上下文是“按任务即时装配”的，而不是“先维护好一棵固定文档树”。

### 3. 依赖工具链来代替长上下文

大型项目能处理，不是因为模型一次记住了整个仓库，而是因为它可以反复调用：

- 搜索
- 文件读取
- git diff
- 测试
- LSP / 符号定位
- 子代理探索

外部工具承担了“导航”和“临时记忆”的很大一部分职责。

### 4. 会形成任务内临时心智模型，但不一定沉淀为固定资产

在执行过程中，代理会逐步理解：

- 哪个模块负责什么
- 哪些约束是隐性的
- 哪个测试覆盖主路径
- 哪些配置会影响行为

但这些理解很多时候是当前任务内临时成立的，不一定自动沉淀成类似 `CLAUDE.md` 的长期知识资产。

## 三、这对 `claude-flow-mega` 的直接启发

这说明当前项目中真正有长期价值的，并不是 `.claude/*` 这些载体本身，而是它们背后的知识与流程资产。

更准确地说，当前项目的核心资产有四类：

### 1. 项目约束

例如：

- constitution
- rules
- 模块边界
- 禁止做法
- 技术选型约束

### 2. 项目地图

例如：

- repo map
- 模块划分
- 关键入口
- 依赖方向
- 影响面分析

### 3. 工作流协议

例如：

- 复杂度分级
- 任务拆解策略
- 验证闭环
- 预算控制
- 持久化执行协议

### 4. 平台适配

例如：

- Claude Code 的 slash commands
- hooks 自动注入
- skills 触发机制
- `CLAUDE.md` 导航

前 3 类属于平台无关资产，第 4 类属于 Claude Code 适配层。

## 四、双模式改造的核心原则

如果目标是同时兼容 Claude Code 和 Codex，那么最重要的原则是：

**把“知识”和“能力”从 Claude 专属目录里解耦，把“交互体验”保留在 Claude 适配层。**

也就是说：

- 核心知识不能只存在于 `.claude/`
- 核心运行逻辑不能和 Claude 的命令机制耦合
- Claude Code 仍然可以是一个很强的前端适配器
- 但不应该再是唯一宿主

## 五、建议的双模式分层

### A. Platform-Neutral Knowledge Layer

这一层存放平台无关的知识资产，应该独立于 `.claude/` 是否存在。

可以承载：

- 模块定义
- 架构边界
- 规则索引
- 上下文装配策略
- 验证标准

适合的形式包括：

- Markdown
- JSON
- YAML
- 由脚本生成的索引文件

例如可以考虑：

- `project-model/modules.json`
- `project-model/rules.json`
- `project-model/context-policy.json`
- `docs/architecture/*.md`

这一层回答的是：

- 这个项目如何分模块
- 哪些规则是硬约束
- 什么任务要加载什么上下文
- 哪些验证步骤是必须的

### B. Platform-Neutral Runtime Layer

这一层存放真正可执行的能力，不依赖 Claude Code 的专有交互方式。

适合放入：

- `repo-map`
- `scope-loader`
- `persistent-solve` 中可复用的引擎部分
- 未来的项目模型库

典型内容包括：

- 模块识别
- affected files 计算
- context assembly
- task graph
- budget control
- verification orchestration

### C. Claude Adapter Layer

这一层继续保留你当前项目对 Claude Code 的强支持：

- `CLAUDE.md`
- `.claude/commands`
- `.claude/skills`
- `.claude/hooks`
- `.claude/agents`

但它们不再是唯一知识来源，而是 Claude 对核心层的消费入口。

换句话说：

- `CLAUDE.md` 负责导航
- commands 负责封装流程
- skills 负责封装操作模式
- hooks 负责自动注入与保护

### D. Codex Adapter Layer

Codex 适配层不需要复制 Claude Code 那套交互模型，而应该提供：

- 机器可读 manifest
- 面向任务的上下文索引
- 可直接调用的脚本
- 简洁的 agent playbook

例如：

- `project-model/context-index.json`
- `scripts/context-for-files.py`
- `scripts/context-for-task.py`
- `docs/agent-playbook.md`

这样 Codex 进入仓库后，可以通过搜索和脚本即时获取上下文，而不是依赖 Claude 风格的 slash commands。

## 六、对现有项目各部分的具体判断

### 1. 应保留为平台无关核心资产的

这些内容本质上不属于 Claude Code，而属于“项目级 agent 基础设施”：

- `repo-map.py`
- `scope-loader.py`
- constitution / rules 的内容本身
- 复杂度分级
- 验证策略
- review 标准
- preset 体系

这些能力应该被抽到平台无关层，由不同 agent 前端消费。

### 2. 应保留为 Claude 适配层的

这些内容仍然有价值，但不该再被当作项目本体：

- `/deep-task`
- `/bug-fix`
- `/feature-plan-creator`
- hooks 自动注入逻辑
- skills 的 Claude 风格触发包装

它们适合继续存在，但角色应该是“Claude UI / UX 适配”，不是唯一核心。

### 3. 介于两者之间、需要拆分的

`persistent-solve.py` 目前就是最典型的混合体：

- 一部分是平台无关核心
- 一部分带有明显 Claude 假设

建议未来拆成：

- 核心调度引擎
- Claude 交互包装
- CLI 参数层

## 七、对 `CLAUDE.md` 的改造建议

如果想支持双模式，`CLAUDE.md` 不应该继续承担过多“知识本体”职责，而应该更偏向导航与消费说明。

更适合的角色是：

- 项目导航入口
- 硬约束摘要
- 任务类型到上下文的映射说明
- 指向平台无关知识层的索引

也就是说，让 `CLAUDE.md` 从“知识本体”降级为“Claude 入口文件”。

这样做的好处是：

- Claude Code 继续高效
- Codex 不会因为知识被锁在 `.claude/` 里而受限
- 知识源可以更稳定地被多个 agent 复用

## 八、对 Codex 更友好的补充物

为了让 Codex 这种搜索驱动、任务驱动的工作流获得更高效率，建议增加这几类结构化资产。

### 1. 模块定义文件

例如：

```json
{
  "modules": [
    {
      "name": "auth",
      "paths": ["src/auth/"],
      "description": "Authentication and session management"
    }
  ]
}
```

用途：

- 统一 repo map 和 scope loader 的模块边界
- 让代理更快理解仓库结构

### 2. 上下文装配策略文件

例如：

```json
{
  "task_types": {
    "bugfix": ["rules", "affected_modules", "tests"],
    "feature": ["constitution", "rules", "affected_modules", "adjacent_modules"]
  }
}
```

用途：

- 让不同 agent 更容易知道“什么任务该加载什么上下文”

### 3. 规则结构化索引

即使规则正文仍然保留 Markdown，也建议增加 machine-readable index，例如：

- rule id
- scope
- severity
- applies_to
- source path

这样更利于自动装配与筛选。

### 4. 面向文件/任务的上下文脚本

例如：

- `scripts/context-for-files.py`
- `scripts/context-for-task.py`

输入：

- 文件列表
- 模块名
- 任务类型

输出：

- 应加载的 rules
- 应参考的 modules
- 关键入口文件
- 推荐测试

这类脚本对 Codex 会比单纯的长文档更直接。

### 5. Agent Playbook

建议提供一份简洁文档，例如：

- `docs/agent-playbook.md`

内容聚焦：

- 仓库怎么快速定位
- 哪些脚本可用
- 修改前后如何验证
- 哪些路径有特殊约束

它的定位不是代替 `CLAUDE.md`，而是给不依赖 Claude slash command 的代理一个统一入口。

## 九、一个更合理的目标模型

这个项目未来更合理的定位，不应该只是：

> Claude Code 的增强模板包

而应该逐步演化成：

> 平台无关的 agentic coding framework + Claude Code adapter

在这个模型里：

- Knowledge Layer 负责知识
- Runtime Layer 负责可执行能力
- Adapter Layer 负责接入不同 agent 平台

Claude Code 是一个适配器，不再是项目本体唯一宿主。

## 十、对当前仓库的具体判断

从现状看，这个仓库其实已经有双模式雏形，只是还没有彻底解耦。

### 已经接近平台无关核心的

- `repo-map.py`
- `scope-loader.py`
- review / verification 方法论
- preset 思路

### 明显属于 Claude 适配层的

- `.claude/*`
- `CLAUDE.md`
- slash command 工作流
- hooks 自动注入机制

### 最需要拆分的

- `persistent-solve.py`
- 文档中的“4 层项目配置”表达方式

因为它们现在既包含通用思想，也混杂了 Claude Code 的载体假设。

## 十一、实际改造方向

如果要推进双模式，建议按这个顺序做：

1. 把项目知识从 `.claude/` 中抽出平台无关版本
2. 让 `CLAUDE.md` 变成导航入口，而不是知识本体
3. 把 `repo-map` / `scope-loader` / 未来 `project_model` 作为 runtime core
4. 给 Codex 增加 manifest + context assembly 脚本
5. 保留 `.claude/*` 作为 Claude Code adapter

这个顺序的优点是：

- 不会破坏现有 Claude Code 体验
- 可以逐步增加 Codex 兼容性
- 不需要一次性推倒重来

## 总结

Claude Code 的强项是渐进式披露和项目内流程封装，Codex 的强项是任务驱动、搜索驱动、即时上下文装配。

因此，这个项目最合理的方向不是在 Claude 和 Codex 之间二选一，而是：

- 保留 Claude Code 的高质量交互层
- 把真正有长期价值的知识和运行时能力抽成平台无关核心

一句话总结：

**不要让 `.claude/*` 成为唯一知识源；要让它成为 Claude Code 的消费入口。**

这样，Claude Code 仍然能享受渐进式披露，而 Codex 也能通过搜索、manifest 和脚本获得同样的核心能力。
