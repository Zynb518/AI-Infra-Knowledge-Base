# 更新与移除 Conda 包

## 引入

上一课已把 `setuptools` 安装进 `py-basics`。以后遇到新版本或不再需要某个包时，要先确认操作针对哪个环境、Conda 打算改动哪些包，再决定是否执行。

本课用已安装的 `setuptools` 练习更新与移除。实操结束时会把它装回去，保留 `py-basics` 供后续课程使用。[Conda 包管理指南](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-pkgs.html)分别介绍了更新和移除命令。

## 核心内容

### 更新前先看当前版本和计划

```bash
conda list -n py-basics setuptools
conda update -n py-basics --dry-run setuptools
```

第一条确认 `py-basics` 中现有的版本。第二条让 Conda 查找兼容的新版本并显示计划；`-n py-basics` 指定目标环境，`--dry-run` 不执行变更。若显示已是可用的兼容版本，就不需要实际更新；若列出更新计划，先看目标环境路径、包的版本变化以及其他受影响的包，再决定是否执行。[官方更新包说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-pkgs.html#updating-packages)

真正更新时去掉 `--dry-run`：

```bash
conda update -n py-basics setuptools
```

这条命令会在更改前展示计划并等待确认；执行后再用 `conda list -n py-basics setuptools` 核对版本。版本变化由当前仓库中可用的软件包决定，不能仅凭收到“有更新”的提示推断已经更新。

### 移除前确认影响范围

```bash
conda remove -n py-basics --dry-run pip
```

这里拿已安装的 `pip` 做预览示例，**不实际移除它**。`remove` 表示从指定环境移除包，`--dry-run` 只展示将要移除或改变的内容。Conda 可能连带移除依赖该包的其他包，因此要先看计划；如果计划中出现你仍需要的包，就停止操作。不要把 `--all` 加在本课命令上，它表示移除整个环境。[官方移除包说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-pkgs.html#removing-packages)

确认计划只涉及可接受的变更后，去掉 `--dry-run` 才会实际移除。以下的 `PACKAGE` 是占位文字，输入命令时要替换成真实包名；随后用查询命令核对：

```bash
conda remove -n py-basics PACKAGE
conda list -n py-basics PACKAGE
```

移除后，查询应提示没有匹配的包。这表示该包不在目标环境中；`py-basics` 环境仍存在。若要恢复，可使用上节课学过的安装命令：

```bash
conda install -n py-basics PACKAGE
conda list -n py-basics PACKAGE
```

恢复后再次查到该包，才说明移除与恢复流程结束。重新安装得到的小版本可能随软件仓库更新而变化，核对包名和目标环境路径比要求版本号完全相同更重要。

## 示例

当前本机查询 `py-basics`，能看到 `setuptools 83.0.0`。如果更新预览显示没有可执行的更新，保留现状即可。对 `pip` 做移除预览后再查询，仍能查到它，因为预览没有改变环境。课后实操会改用 `setuptools` 完成实际移除与恢复；这里要观察的是预览与实际操作的区别，而不是记住固定版本号。

## 小结（掌握范围）

- 能区分更新、移除与重新安装分别会对目标环境产生什么影响。
- 会在更新或移除前查看计划，并核对目标环境和受影响的包。
- 会在操作后查询结果，判断包是否仍在 `py-basics` 中。
- 能恢复本课临时移除的包，使练习环境保持可用。

## 课后小实操

### 实操一

对 `py-basics` 中的 `setuptools` 完成一次“检查更新 → 移除 → 恢复”的练习。课堂用 `pip` 演示移除预览；本题改用 `setuptools` 做实际移除与恢复，并用每一步的结果判断下一步是否合适。

**操作步骤**

先记录当前版本，预览更新并判断是否真的有版本变更；本次只观察更新计划，不执行实际更新。再预览移除计划，确认目标是 `py-basics`，且没有打算保留却会被连带移除的包。确认后实际移除，查询是否已无匹配包。最后重新安装 `setuptools`，查询它是否恢复。若预览计划不符合预期，停止并贴出计划，不继续执行移除。

运行结果只需保留更新预览结论、移除计划的目标与关键变更行、移除后的查询，以及恢复后的包记录；无需粘贴完整下载日志。

**运行结果**

以下保留关键输出，省略重复的元数据与下载日志。

```text
❯ conda update -n py-basics --dry-run setuptools
# All requested packages already installed.

❯ conda remove -n py-basics --dry-run setuptools
## Package Plan ##
  environment location: /home/ubzy/miniconda3/envs/py-basics
  removed specs:
    - setuptools
The following packages will be REMOVED:
  setuptools-83.0.0-py314h06a4308_0
DryRunExit: Dry run. Exiting.

❯ conda remove -n py-basics setuptools
The following packages will be REMOVED:
  setuptools-83.0.0-py314h06a4308_0
Proceed ([y]/n)? y
Executing transaction: done

❯ conda list -n py-basics setuptools
CondaValueError: No packages match 'setuptools'.

❯ conda install -n py-basics setuptools
## Package Plan ##
  environment location: /home/ubzy/miniconda3/envs/py-basics
The following NEW packages will be INSTALLED:
  setuptools         pkgs/main/linux-64::setuptools-83.0.0-py314h06a4308_0
Proceed ([y]/n)? y
Executing transaction: done
```
