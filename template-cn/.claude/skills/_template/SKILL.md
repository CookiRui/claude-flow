---
name: {skill-name}
description: "{framework/module} 使用指南：{keyword-1}、{keyword-2}、{keyword-3}。适用于处理 {scenario-1}、{scenario-2}、{scenario-3} 时使用。"
---

<!--
  触发描述是 Skill 最关键的部分——它决定了 AI 何时加载该 Skill。

  ❌ 模糊（无法触发）：
  description: "网络规范"

  ✅ 精确（准确触发）：
  description: "网络通信：HTTP 请求、Socket 连接、Protobuf 消息、重连。适用于处理网络请求、消息收发、重连、网络错误处理时使用。"

  公式："{主题}：{keyword-1}、{keyword-2}、{keyword-3}。适用于处理 {scenario-1}、{scenario-2}、{scenario-3} 时使用。"
-->

# {Skill Name}

<!--
  可选：如果此 Skill 定义了强制性方法论（如 TDD、验证），
  添加强制声明。框架/API 类 Skill 通常不需要。

## 强制声明

本 Skill 适用于 {applicable-scenarios}。**这不是建议——而是强制要求。**
唯一例外：{exception-scenarios}。
-->

## 组件参考

| 组件          | 职责           |
|--------------|----------------|
| {component-1} | {description}  |
| {component-2} | {description}  |

<!-- 组件表省略文件路径（AI 可以搜索）。减少 token 开销。 -->

## 核心用法

### {usage-1-name}

```{language}
// ✅ Correct
{correct-approach}

// ❌ Wrong
{wrong-approach}
```

### {usage-2-name}

```{language}
// ✅ Correct
{correct-approach}
```

## 常见陷阱

1. {pitfall-1} -> {consequence}。修复方法：{solution}
2. {pitfall-2} -> {consequence}。修复方法：{solution}

@references/detail.md
