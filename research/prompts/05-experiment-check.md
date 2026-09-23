# 05 · Experiment Verification Prompt

论文：

{{PAPER}}

请不要总结实验。

请审查实验是否真的支持作者的 Claims。

---

# 1. Claim → Experiment

建立：

| Claim | Experiment | Evidence |
| ----- | ---------- | -------- |
|       |            |          |

---

# 2. Experiment Validity

对每个关键实验回答：

### What Is Being Tested?

### Why This Experiment?

### Is The Baseline Fair?

### Is The Dataset Appropriate?

### Is The Metric Appropriate?

### Could Another Explanation Produce The Same Result?

---

# 3. Ablation

论文是否证明：

> 每个核心设计都真的必要？

如果没有，缺失什么？

---

# 4. Statistical Reliability

检查：

* Sample Size
* Variance
* Multiple Runs
* Significance
* Confidence Interval

---

# 5. Generalization

论文是否从：

```text
Specific Setting
```

推导出了：

```text
General Conclusion
```

如果是，判断是否过度推广。

---

# 6. Cost

除了性能之外：

* Latency
* Memory
* Compute
* Data
* Complexity

是否发生明显变化？

---

# 7. Missing Experiments

如果让我补实验：

1.

2.

3.

---

# 8. Final Judgment

实验对论文核心 claim 的支持程度：

* Strong
* Moderate
* Weak
* Insufficient
