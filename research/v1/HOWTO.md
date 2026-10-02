# HOWTO：怎么跟 AI 说，才能用起这套系统

> 核心原则一句话：
>
> **一条消息 = 一个阶段。**
>
> 不要问「帮我总结这篇论文」。要问「执行 00 Screening，结果写回 §0 §1 §3」。

---

## 0. 先把论文交给 AI（三选一）

### 方式 A：有链接（最推荐）

直接把 arxiv / ACL / DOI 链接给我即可，我自己抓全文。

```text
论文：https://arxiv.org/abs/2307.03172
```

### 方式 B：只有本地 PDF

`read` 工具只保证能读**文本和图片**，不保证能解析 PDF 正文。所以先把 PDF 转成文本放进论文目录：

```powershell
cd D:\data\paper-st\research
.\tools\new-paper.ps1 -Name "lost-in-the-middle" -Year 2024 -Title "Lost in the Middle"

# 有 pdftotext（poppler）：
pdftotext -layout "C:\Users\me\Downloads\2307.03172.pdf" ".\papers\2024\lost-in-the-middle\fulltext.txt"
```

然后告诉我：

```text
论文全文：papers/2024/lost-in-the-middle/fulltext.txt
```

（实在转不了，就直接把 PDF 路径给我，我先试读，读不了我会明确说"读不到"，不会瞎编。）

### 方式 C：只有截图 / 纸质

把关键页截图发我（Abstract、Intro、Method 图、主要结果表、Ablation）。我能读图。

---

## 1. 每条消息的「四件套」结构

```text
① 上下文   读 profile.md 和 knowledge.md
② 阶段     执行 prompts/0X-xxx.md
③ 对象     论文：<路径 或 链接>
④ 去向     结果直接写回 papers/YYYY/xxx/paper.md 的 §A §B，并勾上进度表
```

① 和 ② 每次都要有，③ 只有换阶段时才要重复，④ 决定你是"手动复制"还是"我直接改文件"。

**因为我有文件读写权限，④ 建议永远带上**——回写这一步你不用动手。

---

## 2. 九阶段话术（可直接复制）

### 第 1 步：筛选（要不要读）

```text
读 research/profile.md 和 research/knowledge.md。

执行 research/prompts/00-screening.md。
论文：<链接或路径>

结果写回 papers/2024/lost-in-the-middle/paper.md 的 §1 §2 §3，并更新顶部进度表的 00 行。
```

看完如果优先级是 D，就到此为止，不要往下走。

---

### 第 2 步：背景（论文之外的人类知识）

> ⚠️ 这一步**不要**把论文给我。这是这套系统最容易做错的地方。

```text
执行 research/prompts/01-background.md。
研究主题：long-context LLM 的位置偏差 / 检索文档排序

注意：不要读目标论文，也不要引用它。我要的是独立的知识坐标系。

结果写回 paper.md 的 §2，并把时间线、范式、trade-off 提炼进 knowledge.md 的 §2 §3 §4。
```

---

### 第 3 步：阅读

```text
执行 research/prompts/02-reading.md。

论文：<链接或路径>
上下文：profile.md + knowledge.md

关键：严格区分 Facts / Author Claims / Author Interpretations / 你的 Inference，四类分栏写。
结果写回 paper.md 的 §3 §4 §6 §7。
```

---

### 第 4 步：逻辑审查

```text
执行 research/prompts/03-logic-check.md，你现在的身份是逻辑审查者，不是总结助手。

论文：<路径>
先重建 Problem→Observation→Hypothesis→Method→Evidence→Conclusion→Impact 的链条，
再逐节找断点。不要讨论写作和格式。

结果写回 paper.md 的 §5 §15。
```

---

### 第 5 步：方法审查

```text
执行 research/prompts/04-method-check.md。
论文：<路径>

要求：§4「Why Should It Work」必须独立解释，不许复述作者原话。
结果写回 paper.md 的 §6 §8 §12 §17。
```

---

### 第 6 步：实验审查

```text
执行 research/prompts/05-experiment-check.md。
论文：<路径>

重点：每个核心 claim 是否都有对应实验；有没有应该做但没做的 baseline 缺失。
结果写回 paper.md 的 §9 §10 §11 §13 §14。
```

---

### 第 7 步：Review（试着 Reject）

```text
执行 research/prompts/06-review.md，不要读 07-defense。
论文：<路径>

目标：找出「这篇论文不该存在」的最强理由。
特别检查 §9「局部改进 vs 系统级影响」。
每条 criticism 必须标注 Confidence，没有证据支撑的就别写。
结果写回 paper.md 的 §15 §16 §17。
```

---

### 第 8 步：Defense（站在作者那边）

> 这一步必须**单独开一轮**，并且把上一轮的 Review 结果原样喂进去。

```text
执行 research/prompts/07-defense.md。
论文：<路径>
Reviewer Criticism：<把第 7 步的输出贴进来，或写"见 paper.md §15">

结果写回 paper.md 的 §18，以及 my-judgment.md 的 §11 §12。
```

---

### 第 9 步：Synthesis（变成自己的知识）

```text
执行 research/prompts/08-synthesis.md。
论文：<路径>
上下文：profile.md + knowledge.md

这一步要动四个文件，请分别给我 diff：
- paper.md           §19 §20 §21 §22 §23
- my-judgment.md     全文填完
- questions.md       至少 1 条可验证的 Open Question
- knowledge.md       §9 §10 §11（新增了什么 / 和什么冲突 / 更新日志）

另外列出 profile.md §4 §5 §6 §7 需要我手动改的地方，我自己决定改不改。
```

---

## 3. 阶段 → 文件章节 映射表

| Prompt | 写回 paper.md | 其他文件 |
| --- | --- | --- |
| 00 Screening | §1 §2 §3 + 进度表 | — |
| 01 Background | §2 | knowledge.md §2 §3 §4 |
| 02 Reading | §3 §4 §6 §7 | — |
| 03 Logic Check | §5 §15 | — |
| 04 Method Check | §6 §8 §12 §17 | — |
| 05 Experiment Check | §9 §10 §11 §13 §14 | — |
| 06 Review | §15 §16 §17 | — |
| 07 Defense | §18 | my-judgment.md §11 §12 |
| 08 Synthesis | §19 §20 §21 §22 §23 | my-judgment.md 全部、questions.md、knowledge.md §9 §10 §11、profile.md（建议） |

---

## 4. 一段真实对话长什么样

**你（第 1 轮）：**

```text
读 research/profile.md 和 research/knowledge.md。

执行 research/prompts/00-screening.md。
论文：https://aclanthology.org/2024.tacl-1.9/

结果写回 papers/2024/lost-in-the-middle/paper.md 的 §0 §1 §2 §3，并勾上进度表 00 行。
```

**我：** 先建目录 → 抓全文 → 按 §1–§10 十个问题输出 → 用 edit 写进 paper.md。
结束时我会告诉你：优先级 B、gap 判断为「真实存在但已被部分解决」、以及**我不确定的三处**（例如训练数据截止时间对结论的影响）。

**你（第 2 轮）：**

```text
你判断 gap「已被部分解决」，依据是什么？把依据写进 §2 的 Possible Research Gap，
另外把这个不确定性记到 questions.md 的 Q001（只是这篇的，不是全局的）。
```

**我：** 补依据 → 改 §2 → 追加 questions.md。

**你（第 3 轮）：**

```text
执行 prompts/03-logic-check.md。论文：同上。
结果写回 §5 §15。
```

……

**你（第 9 轮）：**

```text
执行 prompts/08-synthesis.md。
另外：先别动 profile.md 和 knowledge.md，只给我 diff 建议，我确认后再改。
```

> 注意最后这句——**全局文件（profile / knowledge）永远让你自己拍板**，我的输出只是提案。
> 否则读上 20 篇论文后，你的知识库会被 AI 的措辞慢慢同化。

---

## 5. 纠偏话术（很重要）

| 情况 | 说什么 |
| --- | --- |
| 我又开始写摘要了 | 「不要总结。按 Facts / Claims / Interpretations / Inference 分栏重写。」 |
| 输出太客气，全是优点 | 「列出这篇论文最可能被 Reject 的三个理由，每条给出需要的证据。」 |
| 它在替作者辩护 | 「你现在是 Reviewer，不是作者。重写。」 |
| 它在编造 | 「哪些是你从原文读到的，哪些是你推断的？分开标注。不确定就写不确定。」 |
| 它没结合我的背景 | 「对照 profile.md §2，这里面哪些是我 Already Familiar，哪些是 Not Familiar？我只想细看后者。」 |
| 输出太长没结构 | 「压成 §N 的模板结构，不要小标题以外的自由段落。」 |
| 它把 gap 说得很重要 | 「这个 gap 是论文包装出来的，还是人类真的卡在这里？给反方证据。」 |
| 我想让它停 | 「停止分析。只回答：这篇论文值不值得我复现？一句话 + 三个理由。」 |

---

## 6. 三个最常见的错误

**错误 1：一条消息里塞三个阶段**

```text
❌ 帮我总结这篇论文，批判一下它的实验，再给我几个 idea
```

后果：三个阶段互相污染，Screening 被 Reading 的细节带偏，Review 变成复述。
正确做法：分三条消息。

**错误 2：不给 profile 就扔论文**

后果：输出退化成知乎水平综述。
正确做法：每条消息第一句就是「读 profile.md 和 knowledge.md」。

**错误 3：读完不回写**

后果：三周后你只记得"读过"，不记得"判断过什么"。
正确做法：每轮消息都带「结果写回 §A §B」。
