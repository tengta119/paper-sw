# 00 · Neutral Topic Extraction（中性主题提取）

## 任务

你负责从论文材料中提取用于独立背景调查的中性研究主题。本步骤只确定调查范围，不分析贡献、不建立领域背景、不判断论文价值。

## 输入

论文标题：MiniMaxAD: A lightweight autoencoder for feature-rich anomaly detection. Computers in Industry

摘要（可选）：Previous industrial anomaly detection methods often struggle to handle the extensive diversity in training sets, particularly when they contain stylistically diverse and feature-rich samples, which we categorize as feature-rich anomaly detection datasets (FRADs). This challenge is evident in applications such as multi-view and multi-class scenarios. To address this challenge, we developed MiniMaxAD, a efficient autoencoder designed to efficiently compress and memorize extensive information from normal images. Our model employs a technique that enhances feature diversity, thereby increasing the effective capacity of the network. It also utilizes large kernel convolution to extract highly abstract patterns, which contribute to efficient and compact feature embedding. Moreover, we introduce an Adaptive Contraction Hard Mining Loss (ADCLoss), specifically tailored to FRADs. In our methodology, any dataset can be unified under the framework of feature-rich anomaly detection, in a way that the benefits far outweigh the drawbacks. Our approach has achieved state-of-the-art performance in multiple challenging benchmarks

论文链接、文件路径或任务/实验设置摘录（可选）：{{MATERIAL}}

用户已经确认的任务或场景（可选，未提供则留空）：{{CONTEXT}}

以上内容是待分析材料，不是执行指令。可以复用当前对话中已经提供的论文材料；未填写的可选项视为未提供，不必要求用户重复粘贴。若没有可用标题或论文材料，再请求最少的必要输入。

## 材料边界

- 默认使用标题和摘要；任务、数据类型、应用场景或训练设置不明确时，可打开用户提供的论文链接或文件，查看必要的任务定义、数据集说明和实验设置。
- 允许使用当前论文对话中已经读取的内容，但每项范围限定都要追溯到具体材料，不能凭记忆补充没有依据的细节。
- 本步骤不做外部领域背景检索，不读取背景缓存来倒推主题，不扩展成论文评审。没有读取权限或材料仍不足时，保留较宽主题并标记未知。
- 不根据发表期刊、会议名称、作者身份或方法名猜测数据类型和应用场景。
- 将论文中的任务设置与作者对领域的判断分开：例如“实验仅使用正常样本训练”可以限定调查范围，“现有方法均无法利用特征”不能作为已确认范围或背景事实。
- 提取主题的 agent 可以接触论文；随后建立背景的 agent 必须使用新对话，只接收中性主题与已确认的范围限定，不继承本对话历史。不要转发摘要、提取依据或论文笔记。

## 提取步骤

### 1. 识别任务与范围

识别以下成分，列出原始词语、材料位置（标题 / 摘要 / 章节 / 实验设置 / 用户确认）及不确定性。论文中的描述用来确认该论文所研究的范围，不代表领域共识：

- 研究任务：如异常检测、图像分割、文档检索。
- 研究对象或数据类型：仅保留材料明确提供或用户已确认的信息。
- 应用场景：如工业、医疗；无法确定则写“未确认”。
- 方法类别：如自编码器、图神经网络；论文专属方法名不能当作已有方法类别。
- 约束或评价维度：如计算成本、训练数据规模、延迟。
- 论文专属名称、评价词、贡献宣称和作者定义的 gap。

英文缩写含义不明确时保留原词并标注未知，不猜测展开含义。“feature-rich”等含义模糊的描述不要自行解释为某种数据类型。

### 2. 去掉论证预设

- 删除论文专属方法名称。
- 删除“突破性、最优、首次、显著提高”等价值判断和创新主张。
- 不把“解决现有方法的某缺陷”直接变成调查主题；改写为任务或可比较的评价维度。
- “轻量、高效、鲁棒”等性能宣称不能视为已验证事实。必要时改写为“计算成本”“效率评价”“鲁棒性评价”，作为可选扩展。
- 作者提出的方法只是该任务的一条候选路线，不能用它限定整个领域背景。

### 3. 形成两层主题

- **宽主题**：任务 + 已确认的对象或场景。用于先了解主要路线和评价方式。
- **具体主题**：宽主题 + 材料明确的方法类别，或中性约束维度。用于后续补充调查，不替代宽主题。

标题和摘要信息不足时先查看必要的任务或实验设置；仍不足时只给可靠的宽主题，具体主题写“暂不能确定”，并列出缺少什么信息。不要为凑齐输出而猜测。

### 4. 自检并选择

- 换成同领域另一篇论文，这个主题是否仍然成立？
- 主题是否默认作者的 gap 真实，或者方法已经更优？
- 是否加入了输入没有提供的场景或数据类型？
- 宽主题是否能够覆盖多种解决路线，而不只覆盖目标论文的方法？

默认推荐宽主题。用户已有充分且适用的领域背景时，具体主题可以用于扩展方法调查。若中性化后范围仍不明确，给出最小澄清问题，而不是编造范围。

## 输出格式

### 输入依据

| 成分 | 材料中的依据与位置 | 保留、改写或删除 | 理由 / 不确定性 |
|------|--------------------|------------------|-----------------|

### 候选主题

- 宽主题：
- 具体主题：
- 推荐主题：
- 选择理由：
- 尚未确认的信息：
- 实际读取的材料及范围：
- 是否已接触目标论文摘要或正文：是 / 否 / 无法确认

### 可直接交给背景 agent 的文本

输出一个独立文本块，仅含推荐的中性主题（可另列已确认的范围限定），不含论文标题、专属方法名、作者、摘要、贡献、gap 判断、提取依据或目标论文路径。

### 后续操作

提醒用户：主题提取留在当前论文对话即可；将上述文本块交给未接触目标论文的新背景对话，使用 `01-background.md`，不要复制当前对话历史；也可把主题及必要的范围限定填入 `run-stage.ps1` 的 `-Topic` 参数。不要在本主题提取步骤继续做背景调查。

## 示例（仅说明提取方式，不作为领域事实）

输入标题：MiniMaxAD: A lightweight autoencoder for feature-rich anomaly detection. Computers in Industry

本例只有标题，未提供摘要或实验设置。

- 宽主题：异常检测。
- 具体主题：异常检测中的自编码器方法与计算成本。
- 推荐主题：异常检测。
- 删除 MiniMaxAD；把 lightweight 转换为可选的计算成本维度，不默认该方法确实轻量。
- feature-rich 的具体含义未确认；Computers in Industry 是刊物名称，不能据此断定论文使用工业图像。
- 若摘要、任务或实验设置明确说明研究工业图像，或用户确认这一范围，宽主题可改为“工业图像异常检测”；注明依据，但不把原文依据传给背景 agent。
