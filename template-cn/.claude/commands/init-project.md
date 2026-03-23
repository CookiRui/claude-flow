---
description: 分析代码库并自动生成所有 claude-flow 配置文件
argument-hint: [项目描述] [--lang en]
---

# /init-project

自动分析当前代码库并生成所有 claude-flow 配置文件。用户不需要手动填写任何占位符。

**语言:** 所有生成的文件内容（CLAUDE.md、宪法、规则、REVIEW.md 等）默认使用**中文**编写。如果用户传入 `--lang en` 参数，则使用英文。

## 阶段 0：检测项目状态

首先，判断这是一个**已有项目**还是**新建（空）项目**：

- 使用 Glob 检查源代码文件（`**/*.{ts,js,py,go,rs,cs,java,jsx,tsx}`）
- 检查清单文件（package.json、go.mod、Cargo.toml、*.csproj、pyproject.toml 等）

**如果找到源文件** → 转到阶段 1A（已有项目）
**如果没有源文件** → 转到阶段 1B（新建项目）

## 阶段 1A：已有项目 — 代码库分析（不写入任何文件）

扫描项目以理解其结构。使用 Glob、Grep、Read 工具：

1. **检测项目类型和技术栈**
   - 检查：package.json、go.mod、Cargo.toml、*.csproj、pyproject.toml、pom.xml、build.gradle 等
   - 识别主要语言、框架和构建工具
   - 检查已有的测试框架和 lint 工具

2. **映射架构**
   - 识别顶层目录结构和每个目录的用途
   - 找到入口点（main 文件、路由定义等）
   - 检测模式：分层架构、模块边界、通信模式
   - 识别共享/通用代码与领域专用代码

3. **识别 AI 会违反的约束**
   - 检查自定义封装（日志、HTTP 客户端、错误处理）— AI 会使用标准库代替
   - 检查架构模式（DI、事件总线、Actor 模型）— AI 会使用直接导入
   - 检查性能敏感路径 — AI 会写出分配内存的代码
   - 检查强制技术选型（特定 ORM、异步库等）

4. **检测 CI/CD 和工作流模式**
   - 检查 `.github/workflows/`、`.gitlab-ci.yml`、`Jenkinsfile`、`.gitea/` 等
   - 检查 git 分支命名模式：`git branch -a` 识别约定（feat/、fix/ 等）
   - 识别 AI 不应触碰的保护/生成目录（build/、dist/、vendor/ 等）
   - 检查 `.env` 文件或密钥模式

5. **检查已有配置**
   - 查找已有的 CLAUDE.md、.claude/ 目录、.claudeignore
   - 查找已有的 lint 配置、测试配置、CI/CD 设置
   - 如果配置已存在，询问用户是覆盖还是合并

6. **展示发现并确认**

   通过 AskUserQuestion 输出摘要：
   ```
   检测到：
   - 语言：{detected}
   - 框架：{detected}
   - 架构：{detected pattern}
   - 测试框架：{detected}
   - Linter：{detected}

   拟定的宪法条款：
   §1: {proposed constraint}
   §2: {proposed constraint}
   ...

   确认生成？（或告诉我需要调整的地方）
   ```

   **必须等待用户确认后才能进入阶段 2。**

## 阶段 1B：新建项目 — 引导式设置（不写入任何文件）

通过 AskUserQuestion 让用户描述项目。1-2 轮收集信息：

**第 1 轮（必需）：**
```
这看起来是一个新项目。请告诉我相关信息：

1. 语言和框架？（例如 TypeScript + Next.js、Python + FastAPI、Go + Gin、C# + Unity）
2. 项目做什么？（一句话描述）
3. 有特定的架构吗？（例如 monorepo、微服务、分层架构、ECS）
```

**第 2 轮（如需要，根据第 1 轮回答）：**
```
再补充几个细节：
- 测试框架偏好？（例如 Jest、pytest、go test）
- Linter 偏好？（例如 ESLint、Ruff、golangci-lint）
- 有硬性约束吗？（例如"必须用 SQLAlchemy 不用原生 SQL"、"不用 class 组件"）
```

然后展示摘要供确认，格式与阶段 1A 第 5 步相同，但基于用户回答而非代码扫描。

**必须等待用户确认后才能进入阶段 2。**

## 阶段 2：生成配置文件

基于阶段 1 分析生成所有文件。每个文件必须包含**具体的、项目专属内容** — 不留任何占位符。

### 2.0 仅新项目：初始化项目脚手架

如果是新项目（来自阶段 1B），先搭建基本项目结构：

1. **创建清单文件** — `package.json` / `go.mod` / `pyproject.toml` / `*.csproj` 等，基于用户选择的技术栈
2. **创建目录骨架** — `src/`、`tests/` 等，适合所选技术栈和架构
3. **创建入口文件** — 一个最小的 main 文件，让项目能运行
4. **初始化 git** — 如果还不是 git 仓库则执行 `git init`
5. **安装 linter** — 如果用户指定了 linter，作为开发依赖添加

脚手架保持最小化 — 刚好够项目构建/运行。用户之后自行添加功能。

### 2.1 生成 `CLAUDE.md`

根入口文件。内容：
- 项目名称（来自 package.json/go.mod 等或目录名）
- 架构概览（实际目录结构 — 来自阶段 1A 扫描或阶段 1B 脚手架）
- @import 引用子系统 CLAUDE.md 文件（如果是多模块）

控制在 30 行以内。不写通用规则 — 只写项目专属结构。

### 2.2 生成 `.claude/constitution.md`

- **已有项目**：基于阶段 1A 约束分析生成 4-7 条款。每条必须有 ✅/❌ 配对代码示例，**使用项目实际代码模式**。
- **新项目**：基于用户声明的约束和所选技术栈的最佳实践生成 2-4 条款。使用语言/框架的惯用代码示例。聚焦 AI 可能违反的约束（例如"用 X ORM 不用原生 SQL"、"所有状态通过 store，不用局部状态"）。

包含治理部分和执行协议（从模板复制）。

### 2.3 生成 `.claude/rules/coding-style.md`

1-3 条规则，用具体编码细节补充宪法。
每条规则引用一个宪法条款（参照宪法 §N）。
以自检清单结尾。

只创建宪法中不能推导出的规则。如果没有需要补充的，创建一个只包含自检清单的最小文件。

### 2.3b 生成 `.claude/rules/git-workflow.md`

基于阶段 1 对 git 历史和分支约定的分析：
- **提交信息格式**：从 `git log --oneline -20` 检测现有模式，或默认使用 `type(scope): description`
- **分支命名**：从 `git branch -a` 检测，或默认使用 `feat/`、`fix/`、`chore/`
- **原子提交**：始终包含此规则
- 以自检清单结尾

### 2.3c 生成 `.claude/rules/security.md`

基于检测到的项目类型：
- **代码中不含密钥**：始终包含 — 使用环境变量
- **输入验证**：如果项目有 HTTP 端点、CLI 输入或外部 API 调用则包含
- **依赖安全**：如果项目有带锁文件的包管理器则包含
- 以自检清单结尾

如果项目是纯内部工具且没有对外接口，保持最小化（只有密钥规则）。

### 2.4 生成 `.claudeignore`

基于检测到的项目类型：
- 始终包含：构建产物、依赖、IDE 文件、日志
- 语言专属：node_modules/、vendor/、bin/、obj/、target/ 等
- 项目专属：大型资源、生成代码等

### 2.5 配置 `.claude/settings.json`

生成包含三部分的完整 settings.json：

**权限（拒绝列表）** — 基于阶段 1 检测到的保护路径：
- 始终拒绝：`.env*`（编辑/写入）
- 如果是 Node.js：拒绝 `node_modules/**`（读取/编辑/写入）
- 如果检测到构建输出：拒绝 `{build-dir}/**`（编辑/写入）
- 如果项目有生成文件（如 protobuf 输出、代码生成）：拒绝这些路径

**Hooks — PostToolUse：**
- `lint-feedback.sh` 在 Edit|Write 时执行 — 基于检测到的 linter：
  - Node.js + ESLint → 配置
  - Python + Ruff/Flake8 → 配置
  - Go + golangci-lint → 配置
  - 如果未检测到 linter → 配置基础 hook，建议安装一个

**Hooks — PreToolUse：**
- `protect-files.sh` 在 Edit|Write 时执行 — 基于阶段 1 第 4 步检测配置 HARD_PROTECTED 和 SOFT_PROTECTED 列表：
  - HARD_PROTECTED：配置目录、.env 文件、锁文件
  - SOFT_PROTECTED：构建输出、生成代码、vendor 目录

**Hooks — SessionStart：**
- `reinject-context.sh` 在 compact 时执行 — 始终配置，无需自定义

### 2.6 复制内置 Skills

确保 `tdd/SKILL.md` 和 `verification/SKILL.md` 就位。
如果项目有特定测试框架，取消 tdd/SKILL.md 中相关部分的注释。

### 2.7 生成项目专属 Skills（如适用）

如果阶段 1 发现了 AI 会误用的自定义框架/封装，为它们创建 Skills：
- 自定义日志封装 → logging Skill
- 自定义 HTTP 客户端 → http-client Skill
- 自定义状态管理 → state Skill

每个 Skill 遵循 `_template/SKILL.md` 格式，包含**项目中的实际代码示例**。

### 2.8 复制命令和脚本

确保 `/feature-plan-creator`、`/bug-fix`、`/deep-task`、`/upgrade` 命令就位。
如果配置了 Hooks，复制 `scripts/lint-feedback.sh`。

### 2.8b 初始化 `.claude-flow/learnings/`

为 `/deep-task` 元学习创建 learnings 目录结构：

1. 创建目录 `.claude-flow/learnings/`
2. 创建 `INDEX.md`，内容为空索引：
   ```markdown
   # 学习记录索引

   _尚无记录。条目由 `/deep-task` 阶段 5 自动创建。_
   ```
3. 将 `.claude-flow/learnings/` 加入 git 追踪（不应出现在 `.claudeignore` 中）

### 2.9 生成 `.claude/agents/`

生成 3 个 agent 文件，包含**项目专属内容**（无占位符）：

**feature-builder.md** — 填入：
- `{build-command}`、`{test-single-command}`、`{test-all-command}`、`{lint-command}`：来自检测到的构建/测试/lint 工具
- `{base-branch}`：来自检测到的默认分支（`main` 或 `master`）
- `{repo-map-command}`：如果复制了 repo-map.py 则为 `python scripts/repo-map.py --format md --no-refs`

**code-reviewer.md** — 填入：
- `{performance-critical-path}`：来自阶段 1 约束分析（如"请求处理器"、"渲染循环"、"热路径"）
- `{project-specific-performance-criteria}`：来自宪法性能条款（如果有）
- `{project-specific-review-criteria}`：来自审查者应检查的宪法条款

**test-writer.md** — 填入：
- `{test-framework}`：检测到的测试框架（Jest、pytest、go test 等）
- `{test-directory}`：检测到的测试目录（tests/、__tests__/ 等）
- `{test-naming-convention}`：从已有测试或语言约定检测
- `{test-run-command}`：实际运行测试的命令
- `{performance-critical-path}`：与 code-reviewer 相同

### 2.10 生成 hook 脚本

从模板复制 `.claude/hooks/protect-files.sh` 和 `.claude/hooks/reinject-context.sh`，然后自定义：

**protect-files.sh** — 用实际项目路径替换占位符列表：
- `HARD_PROTECTED`：阶段 1 第 4 步检测到的配置目录（如 `ProjectSettings/`、`.env`、`*.lock`）
- `SOFT_PROTECTED`：生成/构建目录（如 `build/`、`dist/`、`node_modules/`、`vendor/`）

**reinject-context.sh** — 无需自定义，直接使用。

### 2.11 生成 `REVIEW.md`

基于阶段 1 分析生成项目专属代码审查标准文件：

- **维度 A（性能）**：基于检测到的性能约束填写规则（来自宪法）。如果没有性能关键路径，保持最小化。
- **维度 B（可维护性）**：填写项目的命名约定、模块边界、提交标准（来自 git-workflow 规则）。
- **维度 C（正确性与安全）**：填写项目专属验证规则、依赖清单路径、问题追踪器 URL。
- **技术清单**：添加语言/框架专属检查（如 React："不直接操作 DOM"、Go："必须检查 errors"、Python："不使用裸 except"）。

如果项目小/简单，生成精简的 REVIEW.md，只保留要点（跳过扩展表格）。

### 2.12 生成 `.github/workflows/ci.yml`（如适用）

仅在以下情况生成：
- 项目还没有 CI/CD 配置
- 项目托管在 GitHub（检查 `git remote -v` 中是否有 github.com）

如果生成，填入：
- `{language-runtime}`：检测到的 setup action（如 `actions/setup-node`）
- `{language-version}`：从清单文件检测（如 package.json engines、.python-version）
- `{install-command}`：从清单文件检测（如 `npm ci`、`pip install -r requirements.txt`）
- `{build-command}`：检测到的构建脚本，如不适用则移除该步骤
- `{lint-command}`：检测到的 linter 命令
- `{test-command}`：检测到的测试命令

AI 代码审查任务需要 `ANTHROPIC_API_KEY` — 在输出摘要中说明，并建议用户将其添加到 GitHub Secrets 以启用 AI 审查。

## 阶段 3：验证

1. 回读每个生成的文件并验证：
   - 任何文件中不残留 `{placeholder}` 文本
   - 宪法条款引用了实际项目模式
   - 代码示例对项目语言来说语法正确
   - .claudeignore 覆盖了项目的构建产物
   - settings.json hooks 指向正确的脚本路径

2. 输出摘要：
   ```
   已生成：
   - CLAUDE.md（N 行）
   - REVIEW.md（3 维度，N 条规则）
   - .claude/constitution.md（N 条款）
   - .claude/rules/coding-style.md（N 条规则）
   - .claude/rules/git-workflow.md（提交格式、分支命名、原子提交）
   - .claude/rules/security.md（密钥、验证、依赖）
   - .claudeignore
   - .claude/settings.json（hooks: lint + protect-files + reinject-context | deny: N 路径）
   - .claude/agents/feature-builder.md（build: {cmd}, test: {cmd}）
   - .claude/agents/code-reviewer.md（审查标准已配置）
   - .claude/agents/test-writer.md（框架: {framework}, 目录: {dir}）
   - .claude/hooks/protect-files.sh（hard: N 路径, soft: N 路径）
   - .claude/hooks/reinject-context.sh
   - .claude/skills/tdd/SKILL.md
   - .claude/skills/verification/SKILL.md
   - .claude/skills/{custom}/SKILL.md（如有）
   - .claude/commands/{feature-plan-creator,bug-fix,deep-task,upgrade}.md
   - .claude-flow/learnings/INDEX.md（/deep-task 的元学习存储）
   - .github/workflows/ci.yml（如已生成 — AI 审查需要 ANTHROPIC_API_KEY secret）

   下一步：
   - 审查生成的宪法 — 如有条款不正确请调整
   - 审查 REVIEW.md — 添加项目专属的性能/安全规则
   - 如果生成了 CI：将 ANTHROPIC_API_KEY 添加到 GitHub Secrets 以启用 AI 代码审查
   - 开始使用：直接描述你的任务，Claude Code 会遵循框架执行
   - 复杂功能：/feature-plan-creator <名称>
   - Bug 修复：/bug-fix <描述>
   - 复杂跨模块任务：/deep-task <目标>
   - 更新到最新版本：/upgrade
   ```

## 禁止操作

- 不要在生成的文件中留下任何 `{placeholder}`
- 不要生成 AI 默认就会遵循的通用/样板规则
- 不要为标准库用法创建 Skills（仅限项目专属封装）
- 不要跳过阶段 1 的用户确认
- 不要在未获得用户许可的情况下覆盖已有配置
