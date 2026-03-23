# 代码审查标准 — {project-name}

> 本文件定义了自动化审查和人工审查所使用的审查标准。
> 带有 `{placeholder}` 标记的是项目特定规则 — 在执行 `npx claude-autosolve init` 时填写。

---

## 审查维度与严重等级

| 严重等级 | 标签 | 合并策略 |
|---|---|---|
| 🔴 | **阻断（BLOCKER）** | 合并前必须解决 |
| 🟡 | **警告（WARNING）** | 应当解决；附书面说明后可接受 |
| 🔵 | **建议（SUGGESTION）** | 可选改进；不阻断合并 |

---

## 维度 A：性能

| ID | 严重等级 | 规则 | 示例 / 备注 |
|---|---|---|---|
| PERF-B1 | 阻断 | {performance-blocker-1} | 例：热路径循环中不允许堆内存分配 |
| PERF-B2 | 阻断 | {performance-blocker-2} | 例：O(n²) 及更差的算法必须附带解释性注释 |
| PERF-W1 | 警告 | {performance-warning-1} | 例：重复的相同 I/O 调用应使用缓存层 |
| PERF-W2 | 警告 | {performance-warning-2} | 例：长生命周期对象中的集合不可无限增长 |
| PERF-S1 | 建议 | {performance-suggestion-1} | 例：在启动耗时较高的场景使用延迟初始化 |
| PERF-P1 | 阻断 | 主线程/UI 线程上不允许同步阻塞调用 | 适用于涉及 {async-context} 的场景 |
| PERF-P2 | 警告 | 资源句柄（文件、连接、套接字）必须被确定性释放 | 使用语言惯用的清理模式 |

> 添加项目特定的性能规则：`{performance-rule-project-specific}`

---

## 维度 B：可维护性

| ID | 严重等级 | 规则 | 参考 |
|---|---|---|---|
| MAINT-B1 | 阻断 | 所有公开 API 必须有文档字符串/头部注释，描述用途、参数和返回值 | — |
| MAINT-B2 | 阻断 | 每次提交必须是原子的：一个逻辑变更、所有测试通过、构建正常 | 宪法 §{constitution-atomicity-section} |
| MAINT-B3 | 阻断 | 不允许死代码（超过一个迭代周期的注释代码块），除非附带带日期的 TODO 并关联 issue | — |
| MAINT-W1 | 警告 | 命名必须遵循 `.claude/rules/` 中定义的约定 | `.claude/rules/{naming-convention-file}` |
| MAINT-W2 | 警告 | 不得违反模块边界：`{module-A}` 不允许从 `{module-B}` 导入 | `.claude/constitution.md §{boundary-section}` |
| MAINT-W3 | 警告 | 超过 {max-function-lines} 行的函数应进行拆分，除非有合理理由 | — |
| MAINT-W4 | 警告 | 魔法字面量必须定义为命名常量 | — |
| MAINT-S1 | 建议 | 考虑将重复逻辑（出现 3 次及以上）提取为共用辅助函数 | — |
| MAINT-S2 | 建议 | 测试命名应描述行为，而非实现细节 | 例：`test_returns_empty_list_when_input_is_null` |
| MAINT-P1 | 阻断 | 宪法合规性：审查者必须确认变更不违反 `.claude/constitution.md` | `.claude/constitution.md` |

> 添加项目特定的可维护性规则：`{maintainability-rule-project-specific}`

---

## 维度 C：正确性与安全性

| ID | 严重等级 | 规则 | 示例 / 备注 |
|---|---|---|---|
| SEC-B1 | 阻断 | 不允许硬编码密钥、令牌、密码或 API key | 使用环境变量或密钥管理器 |
| SEC-B2 | 阻断 | 所有跨越信任边界的输入必须经过验证和清理 | 例：HTTP 请求参数、文件路径、IPC 消息 |
| SEC-B3 | 阻断 | 错误不能被静默吞没；每个 catch/except 必须记录日志或重新抛出 | — |
| SEC-B4 | 阻断 | 可能接收 null/nil/undefined 的每个解引用处必须进行空值处理 | — |
| SEC-W1 | 警告 | 多线程访问的共享可变状态必须使用显式同步机制 | 如果设计为单线程则需文档说明 |
| SEC-W2 | 警告 | 使用用户数据构造 SQL/shell/eval 时必须使用参数化或转义形式 | — |
| SEC-W3 | 警告 | 本 PR 新增的外部依赖必须审查许可证和供应链风险 | 记录在 `{dependency-manifest}` 中 |
| SEC-W4 | 警告 | {correctness-warning-project-specific} | 例：迁移前需检查 schema 版本 |
| SEC-S1 | 建议 | 考虑为新的解析/序列化逻辑添加基于属性的测试或模糊测试 | — |
| SEC-S2 | 建议 | {security-suggestion-project-specific} | 例：为新端点添加限流注解 |

> 添加项目特定的正确性/安全性规则：`{correctness-rule-project-specific}`

---

## 审查输出格式

提交代码审查（人工或自动化）时，请使用以下结构：

```
## 审查：{PR-or-commit-id} — {short-description}

**审查者：** {reviewer-name}
**日期：** {review-date}
**总体结论：** 通过 | 有条件通过 | 阻断

---

### 阻断项（合并前必须修复）

- [ ] [PERF-B1] <file>:<line> — <违规描述>
- [ ] [SEC-B2] <file>:<line> — <违规描述>

### 警告项（应修复或说明理由）

- [ ] [MAINT-W3] <file>:<line> — <描述> | **理由：** <如延期处理>

### 建议项（可选）

- [ ] [MAINT-S1] <file>:<line> — <描述>

---

### 总结

<1-3 句话概述变更内容和主要关注点。>

### 已提交的后续 issue

- {issue-tracker-link-1}
- {issue-tracker-link-2}
```

---

## 项目特定补充

在项目初始化或首次审查周期中填写本节。

### 附加性能规则

| ID | 严重等级 | 规则 |
|---|---|---|
| PERF-X1 | {severity} | {project-perf-rule-1} |
| PERF-X2 | {severity} | {project-perf-rule-2} |

### 附加可维护性规则

| ID | 严重等级 | 规则 |
|---|---|---|
| MAINT-X1 | {severity} | {project-maintainability-rule-1} |
| MAINT-X2 | {severity} | {project-maintainability-rule-2} |

### 附加正确性/安全性规则

| ID | 严重等级 | 规则 |
|---|---|---|
| SEC-X1 | {severity} | {project-correctness-rule-1} |
| SEC-X2 | {severity} | {project-correctness-rule-2} |

### 技术栈专项检查表

> 将 `{language-or-framework}` 替换为你的技术栈，并填写相关检查项。

**{language-or-framework} 检查表：**

- [ ] {tech-specific-check-1}
- [ ] {tech-specific-check-2}
- [ ] {tech-specific-check-3}

---

## 参考

- 宪法：`.claude/constitution.md`
- 命名规范：`.claude/rules/{naming-convention-file}`
- 架构图：`{architecture-doc-path}`
- 依赖清单：`{dependency-manifest}`
- Issue 跟踪：`{issue-tracker-url}`
