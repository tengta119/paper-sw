# Research Knowledge Base (Simplified)

> 最后更新：2026-10-02

---

## 1. Core Concepts I Understand

### 正常训练集内部多样性（FRAD/FPAD：作者提出的标签）

**定义**: 正常训练集可能包含多个产品类别、视角或同类多种外观；MiniMaxAD 称高多样性为 FRAD、低多样性为 FPAD（论文 §1）。这是论文的归类假说，尚无可复用的数值阈值；多类混合与单类外观变化未必等价。

**为什么重要**: 在论文所测 GoodsAD/统一 VisA 场景，改表示与改损失的结果相对 RD 有提升（表 3、5）；提示训练目标可能需考虑正常变化，而不是只看缺陷种类。

**局限性**: 缺少独立可计算的 FRAD 判别标准；表 5 的跨场景差异不证明多样性是增益的原因。未运行独立复现。

**相关论文**: [MiniMaxAD（arXiv v4，§1、表 5）](https://arxiv.org/html/2405.09933v4)；UniAD（统一多类背景，来源为本地 `background-cache.md` S05，未在本阶段重验）。

---

## 2. Important Methods

### MiniMaxAD：RD 特征重建 + 大核/GRN + ADCLoss

**解决什么问题**: 在 normal-only 的多类或多外观图像中兼顾正常区域重建与批量推理成本；限于所测协议（论文 §1、§4）。

**核心思想**: 冻结预训练 encoder，瓶颈和 decoder 重建多尺度特征，以逐位置余弦差构建异常图；FRAD 用分位数/方差选困难位置的 ADCLoss，FPAD 用全局余弦损失（§3.1–3.4，式 1–8）。大核及 GRN 是既有模块在 RD 中的组合，并非论文首创。

**优势/劣势**: GoodsAD 图像 AUROC 论文报告 RD+global 66.5、新架构+global 77.5、新架构+ADC 86.1（表 5）；RTX 4090、batch 16、256² 报 906 FPS（表 7）。但统一 Real-IAD 图像 AUROC 85.1 < MambaAD 86.3，GoodsAD 像素 AP 43.9 < PatchCore 49.4（表 3）；没有原分辨率/低 FPR/固定阈值的部署证明；机制未被隔离，同预训练公平性不确定。

**代表论文**: [MiniMaxAD（2024 arXiv 首发；所读 v4 为 2025）](https://arxiv.org/html/2405.09933v4)，表 3/5/7、附录 A/B。

---

## 3. Known Research Gaps

### Gap 001（待验证，不预设“当前最佳”）

**问题**: 能否只用正常训练样本测量外观多样性，并据此可靠选择全局损失或困难位置挖掘？

**当前最佳方案**: 未确立；MiniMaxAD 根据作者人工划分的 FRAD/FPAD 分别选择 ADC/global（§1、§3.4），不能称为已验证最优方案。

**为什么不够**: 表 5 有正反例，但未控制 backbone、样本量和训练预算来辨认多样性对收益的因果效应；目前**不确定**是否可无标签自动选择。

**重要性**: Medium（若研究方向转向多类 normal-only IAD）；来源：MiniMaxAD 表 5 + 本次推断；验证设计见 `questions.md` Q001。

---

## 4. Timeline

| Year | Work | Contribution |
|------|------|--------------|
| 2024/2025 | MiniMaxAD（arXiv 首发/期刊年份） | RD 与大核/GRN/ADCLoss 的任务化组合；高正常外观多样性假说，证据限于表 3–7 的协议。 |

---

## 5. My Current Mental Model

```text
正常样本外观变化大（作者称 FRAD；未定量）
  ↓
RD 特征重建可能误报正常难例 → MiniMaxAD 更换表示并挖掘难例
  ↓
表 5 显示部分协议增益，但表示/容量/损失机制未完全隔离
  ↓
控制 backbone、样本量和多样性，测固定阈值及低 FPR 表现（待验证）
```
来源：MiniMaxAD §1、§3、表 3/5；最后一步为研究建议，不是实验事实。

---

## 6. Controversial Questions

### 正常集“特征多样性”是否足以决定最优损失？

**Position A**: MiniMaxAD 认为高多样性场景适合 ADCLoss、低多样性更适合全局损失（§3.4、表 5）。

**Position B**: 差异也可能来自 backbone、数据量、训练预算或缺陷类型；FRAD/FPAD 未量化，尚未做控制实验（本次推断）。

**我的判断**: 表 5 对所列数据集有支持但不足以确定因果或泛化；保持未决，见 `questions.md` Q001。

---

## 7. Important Negative Results

### ADCLoss 对 FPAD 并非必然改进（论文报告；不是独立复现）

**方法**: 同一新架构比较全局损失与 ADCLoss 的图像 AUROC（表 5）。

**预期结果**: 若认为自适应难例挖掘普遍有益，应在 FPAD 也改善；这是检验假设，不是作者承诺。

**实际结果**: AeBAD-S 从 87.4 降至 83.9，单类 VisA 从 96.1 降至 95.6；数值依论文所用协议，未核验方差。

**论文**: [MiniMaxAD，表 5](https://arxiv.org/html/2405.09933v4)。

---

## 8. Recent Updates

### 2026-10-02

从 [MiniMaxAD，arXiv v4](https://arxiv.org/html/2405.09933v4) 的 §1、§3、表 3/5/7 与附录 A/B 学到（仅论文所报，无独立复现）：

**新增**: FRAD/FPAD 可作为讨论正常集复杂性的待验证标签；ADC 在 GoodsAD 表内相较全局损失有增益，效果受数据设置限制。

**修正**: 此知识库之前是空模板，**没有**可确认为既有个人观点并被推翻的内容；记录方法论警示：较少参数、较大特征方差或较高 AUROC 不直接证明 identical shortcut 得到解决（§3.3、表 6；本次推断）。

**冲突**: 作者“全面优越”的叙述与统一 Real-IAD 图像 AUROC、GoodsAD 像素 AP 的表 3 数字不完全一致；这属于**论文内部主张与表格的边界冲突**，不是个人既有知识冲突。关联 `questions.md` Q001；本地 `background-cache.md` 未修正。
