# Agent 工作流程

以下命令在 D:\data\paper-sw\research\v2 执行。脚本只生成文件引用任务：模板、笔记和资料均使用绝对路径，不把正文堆进提示词。将任务交给能访问本地文件的 agent 后，由它先读模板、再按需读取资料，需确认实际读取与回写完成。文件引用不会自动上传材料；纯网页对话无法访问本地路径时，需要另行提供必要文件。

## 0. 初始化（只在文件缺失时复制）

不要覆盖已经填写的个人背景、知识或问题记录。

```powershell
Set-Location D:\data\paper-sw\research\v2
foreach ($name in @('profile', 'knowledge', 'questions', 'background-cache')) {
    if (-not (Test-Path -LiteralPath "$name.md")) {
        Copy-Item -LiteralPath "templates\$name.md" -Destination "$name.md"
    }
}
```

在 profile.md 记录当前知识与想了解的问题；未确定导师或方向可以明确写“探索中”。

## 1. 建立论文笔记

```powershell
.\tools\new-paper.ps1 -Name "example-paper" -Year 2026 -Title "论文标题"
```

生成 ../papers/2026/example-paper/paper.md。在 Metadata 填写标题、发表年份和 Link。-Year 是发表年份；默认当前年份，往年论文必须指定。

## 2. Stage 1A：独立背景调查

先在**当前论文对话**使用 [prompts/00-topic.md](prompts/00-topic.md) 提取主题，不需要单开对话。填入 `{{TITLE}}`，可提供 `{{ABSTRACT}}`、`{{MATERIAL}}`（链接、路径或任务/实验设置摘录）和 `{{CONTEXT}}`（用户确认的场景），也可复用该对话已有材料；未提供的可选项留空。agent 默认看标题和摘要，必要时查看任务定义、数据集和实验设置，提取任务范围，剥离作者的优势与 gap 宣称。

默认采用输出的宽主题。**只有独立背景调查需要新对话**：仅传“可直接交给背景 agent 的文本”，即中性主题与必要的已确认范围限定，不传论文标题、摘要、原文、提取依据或当前对话历史。

这里的独立性指背景证据与判断来自目标论文之外；调查范围可以由论文帮助确定。背景快照是在正式对照分析前保存，不要求论文对话此前完全没看过目标材料。

先用中性主题生成任务，不传论文标题、摘要、链接或原文：

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Stage 1 -Step Background -Topic "异常检测"
```

-Paper 仅为命令兼容而保留；背景分支不读取该论文目录，也不把该参数注入任务。

默认不引用全局 background-cache.md，因为它可能含有目标论文目录、笔记链接或读后修正。需要复用时，先准备仅包含中性主题、范围与证据的独立背景材料文件，检查不含目标论文标识或笔记，再显式传入：

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Stage 1 -Step Background -Topic "异常检测" -CachePath "D:\path\independent-background.md"
```

此参数只用于 Background；agent 仍需核对来源、范围和截止日期，不能跟随材料中的目标论文或笔记链接。

**把生成的提示词放进一个全新对话**，该对话不读取目标论文和论文笔记。背景 agent 检索独立来源，输出任务边界、评价指标、方法路线、有证据支持的局限、争议和未知。每项重要判断附来源、日期及适用范围。无法检索时只输出初步背景，不伪装为已核实共识。

若评价发表时创新性，指定视角及资料截止日期（填真实日期）：

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Stage 1 -Step Background -Topic "中性主题" -Perspective Publication -Cutoff "2025-06-01"
```

背景 agent 的检索日期可以是今天，证据材料必须在截止日期范围内。仅知道发表年份时说明日期精度限制，避免断言临界时间上的创新优先级。

完成后由用户或主对话：

- 保存完整背景到 ../papers/2026/example-paper/background.md；参考 templates/background-cache.md 的结构。
- 将可复用记录合并到 background-cache.md，保留版本、来源和演化日志。
- 若已有可核实、时间与范围适用的缓存，将相应条目保存为快照即可，不必重新调查。空模板和“待核实示例”不算可用背景。

若让 agent 直接回写文件，需要允许背景 agent 访问目标目录；这会削弱隔离。本流程让它只返回背景结果，由主对话保存。真正的隔离依赖新上下文和工具访问约束，提示词本身不是访问控制。

## 3. Stage 1B：对照筛选

回到论文阅读对话，提供目标论文：

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 1 -Url "https://example.org/paper"
# 或本地材料：
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 1 -SourcePath "D:\path\paper.pdf"
```

任务默认引用该论文目录的 background.md；缺失或为空会报错。也可用 -BackgroundPath 指定已经保存的背景文件。脚本只检查文件存在且非空，agent 必须实际读取背景再对照论文；证据是否充分需要人工或 agent 检查。任务同时包含 paper.md 的准确回写路径，复制到剪贴板时会一并保留。

agent 实际读取论文后，填写 paper.md §1：分析范围、背景版本、证据对照、gap 判断，以及学习价值、相关性、证据质量。允许“暂不能判断”；不要把缓存当作真理。

完成后勾选 01 Screening。D 类写清理由即可停止，不要求继续凑满三阶段。发现值得读也不等于值得复现。

## 4. Stage 2：批判性阅读

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 2
```

任务引用已有笔记、个人背景和知识库，agent 从 Metadata 的 **Link** 字段读取链接。若未保存链接，再次传 -Url 或 -SourcePath。文本文件 .md/.txt 与 PDF 均只提供绝对路径，agent 使用相应读取工具打开；较大的知识库按论文主题读取相关条目。

agent 理解方法，区分 Facts / Claims / Inferences，并用章节或图表支持关键判断。根据主张设计有意义的质疑；只有摘要时不得声称已检查全文实验。

回写 §2，达到本次阅读目标后勾选 02 Reading。

## 5. Stage 3：沉淀与修正

```powershell
.\tools\run-stage.ps1 -Paper "example-paper" -Year 2026 -Stage 3
```

任务会列出各文件的准确路径。更新前读取现有内容，对问题和阅读记录去重，保留无关条目；必要的知识库或问题库缺失时可以创建。完成后检查实际写入结果。

完成以下回写：

- paper.md §3：收获、问题、知识增量、一句话总结。
- knowledge.md：更新对应概念或方法，并在 §8 Recent Updates 记来源与修正。
- questions.md：追加有依据的问题、重要性和验证方法；没有合理问题时写明原因。
- profile.md §4：追加阅读记录，保留已有个人背景。
- background-cache.md：必要时写入有证据的修正及演化日志；保留该论文的阅读前 background.md。

实际回写完成后勾选 03 Synthesis。

## 6. 查看进度

```powershell
.\tools\status.ps1
```

进度来自手动勾选，不代表自动核验分析质量。Summary 只检查是否有非空的一句话总结。筛选后停止的论文可能显示 1/3，结合 §1 决策理解。

命令加 -NoClipboard 可只输出提示词而不修改剪贴板。模糊匹配出现多篇时会报错，应指定完整论文目录名。

## 已有 MiniMaxAD 记录

当前尚未填写，没有背景快照。可先用 00-topic.md 从标题提取“异常检测”作为宽主题；数据类型和应用场景尚未确认，不能仅因期刊名推断为工业视觉任务。之后可补充“异常检测中的自编码器方法与计算成本”调查；取得真实论文材料后再筛选。论文实际发表年份需要从原文核实，现有 2026 目录来自创建时的元数据，不代表已核实年份。
