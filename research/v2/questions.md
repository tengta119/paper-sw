# Open Questions

> 最后更新：2026-10-02

---

## Q001 · 正常集多样性与损失选择

**问题**: 仅用正常训练数据测量的外观多样性，能否预测自适应困难位置挖掘（ADCLoss）相对全局重建损失何时更有效？这种关系是否独立于 backbone 表示、样本量及训练预算？

**为什么重要**: 若关系成立且可测，可在没有异常验证样本时选择训练目标；若不成立，FRAD/FPAD 只是事后分类，无法指导部署。

**当前理解**: MiniMaxAD 表 5 的 GoodsAD/统一 VisA 与 AeBAD-S/单类 VisA 方向不同；提示可能有条件效应，**并未建立因果或可泛化判别规则**。§1 对 FRAD 无量化阈值；此处问题是读后的推断，不是已知领域定论。

**如何验证**: 固定预训练 encoder、decoder、类别与训练步数，独立操控正常样本视角/外观变化和样本量；在训练集上定义无需异常标签的多样性指标，比较 global、固定难例挖掘与 ADCLoss；在留出的异常测试集按多个随机种子报告图像 AUROC、像素 AP、低 FPR 指标和正常/异常重建误差，并跨数据集复查。预先固定选择规则，避免测试集选型泄漏。

**相关论文**: [MiniMaxAD](https://arxiv.org/html/2405.09933v4) §1、§3.4、表 5；UniAD 为上下文（本地背景 S05，本阶段未重新核验）。

**来源**: `../papers/2026/minimaxad-a-lightweight-autoencoder-for-feature-rich-anomaly-detection/paper.md` §2–3，2026-10-02。

---

## Answered Questions

暂无。
