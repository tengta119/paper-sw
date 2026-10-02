# papers/

每篇论文一个目录，由 v2 的工具和模板维护：

```text
papers/发表年份/论文短名/
├── paper.md       # 筛选、阅读、知识沉淀与进度
└── background.md  # 阅读前独立背景快照，调查完成后保存
```

论文短名使用小写英文与连字符。-Year 是发表年份，默认当前年份，往年论文必须显式指定。背景快照保留版本、来源、资料截止日期和适用范围；阅读后的修正写入 v2/background-cache.md，不覆盖快照。

从 research 目录创建：

```powershell
.\v2\tools\new-paper.ps1 -Name "example-paper" -Year 2026 -Title "论文标题"
```

详细流程见 [v2/QUICKSTART.md](../v2/QUICKSTART.md)。v1 旧版可能还有 my-judgment.md 和单篇 questions.md，v2 不要求新增这些文件。
