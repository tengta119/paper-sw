# 研究生论文阅读系统 v1.0

> 目标不是知识管理，而是让每一篇论文都走完一条固定流水线：
>
> **筛选 → 建立背景 → 阅读 → 重建逻辑 → 验证 → 反驳 → 形成自己的判断 → 沉淀知识 → 产生新问题**

---

## 1. 目录结构

```text
research/
├── README.md            ← 本文件：系统说明与使用方式
├── HOWTO.md             ← 「怎么跟 AI 说」的对话话术速查（先看这个）
├── profile.md           ← 我的科研身份与当前知识状态（AI 的长期上下文）
├── knowledge.md         ← 我认为人类已经知道什么（抗论文叙事污染的 grounding）
├── questions.md         ← 我目前真正不知道答案的问题
│
├── prompts/             ← 分阶段 Prompt，不要合成一个大 Prompt
│   ├── 00-screening.md
│   ├── 01-background.md
│   ├── 02-reading.md
│   ├── 03-logic-check.md
│   ├── 04-method-check.md
│   ├── 05-experiment-check.md
│   ├── 06-review.md
│   ├── 07-defense.md
│   └── 08-synthesis.md
│
├── templates/           ← 空白模板（由 tools/new-paper.ps1 复制）
│   ├── paper.md
│   ├── my-judgment.md
│   └── questions.md
│
├── tools/
│   └── new-paper.ps1    ← 一键建论文目录
│
└── papers/
    └── YYYY/
        └── paper-name/
            ├── paper.md
            ├── my-judgment.md
            └── questions.md
```

---

## 2. 标准流程

```text
                   新论文
                     │
                     ▼
              00 Screening
                     │
             值不值得读？
                /          \
              No            Yes
              │              │
             结束             ▼
                     01 Background
                             │
                     建立知识坐标系
                             │
                             ▼
                       02 Reading
                             │
                       第一次理解
                             │
                             ▼
                      03 Logic Check
                             │
                       逻辑是否成立？
                             │
                             ▼
                      04 Method Check
                             │
                        方法真的新吗？
                             │
                             ▼
                   05 Experiment Check
                             │
                      实验真的证明了吗？
                             │
                             ▼
                       06 Review
                             │
                       尝试 Reject
                             │
                             ▼
                       07 Defense
                             │
                       尝试反驳 Reviewer
                             │
                             ▼
                      08 Synthesis
                             │
                   变成自己的知识
                             │
               ┌─────────────┴─────────────┐
               ▼                           ▼
        knowledge.md                 questions.md
               │                           │
               └─────────────┬─────────────┘
                             ▼
                       Research Ideas
```

---

## 3. 三条硬规则

**第一，不要让 AI 的第一个动作就是总结。**

```text
Human Knowledge → Current State → Paper        ✅
Paper → AI Summary → 相信 AI                    ❌
```

**第二，每篇论文必须留下一个 `My Judgment`。**

否则你保存的只是「这篇论文讲了什么」，而不是「我认为这篇论文到底贡献了什么」。

**第三，每读完一篇论文，至少产生一个 `Open Question`。**

---

## 4. 三档使用强度（防止变成"维护 Markdown"）

| 档位 | 适用 | 执行流程 |
| --- | --- | --- |
| **C** | 普通论文 | Screening → Reading → Synthesis |
| **B** | 重要论文 | Screening → Background → Reading → Logic → Experiment → Synthesis |
| **A** | 核心论文 / 导师要求 / 准备复现 | 全流程 + Review + Defense + Reproduction + Research Ideas |

---

## 5. 怎么用

> 只想看「话怎么说」→ 直接读 [HOWTO.md](HOWTO.md)，里面有九阶段可复制话术。

### 5.1 新建一篇论文

```powershell
cd research
.\tools\new-paper.ps1 -Name "rag-hallucination-survey"
# 或指定年份
.\tools\new-paper.ps1 -Name "xxx" -Year 2025
```

生成 `papers/<year>/<name>/{paper.md,my-judgment.md,questions.md}`。

### 5.2 和 AI 对话时怎么给上下文

每个 prompt 里有 `{{PROFILE}}` / `{{KNOWLEDGE}}` / `{{PAPER}}` 占位符。两种给法：

- **贴内容**：把 `profile.md`、`knowledge.md` 的正文粘进去（最可靠）
- **给路径**：告诉 AI「先读 `research/profile.md` 和 `research/knowledge.md`，再读 `papers/2026/xxx/paper.md`」

建议顺序永远是：

```text
profile.md → knowledge.md → 目标论文
```

### 5.3 一次对话只做一个阶段

```text
Screening ≠ Reading
Reading   ≠ Reviewing
Reviewing ≠ Research Ideation
```

不要在一个 prompt 里既让它总结、又让它批判、又让它提 idea。阶段输出分别写回 `paper.md` 的对应章节。

### 5.4 读完之后必须回写

| 文件 | 何时更新 |
| --- | --- |
| `papers/.../paper.md` | 每完成一个阶段，写回对应章节 |
| `papers/.../my-judgment.md` | 08 Synthesis 之后 |
| `papers/.../questions.md` | 每篇至少 1 条 |
| `profile.md` §4 §5 §6 §7 | 每读 3~5 篇，或知识/信念发生改变时 |
| `knowledge.md` §9 §10 §11 | 有新知识 / 有冲突 / 有推翻时 |
| `questions.md` | 有新的未解问题，或旧问题被refine |

---

## 6. 终点

```text
100 papers
     ↓
Knowledge Graph
     ↓
30 important ideas
     ↓
15 unresolved questions
     ↓
5 potential research directions
```
