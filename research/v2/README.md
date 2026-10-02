# v2 论文研究系统

以 Markdown 保存研究积累，用 agent 完成独立背景调查、论文阅读和知识沉淀。

## 工作流程

准备：在当前论文对话使用 `prompts/00-topic.md`，结合标题、摘要及必要的任务/实验设置提取中性主题。只将主题与已确认的范围限定交给新的背景对话，不传论文内容或对话历史。

1. Stage 1A Background：在未接触目标论文的新对话中，围绕中性主题检索独立来源，形成带证据、日期、范围和未知项的背景。
2. 保存阅读前快照到 papers/发表年份/论文名/background.md，把可复用部分更新到 v2/background-cache.md。
3. Stage 1B Screening：阅读目标论文，对照背景，分别评价学习价值、研究相关性、证据质量，决定 A/B/C/D。
4. Stage 2 Reading：解释方法，区分 Facts / Claims / Inferences，检查关键主张与实验。
5. Stage 3 Synthesis：更新论文笔记、全局知识库、问题库和阅读记录；必要时修正背景缓存，保留旧快照。

1A 和 1B 属于同一个 Screening 阶段。已有适用且可核实的背景可复用，不必每篇重新检索。新领域调查按需要投入时间，不保证几分钟完成。

## 文件结构

```text
research/
├── v2/
│   ├── profile.md
│   ├── knowledge.md
│   ├── questions.md
│   ├── background-cache.md
│   ├── prompts/
│   │   ├── 00-topic.md
│   │   ├── 01-background.md
│   │   ├── 01-screening.md
│   │   ├── 02-reading.md
│   │   └── 03-synthesis.md
│   ├── templates/
│   │   ├── paper.md
│   │   ├── background-cache.md
│   │   ├── profile.md
│   │   ├── knowledge.md
│   │   └── questions.md
│   └── tools/
│       ├── new-paper.ps1
│       ├── run-stage.ps1
│       └── status.ps1
└── papers/发表年份/论文名/
    ├── paper.md
    └── background.md
```

## 工具边界

脚本创建笔记、生成提示词并复制到剪贴板、统计手动勾选的进度。它们不会调用模型、下载论文或自动回写分析。agent 在接收任务后使用读取和检索工具；没有访问能力时必须说明限制。

背景任务不会读取目标论文文件，但仅靠提示词不能保证 agent 的上下文隔离。应使用新对话，或平台确实支持不继承历史的独立 agent。不要直接在已读过目标论文的对话中执行 1A。

## 快速使用

在 v2 目录运行：

```powershell
.\tools\new-paper.ps1 -Name "example-paper" -Year 2026 -Title "论文标题"
.\tools\run-stage.ps1 -Paper "example-paper" -Stage 1 -Step Background -Topic "中性研究主题"
# 在新对话执行生成任务，保存背景后：
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 1 -Url "https://example.org/paper"
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 2
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 3
.\tools\status.ps1
```

后续阶段仅从 paper.md 的 **Link** 字段复用链接，不会记住上一次命令的 -Url；请保存链接或再次提供。本地文件用 -SourcePath。年份默认当前年份，阅读往年论文必须显式传 -Year。

详见 [QUICKSTART.md](QUICKSTART.md)。[WHY-SIMPLIFIED.md](WHY-SIMPLIFIED.md) 解释设计理由，[SIMPLIFICATION-GUIDE.md](SIMPLIFICATION-GUIDE.md) 说明 v1 到 v2 的取舍。
