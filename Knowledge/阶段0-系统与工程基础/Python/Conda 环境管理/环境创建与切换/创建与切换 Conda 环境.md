# 创建与切换 Conda 环境

## 引入

Miniconda 已安装好，但把所有练习都放进自带的 `base` 环境，后续很难区分哪些软件属于哪项学习任务。独立环境相当于为一组程序准备单独的位置；激活环境后，同一条 `python` 命令会找到该环境里的解释器。

本课只练习创建、查看、激活和退出环境，不安装 NumPy、Pandas 等第三方库。你将在本机创建一个留给后续 Python 课程使用的环境。[Conda 环境管理文档](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html)说明了这些基本操作。

## 核心内容

### 创建带 Python 的独立环境

创建环境时，可以给它一个名字，并指定 Python 版本。例如，下面的 `text-demo` 是演示用名称：

```bash
conda create -n text-demo python=3.14
```

`-n` 后面是环境名，`python=3.14` 表示安装 Python 3.14 系列。这里选择 3.14，是因为本机已安装的 Miniconda 基础环境使用 Python 3.14；实际小版本由 Conda 当前可用的软件包决定。Conda 会先显示拟安装的软件包和目标路径，等待确认后再创建。环境通常位于 `$HOME/miniconda3/envs/text-demo`，与 `base` 分开。第一次创建可能需要联网下载 Python 及依赖。[官方创建环境说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#creating-an-environment-with-commands)给出了带 Python 版本的写法。

若环境名已经存在，先检查已有环境，不要直接重复创建。本课后面的实操会使用另一个名称，因此不需要为演示额外创建 `text-demo`。

### 查看已有环境与当前环境

```bash
conda info --envs
```

输出列出环境名和路径；当前激活的环境旁会有 `*`。新环境出现在列表中，说明创建完成，但不代表它已经激活。提示符可能显示环境名，也可能因终端主题设置而不显示；以列表中的 `*` 为准。[官方查看环境说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#viewing-a-list-of-your-environments)

### 激活并确认 Python 解释器

在同一个终端中激活演示环境，然后检查：

```bash
conda activate text-demo
conda info --envs
python --version
command -v python
```

`conda activate` 改变当前 Shell 的环境，因此之后的检查要在同一个终端执行。列表里的 `*` 应移动到 `text-demo`；`python --version` 显示所用 Python 版本；`command -v python` 显示终端会执行的解释器路径，应指向类似 `$HOME/miniconda3/envs/text-demo/bin/python` 的位置。仅看版本号不能确定解释器来自哪个环境，路径更能说明当前选择。[官方激活环境说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#activating-an-environment)

### 退出或明确切回 base

```bash
conda deactivate
conda info --envs
command -v python
```

`conda deactivate` 退出当前的命名环境。若先前位于 `base`，通常会回到 `base`；若先前没有激活环境，则可能回到没有活动 Conda 环境的状态，此时 `command -v python` 也可能找不到命令。再次查看 `*` 和 `python` 路径，确认切换确实发生。需要明确进入基础环境时，可以使用 `conda activate base`。不要依赖提示符的外观来判断。[官方退出环境说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#deactivating-an-environment)

## 示例

假设 `text-demo` 已创建，且起初位于 `base`。运行 `conda info --envs` 时，`*` 在 `base` 一行；运行 `conda activate text-demo` 后，`*` 移到 `text-demo`，`command -v python` 指向它的 `envs/text-demo/bin/python`。执行 `conda deactivate` 后，再检查列表和路径，应回到原来的环境。具体路径以本机实际输出为准。

这个例子要观察的是“环境标记与解释器路径一起变化”。即使两个环境的 `python --version` 相同，也不能据此认为环境没有切换。

## 小结（掌握范围）

- 会用环境名和 Python 版本创建独立环境，并在确认安装计划后完成创建。
- 会从 `conda info --envs` 中辨认已有环境和当前环境。
- 会激活、退出环境，并用 `command -v python` 确认解释器来自哪里。
- 知道 `base` 与新建环境分开，环境切换只影响当前 Shell。

## 课后小实操

### 实操一

为后续 Python 基础语法课程创建一个名为 `py-basics`、使用 Python 3.14 的环境，并验证激活与退出时解释器路径如何变化。本题与正文演示使用不同的环境名；创建后保留该环境，后续课程会继续使用。

**操作步骤**

先查看当前环境列表，确认 `py-basics` 尚不存在；若它已存在，直接使用已有环境，不要覆盖。自己输入创建命令，阅读 Conda 显示的安装计划后确认。创建完成后，在同一终端激活 `py-basics`，查看环境列表、Python 版本和解释器路径。随后退出该环境，再查看环境列表和解释器路径，对比前后变化。

请在运行结果中贴出创建前后环境列表的关键行、激活后的 Python 版本与解释器路径，以及退出后的环境标记与解释器路径；若退出后找不到 `python`，按实际情况记录。若 Conda 提示错误，贴出原始报错；无需粘贴完整的软件包下载日志。

**运行结果**

```text
❯ conda create -n py-basics python=3.14
Do you accept the Terms of Service (ToS) for https://repo.anaconda.com/pkgs/r? 
[(a)ccept/(r)eject/(v)iew]: a
2 channel Terms of Service accepted
..... 安装信息略

❯ conda activate py-basics
❯ conda info --envs
# conda environments:
#
# * -> active
# + -> frozen
base                     /home/ubzy/miniconda3
py-basics            *   /home/ubzy/miniconda3/envs/py-basics
❯ python --version
Python 3.14.7
❯ command -v python
/home/ubzy/miniconda3/envs/py-basics/bin/python

❯ conda deactivate
❯ conda info --envs
# conda environments:
#
# * -> active
# + -> frozen
base                 *   /home/ubzy/miniconda3
py-basics                /home/ubzy/miniconda3/envs/py-basics
❯ python --version
Python 3.14.7
❯ command -v python
/home/ubzy/miniconda3/bin/python

```
