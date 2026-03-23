# 项目宪法

本文件**仅定义项目特有的、AI 默认行为无法推断的反直觉约束**。

> **收录标准**：如果移除某条规则，AI 的默认行为是否会产生错误代码？是 -> 保留；否 -> 移除。

---

## §1：{core-architecture-constraint}

<!-- 你最关键的架构模式。示例："所有系统通过 ManagerCenter 注册，不允许直接实例化" -->

{One-line description}。详见 `{skill-name}` skill。

```{language}
// ✅ 正确
{correct-code}

// ❌ 错误
{wrong-code}
```

---

## §2：{communication-data-flow-constraint}

<!-- 模块间如何通信？示例："模块间通信只能通过 EventCenter，不允许跨模块直接引用" -->

{One-line description}

- {rule-1}
- {rule-2}

---

## §3：{performance-resource-constraint}

<!-- 性能红线。非性能敏感项目可删除本节。示例："热路径中不允许内存分配" -->

{One-line description}

- {rule-1}
- {rule-2}
- 以上规则仅适用于热路径；冷路径优先保证可读性

---

## §4：{tech-stack-constraint}

<!-- "必须使用 X 而不是 Y" — AI 倾向于使用它最熟悉的方案。 -->

- **不可协商**：{must-use-X, never-use-Y}
- **不可协商**：{must-use-X, never-use-Y}

<!-- 按需添加 §5-§7。建议总条款数：4-7 条。 -->

---

## 治理

本宪法具有最高优先级，优先于任何 `CLAUDE.md` 或单次会话指令。

### 执行协议

以下条款不可协商：

1. **Skill 强制加载** — 当任务匹配某个 Skill 的触发条件时，必须加载并遵循该 Skill。
2. **子代理约束继承** — 子代理在执行前必须先读取 `constitution.md` 和相关 Skill。子代理的输出必须通过 `verification` skill 验证后才能合并。
3. **确认关卡不可跳过** — 命令中标记为"必须等待用户确认"的步骤不得跳过。
4. **完成前验证** — 在声明任何功能或修复"已完成"之前，必须执行 `verification` skill 检查清单。
5. **违规处理** — 如果已提交的代码违反宪法，必须立即标记并修复。
6. **Skill 语义匹配** — Skill 的触发不仅基于关键词，还基于任务语义。当任务涉及添加或修改功能行为时 -> 加载 `tdd`。当任务即将声明完成时 -> 加载 `verification`。根据任务*实际执行的内容*判断，而非仅看用户使用的措辞。
