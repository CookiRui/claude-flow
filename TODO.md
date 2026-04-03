# claude-flow TODO

## 扩大影响力（优先）

- [x] 发 npm 包 — `npx claude-autosolve init`（已发布 v1.0.0）
- [x] 加英文 README — README_EN.md + 双语互链
- [ ] 写一篇实战博客（Medium / dev.to）— "How I made Claude Code 10x more reliable"
- [ ] 发 Twitter/X 线程 — 标记 @AnthropicAI，Claude Code 社区活跃
- [ ] 提交到 awesome-claude-code 列表 — 长尾曝光
- [ ] 录一个 3 分钟 demo 视频 — 效果最直观

## 短期盈利

- [ ] 开源核心 + 付费模板包（行业专用模板：游戏开发、金融后端、移动端）
- [ ] 付费咨询 — 帮团队配置 claude-flow
- [ ] Gumroad / 小报童 — 卖 Claude Code 高效使用指南

## 中期（3-6 个月）

- [ ] SaaS 化 — Web 界面配置 constitution/rules，一键导出 .claude/ 目录
- [ ] 团队版 — 多人共享 constitution + rules 同步服务

## autosolve / 看板优化

- [ ] 规划阶段进度展示 — planning 阶段看板空白，应显示递归分解实时进度（depth/parent）
- [ ] phase 状态可视化 — kanban.json 有 phase 字段但 viewer 没展示（planning/clarify/executing）
- [ ] clarify 过程可见 — 目标澄清的问答内容展示在看板上
- [x] 递归拆分智能终止 — 用 leaf 标记替代纯 complexity 判断，Claude 自主决定是否继续拆分
- [ ] 规划阶段 JSON 解析健壮性 — Claude 输出偶尔截断或缺 code fence，需要更好的 fallback/重试
- [ ] checkpoint commit 目录隔离 — 子进程可能 cd 到目标目录导致 git commit 污染其他仓库
- [ ] kill autosolve 时级联终止子进程 — kill python 后 claude 子进程（node）继续跑并 commit
- [x] subprocess encoding=utf-8 — Windows GBK 编码导致中文 commit message 解码失败
- [x] 规划完成后立即写入 kanban — 之前只有 dry-run 模式才在规划后写入

## 长期（等生态成熟）

- [ ] 官方市场上架（等 Anthropic 开放 marketplace）
- [ ] 企业合同 — 大团队 AI 编码规范落地
