# Git 工作流规则

> 补充宪法无法涵盖的细节。如果某条规则可从宪法推导出来，请删除它。

## 规则 1：提交消息格式（依据宪法 §{N}）

所有提交消息必须遵循 `type(scope): description` 格式。允许的类型：`feat`、`fix`、`refactor`、`docs`、`chore`、`test`、`style`、`perf`。

```text
// ✅ 正确
feat(auth): add OAuth2 login support
fix(api): handle null response from external service
docs(readme): update installation instructions

// ❌ 错误
fixed stuff
WIP
update
```

**例外情况：** {exception-scenarios — 例：git 生成的合并提交可使用默认合并消息格式}

## 规则 2：分支命名（依据宪法 §{N}）

分支名称必须遵循 `{branch-prefix}/{feature-name}` 模式。常用前缀：`feat`、`fix`、`chore`、`release`、`hotfix`。

```text
// ✅ 正确
feat/{feature-name}
fix/{issue-or-bug-name}
chore/{task-name}

// ❌ 错误
my-branch
test123
{developer-name}-branch
```

**例外情况：** {exception-scenarios — 例：`main`、`master`、`develop` 是受保护的分支名称，不遵循此模式}

## 规则 3：原子提交（依据宪法 §{N}）

每次提交必须服务于一个明确的目的。不要将不相关的变更打包到一次提交中。

```text
// ✅ 正确
— 一次提交添加一个功能
— 一次提交修复一个 bug
— 一次提交更新该 bug 修复对应的测试

// ❌ 错误
— 一次提交中同时添加功能、修复两个 bug 并更新文档
```

**例外情况：** {exception-scenarios — 例：项目特定的原子性规则：{atomic-commit-exceptions}}

## 自查清单

- [ ] 每条提交消息是否遵循 `type(scope): description` 并使用允许的类型？
- [ ] 每个分支名称是否遵循 `{branch-prefix}/{feature-name}` 格式？
- [ ] 每次提交是否只包含一个逻辑变更（没有捆绑不相关的文件）？
