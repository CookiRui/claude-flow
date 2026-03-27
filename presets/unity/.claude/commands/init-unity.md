---
description: 分析 Unity 项目并替换所有 preset 占位符
argument-hint: [--force]
---

# /init-unity

扫描当前 Unity 项目，自动检测配置值并替换 `.claude/` 下所有 `{placeholder}`。
用户只需确认检测结果或补充少量无法自动推断的值。

---

## 阶段 0：定位 Unity 项目

自动扫描，无需用户手动 cd：

1. **检查当前目录**是否是 Unity 项目（`Assets/` + `ProjectSettings/` 同时存在）
2. **如果不是**，扫描一级子目录，找到所有包含 `Assets/` + `ProjectSettings/` 的子目录
   - 如果找到 1 个 → 自动选中
   - 如果找到多个 → 用 AskUserQuestion 让用户选择
   - 如果一个都没找到 → 报错退出
3. 确定后，以下所有阶段的文件操作都**基于该 Unity 项目目录**（记为 `UNITY_ROOT`）
4. 读取 `UNITY_ROOT/ProjectSettings/ProjectSettings.asset`，提取：
   - `productName` → 用作 `{project-name}`
   - `companyName` → 备用信息
5. 确定项目在仓库中的相对位置：
   - 运行 `git rev-parse --show-toplevel` 获取仓库根目录
   - 计算 `UNITY_ROOT` 相对于仓库根的路径 → `{unity_project_subdir}`
   - 如果不是 git 仓库，`{project_root}` 使用仓库根目录或当前目录

---

## 阶段 1：自动检测（不写入任何文件）

依次扫描以下信息，尽量自动推断：

### 1.1 Unity Editor 路径

按优先级检测：
- 读取 `Library/EditorInstance.json`（如果 Unity 正在运行，里面有 editor 路径）
- 读取 `ProjectSettings/ProjectVersion.txt` 获取 Unity 版本号，然后搜索常见安装路径：
  - Windows: `C:/Program Files/Unity/Hub/Editor/{version}/Editor/Unity.exe`
  - macOS: `/Applications/Unity/Hub/Editor/{version}/Unity.app/Contents/MacOS/Unity`
  - Linux: `~/Unity/Hub/Editor/{version}/Editor/Unity`
- 如果找不到，标记为需要用户输入

→ `{unity_editor_path}`

### 1.2 命名空间和程序集

- 搜索 `Assets/**/*.asmdef` 文件，读取其 `name` 字段
- 从 asmdef 名称推断 `{root-namespace}`（取最短的公共前缀，如 `MyGame.Gameplay` + `MyGame.Editor` → `MyGame`）
- 如果没有 asmdef 文件，扫描 `Assets/Scripts/` 下 `.cs` 文件的 `namespace` 声明，取最常见的顶层命名空间
- 从检测到的 asmdef 中识别：
  - `{test-assembly-name}` — 包含 `Tests` 或 `Editor` 的 asmdef
  - `{project-core-assembly}` — 主游戏逻辑 asmdef（不含 Editor/Tests）
  - `{autotest-assembly-name}` — 包含 `AutoTest` 的 asmdef（如果存在）

→ `{root-namespace}`, `{project-namespace}`, `{test-assembly-name}`, `{project-core-assembly}`, `{autotest-assembly-name}`

### 1.3 场景路径

- 搜索 `Assets/**/*.unity` 文件
- 按规则分类：
  - 包含 `Main`、`Game`、`Gameplay`、`Level` 的 → 候选 `{default-scene-path}`
  - 包含 `Test`、`AutoTest`、`Sandbox` 的 → 候选 `{default-test-scene-path}`
- 如果只有一个场景，同时用作两者
- 如果找不到明确候选，列出所有场景让用户选

→ `{default-scene-path}`, `{default-test-scene-path}`

### 1.4 测试用例路径

- 搜索 `Assets/**/AutoTest/` 或 `Assets/**/TestCases/` 或 `Assets/**/Tests/*.json`
- 如果找到 → `{test-cases-path}`
- 如果没找到，使用默认值 `Assets/Tests/AutoTest/Cases`

→ `{test-cases-path}`

### 1.5 批处理入口类

- 搜索项目中的 C# 文件，查找继承或使用了批处理模式的类：
  - Grep `UnityOpsRunner` 或 `BatchMode` → `{unity_ops_runner_class}`
  - Grep `BatchPlayModeRunner` 或 `PlayModeRunner` → `{batch_playmode_runner_class}`
  - Grep `BatchCompile` 或 `CompileMethod` → `{batch_compile_method}`
- 如果在 `unity-runtime/` 模板代码中找到（由 install.py 复制），使用模板中的完整类路径
- 如果找不到，标记为需要用户后续配置（注释掉相关功能）

→ `{unity_ops_runner_class}`, `{batch_playmode_runner_class}`, `{batch_compile_method}`

### 1.6 Gitea 配置（可选）

- 检查 `git remote -v` 的 URL
- 如果包含 gitea 关键字或非 github.com/gitlab.com 的自托管地址：
  - 从 URL 解析 `{gitea-url}`、`{gitea-owner}`、`{gitea-repo}`
- 如果是 GitHub/GitLab，将 gitea 相关文件中的占位符替换为注释说明

→ `{gitea-url}`, `{gitea-owner}`, `{gitea-repo}`

### 1.7 保护路径

根据项目结构自动确定：
- `{protected-config-dir}` → `ProjectSettings/`
- `{protected-generated-dir}` → `Library/`（始终被 gitignore，但作为保护目标）

→ `{protected-config-dir}`, `{protected-generated-dir}`

### 1.8 构建/测试/Lint 命令

根据检测结果组装：
- `{build-command}` → `bash .claude/scripts/unity-compile.sh`
- `{test-single-command}` → `bash .claude/scripts/unity-editmode-test.sh --filter <TestName>`
- `{test-all-command}` → `bash .claude/scripts/unity-editmode-test.sh`
- `{lint-command}` → 检测是否有 `.editorconfig` 或 `dotnet format`，否则标注 `# 暂无 lint 工具`
- `{test-framework}` → `NUnit (Unity Test Framework)`
- `{test-directory}` → 检测到的 Tests asmdef 所在目录
- `{test-naming-convention}` → `Test_{类名}_{行为}.cs`（Unity 惯例）
- `{test-run-command}` → `bash .claude/scripts/unity-editmode-test.sh`

→ `{build-command}`, `{test-single-command}`, `{test-all-command}`, `{lint-command}`, `{test-framework}`, `{test-directory}`, `{test-naming-convention}`, `{test-run-command}`

### 1.9 其他

- `{repo-map-command}` → 检查 `scripts/repo-map.py` 是否存在，存在则设为 `python scripts/repo-map.py --format md --no-refs`，否则留空
- `{base-branch}` → `git symbolic-ref refs/remotes/origin/HEAD` 或从 `git branch` 检测 main/master
- `{unity-docs-path}` → 检测 Unity Hub 安装路径下的 Documentation 目录，找不到则标注 `# 未检测到本地文档`
- `{unity-editor-path}` (git-ops.md 中用的路径) → 与 `{unity_editor_path}` 取同一安装目录
- `{unity-project-path}` (git-ops.md 中用的) → 与 `{unity_project_subdir}` 一致
- `{performance-critical-path}` → `Update/FixedUpdate/LateUpdate 热路径`

---

## 阶段 2：用户确认

使用 AskUserQuestion 展示检测结果，分为"已确认"和"需要输入"两部分：

```
Unity 项目初始化检测结果：

✅ 已自动检测：
- 项目名称: {detected}
- Unity 版本: {detected}
- Editor 路径: {detected}
- 根命名空间: {detected}
- 默认场景: {detected}
- 测试场景: {detected}
- 默认分支: {detected}

❓ 需要确认或补充：
- [如有未检测到的项，列出并要求输入]

是否按此结果替换所有占位符？
```

**必须等待用户确认后才能进入阶段 3。**

如果用户要求调整某些值，记录调整后重新确认。

---

## 阶段 3：替换占位符

逐个文件读取并替换所有 `{placeholder}`。替换范围：

### 3.1 脚本文件
| 文件 | 替换的占位符 |
|------|-------------|
| `.claude/scripts/unity-env.sh` | `{unity_editor_path}`, `{project_root}`, `{unity_project_subdir}` |
| `.claude/scripts/unity-compile.sh` | `{batch_compile_method}` |
| `.claude/scripts/unity-game-test.sh` | `{batch_playmode_runner_class}` |
| `.claude/scripts/unity-ops.sh` | `{unity_ops_runner_class}` |
| `.claude/scripts/gitea-api.sh` | `{gitea-url}`, `{gitea-owner}`, `{gitea-repo}` |

### 3.2 Agent 文件
| 文件 | 替换的占位符 |
|------|-------------|
| `.claude/agents/feature-builder.md` | `{repo-map-command}`, `{build-command}`, `{test-single-command}`, `{test-all-command}`, `{lint-command}`, `{default-test-scene-path}`, `{base-branch}` |
| `.claude/agents/test-writer.md` | `{test-framework}`, `{test-directory}`, `{test-naming-convention}`, `{test-run-command}`, `{performance-critical-path}` |
| `.claude/agents/unity-dev.md` | `{unity-docs-path}`, `{test-assembly-name}`, `{default-scene-path}`, `{project-namespace}`, `{test-cases-path}` |
| `.claude/agents/git-ops.md` | `{unity-project-path}`, `{base-branch}`, `{unity-editor-path}` |

### 3.3 Hook 文件
| 文件 | 替换的占位符 |
|------|-------------|
| `.claude/hooks/protect-files.sh` | `{protected-config-dir}`, `{protected-generated-dir}` |

### 3.4 Skill 文件
| 文件 | 替换的占位符 |
|------|-------------|
| `.claude/skills/autotest/SKILL.md` | `{default-test-scene-path}`, `{test-cases-path}`, `{autotest-assembly-name}`, `{project-core-assembly}` |

### 3.5 文档文件
| 文件 | 替换的占位符 |
|------|-------------|
| `REVIEW.md` | `{project-name}` 以及所有 performance/maintainability/correctness 占位符 |

**REVIEW.md 特殊处理：** 由于 REVIEW.md 包含大量通用占位符（`{performance-blocker-1}` 等），用 Unity 项目的具体规则填充：

| 占位符 | 填充值 |
|--------|--------|
| `{performance-blocker-1}` | `Update/FixedUpdate 中存在堆内存分配（GC.Alloc > 0B）` |
| `{performance-blocker-2}` | `热路径中使用 GetComponent<T>()、Find()、LINQ` |
| `{performance-warning-1}` | `未缓存 WaitForSeconds 等 YieldInstruction` |
| `{performance-warning-2}` | `使用 magnitude 而非 sqrMagnitude 做距离比较` |
| `{performance-suggestion-1}` | `可用对象池替代频繁 Instantiate/Destroy` |
| `{async-context}` | `主线程（Unity API 仅可在主线程调用）` |
| `{performance-critical-path}` | `MonoBehaviour.Update, FixedUpdate, LateUpdate, OnGUI 及协程热路径` |
| `{performance-resource-constraint}` | `移动端 / 主机端帧率预算（16.6ms@60fps）、GC 暂停敏感` |
| `{naming-convention-file}` | `.claude/rules/unity-scripts.md` |
| `{module-A}`, `{module-B}` | 从检测到的 asmdef 中取两个代表性模块名 |
| `{max-function-lines}` | `80` |
| `{dependency-manifest}` | `Packages/manifest.json` |
| `{architecture-doc-path}` | `Docs/Architecture/` 或项目中已有的文档路径 |
| `{language-or-framework}` | `Unity (C#)` |
| `{tech-specific-check-1}` | `MonoBehaviour 生命周期顺序是否正确（Awake→OnEnable→Start）` |
| `{tech-specific-check-2}` | `SerializeField 字段是否在 Inspector 中有合理默认值` |
| `{tech-specific-check-3}` | `.meta 文件是否与资产文件同步提交` |

其余 `{placeholder}` 类占位符（如 `{project-perf-rule-1}`），如果无法从项目中推断，则替换为空字符串或删除该行（不要留下未替换的占位符）。

### 3.6 CI/Workflow 文件
| 文件 | 替换的占位符 |
|------|-------------|
| `.gitea/workflows/compile.yml` | `{unity-project-path}`, `{ci-workspace-path}` |
| `.gitea/workflows/review.yml` | `{gitea-url}`, `{ci-workspace-path}`, `{review-file-extensions}` |

### 3.7 Assembly Definition 文件

如果 `unity-runtime/` 目录存在（由 install.py 复制的模板代码）：
- 将文件名中的 `{root-namespace}` 替换为实际值（需要重命名文件）
- 替换文件内容中的 `{root-namespace}`

---

## 阶段 4：创建必要目录

确保以下目录存在：
- `.claude/logs/`
- `.claude/batch-mode/results/`
- `.claude/batch-mode/commands/`
- 检测到的 `{test-cases-path}` 目录

---

## 阶段 5：验证

1. 对所有在阶段 3 中修改过的文件执行 Grep 检查，确认不存在残留的 `{placeholder}` 模式（`\{[a-z][a-z0-9_-]*\}`）
   - 排除 Bash 变量 `${VAR}`、shell 函数中的 `${1:-}`、以及 markdown 代码块中的示例
   - 只检查真正的模板占位符（被花括号包裹的小写字母开头的标识符）
2. 验证 shell 脚本中的路径引用是否指向实际存在的文件
3. 验证 asmdef 文件重命名是否成功

输出验证摘要：

```
/init-unity 完成！

替换统计：
- 处理文件: N 个
- 替换占位符: N 处
- 残留占位符: 0（如有残留则列出详情）

项目配置：
- 项目名称: xxx
- 根命名空间: xxx
- Unity 版本: xxx
- Editor 路径: xxx
- 默认场景: xxx
- 默认分支: xxx

已就绪的工具：
- ✅ bash .claude/scripts/unity-compile.sh — 编译检查
- ✅ bash .claude/scripts/unity-editmode-test.sh — EditMode 测试
- ✅/⚠️ bash .claude/scripts/unity-game-test.sh — PlayMode 测试（需要 BatchPlayModeRunner）
- ✅/⚠️ bash .claude/scripts/unity-ops.sh — 资产操作（需要 UnityOpsRunner）

下一步：
- 在 Unity Editor 中打开项目，确认编译通过
- 运行 `bash .claude/scripts/unity-compile.sh` 验证批处理模式
- 如需 PlayMode 测试，将 unity-runtime/ 中的 C# 代码集成到项目中
- 使用 /feature-plan-creator 开始规划新功能
```

---

## 禁止操作

- 不要在任何文件中留下未替换的 `{placeholder}`
- 不要修改 `.claude/rules/` 下不含占位符的规则文件（如 `unity-assets.md`、`cli-tools.md`）
- 不要删除或重写用户已有的代码文件
- 不要跳过用户确认（阶段 2）
- 如果某个值无法检测也无法从用户获得，用注释标记而非留下占位符（如 `# TODO: 配置 Unity Editor 路径`）
