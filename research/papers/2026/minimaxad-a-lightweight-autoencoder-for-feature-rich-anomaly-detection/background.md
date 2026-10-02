# 工业图像异常检测：独立背景快照

## 0. 元信息

- **版本**：2026-10-02-r1
- **建立日期**：2026-10-02
- **状态**：已核实的初始快照（用户提供；本次仅归档，未重新核验来源）
- **中性研究主题**：工业图像异常检测（Industrial Image / Visual Anomaly Detection, IAD / VAD）
- **调查视角**：当前阅读价值
- **资料截止日期**：2026-10-02
- **主题边界**：
  - 核心关注二维工业视觉中的异常检测、图像级判别与像素级异常定位。
  - 重点关注“异常样本稀缺、正常样本较容易获得”的场景。
  - 包括 normal-only、fully-unsupervised、few-shot、zero-shot、multi-class/general anomaly detection、logical anomaly detection。
  - 3D、点云、X-Ray、视频异常检测和已知缺陷类别的传统监督式 defect detection 不作为主体，只在方法演化有直接关系时提及。
- **上下文隔离检查**：本任务未提供目标论文标题、摘要、正文或阅读笔记；未发现需要排除的目标论文。
- **缓存复用情况**：用户提供的缓存为调查模板和方法论规则，没有可直接复用的领域事实，因此本版事实均重新检索。
- **主要检索来源**：
  - CVPR / ICCV / ECCV / WACV / NeurIPS / ICLR / AAAI / IJCV 等原始论文；
  - MVTec 等数据集官方页面；
  - 2025 年综述仅用于检查分类完整性，不用其替代原论文证据。
- **主要限制**：
  - 不能把不同监督设置、不同 backbone、分辨率和辅助训练数据下的 benchmark 数字直接横向比较。
  - 2026 年新方法发表时间较短，跨团队复现和长期工业验证仍有限。
  - “当前阅读价值”指理解问题演化和后续研究的价值，并不等同于当前 leaderboard 排名。

---

# 1. 当前领域的核心任务

工业异常检测最经典的设置是：

> 给定大量正常产品图像，而没有或几乎没有真实缺陷图像，学习“正常状态”，部署时发现偏离正常状态的样本或区域。

MVTec AD 在 2019 年把这种 normal-only 工业检测设置系统化：包含 15 个物体/纹理类别、5000 余张高分辨率图像和像素级缺陷标注。

截至 2026 年，这个定义已经扩展成至少以下几种不同问题。

| 设置 | 训练时数据 | 测试目标 | 当前意义 |
|---|---|---|---|
| One-class / Normal-only UAD | 某类别正常图像 | 未知结构异常 | 经典设置 |
| Fully Unsupervised IAD | 未清洗、可能混有异常的数据 | 从污染数据中学习正常性 | 更接近真实产线 |
| Multi-class / Unified AD | 多个产品类别正常样本 | 一个模型服务多个产品 | 降低模型维护成本 |
| Few-shot IAD | 1/2/4 等少量正常样本 | 新产品快速上线 | 当前活跃方向 |
| Zero-shot AD | 目标类别无训练图像 | 未见类别异常 | Foundation Model 重要应用 |
| Logical AD | 正常局部组件本身可能都正常 | 缺件、多件、顺序/位置错误 | 要求全局关系理解 |
| Multi-view IAD | 一个产品多个拍摄视角 | 样本级综合判断 | 更接近真实检测设备 |
| General AD / anomaly reasoning | 多领域辅助数据或 Foundation Model | 新类别检测、定位甚至解释 | 2025–2026 前沿方向 |

Real-IAD 特别提出 Fully Unsupervised IAD：作者认为真实产线中可以利用“良率通常高于 60%”这一事实，而不必假定训练集已经被人工清洗为完全正常。

---

# 2. 实际工业约束

## 2.1 异常样本稀缺

异常本身属于长尾事件，而且不同产品可能出现完全不同的异常，因此长期以来 normal-only learning 是 IAD 的基本出发点。PatchCore、Reverse Distillation、DRAEM 等均建立在这一约束上。

---

## 2.2 “正常”本身不是固定分布

真实工业环境中的正常样本可能因为以下因素产生很大变化：

- 光照及曝光变化；
- 反光；
- 姿态变化；
- 表面纹理变化；
- 正常制造公差；
- 相机或生产环境漂移。

MVTec AD 2 专门设置了未在训练阶段出现的光照条件，并设计 `TEST_priv,mix` 测试这种 distribution shift。所有类别至少包含四种光照条件。

2026 年 PTAD、PGBL 等工作仍把 pose、texture、illumination 引起的正常类内部变化作为主要问题，说明这一问题并未因早期 MVTec AD 的高 AUROC 而消失。

---

## 2.3 缺陷可能极小

真实检测经常处理数百万像素图像中的微小划痕、孔洞和污染。

MVTec AD 2 的实验显示，把高分辨率图像统一缩放到常见的 `256×256` 后，一些细小低对比缺陷可能直接损失；提高输入分辨率可以明显改善定位，但计算时间和显存可能增加一个数量级以上。

因此：

> **分辨率、检测精度与实时性能之间的冲突是实际研究问题，而不是单纯工程实现细节。**

---

## 2.4 局部异常并不是全部问题

传统 anomaly map 很擅长：

- 划痕；
- 裂纹；
- 污渍；
- 凹陷；
- 破损。

但“部件少了一个”“合法部件放错位置”“数量不对”等异常，仅看局部纹理可能完全正常。

MVTec LOCO AD 因此将异常明确分成 structural anomaly 与 logical anomaly。

---

## 2.5 实时性和硬件成本不可忽略

EfficientAD 把工业部署时延直接作为核心研究目标，作者报告约 2 ms latency、约 600 images/s 的实验结果。

MVTec AD 2 进一步把：

- inference latency；
- GPU memory；
- resolution scaling；

作为 benchmark 的正式组成部分。

---

# 3. 评价指标

## 3.1 图像级检测

常见：

- Image AUROC
- Image AUPR
- F1
- Precision / Recall

AUROC 适合描述不同 threshold 下整体排序能力，但不能回答：

> 真正部署一个固定 threshold 后会误报多少？

---

## 3.2 像素级定位

常见：

- Pixel AUROC
- Pixel AUPR
- PRO / AU-PRO

MVTec AD 2 明确指出 Pixel AUROC 中，大缺陷会在像素数量上占据较大权重，可能高估模型发现多个小缺陷的能力；PRO 则对每个异常区域等权。

传统 MVTec AD 常使用：

`AU-PRO_0.30`

即允许 false-positive rate 积分到 30%。

MVTec AD 2 将主要指标收紧到：

`AU-PRO_0.05`

因为在数百万像素图像中，即使 5% FPR，对极小缺陷而言也已经意味着巨量误检像素。

---

## 3.3 阈值相关指标

工业部署最终需要：

```text
anomaly score
      ↓
threshold
      ↓
GOOD / REJECT
```

MVTec AD 2 的结果特别显示：

> threshold-independent metric 较高，并不意味着使用正常验证集确定 threshold 后仍具有良好的 F1。

因此 anomaly detector 与 threshold calibration 不宜被视为完全独立的问题。

---

# 4. 主要方法路线

| 路线 | 代表方法 | 适用条件 | 优势 | 主要局限 |
|---|---|---|---|---|
| 预训练特征 + 统计建模 | PaDiM、SubspaceAD | normal-only / few-shot | 简单、可解释、训练成本低 | 强依赖 backbone representation |
| Memory Bank / Nearest Neighbor | SPADE、PatchCore | normal-only / few-shot | 保留正常局部实例信息，定位能力强 | memory、检索成本及正常变化敏感 |
| Normalizing Flow | FastFlow、CFLOW-AD | normal-only | 显式建模 feature density | 实际增益依赖 backbone 和数据分布 |
| Teacher–Student / Distillation | RD、EfficientAD | normal-only | anomaly discrepancy 自然形成异常分数 | teacher 表示与 domain shift 影响大 |
| Reconstruction | AE 类、UniAD、DiAD | normal-only / multi-class | 可通过 reconstruction residual 表示异常 | 容易把异常也重建出来 |
| Synthetic Anomaly + Discriminator | DRAEM、SimpleNet、RealNet、PGBL | 无真实或少量真实异常 | 可以直接学习异常边界 | synthetic anomaly realism 是关键 |
| VLM / CLIP | WinCLIP、AnomalyCLIP、AdaCLIP、AA-CLIP | zero-/few-shot | 跨类别能力强 | CLIP 本身偏语义而非微小异常 |
| VFM | DINOv2/RADIO + SubspaceAD、AnomalyVFM | few-/zero-shot | 强视觉表征、无需依赖文本 | representation adaptation 仍未定型 |
| Retrieval / Prototype | PatchCore、FastRef、RAID | few/full shot | 与正常 reference 对比直观 | reference coverage 和检索噪声问题 |
| Logical / Reasoning | EfficientAD、LogicAD、ADSeeker | relational anomaly | 能发现局部正常但全局错误的问题 | 推理可靠性与细粒度定位仍需验证 |
| Anomaly Generation | DRAEM、RealNet、O2MAG、MIRAGE | 缺陷数据极少 | 可用于监督 detector 数据增强 | 生成异常是否代表真实 defect distribution |

---

# 5. 方法演化及当前阅读价值

## 5.1 第一阶段：学习“正常特征空间”

### PaDiM

PaDiM 使用预训练 CNN patch embedding，并为每个空间位置建立多元高斯正常分布。

它现在的价值主要不在 leaderboard，而在帮助理解：

```text
normal images
    ↓
pretrained representation
    ↓
estimate normal distribution
    ↓
distance from normal
    ↓
anomaly score
```

这是之后大量方法的基本思想。

---

### PatchCore

PatchCore 是当前仍非常值得读的经典工作。

核心不是复杂训练，而是：

```text
pretrained CNN
    ↓
mid-level patch features
    ↓
normal patch memory bank
    ↓
coreset compression
    ↓
nearest-neighbor distance
```

作者强调使用 mid-level feature、局部上下文以及 coreset 来保留正常样本信息同时控制 memory/inference cost。

即使到 2026 年，FastRef、RAID 等论文仍把 prototype/reference retrieval 作为基本建模单元。

**当前阅读价值：高。**

但重点应该读其建模思想，而不是记住 MVTec AD 上的 99.x AUROC。

---

# 6. 第二阶段：学习“异常边界”

## DRAEM

DRAEM 通过人为合成 anomaly：

```text
normal image
     ↓
synthetic defect
     ↓
reconstruction network
     +
discriminative segmentation network
```

将 anomaly detection 从单纯 reconstruction 转化为 discriminative learning。

这开启了一个长期存在的研究方向：

> 如果真实 anomaly 不存在，能否制造“足够像异常”的数据？

---

## SimpleNet

SimpleNet 更进一步，在 feature space 中加入 Gaussian noise 构造 anomaly feature，再训练 binary discriminator。

它的重要意义不是具体的 Gaussian noise，而是说明：

> anomaly synthesis 不一定必须发生在 pixel space。

---

## RealNet → 2026 anomaly generation

RealNet 使用 diffusion-based anomaly synthesis，希望得到更真实、强度可控的异常，并结合 feature selection。

2026 年 O2MAG 又进一步研究：

> 只有一个真实 anomaly reference 时，如何通过 diffusion 合成更多高保真异常。

因此 anomaly synthesis 到 2026 年依然是活跃方向，而不是 DRAEM 时代已经解决的问题。

---

# 7. 第三阶段：单模型服务多个产品

传统方法通常：

```text
bottle → model A
cable  → model B
screw  → model C
```

这在工厂维护大量 SKU 时成本很高。

UniAD 在 2022 年明确研究 unified multi-class anomaly detection，一个模型同时学习 MVTec AD 15 类。其核心问题之一是 reconstruction network 的 **identical shortcut**：模型可能把 anomaly 也很好地恢复出来。

这一工作当前仍适合用来理解：

- single-class → multi-class 为什么不是简单的数据合并；
- reconstruction information leakage；
- shared anomaly detector 的基本困难。

---

# 8. 第四阶段：从“每个产品训练模型”走向 zero/few-shot

## WinCLIP

WinCLIP 是 CLIP 进入工业 anomaly detection 的关键代表。

它通过窗口级 CLIP feature 与 normal / abnormal text prompts，在无需目标任务训练或只有极少 normal example 的情况下进行检测。

其当前阅读价值主要是理解：

> 如何第一次把视觉语言模型的 zero-shot 能力转化成 anomaly map。

---

## AnomalyCLIP

AnomalyCLIP 提出的关键观察更值得保留：

CLIP 原本主要学习：

```text
“What object is this?”
```

而 anomaly detection 要解决：

```text
“Is this object normal?”
```

因此 object semantic 与 normal/abnormal semantic 并不是一回事。

AnomalyCLIP 使用 object-agnostic prompts 学习一般性的 normality / abnormality，并在 17 个工业和医疗 anomaly dataset 上进行跨类别实验。

这仍是理解 CLIP-based AD 的关键论文之一。

---

## 后续趋势

AdaCLIP 使用 static + image-conditioned dynamic prompts。

AA-CLIP 进一步尝试让 CLIP 的 text 和 visual representation 都变得 anomaly-aware。

2026 年 FB-CLIP、DLVP-CLIP 等又继续处理：

- foreground/background entanglement；
- CLIP 对局部微小异常感知不足；

说明 CLIP-based anomaly detection 的主要困难已经从：

> “CLIP 能不能做 anomaly detection？”

变成：

> “如何让为全局语义预训练的模型感知工业场景的细粒度局部异常？”

---

# 9. Vision Foundation Model 正在改变问题

这是截至 2026-10-02 很值得关注的变化。

## SubspaceAD

SubspaceAD 使用：

```text
normal images
    ↓
frozen DINOv2
    ↓
patch features
    ↓
PCA normal subspace
    ↓
reconstruction residual
```

不训练 detector，不使用 prompt tuning，也不需要 memory bank。

作者报告这种非常简单的 PCA 方法在 one-/few-shot MVTec AD、VisA 上可以达到很强的表现。

这一结果提出了一个重要研究问题：

> 很多过去归因于 anomaly architecture 的性能，究竟有多少其实来自 representation？

因此从当前阅读价值看，2026 年以后研究 anomaly detection，不能只关注 detector architecture，也必须关注 backbone / foundation representation。

---

## AnomalyVFM

AnomalyVFM 则从另一方向证明 purely visual foundation models 也可以被适配为 zero-shot anomaly detector。

其核心包括：

- synthetic auxiliary anomaly data；
- parameter-efficient feature adaptation；
- VFM backbone。

作者在 9 个数据集上进行了跨数据集评估。

因此截至 2026 年：

```text
CNN pretrained feature
        ↓
Vision Foundation Model
        ↓
representation + lightweight adaptation
```

已经成为一条明确路线。

---

# 10. Benchmark 本身已经发生变化

## MVTec AD：仍然重要，但不再足够

MVTec AD 是理解该领域最重要的历史 benchmark。

但 MVTec AD 2 的作者明确指出：

> 现有 MVTec AD / VisA 上的 segmentation performance 已出现饱和，部分方法之间差距不足一个百分点。

因此 2026 年继续只报告：

```text
MVTec AD AUROC = 99.x%
```

不足以证明方法已经解决真实工业 anomaly detection。

---

## VisA

VisA 包含 10,821 张图像和 12 个 object categories，包括 PCB、多实例场景及位置变化，比早期 MVTec AD 增加了复杂结构和实例布局。

它仍然适合用于跨 benchmark 验证。

---

## MVTec LOCO AD

MVTec LOCO AD 的当前阅读价值在于：

> 它改变了 anomaly 的定义。

异常不再只是 abnormal texture：

```text
scratch / dent / contamination
```

也可能是：

```text
missing component
extra component
wrong location
wrong combination
```

---

## Real-IAD

Real-IAD 包含约 150K 高分辨率图像、30 种物体，并引入：

- multi-view；
- sample-level evaluation；
- Fully Unsupervised IAD。

它的意义主要不是“更大的 MVTec”，而是尝试改变数据采集和训练假设。

---

## MVTec AD 2

截至资料截止日期，MVTec AD 2 是理解“经典方法距离真实工业约束还有多远”非常重要的 benchmark。

它加入：

- 8 种工业场景；
- 8000+ 高分辨率图像；
- 2.6–5 MP 图像；
- 极小缺陷；
- high normal variance；
- transparent / overlapping objects；
- dark-field illumination；
- backlight illumination；
- unseen lighting distribution shift；
- private test set。

更值得注意的是实验结果：

在 `TEST_priv` 上，所测试方法的 `AU-PRO_0.05` **全部低于 32%**。

这与 MVTec AD 上接近 99% 的 AUROC 形成明显反差。

---

# 11. 关键判断

## B001：经典 MVTec AD 已不适合作为单独判断新方法价值的依据

- **类型**：多来源支持的判断
- **适用范围**：2026 年工业图像 anomaly detection 方法比较
- **支持证据**：
  - MVTec AD 2 指出现有 MVTec AD / VisA segmentation benchmark 已出现饱和，方法差距往往小于一个百分点。
  - Real-IAD 同样指出主流 benchmark 上许多方法的 AUROC 已超过 99%，难以进一步区分方法。
- **反例/限定**：
  - MVTec AD 仍是算法 sanity check、历史比较和复现的重要 benchmark。
- **当前把握**：较充分
- **待验证**：
  - 不同研究社区是否已普遍转向 MVTec AD 2 / Real-IAD，尚不能据当前检索断言。

---

## B002：PatchCore 仍具有很高阅读价值，但价值主要来自范式而非当前 benchmark 数字

- **类型**：多来源支持 + 当前阅读价值判断
- **适用范围**：normal-only、few-shot anomaly detection
- **支持证据**：
  - PatchCore 系统化使用 pretrained mid-level patch features、memory bank 和 coreset。
  - 2026 年 FastRef、RAID 等仍继续围绕 prototype / retrieval 解决 few-shot 和 normal-reference matching。
- **反例/限定**：
  - MVTec AD 2 表明 PatchCore 在高分辨率、distribution shift 和实际 threshold 下仍存在显著限制。
- **当前把握**：较充分
- **待验证**：foundation feature + NN 是否会进一步取代复杂 memory-bank 设计。

---

## B003：Synthetic anomaly 的主要问题已经从“是否有用”转向“生成分布是否真实”

- **类型**：多来源支持的判断
- **适用范围**：异常样本稀缺场景
- **支持证据**：
  - DRAEM 使用 synthetic anomaly 进行 discriminative reconstruction learning。
  - SimpleNet 将 anomaly synthesis 转到 feature space。
  - RealNet 使用 diffusion 生成更真实和可控的 anomaly。
  - 2026 O2MAG 继续把“生成异常与真实异常分布的一致性”作为核心问题。
- **反例/限定**：
  - synthetic anomaly 与真正未知 defect 是否同分布通常无法提前保证。
- **当前把握**：较充分
- **待验证**：
  - 合成异常质量与真实 downstream detection improvement 是否存在可靠、统一的评价标准。

---

## B004：Logical anomaly 是与表面 defect 不同的建模问题

- **类型**：来源报告 + 多来源支持
- **适用范围**：assembly / component / counting / positional inspection
- **支持证据**：
  - MVTec LOCO AD 明确将 structural 与 logical anomaly 分开。
  - EfficientAD 为 logical anomaly 增加 global autoencoder branch。
  - LogicAD 使用 VLM + logic reasoner 专门处理 logical AD。
- **反例/限定**：
  - 某些 global visual encoder 也可能隐式编码关系信息，并不意味着 logical anomaly 必须依赖语言模型。
- **当前把握**：较充分
- **待验证**：
  - MLLM / VLM 是否在复杂工业 logical AD 中比专用视觉模型更稳定。

---

## B005：Few-shot、zero-shot 与 conventional normal-only IAD 是不同任务，数字不可直接混用

- **类型**：多来源支持的判断
- **适用范围**：benchmark comparison
- **支持证据**：
  - PatchCore 使用目标类别 normal training images。
  - WinCLIP 明确区分 zero-shot 与 few-normal-shot。
  - AnomalyCLIP 的 zero-shot 定义允许使用 auxiliary anomaly datasets，但目标数据不可用。
  - SubspaceAD 则使用少量目标 normal image。
- **反例/限定**：无。
- **当前把握**：较充分
- **待验证**：
  - 不同论文对 auxiliary data / pretraining leakage 的声明是否完全统一。

---

## B006：Foundation representation 正在成为决定 anomaly performance 的核心变量

- **类型**：多来源支持 + 推断
- **适用范围**：few-/zero-shot IAD
- **支持证据**：
  - SubspaceAD 使用 frozen DINOv2 + PCA 即取得强 few-shot 结果。
  - 作者的 backbone scale ablation 显示更强 DINOv2 feature 会明显改善结果。
  - AnomalyVFM 研究如何把 VFM 直接适配为 zero-shot detector。
- **反例/限定**：
  - 当前结果仍主要来自有限数量 benchmark。
  - 强 backbone 可能增加推理成本。
- **当前把握**：初步至较充分
- **待验证**：
  - 在 MVTec AD 2、真实长期 domain shift 和 edge deployment 中这种结论是否仍成立。

---

## B007：当前更有价值的问题不是继续压 MVTec AD 的最后 0.x%，而是 robustness、few-shot、generalization 和 deployment

- **类型**：综合推断
- **适用范围**：2026 年研究选题
- **支持证据**：
  - MVTec AD 2 暴露 lighting shift、高分辨率和 tiny defect 问题。
  - Real-IAD 研究 multi-view 和 fully-unsupervised setting。
  - 2026 FastRef、SubspaceAD 聚焦 few-shot。
  - 2026 AnomalyVFM 聚焦 zero-shot generalization。
- **反例/限定**：
  - 对特定工业产品，专用 single-class detector 仍可能是最佳工程方案。
- **当前把握**：较充分
- **待验证**：不同制造行业对这些问题的优先级不同。

---

## B008：仅报告 AUROC 已不足以判断工业部署价值

- **类型**：来源报告 + 多来源支持
- **适用范围**：实际 anomaly detection deployment
- **支持证据**：
  - MVTec AD 2 使用 AU-PRO 并将积分 FPR 从常见 0.30 收紧至 0.05。
  - threshold-independent score 与实际 threshold F1 可能不一致。
  - runtime 和 memory 被正式纳入 benchmark。
- **反例/限定**：
  - AUROC 仍然适合算法早期开发和 threshold-independent comparison。
- **当前把握**：较充分
- **待验证**：
  - 工业界是否会形成统一的 cost-sensitive / false reject / false accept benchmark。

---

## B009：工业 anomaly detection 正开始从“检测”向“检测 + reasoning”延伸，但这一方向仍处于早期阶段

- **类型**：多来源支持 + 推断
- **适用范围**：2025–2026 general / logical anomaly detection
- **支持证据**：
  - LogicAD 使用 VLM text feature 和 logic reasoning。
  - ADSeeker 研究 industry anomaly detection + reasoning，并构建 MulA 数据集。
  - MMR-AD 将 MLLM general anomaly detection 作为单独 benchmark。
- **反例/限定**：
  - reasoning accuracy 与高质量 pixel segmentation 是不同能力。
  - MLLM 是否能满足工业稳定性、时延和 hallucination 要求，目前证据不足。
- **当前把握**：趋势本身较充分；工业成熟度未确认
- **待验证**：
  - reasoning 能否真正降低人工复检成本；
  - hallucination、calibration 与 traceability。

---

# 12. 当前阅读路线

如果目的是进入该方向做研究，而不是复现全部历史论文，建议按问题演化阅读。

## A. 基础范式

### 1. MVTec AD — Bergmann et al., CVPR 2019

理解：

- industrial normal-only setting；
- detection vs localization；
- benchmark protocol。

---

### 2. PaDiM — Defard et al., ICPR 2021

理解：

- pretrained patch representation；
- normal distribution modeling。

---

### 3. PatchCore — Roth et al., CVPR 2022

重点理解：

- patch memory；
- mid-level representation；
- nearest-neighbor anomaly score；
- coreset。

这是 embedding / memory-bank 路线的核心代表。

---

## B. 学习 abnormal boundary

### 4. DRAEM — ICCV 2021

理解：

- synthetic anomaly；
- reconstruction + discrimination。

### 5. SimpleNet — CVPR 2023

理解：

- feature-space synthetic anomaly；
- discriminator。

---

## C. Reconstruction / Distillation

### 6. Reverse Distillation — CVPR 2022

理解：

- teacher/student discrepancy；
- normal bottleneck；
- multi-scale reconstruction。

### 7. EfficientAD — WACV 2024

重点理解：

- distillation；
- latency；
- logical anomaly；
- global/local information。

当前阅读价值仍然较高。

---

## D. Unified IAD

### 8. UniAD — NeurIPS 2022

重点理解：

- multi-class anomaly detection；
- identical shortcut；
- information leakage。

---

## E. Zero-shot / Foundation Model

### 9. WinCLIP — CVPR 2023

作为 VLM anomaly detection 起点。

### 10. AnomalyCLIP — ICLR 2024

重点理解：

- object semantic ≠ anomaly semantic；
- object-agnostic prompt。

### 11. AA-CLIP — CVPR 2025

观察 CLIP 从 prompt adaptation 向 anomaly-aware representation adaptation 演化。

---

## F. 重新理解 benchmark

### 12. MVTec LOCO AD — IJCV 2022

理解 logical anomaly。

### 13. Real-IAD — CVPR 2024

理解：

- multi-view；
- realistic scale；
- contaminated / fully-unsupervised training。

### 14. MVTec AD 2 — IJCV 2026

**当前非常值得完整阅读。**

它直接涉及：

- benchmark saturation；
- distribution shift；
- high resolution；
- tiny anomaly；
- threshold calibration；
- low-FPR localization；
- latency/memory；
- private benchmark。

它比继续阅读大量 MVTec AD 99.x% 方法更能说明截至 2026 年领域真正剩下的问题。

---

## G. 2026 Foundation Model 方向

### 15. SubspaceAD — CVPR 2026

重点不是 PCA 本身，而是：

> Foundation representation 足够强时，anomaly detector 到底需要多复杂？

### 16. AnomalyVFM — CVPR 2026

关注：

- visual foundation model；
- zero-shot；
- synthetic auxiliary data；
- lightweight adaptation。

### 17. RAID — CVPR 2026

关注：

```text
reference retrieval
    ↓
hierarchical representation
    ↓
noise suppression
    ↓
anomaly localization
```

---

## H. 作为前沿观察，而非已有定论

### ADSeeker / MMR-AD

研究：

- general anomaly detection；
- MLLM；
- anomaly reasoning。

### O2MAG / MIRAGE

研究：

- realistic anomaly generation；
- generative model + VLM；
- synthetic dataset construction。

这两个方向值得跟踪，但目前不宜视作传统 pixel-level IAD 已被替代。

---

# 13. 未解问题、争议与未知

## U001：Benchmark performance 与实际产线性能之间的关系

已有证据表明 MVTec AD performance 已明显饱和，而 MVTec AD 2 中经典方法性能大幅下降。

**未知：**

尚不存在足够公开证据证明某一种 benchmark 能稳定预测不同真实工厂中的长期表现。

---

## U002：Foundation Model 是否真正提高了“异常理解”

目前能够确认：

> foundation feature 能明显提高 representation quality。

但仍不能确认：

> 模型真正获得了与制造语义一致的“正常/异常概念”。

尤其是 tiny defect、unseen process failure 和 logical constraint。

---

## U003：Foundation Model 的数据泄漏问题

CLIP、DINOv2、RADIO 等使用规模很大的预训练数据。

对于公开工业 benchmark：

> 是否存在 benchmark 类似图像或相关视觉知识进入预训练数据？

很多实验难以严格证明完全不存在。

因此 zero-shot 结果需要区分：

```text
target training-free
```

和：

```text
truly unseen visual distribution
```

二者并不完全等价。

---

## U004：Synthetic anomaly 的真实性如何评价

当前很多方法利用 synthetic anomaly。

尚未解决：

```text
生成图像“看起来真实”
        ≠
生成异常具有真实工艺 failure distribution
```

这是生成式 IAD 的核心未解问题之一。

---

## U005：阈值如何在没有异常 validation data 时确定

真实 normal-only setting 中：

```text
train: normal
validation: normal
```

因此无法直接使用异常样本寻找最佳 threshold。

MVTec AD 2 明确显示 threshold determination 会显著影响最终 F1。

这是实际部署中仍未被 leaderboard 充分解决的问题。

---

## U006：跨时间 domain shift

公开 benchmark 主要是有限时间窗口的数据。

真实产线可能出现：

- 镜头老化；
- 光源衰减；
- 设备维护；
- 原材料批次变化；
- 产品版本变化。

长期 continual anomaly detection 的公开证据仍相对不足。

---

## U007：多视角信息应该怎样融合

Real-IAD 已提供 multi-view scenario，但“多个 camera view 是分别检测后 voting，还是联合建模产品状态”仍不存在统一答案。

---

## U008：Reasoning 模型的工业可靠性

MLLM 可以生成：

> “这里缺少一个组件。”

但工业系统还要求：

- 可复现；
- calibration；
- deterministic behavior；
- traceability；
- low latency；
- extremely low miss rate。

目前尚不能确认通用 MLLM reasoning 已满足这些条件。

---

# 14. 来源列表

| 编号 | 来源 | 日期 | 主要支持判断 | 证据位置 |
|---|---|---:|---|---|
| S01 | [MVTec AD — CVPR 2019](https://openaccess.thecvf.com/content_CVPR_2019/html/Bergmann_MVTec_AD_--_A_Comprehensive_Real-World_Dataset_for_Unsupervised_Anomaly_CVPR_2019_paper.html?utm_source=chatgpt.com) | 2019-06 | 经典 normal-only IAD benchmark | Abstract |
| S02 | [DRAEM — ICCV 2021](https://openaccess.thecvf.com/content/ICCV2021/html/Zavrtanik_DRAEM_-_A_Discriminatively_Trained_Reconstruction_Embedding_for_Surface_Anomaly_ICCV_2021_paper.html?utm_source=chatgpt.com) | 2021-10 | synthetic anomaly + discriminative reconstruction | Abstract |
| S03 | [PatchCore — CVPR 2022](https://openaccess.thecvf.com/content/CVPR2022/html/Roth_Towards_Total_Recall_in_Industrial_Anomaly_Detection_CVPR_2022_paper.html?utm_source=chatgpt.com) | 2022-06 | memory bank、mid-level patch、coreset | Abstract / method motivation |
| S04 | [MVTec LOCO AD — IJCV 2022](https://link.springer.com/article/10.1007/s11263-022-01578-9?utm_source=chatgpt.com) | 2022 | structural vs logical anomaly | Dataset / results discussion |
| S05 | [UniAD — NeurIPS 2022](https://proceedings.neurips.cc/paper_files/paper/2022/hash/1d774c112926348c3e25ea47d87c835b-Abstract-Conference.html?utm_source=chatgpt.com) | 2022 | unified multi-class、identical shortcut | Abstract |
| S06 | [WinCLIP — CVPR 2023](https://openaccess.thecvf.com/content/CVPR2023/html/Jeong_WinCLIP_Zero-Few-Shot_Anomaly_Classification_and_Segmentation_CVPR_2023_paper.html?utm_source=chatgpt.com) | 2023-06 | zero/few-shot CLIP anomaly detection | Abstract |
| S07 | [SimpleNet — CVPR 2023](https://openaccess.thecvf.com/content/CVPR2023/html/Liu_SimpleNet_A_Simple_Network_for_Image_Anomaly_Detection_and_Localization_CVPR_2023_paper.html?utm_source=chatgpt.com) | 2023-06 | feature-space anomaly generation | Abstract |
| S08 | [EfficientAD — WACV 2024](https://openaccess.thecvf.com/content/WACV2024/html/Batzner_EfficientAD_Accurate_Visual_Anomaly_Detection_at_Millisecond-Level_Latencies_WACV_2024_paper.html?utm_source=chatgpt.com) | 2024-01 | distillation、logical AD、runtime | Abstract |
| S09 | [AnomalyCLIP — ICLR 2024](https://proceedings.iclr.cc/paper_files/paper/2024/hash/d7b50b8ac2c781a12f26155f48310d8d-Abstract-Conference.html?utm_source=chatgpt.com) | 2024 | object-agnostic anomaly semantics | Abstract |
| S10 | [Real-IAD — CVPR 2024](https://openaccess.thecvf.com/content/CVPR2024/html/Wang_Real-IAD_A_Real-World_Multi-View_Dataset_for_Benchmarking_Versatile_Industrial_Anomaly_CVPR_2024_paper.html?utm_source=chatgpt.com) | 2024-06 | multi-view、150K、FUIAD | Abstract / Sec. 3.1 |
| S11 | [RealNet — CVPR 2024](https://openaccess.thecvf.com/content/CVPR2024/html/Zhang_RealNet_A_Feature_Selection_Network_with_Realistic_Synthetic_Anomaly_for_CVPR_2024_paper.html?utm_source=chatgpt.com) | 2024-06 | diffusion anomaly synthesis | Abstract |
| S12 | [AA-CLIP — CVPR 2025](https://openaccess.thecvf.com/content/CVPR2025/html/Ma_AA-CLIP_Enhancing_Zero-Shot_Anomaly_Detection_via_Anomaly-Aware_CLIP_CVPR_2025_paper.html?utm_source=chatgpt.com) | 2025-06 | anomaly-aware CLIP adaptation | Abstract |
| S13 | [MVTec AD 2 — IJCV 2026](https://link.springer.com/article/10.1007/s11263-026-02743-0?utm_source=chatgpt.com) | 2026-03-09 | benchmark saturation、lighting shift、high-res、metrics | Sec. 3–5、Tables 7–9、Fig. 6 |
| S14 | [SubspaceAD — CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Lendering_SubspaceAD_Training-Free_Few-Shot_Anomaly_Detection_via_Subspace_Modeling_CVPR_2026_paper.html?utm_source=chatgpt.com) | 2026-06 | DINOv2 + PCA few-shot | Abstract / Tables 3–4 / Conclusion |
| S15 | [AnomalyVFM — CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Fucka_AnomalyVFM_--_Transforming_Vision_Foundation_Models_into_Zero-Shot_Anomaly_Detectors_CVPR_2026_paper.html?utm_source=chatgpt.com) | 2026-06 | VFM zero-shot anomaly detection | Abstract |
| S16 | [RAID — CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Cai_RAID_Retrieval-Augmented_Anomaly_Detection_CVPR_2026_paper.html?utm_source=chatgpt.com) | 2026-06 | retrieval-augmented anomaly detection | Abstract |
| S17 | [ADSeeker — CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Zhang_ADSeeker_A_Knowledge-Grounded_Reasoning_Framework_for_Industry_Anomaly_Detection_and_CVPR_2026_paper.html?utm_source=chatgpt.com) | 2026-06 | anomaly detection + reasoning、MulA | Abstract |
| S18 | [One-to-More / O2MAG — CVPR 2026](https://openaccess.thecvf.com/content/CVPR2026/html/Rao_One-to-More_High-Fidelity_Training-Free_Anomaly_Generation_with_Attention_Control_CVPR_2026_paper.html?utm_source=chatgpt.com) | 2026-06 | few-shot high-fidelity anomaly generation | Abstract |

---

# 15. 待验证清单

后续读论文时，优先验证以下问题。

### V001

新方法是否仍主要在 MVTec AD / VisA 上证明性能，而没有：

- Real-IAD；
- MVTec AD 2；
- cross-dataset；
- distribution-shift evaluation。

---

### V002

所谓 zero-shot 是否实际使用了：

- auxiliary industrial anomaly datasets；
- anomaly masks；
- target class descriptions；
- benchmark-related auxiliary information。

需要区分不同 zero-shot protocol。

---

### V003

方法提升究竟来自：

```text
new anomaly algorithm
```

还是：

```text
stronger pretrained backbone
```

需要检查 backbone-controlled ablation。

---

### V004

是否给出了：

- latency；
- GPU memory；
- input resolution；
- parameter count；
- training/inference cost。

没有这些数据时，不应直接推出“适合工业部署”。

---

### V005

是否只报告 AUROC，而没有：

- AUPR；
- PRO；
- low-FPR performance；
- fixed-threshold F1。

---

### V006

threshold 是否使用 test anomaly 进行调优。

若使用，则与严格 normal-only deployment setting 不完全一致。

---

### V007

synthetic anomaly 方法是否验证：

- synthetic → real anomaly transfer；
- defect realism；
- anomaly type diversity；
- 对未模拟 defect 的泛化。

---

### V008

Foundation Model 方法是否控制：

- backbone；
- resolution；
- auxiliary training set；
- model scale。

否则不能确定改进来自 anomaly method 本身。

---

# 16. 当前总体图景

截至 **2026-10-02**，工业图像异常检测可以概括成一次明显的问题迁移：

```text
2019–2021
“如何只用正常图像发现缺陷？”
        │
        ▼
pretrained feature / reconstruction
        │
        ▼
2021–2023
memory bank / distillation /
synthetic anomaly / multi-class
        │
        ▼
2023–2025
CLIP / zero-shot / unified model /
realistic benchmarks
        │
        ▼
2025–2026
Vision Foundation Model
few-shot / generalization
distribution shift
high-resolution tiny defects
retrieval
anomaly generation
reasoning
deployment metrics
```

早期核心问题是：

> **怎样构造一个更强的 anomaly detector？**

现在逐渐变成：

> **在强 Foundation Representation 已经存在的情况下，怎样用极少目标数据可靠地定义 normality，并在高分辨率、分布漂移、逻辑异常和严格低误报要求下工作？**

其中值得特别保留的两个认识是：

1. **MVTec AD 上的接近满分并不意味着工业异常检测已经接近解决。** MVTec AD 2 上主流方法在严格 `AU-PRO_0.05` 下仍低于 32%，而光照变化还能显著进一步降低性能。

2. **模型结构本身可能不再是唯一主角。** 2026 年 SubspaceAD 表明强 DINOv2 patch representation 配合非常简单的 PCA normal-subspace model 就具有很强的 few-shot performance；与此同时，AnomalyVFM、RAID 等工作继续把重点转向 representation、adaptation 与 reference retrieval。

因此，如果下一步要评估一篇具体工业异常检测论文，其创新不应只问：

> “比 PatchCore / SimpleNet 高了多少 AUROC？”

更值得检查的是：

```text
它解决的是哪一种 IAD setting？
           ↓
这个 setting 是否对应真实约束？
           ↓
提升来自新方法还是更强 backbone / 更多 auxiliary data？
           ↓
是否跨 dataset / distribution 验证？
           ↓
是否处理 threshold、false positive、resolution、latency？
           ↓
结论是否仍然建立在已经饱和的 benchmark 上？
```

这套问题可以作为后续目标论文阅读时的独立背景基线。

---

# 演化日志

| 日期 | 原判断 | 修正 | 新证据与原因 |
|---|---|---|---|
| 2026-10-02 | 无领域事实缓存；仅有空模板 | 将用户提供的完整独立背景记录为 2026-10-02-r1 快照 | 来源 S01–S18 与判断 B001–B009 均随用户背景归档；本次未重新调查或核验链接。 |

> 阅读前的 `background.md` 是历史快照；阅读后的修正写入全局 `background-cache.md` 及论文笔记，不覆盖该快照。
