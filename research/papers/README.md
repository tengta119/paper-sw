# papers/

每篇论文一个目录：

```text
papers/YYYY/paper-name/
├── paper.md          ← 全流程记录（模板 templates/paper.md）
├── my-judgment.md    ← 我的最终判断（模板 templates/my-judgment.md）
└── questions.md      ← 这篇论文产生的未解问题（模板 templates/questions.md）
```

## 命名约定

- 年份目录：论文**发表年份**（不是阅读年份）
- `paper-name`：小写、连字符分隔、能一眼认出的短名

```text
papers/2026/rag-hallucination-survey/
papers/2026/agent-memory-benchmark/
papers/2025/long-context-attention/
```

## 可选：文件名前缀标注档位

如果同时读很多论文，可在目录名前加档位：

```text
papers/2026/A-xxx/   ← 核心论文，全流程
papers/2026/B-xxx/   ← 重要论文
papers/2026/C-xxx/   ← 普通论文
```

## 新建

```powershell
cd research
.\tools\new-paper.ps1 -Name "rag-hallucination-survey"
```
