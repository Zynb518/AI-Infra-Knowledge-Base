# 查看与安装 Conda 包

## 引入

你已经创建了 `py-basics`，但创建环境只是选好了 Python 和初始依赖。后续如果需要工具，应先确认它是否已在目标环境中，再安装，并检查安装结果。这样能避免把练习用的软件装进 `base`。

本课用 Conda 管理一个轻量的打包工具，只练习包的查询和安装，不学习该工具的 Python API。[Conda 包管理指南](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-pkgs.html)给出了查询与安装的基本命令。

## 核心内容

### 指明要查看的环境

```bash
conda list -n py-basics python
```

`conda list` 查询已安装的软件包；`-n py-basics` 指定目标环境，末尾的 `python` 是筛选用的包名。输出应包含 `py-basics` 的环境路径和 Python 版本。即使当前终端停留在 `base`，这个命令查询的仍是 `py-basics`。[`conda list` 命令文档](https://docs.conda.io/projects/conda/en/stable/commands/list.html)

如果指定的包不存在，这个版本的 Conda 会提示 `No packages match`。这表示目标环境里没有匹配的已安装包，不表示环境损坏。可用同样的方式分别查询 `base` 和 `py-basics`，观察两边的软件包是否相同。

### 先预览安装计划

下面用 `wheel` 作课堂示例。先让 Conda 计算安装方案，但不写入环境：

```bash
conda install -n py-basics --dry-run wheel
```

`install` 表示安装，`-n py-basics` 指明写入哪个环境，`--dry-run` 只显示计划。重点看计划中的目标环境路径、拟新增或改变的软件包。如果显示的目标不是 `py-basics`，不要继续。第一次查询软件源可能需要一些时间；预览结束后，环境中的包仍不变。[`conda install` 命令文档](https://docs.conda.io/projects/conda/en/stable/commands/install.html)

### 安装后再验证

确认计划合适后，去掉 `--dry-run` 就会真正安装：

```bash
conda install -n py-basics wheel
conda list -n py-basics wheel
```

Conda 会在实际改动前再次显示计划并等待确认。安装完成后，查询结果应出现 `wheel` 的版本和来源。查询 `base` 只能看到 `base` 自己的包；不同环境各有自己的安装记录。课堂示例用的是 `wheel`，课后实操会换一个包名，因此不必先运行此示例来增加额外软件。[Conda 安装与验证说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-pkgs.html#installing-packages)

## 示例

当前本机的 `py-basics` 中，`conda list -n py-basics pip` 能查到 `pip 26.2.1`，而查询 `setuptools` 会得到 `No packages match`。这说明查询结果取决于目标环境和包名。`base` 中存在某个包，并不意味着 `py-basics` 中也有它。

## 小结（掌握范围）

- 会用 `conda list -n` 查询指定环境中的包，并理解没有匹配结果的含义。
- 会用 `conda install -n ... --dry-run` 预览安装目标和变更计划。
- 会在确认计划后安装包，再查询目标环境验证结果。
- 能明确把查询和安装操作指向 `py-basics`。

## 课后小实操

### 实操一

在 `py-basics` 中安装 `setuptools`，用于练习在指定环境中增加和核验一个打包工具。它与课堂示例中的 `wheel` 不同；完成后保留安装结果，供后续环境复现练习使用。

**操作步骤**

先查看 `py-basics` 中是否已有 `setuptools`。对 `py-basics` 预览安装计划，确认目标路径和拟变更的包；再执行实际安装，并查询安装后的 `setuptools` 记录。整个过程只修改 `py-basics`。如果检查时发现该包已存在，不要重复安装，按实际情况记录。

请在运行结果中贴出安装前 `py-basics` 的查询结果、预览计划中的目标路径与关键变更行，以及安装后的包记录。下载过程的完整日志不必粘贴；若出现错误，保留原始报错。

**运行结果**

```text
❯ conda list -n py-basics setuptools

CondaValueError: No packages match 'setuptools'.

❯ conda install -n py-basics --dry-run setuptools
2 channel Terms of Service accepted
Channels:
 - defaults
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: done


==> WARNING: A newer version of conda exists. <==
    current version: 26.7.1
    latest version: 26.7.2

Please update conda by running

    $ conda self update



## Package Plan ##

  environment location: /home/ubzy/miniconda3/envs/py-basics

  added / updated specs:
    - setuptools


The following NEW packages will be INSTALLED:

  setuptools         pkgs/main/linux-64::setuptools-83.0.0-py314h06a4308_0 



DryRunExit: Dry run. Exiting.

❯ conda install -n py-basics setuptools
2 channel Terms of Service accepted
Channels:
 - defaults
Platform: linux-64
Collecting package metadata (repodata.json): done
Solving environment: done


==> WARNING: A newer version of conda exists. <==
    current version: 26.7.1
    latest version: 26.7.2

Please update conda by running

    $ conda self update



## Package Plan ##

  environment location: /home/ubzy/miniconda3/envs/py-basics

  added / updated specs:
    - setuptools


The following NEW packages will be INSTALLED:

  setuptools         pkgs/main/linux-64::setuptools-83.0.0-py314h06a4308_0 


Proceed ([y]/n)? y


Downloading and Extracting Packages:

Preparing transaction: done
Verifying transaction: done
Executing transaction: done
WARNING conda.conda_pypi.main:notify_externally_managed_future(156): 
  Did you know? You can install many PyPI packages with conda
  using the conda-pypi beta. Get started:
    https://docs.conda.io/projects/conda/en/stable/new-features.html

❯ conda list -n py-basics setuptools
# packages in environment at /home/ubzy/miniconda3/envs/py-basics:
#
# Name                     Version          Build            Channel
setuptools                 83.0.0           py314h06a4308_0

```
