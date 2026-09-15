# 云端 AI Infra 学习路线（NVIDIA + 昇腾双栈）

> 面向大模型时代的云端 AI 基础设施岗位，覆盖 GPU/NPU 性能、推理系统、分布式训练、集群调度和生产运维。
>
> 建议周期：8～11 个月，每周投入 12～18 小时。以厂商无关的系统原理为主线，在关键阶段分别实践 NVIDIA 与昇腾实现；不要求把每个实验机械地做两遍。

## 一、路线定位

这份路线主要面向以下岗位：

- LLM 推理系统工程师
- 分布式训练 / 分布式系统工程师
- GPU/NPU 平台 / AI 平台工程师
- 模型服务与性能工程师
- AI Infra / ML Systems 工程师

它不以算法研究、Prompt Engineering、RAG 应用开发或端侧推理为主。核心目标是让模型在云端环境中：

- 跑得起来：正确部署训练与推理任务。
- 跑得更快：定位计算、显存/设备内存、通信和调度瓶颈。
- 扩得出去：从单卡扩展到单机多卡和多机多卡。
- 稳定服务：具备监控、扩缩容、故障恢复和容量规划能力。
- 控制成本：理解吞吐、延迟、利用率和成本之间的取舍。

### AI Infra 技术栈全景

```text
模型与工作负载
  Transformer / MoE / 训练 / 推理 / 多模态
                    ↓
框架与运行时
  PyTorch / torch_npu / torch.compile / vLLM / MindIE
                    ↓
加速器与分布式通信
  CUDA / Ascend C / Triton(-Ascend) / NCCL / HCCL
                    ↓
集群与服务平台
  Docker / Kubernetes / Device Plugin / Ray Serve / KServe
                    ↓
可靠性与效率
  Prometheus / Grafana / OpenTelemetry / SLO / 容量与成本
```

### 学完后的能力标准

- 能独立部署单卡和多卡 LLM 服务，并进行系统化压测。
- 能解释 Prefill、Decode、KV Cache、Continuous Batching 和模型并行。
- 能使用 Nsight、msProf、PyTorch Profiler 和系统工具定位性能瓶颈。
- 能理解并排查 NCCL/HCCL 集合通信、GPU/NPU 拓扑和多进程问题。
- 能使用 PyTorch DDP、FSDP2，并理解 TP、PP、DP、EP 的组合方式。
- 能在 Kubernetes 上管理 GPU/NPU 工作负载，配置调度、存储、扩缩容和灰度发布。
- 能建立覆盖请求、引擎、加速器、节点和集群的监控体系。
- 能围绕 SLO、吞吐、延迟、利用率和成本做工程决策。

## 二、推荐主技术栈

主线保持统一，在硬件相关层建立对应实现：

| 层次 | 通用主线 | NVIDIA 路径 | 昇腾路径 |
|---|---|---|---|
| 编程与系统 | Python、C++、Linux、Bash | 通用 | 通用 |
| 深度学习框架 | PyTorch | PyTorch CUDA | PyTorch + `torch_npu` |
| 算子开发 | Tiling、融合、数值与性能方法 | CUDA、Triton、CUTLASS | Ascend C、Triton-Ascend、CATLASS |
| 性能分析 | Roofline、Timeline、瓶颈假设 | Nsight Systems / Compute | msProf / MindStudio Insight |
| 分布式通信 | `torch.distributed`、集合通信 | NCCL | HCCL |
| 推理引擎 | Scheduler、KV Cache、Batching | vLLM、TensorRT-LLM | vLLM Ascend、MindIE-LLM |
| 容器与设备管理 | Docker、Kubernetes Device Plugin | NVIDIA Container Toolkit、GPU Operator | Ascend Docker Runtime、Ascend Device Plugin、MindCluster |
| 模型服务 | Ray Serve 或 KServe 二选一深入 | 接入 NVIDIA 后端 | 接入 vLLM Ascend 或 MindIE 后端 |
| 可观测性 | Prometheus、Grafana、OpenTelemetry | DCGM Exporter、Nsight | 昇腾设备指标、msProf、MindStudio |
| 存储与制品 | S3 兼容对象存储、OCI 镜像、模型仓库 | 通用 | 通用 |

### 双栈学习原则

- 原理只学一次：Transformer、Roofline、集合通信、调度、SLO 和 Kubernetes 不按厂商重复记录。
- 实现按需对照：每个关键阶段至少选择一个代表性任务完成 NVIDIA/昇腾对照。
- 先建立 baseline，再切换后端；不要同时调试模型、框架和算子三个变量。
- 不强行寻找一一对应 API。CUDA 与 CANN 的硬件模型、执行模型和工具能力存在差异。
- 每次实验固定硬件型号、驱动/固件、框架、CANN/CUDA 和引擎版本，并保存兼容性矩阵。
- 建议将约 70% 时间用于通用 AI Infra，20% 用于昇腾专项，10% 用于跨平台对照；求职目标偏昇腾生态时可提高专项比例。

双栈实验至少记录以下环境信息：

```yaml
hardware: NVIDIA/Ascend 型号与卡数
topology: PCIe/NVLink/HCCS/RoCE 与 NUMA 信息
driver_firmware: 驱动与固件版本
toolkit: CUDA 或 CANN 版本
framework: PyTorch 与 torch_npu 版本
engine: vLLM、vLLM Ascend、TensorRT-LLM 或 MindIE 版本
container: 镜像名称与 digest
workload: 模型、dtype、输入/输出长度与并发配置
```

## 三、总体阶段安排

| 阶段 | 建议时间 | 核心主题 | 阶段产出 |
|---|---:|---|---|
| 0 | 2～3 周 | Linux、网络、并发、容器 | 可观测的容器化服务 |
| 1 | 3～4 周 | 模型结构与推理工作负载 | 最小 Transformer 与 KV Cache 实验 |
| 2 | 6～7 周 | GPU/NPU、CUDA/Ascend C、Triton、性能分析 | 跨后端算子优化报告 |
| 3 | 5～6 周 | vLLM、vLLM Ascend/MindIE 与推理服务 | 完整推理基准测试平台 |
| 4 | 5～6 周 | NCCL/HCCL 与分布式训练 | 多加速器扩展与故障分析报告 |
| 5 | 5～6 周 | Kubernetes GPU/NPU 平台 | 可部署、可扩缩的模型服务 |
| 6 | 3～4 周 | 可观测性、可靠性、成本 | SLO、告警和故障演练 |
| 7 | 4～6 周 | 综合项目与求职准备 | 可公开展示的 AI Infra 项目 |

各阶段可以有少量重叠，但不建议跳过阶段 0、1 和 4。真正的 AI Infra 岗位不仅要求会调用框架，还要求理解操作系统、网络和分布式系统。

## 四、阶段 0：系统与工程基础

### 目标

建立排查线上问题所需的系统能力，而不是只会在 Notebook 中运行模型。

### Linux 与操作系统

- 进程、线程、信号、文件描述符和进程间通信。
- 虚拟内存、page fault、page cache、mmap 和 swap。
- CPU cache、NUMA、上下文切换和 CPU affinity。
- cgroups、namespace 与容器资源隔离。
- 文件系统、块设备、网络文件系统和对象存储的差异。
- `/proc`、systemd、权限、用户、日志和环境变量。

重点工具：

- `top`、`htop`、`free`、`vmstat`、`iostat`
- `pidstat`、`sar`、`lsof`、`strace`
- `perf stat`、`perf record`
- `lscpu`、`numactl`、`taskset`

### 网络基础

- TCP 连接、拥塞、重传、连接池和 Keep-Alive。
- HTTP/1.1、HTTP/2、gRPC、SSE 与流式响应。
- DNS、四层/七层负载均衡、反向代理和 TLS。
- 延迟、带宽、吞吐、并发和排队之间的关系。
- 超时、重试、幂等、限流、熔断和背压。

重点工具：

- `curl`、`ss`、`ip`、`dig`
- `ping`、`traceroute`、`iperf3`
- `tcpdump`、Wireshark

### 编程与工程化

- Python：类型标注、虚拟环境、异步编程、multiprocessing、性能分析。
- C++：RAII、智能指针、线程、同步原语、内存布局、CMake。
- Git：分支、rebase、bisect、submodule 和基本协作流程。
- 测试：单元测试、集成测试、基准测试和可重复实验。
- Docker：镜像分层、多阶段构建、网络、存储、资源限制和 GPU/NPU 容器。

### 阶段项目：可观测的容器化服务

实现一个支持流式返回的 Python API 服务：

1. 使用 Docker 打包并设置 CPU、内存限制。
2. 实现超时、并发限制、优雅退出和健康检查。
3. 暴露请求数、延迟、错误率和队列长度指标。
4. 使用压测工具制造高并发，观察排队和 P99 延迟变化。
5. 使用 `strace`、`perf`、`pidstat` 解释一次性能问题。

### 验收标准

- 能解释容器不是虚拟机，以及 cgroups 和 namespace 分别解决什么问题。
- 能区分 CPU bound、memory bound、I/O bound 和 lock contention。
- 能从连接、队列、进程和资源四个层面排查服务超时。
- 能提交包含 Dockerfile、测试、指标和压测结果的完整仓库。

## 五、阶段 1：理解模型与推理工作负载

### PyTorch 基础

- Tensor 的 shape、dtype、device、stride 和 contiguous。
- 广播、矩阵乘法、归约和维度变换。
- `nn.Module`、参数、buffer、hook 和 state dict。
- `model.eval()`、`torch.inference_mode()`、AMP、FP16 和 BF16。
- PyTorch Profiler 与基础显存分析。
- `torch.compile` 的图捕获、graph break、动态 shape 和 warm-up。

### PyTorch 昇腾适配

- `torch_npu` 的安装、版本匹配、device、stream、event 和内存接口。
- 将设备相关代码封装在统一的 backend/device 层，避免散落硬编码。
- CUDA 模型迁移到 NPU 时的算子、dtype、动态 shape 和精度兼容性。
- 使用 C++ Extension 将 Ascend C 自定义算子注册并接入 PyTorch。
- 使用同一组输入和容差标准验证 CPU、CUDA 与 NPU 结果。

### Transformer 必备原理

- Tokenization、Embedding 和 Decoder-only Transformer。
- Self-Attention、Causal Mask、Multi-Head Attention。
- RMSNorm、RoPE、SwiGLU、残差连接。
- MHA、MQA、GQA 的结构与 KV Cache 差异。
- Dense 模型与 MoE 模型；router、expert 和 token dispatch。

无需把主要精力放在训练损失推导上，但必须能根据代码推导每一步的 shape、计算量和显存占用。

### 推理执行过程

- 自回归生成与采样。
- Prefill 与 Decode 的工作负载差异。
- KV Cache 的结构、容量估算和生命周期。
- Static Batching 与 Continuous Batching。
- Chunked Prefill、Prefix Caching 和请求抢占。
- TTFT、TPOT、ITL、E2E Latency、Throughput 和 Goodput。
- 为什么不能只用平均延迟评价在线服务。

### 阶段项目：最小推理实验

1. 用 PyTorch 实现一个不硬编码设备的最小 Decoder-only Transformer。
2. 分别实现“无 KV Cache”和“有 KV Cache”的生成流程。
3. 记录不同序列长度下的延迟和设备内存占用。
4. 分别测量 Prefill 和 Decode，解释二者瓶颈为何不同。
5. 在可用硬件上分别运行 CUDA 或 `torch_npu` 后端，并记录环境与兼容性差异。
6. 输出一份包含公式、实验数据和 profiler 截图的报告。

### 验收标准

- 能手算一个模型的权重大小和单请求 KV Cache 大小。
- 能解释为什么 Decode 往往更容易受显存带宽限制。
- 能设计区分 TTFT、TPOT 和总体吞吐的压测。
- 能解释 GQA 为什么能够降低 KV Cache 占用。

### 推荐资料

- [PyTorch Tutorials](https://docs.pytorch.org/tutorials/)
- [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)
- [Attention Is All You Need](https://arxiv.org/abs/1706.03762)
- [Hugging Face KV Cache 说明](https://huggingface.co/docs/transformers/en/cache_explanation)
- [Ascend Extension for PyTorch 文档](https://ascend.github.io/docs/sources/pytorch/)
- [Ascend C 自定义算子接入 PyTorch](https://www.hiascend.com/document/detail/en/Pytorch/2610/devguide/fwfeatures/examples/cpp_extension_asc/README_en.md)

## 六、阶段 2：GPU/NPU、算子与性能工程

### 通用性能模型

- Latency、Throughput、Bandwidth、IOPS 和 FLOPS。
- Arithmetic Intensity 与 Roofline Model。
- Compute bound、memory bound、launch bound 和 communication bound。
- Tiling、数据复用、并行度、流水线、融合和同步开销。
- warm-up、同步点、随机误差与可重复基准测试。
- 数值精度、累加精度、溢出和混合精度。

### NVIDIA GPU 硬件模型

- SM、warp、thread、block、grid。
- CUDA Core、Tensor Core、寄存器和 shared memory。
- L1/L2 Cache、HBM、内存事务和合并访问。
- Occupancy、warp stall、bank conflict 和分支发散。
- PCIe、NVLink、Host Memory 与 Device Memory。

### NVIDIA CUDA 路径

- Kernel 编写、线程索引与边界处理。
- Global、Shared、Constant、Pinned Memory。
- 同步、atomic、stream、event 和异步拷贝。
- Kernel launch overhead 与 CUDA Graph。
- GEMM、GEMV、Softmax、LayerNorm 和 Reduction 的基本实现。
- 使用 CUTLASS 理解 GEMM 分层、tile 和 Tensor Core 映射。

### 昇腾 CANN 路径

- AI Core、Cube/Vector 计算单元和存储层级。
- Ascend C Kernel、Host 侧 tiling 与多核切分。
- Global Memory 与 Local Memory 之间的数据搬运。
- Queue、Pipe、Double Buffer 与计算搬运流水并行。
- Vector、Cube 与融合算子的实现方式。
- 使用 CATLASS 理解 MatMul 模板、tile 和数据布局。
- 图模式、任务下发和同步开销；理解其与 CUDA Graph 的共同目标与实现差异。
- 动态 shape、算子精度验证与不同芯片型号的兼容边界。

### 双栈性能分析

- Nsight Systems：分析 CPU、CUDA、通信和时间线。
- Nsight Compute：分析单个 kernel 的指令、吞吐和 stall。
- msProf：采集 CANN API、任务、算子、流水和通信数据。
- MindStudio Insight：分析时间线、指令流水和计算/搬运热点。
- 使用相同方法提出瓶颈假设，但根据硬件模型选择指标，避免机械对照字段。

### Triton、Triton-Ascend 与编译器基础

- 使用 Triton 编写向量加法、Softmax 或 LayerNorm。
- 理解 tiling、program ID、mask 和 autotune。
- 使用 Triton-Ascend 移植一个已验证的 Triton 算子，记录不支持语义与性能差异。
- 理解 eager execution、graph capture、operator fusion 和 code generation。
- 了解 TorchInductor、CUTLASS、CATLASS、TensorRT 和 CANN 编译栈的职责边界。

### 阶段项目：算子优化

选择 Softmax、RMSNorm、RoPE 或 MatMul 中的一个：

1. 建立 PyTorch/`torch_npu` 框架 baseline。
2. NVIDIA 路径选择 CUDA、Triton 或 CUTLASS 实现。
3. 昇腾路径选择 Ascend C、Triton-Ascend 或 CATLASS 实现。
4. 至少完成一个底层实现；具备两种硬件时，再完成同一问题的跨平台实现。
5. 覆盖多个 shape 和 dtype，使用统一测试向量验证数值正确性。
6. 分别使用 Nsight 或 msProf 分析计算、访存/搬运、并行度和下发开销。
7. 给出在哪些 shape 下更快、在哪些情况下反而更慢的解释。

> 跨平台实验用于比较优化方法和工程取舍，不用于简单比较两种芯片的绝对快慢。硬件代际、功耗、软件版本和算子库不同都会影响结果。

### 验收标准

- 不依赖猜测，能够使用 profiler 证实瓶颈。
- 能画出一个 kernel 的访存路径和线程映射。
- 能解释算子融合为什么可能降低 HBM 流量和 launch overhead。
- 能将 NVIDIA 的线程/warp/tile 思维与昇腾的多核/流水/搬运思维联系起来，同时说清差异。
- 能区分“理论 FLOPS 很高”“单算子很快”和“实际模型服务很快”。

### 推荐资料

- [CUDA C++ Programming Guide](https://docs.nvidia.com/cuda/cuda-c-programming-guide/)
- [CUDA C++ Best Practices Guide](https://docs.nvidia.com/cuda/cuda-c-best-practices-guide/)
- [Nsight Systems 文档](https://docs.nvidia.com/nsight-systems/)
- [Nsight Compute 文档](https://docs.nvidia.com/nsight-compute/)
- [Triton 官方教程](https://triton-lang.org/main/getting-started/tutorials/)
- [FlashAttention](https://arxiv.org/abs/2205.14135)
- [Ascend C 高性能算子最佳实践](https://www.hiascend.com/document/detail/en/CANNCommunityEdition/850/opdevg/Ascendcopdevg/atlas_ascendc_best_practices_10_0001.html)
- [msProf Quick Start](https://www.hiascend.com/document/detail/en/mindstudio/2610/TITools/msProf/docs/en/quick_start/msprof_quick_start.md)
- [Triton-Ascend](https://ascend.github.io/triton-ascend/)

## 七、阶段 3：LLM 推理引擎与在线服务

### 先深入 vLLM

不要一开始同时深挖多个引擎。先通过 vLLM 学习调度、KV Cache 和服务化等通用结构，再根据可用硬件选择后端：

- NVIDIA 主实践：上游 vLLM；TensorRT-LLM 或 SGLang 作为对照。
- 昇腾主实践：vLLM Ascend；MindIE-LLM 作为昇腾原生生产推理栈对照。
- 双栈的重点是理解硬件插件边界和执行后端差异，不是分别背诵两套 API。

需要理解的调用链：

```text
API / Tokenizer
      ↓
请求队列与准入控制
      ↓
Scheduler / Continuous Batching
      ↓
KV Cache Manager / Block Table
      ↓
Model Executor / GPU or NPU Worker
      ↓
Sampling / Streaming Response
```

### 核心机制

- PagedAttention 与分页 KV Cache。
- Continuous Batching、Chunked Prefill 和抢占。
- Prefix Caching 与 prefix-aware routing。
- CUDA Graph / 昇腾图模式、算子选择和模型加载流程。
- FP8、INT8、INT4、AWQ、GPTQ 与量化评估。
- LoRA Adapter 动态加载与多 LoRA 服务。
- Structured Output 和采样开销。
- 请求优先级、超时、取消和 backpressure。

### 推理并行与新型架构

- Tensor Parallel、Pipeline Parallel 和 Data Parallel Serving。
- MoE 的 Expert Parallel 与 All-to-All 通信。
- Prefill–Decode Disaggregation 的动机和代价。
- KV Cache 在实例间传输、复用与路由。
- 单模型多副本、多模型共享集群和异构加速器部署。

### NVIDIA 与昇腾后端观察点

| 观察问题 | NVIDIA 路径 | 昇腾路径 |
|---|---|---|
| PyTorch 设备后端 | CUDA | `torch_npu` |
| vLLM 执行后端 | 上游 CUDA Worker / Kernel | vLLM Ascend Plugin / NPU Kernel |
| 图执行 | CUDA Graph | vLLM Ascend graph mode / CANN 图执行 |
| 高性能原生引擎 | TensorRT-LLM | MindIE-LLM |
| 算子与融合 | CUDA、Triton、FlashAttention | Ascend C、Triton-Ascend、昇腾融合算子 |
| 多卡通信 | NCCL | HCCL |

每次使用 vLLM Ascend 或 MindIE 前先检查模型、硬件、量化方式和功能支持矩阵。不要默认上游 vLLM 的所有参数都已在昇腾后端实现。

### 正确的压测方法

必须区分：

- Offline Benchmark：测最大吞吐和内核效率。
- Online Serving：模拟真实到达率和排队行为。
- ShareGPT 等真实长度分布与固定长度合成数据。
- Closed-loop 与 Open-loop 压测。
- P50、P95、P99 TTFT / TPOT 与 Goodput。

压测变量至少包括：

- 输入长度、输出长度和并发数。
- 请求到达率和 burst。
- batch token 上限与最大序列数。
- dtype、量化方式和 KV Cache 配置。
- 单卡、多卡、TP 大小和副本数。

### 阶段项目：推理性能实验平台

在可用的 NVIDIA 或昇腾环境中部署 vLLM 服务；有两种硬件时再做跨后端对照：

1. 编写可配置的 Open-loop 压测程序。
2. 同时采集请求指标、vLLM 指标和 GPU/NPU 指标。
3. NVIDIA 路径对比 PyTorch/Hugging Face eager、vLLM 和一个量化版本。
4. 昇腾路径对比 `torch_npu` eager、vLLM Ascend、MindIE-LLM 或一个量化版本。
5. 分析不同输入/输出比例下 TTFT 与 TPOT 的变化。
6. 测试当前后端支持的 Prefix Caching、Chunked Prefill 和 Continuous Batching。
7. 实现一个简单的准入控制或 prefix-aware 路由代理。
8. 输出实验方法、软硬件版本、原始数据、图表、结论和局限性。

### 源码阅读顺序

1. 从一次请求的端到端调用链开始。
2. 阅读 Scheduler 的输入、输出和核心状态。
3. 阅读 KV Cache block 的分配、释放与抢占。
4. 阅读 Model Executor、Worker 和模型执行路径。
5. 昇腾方向继续阅读 vLLM Ascend 插件的注册、Worker、算子与 graph mode 边界。
6. 带着一个具体问题修改代码并重新压测。

不要以“读完仓库”为目标；以回答一个性能或调度问题为目标。

### 验收标准

- 能解释吞吐升高而 P99 变差的原因。
- 能根据业务 SLO 选择 TP、副本数、batch 参数和量化方式。
- 能区分引擎优化、服务层优化和集群层优化。
- 能从指标判断瓶颈处于排队、Prefill、Decode、通信还是加速器空转。
- 能解释上游 vLLM 与 vLLM Ascend 的核心共用层和硬件插件层。

### 推荐资料

- [vLLM 官方文档](https://docs.vllm.ai/)
- [vLLM Metrics](https://docs.vllm.ai/en/stable/usage/metrics.html)
- [vLLM Benchmark 工具](https://github.com/vllm-project/vllm/tree/main/benchmarks)
- [PagedAttention 论文](https://arxiv.org/abs/2309.06180)
- [TensorRT-LLM 文档](https://docs.nvidia.com/tensorrt-llm/)
- [vLLM Ascend 用户指南](https://docs.vllm.ai/projects/ascend/en/latest/user_guide/)
- [vLLM Ascend 插件文档](https://docs.vllm.ai/projects/ascend/en/latest/)
- [MindIE-LLM](https://gitcode.com/Ascend/MindIE-LLM/)

## 八、阶段 4：分布式通信与训练系统

真正的 AI Infra 工程师需要理解训练和推理共享的分布式基础，即使最终专注推理服务。

### 分布式系统基础

- rank、world size、process group 和 rendezvous。
- 同步、屏障、超时、失败传播和分布式死锁。
- 吞吐扩展、强扩展、弱扩展和 scaling efficiency。
- straggler、负载不均、网络拥塞和尾延迟。
- 数据一致性、checkpoint、重试和弹性恢复。

### 集合通信通用原理

- Broadcast、Reduce、AllReduce。
- AllGather、ReduceScatter、All-to-All。
- Ring、Tree 等通信算法的基本直觉。
- 节点内通信与节点间通信；带宽、时延、消息大小和拥塞。
- 通信域、rank placement、NUMA 绑定和拓扑映射。
- 通信计算重叠、慢 rank、慢链路、timeout 和分布式 hang。

### NVIDIA NCCL 路径

- GPU Direct、P2P、NVLink、PCIe、RDMA 和 InfiniBand。
- 使用 NCCL Tests 建立不同消息大小和集合通信的带宽 baseline。
- `NCCL_DEBUG`、拓扑文件、网卡选择、timeout 和异步错误处理。

### 昇腾 HCCL 路径

- HCCS、PCIe、RoCE 与昇腾集群拓扑。
- HCCL 的通信域、rank table、集合通信算法和环境变量。
- PyTorch 中使用 `backend="hccl"`，分析 AllReduce、AllGather、ReduceScatter 和 All-to-All。
- 使用 msProf 采集通信 timeline，分析慢 rank、慢链路和通信计算重叠。
- 了解 Ascend C 中计算通信融合及通信算子的能力边界。

### PyTorch 分布式训练

- `torchrun` 与 `torch.distributed`。
- CUDA 后端使用 NCCL，昇腾后端通过 `torch_npu` 使用 HCCL。
- DDP：数据并行、梯度同步与 AllReduce。
- FSDP2：参数、梯度和优化器状态分片。
- DTensor 与 DeviceMesh。
- Tensor Parallel 与 Sequence Parallel。
- Pipeline Parallel 与 micro-batch 调度。
- MoE Expert Parallel 与 All-to-All。
- 2D / 3D 并行组合与通信域划分。
- Distributed Checkpoint 与不同 world size 恢复。
- 计算通信重叠、gradient accumulation 和混合精度。

### 阶段项目：多加速器扩展实验

建议使用 2～4 张同类 GPU 或 NPU，不要在第一个分布式实验中混合不同后端：

1. 先用 DDP 训练一个小型 Transformer。
2. 再用 FSDP2 运行同一个模型。
3. NVIDIA 路径使用 NCCL，昇腾路径使用 HCCL；至少完整完成其中一条。
4. 记录单卡与多卡的 step time、设备内存、通信时间和扩展效率。
5. 使用 PyTorch Profiler、Nsight 或 msProf 找出 AllReduce、AllGather 和 ReduceScatter。
6. 修改 batch size、bucket 或分片配置，验证性能变化。
7. 人为制造 rank 退出、网络变慢或 checkpoint 恢复场景。
8. 写一份故障分析和扩展效率报告；注明拓扑、链路和通信库版本。

没有长期多卡环境时，可以短租相应加速器资源完成集中实验；平时在单机上学习接口、分析 trace 和编写自动化脚本。不要因为硬件有限而跳过通信原理。

### 验收标准

- 能解释 DDP、FSDP2、TP、PP 和 EP 分别切分什么。
- 能根据模型大小、节点拓扑和网络条件选择并行策略。
- 能解释 FSDP 为什么使用 AllGather 和 ReduceScatter。
- 能根据 NCCL/HCCL 日志、timeline 和拓扑信息初步定位 hang 或性能下降。
- 能说清 NCCL 与 HCCL 共享的集合通信原理，以及二者配置和硬件链路的差异。
- 能设计可从 checkpoint 恢复的多加速器作业。

### 推荐资料

- [PyTorch Distributed Overview](https://docs.pytorch.org/tutorials/beginner/dist_overview.html)
- [PyTorch Distributed Tutorials](https://docs.pytorch.org/tutorials/distributed.html)
- [PyTorch FSDP2](https://docs.pytorch.org/docs/main/distributed.fsdp.fully_shard.html)
- [PyTorch Distributed Checkpoint](https://docs.pytorch.org/tutorials/recipes/distributed_checkpoint_recipe.html)
- [NCCL 官方文档](https://docs.nvidia.com/deeplearning/nccl/)
- [HCCL 官方文档](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/commlib/hcclug/hcclug_000001.html)
- [昇腾 PyTorch 分布式功能样例](https://ascend.github.io/docs/sources/pytorch/examples.html)
- [Megatron-LM](https://github.com/NVIDIA/Megatron-LM)

## 九、阶段 5：Kubernetes 与 GPU/NPU 平台

### Kubernetes 基础

- Pod、Deployment、StatefulSet、DaemonSet 和 Job。
- Service、Ingress / Gateway、DNS 和网络策略。
- ConfigMap、Secret、PVC、StorageClass 和 CSI。
- requests、limits、QoS、健康检查和优雅终止。
- nodeSelector、affinity、taint、toleration 和 topology spread。
- HPA、PDB、滚动升级、灰度发布与回滚。
- RBAC、ServiceAccount 和最小权限。

### 加速器资源管理通用能力

- Kubernetes Device Plugin 机制与扩展资源。
- 节点发现、设备上报、分配、健康检查和故障隔离。
- 整卡、硬件切分、软件共享和超卖的边界。
- 拓扑感知调度、gang scheduling、队列准入和配额。
- 训练 Job 与在线 Serving 工作负载的调度差异。
- 驱动、固件、运行时、框架和容器镜像的兼容矩阵。

### NVIDIA GPU 平台路径

- NVIDIA Container Toolkit 与 Kubernetes Device Plugin。
- NVIDIA GPU Operator 的组件和生命周期。
- GPU 标签、节点发现、驱动与 CUDA 兼容性。
- 整卡、MIG、MPS、time-slicing 的边界和适用场景。

### 昇腾 NPU 平台路径

- Ascend Docker Runtime 与 Ascend Device Plugin。
- NPU 发现、分配、健康检查以及 Pod 设备挂载。
- 整卡、静态/动态 vNPU 与型号相关约束。
- Ascend Operator、rank 配置与分布式任务启动。
- MindCluster 与 Volcano 的拓扑调度、弹性训练和故障重调度能力。
- 使用 910B3 时固定与其匹配的驱动、固件、CANN、`torch_npu` 和镜像版本。

两条路径都需要了解 Kueue、Volcano 或企业内部调度系统解决的排队、配额、gang scheduling 和抢占问题。

### 模型服务平台

Ray Serve 与 KServe 选择一个深入：

- 模型服务声明、版本、路由和副本管理。
- OpenAI-compatible API 与流式响应。
- 单节点多加速器与多节点部署。
- 自动扩缩容与冷启动。
- 多模型部署、LoRA、缓存和请求路由。
- Prefill / Decode 分离部署的资源配置。
- NVIDIA 后端部署上游 vLLM/TensorRT-LLM；昇腾后端部署 vLLM Ascend/MindIE-LLM。

### 模型制品与存储

- OCI 镜像、模型权重、配置和 tokenizer 的版本关系。
- S3 兼容对象存储、共享文件系统和本地 NVMe 的取舍。
- 模型下载、缓存、校验、断点续传和并发加载。
- 启动时间、镜像大小、权重复制和节点缓存。
- 模型来源凭据、Secret 管理和供应链安全。

### 阶段项目：GPU/NPU 模型服务平台

在 Kubernetes 上选择 NVIDIA 或昇腾后端部署 vLLM；有条件时复用同一服务层配置验证另一个后端：

1. 使用 Helm 或 Kustomize 管理配置。
2. 配置 GPU/NPU 资源、affinity、健康检查和优雅终止。
3. 配置模型存储、节点缓存或 init container。
4. 部署 Gateway、认证、限流和流式接口。
5. 基于队列长度、并发请求或 token 指标进行扩缩容。
6. 完成新版本灰度、流量切换和回滚。
7. 比较冷启动、模型加载和扩容时间。
8. 昇腾路径记录 Ascend Device Plugin、rank 配置和版本兼容问题；NVIDIA 路径记录 GPU Operator 与驱动生命周期问题。

### 验收标准

- 能解释为什么只根据 GPU/NPU utilization 扩缩容可能失效。
- 能处理 Pod 调度失败、加速器不可见、驱动/固件不兼容和模型加载过慢。
- 能解释 Deployment、Job 和自定义控制器在 AI 工作负载中的差异。
- 能给出在线推理与离线训练共用加速器集群时的资源隔离方案。

### 推荐资料

- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Kubernetes GPU 调度](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/)
- [NVIDIA GPU Operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/)
- [Ascend Device Plugin / MindCluster](https://github.com/Ascend/mind-cluster)
- [Ascend Device Plugin 安装说明](https://github.com/Ascend/mind-cluster/blob/master/docs/en/scheduling/developer_guide/installation_deployment/manual_installation/04_ascend_device_plugin.md)
- [Ray Serve LLM](https://docs.ray.io/en/latest/serve/llm/)
- [KServe Generative Inference](https://kserve.github.io/website/docs/model-serving/generative-inference/overview)
- [Kueue](https://kueue.sigs.k8s.io/)

## 十、阶段 6：可观测性、可靠性与成本

### 四层指标体系

| 层次 | 需要关注的指标 |
|---|---|
| 请求层 | QPS、并发、状态码、取消、排队时间、E2E Latency |
| 引擎层 | TTFT、TPOT、ITL、tokens/s、batch、KV Cache、抢占、prefix hit rate |
| 加速器 / 节点层 | GPU/NPU 利用率、设备内存、功耗、温度、计算单元、PCIe/互联、CPU、内存、网络 |
| 集群层 | Pod 状态、调度等待、启动时间、副本数、加速器分配率、失败 Job、成本 |

### SLO 与告警

- 为成功率、TTFT、TPOT、P99 延迟和可用性定义 SLO。
- 使用 Goodput 表示满足延迟目标的有效吞吐。
- 区分症状告警与原因告警。
- 设置 burn-rate 告警，避免只根据瞬时阈值报警。
- 为告警编写 runbook、升级路径和恢复验证方法。

### 日志与追踪

- 结构化日志、request ID、模型版本和实例信息。
- OpenTelemetry trace 与跨 Gateway、Scheduler、Engine 的上下文传播。
- 将请求延迟与 GPU/NPU kernel、NCCL/HCCL 和节点指标关联。
- 控制日志基数、隐私信息和采样成本。

### 故障场景

- CUDA/CANN OOM、设备内存碎片和 KV Cache 耗尽。
- GPU XID、NPU 健康异常、掉卡、ECC、驱动或固件问题。
- NCCL/HCCL hang、rank 退出和网络抖动。
- 请求堆积、突发流量和下游超时。
- 模型加载失败、对象存储变慢和冷启动过长。
- Pod 驱逐、节点维护和区域故障。

### 容量与成本

- 用输入/输出 token 分布而不是只用 QPS 做容量规划。
- 区分 Prefill 和 Decode 的资源需求。
- 评估 GPU/NPU 类型、量化、TP 大小和副本数的成本差异。
- 关注每百万 token 成本、满足 SLO 的 Goodput/加速器和空闲率。
- 计算预留容量、峰值容量和故障冗余。

### 阶段项目：SLO 与故障演练

1. 使用 Prometheus 采集服务、vLLM、Kubernetes 与加速器指标；NVIDIA 接入 DCGM，昇腾接入环境支持的设备指标。
2. 建立 Grafana 仪表盘和 SLO 面板。
3. 为高 TTFT、KV Cache 压力、GPU/NPU 错误和请求积压配置告警。
4. 注入进程退出、模型加载失败、流量突增和单设备故障。
5. 记录 MTTD、MTTR、用户影响和改进措施。
6. 输出容量规划表和每百万 token 成本估算。

### 验收标准

- 能从用户侧延迟一路定位到引擎、GPU/NPU 或集群根因。
- 能写出可操作的告警，而不是堆积大量无意义指标。
- 能在容量、成本和可靠性之间给出有数据支撑的取舍。
- 能完成一份结构清楚的事故复盘。

### 推荐资料

- [Prometheus 文档](https://prometheus.io/docs/)
- [Grafana 文档](https://grafana.com/docs/grafana/latest/)
- [OpenTelemetry 文档](https://opentelemetry.io/docs/)
- [NVIDIA DCGM](https://docs.nvidia.com/datacenter/dcgm/latest/)
- [DCGM Exporter 安装与集成](https://docs.nvidia.com/datacenter/dcgm/latest/installation/install-dcgm-exporter.html)
- [CANN 性能分析工具概览](https://www.hiascend.com/document/detail/en/canncommercial/850/devaids/profiling/atlasprofiling_16_0001.html)
- [msProf 离线推理性能分析](https://www.hiascend.com/document/detail/en/CANNCommunityEdition/850/devaids/profiling/atlasprofiling_16_0005.html)
- [Ray Serve LLM Observability](https://docs.ray.io/en/latest/serve/llm/user-guides/observability.html)

## 十一、阶段 7：综合项目

### 推荐题目：生产级多加速器 LLM 服务平台

项目应至少包含以下组件：

```text
Client / Load Generator
          ↓
Gateway：认证、限流、超时、流式转发
          ↓
Router：负载感知或 Prefix 感知
          ↓
vLLM / vLLM Ascend Replicas：TP / DP / KV Cache
          ↓
Accelerator Nodes：
  NVIDIA GPU Operator / DCGM Exporter
  Ascend Device Plugin / MindCluster

Control Plane：Kubernetes / Ray Serve 或 KServe
Observability：Prometheus / Grafana / OpenTelemetry
Artifacts：对象存储 / 模型缓存 / 版本管理
```

### 必须完成的实验

- 单卡与多卡 TP 的吞吐、延迟和利用率对比，可选择 NVIDIA 或昇腾完成主实验。
- 单个 TP 副本与多个数据并行副本的对比。
- 不同输入/输出长度和到达率下的 P99。
- Prefix Caching 或 Chunked Prefill 的收益边界。
- 一种量化配置的精度、延迟和成本对比。
- 自动扩缩容过程中的排队、冷启动和抖动。
- 至少三个故障注入场景及恢复过程。
- 有两种硬件条件时，使用同一模型、请求分布和 SLO 做跨后端实验；明确声明硬件差异，不做脱离环境的绝对性能结论。

### 仓库交付物

- 架构图和关键设计决策。
- 一键部署脚本或 Helm Chart。
- 可重复的压测程序和配置。
- 原始实验数据与分析 Notebook。
- Grafana Dashboard 和告警规则。
- Runbook、容量规划和事故复盘。
- 性能结论、适用范围和已知限制。

### 项目评价标准

优秀项目不以代码行数判断，而看以下内容：

- 是否提出了明确的问题和 SLO。
- 实验能否重复，变量是否受到控制。
- 是否能用 trace 和指标解释结果。
- 是否展示了失败案例和错误假设。
- 是否说明了性能、可靠性、复杂度和成本的取舍。

## 十二、完成主线后的专项方向

### A. 推理引擎与 GPU/NPU 性能

适合喜欢 C++、CUDA/Ascend C 和性能分析的人：

- 深入 vLLM / vLLM Ascend / SGLang / TensorRT-LLM / MindIE-LLM 执行路径。
- CUDA、Ascend C、Triton、Triton-Ascend、CUTLASS、CATLASS 和算子融合。
- FP8 / INT4、量化 kernel 与低精度数值。
- MoE kernel、Expert Parallel 和 All-to-All 优化。
- Prefill–Decode 分离与 KV Cache 传输。
- 编译器、图优化和硬件后端。

### B. 分布式训练系统

适合喜欢分布式算法和大规模作业的人：

- FSDP2、DTensor、DeviceMesh 和 TorchTitan。
- Megatron-LM、DeepSpeed 与多维并行。
- Distributed Checkpoint 与弹性训练。
- 通信计算重叠、拓扑映射和 straggler 处理。
- 数据加载、对象存储和训练吞吐。
- 多机故障诊断和作业恢复。

### C. GPU/NPU 平台与调度

适合喜欢 Kubernetes、控制面和可靠性的人：

- Kubernetes Operator 和自定义控制器。
- Kueue、Volcano、gang scheduling 和配额管理。
- GPU/NPU 拓扑感知、碎片整理、MIG/vNPU 和共享策略。
- 多租户、优先级、抢占、公平性与成本分摊。
- 模型制品、缓存、镜像分发和节点生命周期。
- 跨集群调度、容灾和平台 API。

## 十三、前 12 周执行计划

如果不知道从哪里开始，可以直接按下面执行：

| 周数 | 学习任务 | 实际产出 |
|---:|---|---|
| 1 | Linux 进程、内存、系统工具 | 一份进程和内存分析记录 |
| 2 | 网络、HTTP、流式响应、压测 | 一个流式 API 与压测结果 |
| 3 | Docker、cgroups、指标 | 容器化服务与 Prometheus 指标 |
| 4 | PyTorch、`torch_npu` 与设备抽象 | 可切换设备的 Tensor 实验 |
| 5 | Transformer、Attention、shape | 最小 Self-Attention 实现 |
| 6 | 自回归、Prefill、Decode | 无 Cache 生成 baseline |
| 7 | KV Cache、GQA、显存公式 | KV Cache 实现与对比报告 |
| 8 | GPU/NPU 架构与执行模型 | CUDA 与 CANN 概念映射笔记 |
| 9 | CUDA 或 Ascend C 知识恢复 | 一个可验证的优化 kernel |
| 10 | Nsight 与 msProf | 双工具性能分析记录 |
| 11 | Triton / Triton-Ascend、tiling、融合 | 一个 DSL 算子实验 |
| 12 | Roofline 与跨后端分析 | 算子性能报告和阶段复盘 |

从第 13 周开始进入 vLLM/vLLM Ascend、NCCL/HCCL、分布式训练和 Kubernetes 主线。

## 十四、面试与自检清单

### 系统基础

- 进程与线程有什么区别？容器如何限制 CPU 和内存？
- page cache、mmap、NUMA 对模型加载和推理有什么影响？
- 高并发服务的 P99 为什么会在高负载时突然恶化？

### GPU/NPU 与性能

- 为什么 Decode 常见为 memory bound？
- 如何使用 Roofline 判断算子瓶颈？
- CUDA Stream、CUDA Graph、CANN 图执行和算子融合分别减少什么开销？
- 如何证明一个优化确实有效且没有破坏正确性？
- CUDA 与 Ascend C 在并行组织、存储层级和数据搬运上的主要差异是什么？

### 推理系统

- Continuous Batching 如何提高加速器利用率？
- PagedAttention 如何降低显存浪费？
- TP 和多副本 DP 应该如何选择？
- Prefix Caching、Chunked Prefill 和 Prefill–Decode 分离各自适合什么场景？

### 分布式系统

- AllReduce、AllGather、ReduceScatter 和 All-to-All 分别用于哪里？
- DDP、FSDP2、TP、PP、EP 分别切分什么？
- 为什么跨节点 TP 通常比节点内 TP 更昂贵？
- NCCL/HCCL hang 应该从哪些日志、timeline 和拓扑信息开始排查？

### 平台与可靠性

- Kubernetes 如何通过 Device Plugin 把 GPU/NPU 分配给 Pod？
- 为什么加速器 utilization 不能单独作为 LLM 服务扩容指标？
- 如何设计模型服务的 SLO、告警和容量规划？
- 模型版本升级如何做到灰度、回滚和结果验证？

## 十五、学习中最容易踩的坑

- 同时学习 vLLM、SGLang、TensorRT-LLM，却没有深入任何一个。
- 花数月看 Transformer 理论，迟迟不做服务和性能实验。
- 只会执行部署命令，不会解释请求经过了哪些组件。
- 只测最大 tokens/s，不测真实到达率和 P99。
- 只关注 GPU/NPU kernel，忽略排队、CPU、网络、存储和模型加载。
- 跳过 NCCL/HCCL 和分布式训练，导致对多加速器系统理解不完整。
- 只会画 Grafana 图表，没有 SLO、告警和故障恢复过程。
- 项目只有最终结果，没有 baseline、原始数据和失败实验。
- 追逐框架最新功能，但没有固定版本和可重复环境。
- 将 NVIDIA 和昇腾拆成两套重复知识，没有抽取共享的系统原理。
- 忽略 CANN、`torch_npu`、vLLM Ascend、驱动和固件的版本兼容关系。

## 十六、最终建议

学习顺序应始终遵循下面的闭环：

```text
建立 baseline
    ↓
采集指标与 trace
    ↓
提出瓶颈假设
    ↓
只修改一个变量
    ↓
重新测试并解释结果
    ↓
记录适用范围与代价
```

AI Infra 的核心竞争力不是记住多少框架名称，也不是只熟悉某一家硬件，而是面对模型慢、GPU/NPU 空转、通信卡死、Pod 起不来或成本过高时，能用系统方法找到原因，并交付可验证、可运行、可维护的解决方案。
