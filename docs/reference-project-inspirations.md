# 参考 `claude-code-sourcemap/restored-src/src` 对 `claude-flow-mega` 的启发与优化建议

## 结论

对这个项目最有价值的，不是直接照搬参考项目的具体功能，而是吸收它的架构分层方式，把当前仓库从“模板分发 + 多个独立脚本”升级成“可组合的运行时内核 + 薄 CLI + 可扩展注册表”。

当前仓库的能力已经比较完整：

- 安装分发
- 模板体系
- rules / skills / commands 方法论
- DAG 调度
- repo map
- scope loader

但这些能力目前仍然主要以脚本和模板的形式存在，复用边界不够清晰。参考项目的核心启发在于，它把工具、命令、查询引擎、状态、服务、插件、技能都拆成了独立边界，后续功能增长时更稳定。

## 当前项目的定位

从代码结构看，这个仓库目前更像：

- 一个面向 Claude Code 的框架模板分发器
- 附带几个关键自动化脚本
- 再加一套项目配置方法论文档

关键入口大致集中在：

- `install.py`
- `bin/claude-autosolve.js`
- `scripts/persistent-solve.py`
- `scripts/repo-map.py`
- `scripts/scope-loader.py`

这说明当前架构偏“脚本级组合”，而不是“内核级组合”。

## 参考项目最值得借鉴的点

参考项目里最值得关注的不是目录多，而是职责拆分比较清楚：

- `tools.ts`: 工具注册与启用策略
- `commands.ts`: 命令注册、动态技能、插件命令装配
- `QueryEngine.ts`: 查询生命周期、状态、预算、消息流的统一内核

这三个点对应到你这个项目，分别能带来：

- 更稳定的能力注册机制
- 更清晰的命令扩展能力
- 更统一的执行与上下文编排内核

## 对当前项目的具体启发

### 1. 把“脚本能力”收敛成核心引擎层

现在的几个核心能力都很重要，但它们彼此还是偏独立：

- `persistent-solve.py`
- `repo-map.py`
- `scope-loader.py`

建议做一个统一的 engine 层，把以下能力抽成公共服务：

- 任务分解
- 上下文装配
- 模块识别
- 预算控制
- 执行器调度
- 结果回写

这样 CLI 入口只负责参数解析和输出格式，而不是承载主要业务逻辑。

### 2. 建立单一注册表，避免双端硬编码

当前安装清单在两处维护：

- `install.py`
- `bin/claude-autosolve.js`

这会带来典型问题：

- 文件列表漂移
- 预设能力不同步
- 升级逻辑难以校验

建议抽出一个单一 manifest，例如：

```json
{
  "template_items": [],
  "script_items": [],
  "presets": {
    "unity": {
      "detect": ["Assets", "ProjectSettings"]
    }
  }
}
```

然后：

- Python 安装器读取它
- Node CLI 读取它
- 后续 `upgrade` 命令也复用它

这会明显降低维护成本。

### 3. 把模块识别逻辑抽成共享库

`repo-map.py` 和 `scope-loader.py` 都维护了类似逻辑：

- `detect_modules`
- `classify_file_to_module`
- `.repo-map/config.json` 读取
- ignore 目录规则

这已经是明显的抽象信号。

建议新增一个共享模块，例如：

```text
scripts/lib/project_model.py
```

统一承载：

- module detection
- file-to-module mapping
- config load/save
- git diff affected files
- ignore rules

这样可以避免两个脚本之后继续渐行渐远。

### 4. 从“模板仓库”升级成“可扩展平台”

参考项目很重视：

- 动态命令发现
- 动态技能发现
- 插件命令装配

你当前也有类似潜力，但还停留在“preset = overlay copy”阶段。

建议把 `presets/` 从纯文件覆盖升级成带元数据的扩展单元，比如：

```json
{
  "name": "unity",
  "commands": [],
  "rules": [],
  "skills": [],
  "hooks": [],
  "scripts": []
}
```

这样新增 preset 时，不只是拷文件，还能声明：

- 提供哪些命令
- 注入哪些规则
- 启用哪些 hooks
- 依赖哪些脚本

以后扩展到更多技术栈时会轻很多。

### 5. 增加状态模型与迁移机制

参考项目里有明显的 state / migrations 思路。

你现在已经开始依赖：

- `.claude-flow/`
- `.repo-map/`

但状态结构还比较松散。建议尽早引入版本化状态模型，例如：

- `.claude-flow/state.json`
- `.repo-map/state.json`
- `schema_version`
- migration runner

否则后续一旦脚本输出结构调整，旧项目会很难平滑升级。

## 最值得优先做的三件事

### 1. 先抽共享的项目模型层

优先把以下逻辑统一：

- 模块识别
- 文件归属
- config 读取
- affected files 解析

目标是让 `repo-map.py` 和 `scope-loader.py` 共用一套模型。

### 2. 引入单一 manifest

先解决：

- `install.py` 和 `bin/claude-autosolve.js` 的重复维护
- preset 列表重复
- 模板文件列表重复

这是最直接的降维护成本动作。

### 3. 把 `persistent-solve.py` 拆成 CLI + service

当前这个脚本已经承担了很多职责：

- DAG 数据结构
- 预算管理
- WIP 协议
- prompt 构建
- 执行调度

建议拆成：

- `engine/task_graph.py`
- `engine/budget.py`
- `engine/planner.py`
- `engine/executor.py`
- `scripts/persistent-solve.py`

这样测试会更细，功能也更容易继续扩展。

## 当前仓库还可以顺手处理的两个问题

### 1. 测试文件有重复内容，建议清理

`tests/test_scope_loader.py` 里存在重复段落，后续维护容易混淆。

### 2. 中文文档/模板的编码链路要统一

当前在 Windows PowerShell 输出里已经能看到中文显示异常的迹象。这个问题不一定是文件本身坏了，但至少说明：

- 编码处理链路不稳定
- 某些终端下可读性会受影响
- 安装与脚本打印时存在风险

建议统一确认：

- README / docs / template-cn 使用 UTF-8
- Python/Node 输出编码行为一致
- Windows 终端显示路径做过验证

## 推荐的下一步实施顺序

建议按下面顺序推进：

1. 抽 `scripts/lib/project_model.py`
2. 改造 `repo-map.py` 和 `scope-loader.py` 复用它
3. 补测试并去重
4. 引入安装 manifest
5. 拆分 `persistent-solve.py`
6. 再考虑 preset 元数据化和迁移机制

这个顺序的好处是：

- 风险低
- 改动边界清晰
- 能最快减少重复代码
- 不会一开始就把整个仓库重构得过大

## 总结

这个项目现在最缺的不是新功能，而是“把已有能力组织成稳定内核”的那一步。

参考项目给你的最大启发应该是：

- 注册表化
- 内核化
- 状态化
- 插件化

如果继续沿现在的方向堆脚本，短期还能跑，但中期会越来越难维护。相反，如果先把项目模型、安装 manifest、执行引擎这三块抽出来，后面再加 preset、命令、技能、升级器，整个仓库会更像平台，而不是一组越来越重的脚本。
