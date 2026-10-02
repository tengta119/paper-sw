# 研究生论文阅读系统

> 两个版本可选：**v2 简化版（推荐）** vs **v1 完整版**

---

## 📂 目录结构

```
research/
├── README.md              ← 本文件：版本说明
├── papers/                ← 论文存放目录（两个版本共享）
│
├── v2/                    ← 简化版（推荐）⭐
│   ├── README.md          ← v2 使用说明
│   ├── QUICKSTART.md      ← 10分钟快速上手
│   ├── WHY-SIMPLIFIED.md  ← 为什么简化
│   ├── SIMPLIFICATION-GUIDE.md  ← 完整减法说明
│   ├── profile.md         ← 你的研究背景
│   ├── knowledge.md       ← 知识库
│   ├── questions.md       ← 开放问题
│   ├── prompts/           ← 3个简化prompt
│   ├── templates/         ← 简化模板
│   └── tools/             ← 自动化工具
│
└── v1/                    ← 完整版
    ├── README.md          ← v1 使用说明
    ├── HOWTO.md           ← 详细话术
    ├── profile.md         ← 研究背景（详细版）
    ├── knowledge.md       ← 知识库（详细版）
    ├── questions.md       ← 开放问题（详细版）
    ├── prompts/           ← 9个完整prompt
    ├── templates/         ← 完整模板
    └── tools/             ← 基础工具
```

---

## 🚀 快速选择

### 推荐：v2 简化版 ⭐

**适合你，如果：**
- ✅ 想快速上手，10分钟开始使用
- ✅ 每周需要读3-5篇论文
- ✅ 希望30分钟/篇的效率
- ✅ 想要一个能坚持使用的系统

**特点：**
- 3阶段流程（Screening → Reading → Synthesis）
- 120行简化模板
- 自动化工具支持
- 30分钟/篇

**开始使用：**
```powershell
cd v2
# 阅读 QUICKSTART.md，10分钟上手
```

---

### v1 完整版

**适合你，如果：**
- ✅ 需要极致深度的论文分析
- ✅ 准备复现核心论文
- ✅ 时间充裕，愿意投入3小时/篇
- ✅ 追求系统性、穷尽式的审查

**特点：**
- 9阶段流程（包含Logic/Method/Experiment独立审查）
- 350行完整模板
- 对抗性Review+Defense
- 3小时/篇

**开始使用：**
```powershell
cd v1
# 阅读 README.md 和 HOWTO.md
```

---

## 📊 版本对比

| 项目 | v2 简化版 | v1 完整版 |
|------|-----------|-----------|
| **阶段数** | 3个 | 9个 |
| **单篇时间** | 30分钟 | 3小时 |
| **模板行数** | 120行 | 350行 |
| **学习曲线** | 10分钟 | 1-2天 |
| **自动化工具** | ✅ run-stage.ps1 | 部分手动 |
| **适用场景** | 日常论文阅读 | 深度分析 |
| **推荐指数** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🎯 核心价值（两版本共享）

无论选择哪个版本，核心目标不变：

✅ **批判性思维**：区分 Facts / Claims / Inferences  
✅ **反对AI总结**：用自己的话理解  
✅ **知识沉淀**：持续更新 knowledge.md  
✅ **问题驱动**：每篇论文产生至少1个问题  
✅ **可验证性**：One-Sentence Summary 检验理解  

---

## 💡 使用建议

### 如果你是第一次使用
→ **从 v2 开始**，读 `v2/QUICKSTART.md`

### 如果你不确定选哪个
→ **先用 v2**，不够用再补充 v1 的某些阶段

### 如果你遇到特殊情况
- 核心论文需要复现 → v2 + 手动补充详细分析
- 准备写Survey → v2 标准流程 + v1 Background阶段
- 论文逻辑极其复杂 → v2 + 手动重建逻辑链

### 如果你已经熟悉系统
→ 标准流程用 v2，A类论文混用 v1 部分阶段

---

## 📁 papers/ 目录（共享）

两个版本使用**同一个** `papers/` 目录存放论文。

```
papers/
└── 2024/
    ├── paper-name-1/
    │   └── paper.md      ← 可以用v1或v2模板
    └── paper-name-2/
        └── paper.md
```

**创建论文目录：**
```powershell
# v1 方式
.\v1\tools\new-paper.ps1 -Name "example"

# v2 方式（推荐）
.\v2\tools\new-paper.ps1 -Name "example"
```

---

## 🛠️ 工具对比

### v2 工具（自动化）
```powershell
# 一键执行阶段（自动组装prompt）
.\v2\tools\run-stage.ps1 -Paper "example" -Stage 1

# 查看进度
.\v2\tools\status.ps1
```

### v1 工具（基础）
```powershell
# 创建论文目录
.\v1\tools\new-paper.ps1 -Name "example"

# 查看进度
.\v1\tools\status.ps1

# Prompt需要手动组装（参考HOWTO.md）
```

---

## 📖 推荐阅读路径

### 路径1：快速上手（推荐）
1. `v2/QUICKSTART.md` - 10分钟上手
2. `v2/WHY-SIMPLIFIED.md` - 理解简化原因
3. 开始读第一篇论文

### 路径2：深入理解
1. `v2/QUICKSTART.md` - 先了解简化版
2. `v2/SIMPLIFICATION-GUIDE.md` - 详细对比
3. `v1/README.md` - 完整版说明
4. `v1/HOWTO.md` - 完整版话术

### 路径3：直接用完整版
1. `v1/README.md` - 系统说明
2. `v1/HOWTO.md` - 话术速查
3. 开始第一篇论文

---

## ❓ 常见问题

**Q: 我应该选哪个版本？**  
A: 如果不确定，从 v2 开始。80%的场景下 v2 够用。

**Q: 可以混用两个版本吗？**  
A: 可以。标准流程用 v2，核心论文用 v1 的部分阶段。

**Q: v2 会不会丢失重要信息？**  
A: 核心批判性思维没有丢失。需要更深入分析时，随时在 Notes 部分补充。

**Q: papers/ 目录是共享的吗？**  
A: 是的，两个版本共享 `papers/` 目录。paper.md 可以用 v1 或 v2 模板。

**Q: 如何从 v1 切换到 v2？**  
A: 新论文直接用 v2。旧论文保持原样，或者手动精简到 v2 格式。

**Q: 如何从 v2 升级到 v1？**  
A: 在 v2 的 paper.md 基础上，补充 v1 需要的额外章节即可。

---

## 🚦 立即开始

### 如果你想快速上手
```powershell
cd v2
notepad QUICKSTART.md
```

### 如果你想深度分析
```powershell
cd v1
notepad README.md
notepad HOWTO.md
```

---

## 🎓 记住

> **最好的系统是你真正会用的系统。**

- 完美但用不起来 = 0分
- 简化但能坚持 = 80分  
- 简化 + 按需补充 = 90分

从 v2 开始，先用起来，再根据需要调整。
