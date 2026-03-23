# 安全规则

> 补充宪法无法涵盖的细节。如果某条规则可从宪法推导出来，请删除它。

## 规则 1：代码中不允许包含密钥（依据宪法 §{N}）

永远不要在源代码中硬编码 API key、密码、令牌或任何凭证。始终从环境变量或密钥管理器中加载密钥。

```{language}
// ✅ 正确
const apiKey = process.env.API_KEY;

// ❌ 错误
const apiKey = "sk-abc123hardcodedtoken";
```

**例外情况：** {exception-scenarios — 例：不涉及安全风险的非敏感公共配置值（如公共 base URL）可以内联}

## 规则 2：边界处的输入验证（依据宪法 §{N}）

在系统边界处验证所有用户输入和外部 API 响应后再进行处理。尽可能使用允许列表而非拒绝列表。{project-specific-validation-rules — 例：本项目的必填字段、类型约束、长度限制}

```{language}
// ✅ 正确
{correct-validation-example}

// ❌ 错误
{wrong-validation-example — 例：将原始用户输入直接传递给数据库查询或 shell 命令}
```

**例外情况：** {exception-scenarios — 例：在可信网络边界内的服务间内部调用可根据 {project-trust-policy} 放宽验证要求}

## 规则 3：依赖安全（依据宪法 §{N}）

仅使用经批准的依赖。不要引入已废弃、存在已知严重 CVE 漏洞或不在项目允许列表中的包。{dependency-policy — 例：允许的包注册表、禁止的包，以及请求新依赖的流程}

```text
// ✅ 正确
{allowed-package-example}

// ❌ 错误
{forbidden-package-example}
```

**例外情况：** {exception-scenarios — 例：仅在获得明确批准并记录在 {approval-doc-location} 中的情况下，才允许临时使用被标记的包}

## 自查清单

- [ ] 变更的文件中是否存在硬编码的密钥、令牌或密码？
- [ ] 所有用户输入和外部数据是否在入口点经过验证后才被使用？
- [ ] 所有新增的依赖是否在项目的已批准依赖列表中？
