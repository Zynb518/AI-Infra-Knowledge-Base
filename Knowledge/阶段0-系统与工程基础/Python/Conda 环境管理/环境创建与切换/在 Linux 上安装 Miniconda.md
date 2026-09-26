# 在 Linux 上安装 Miniconda

## 引入

Conda 是管理软件包和独立环境的工具，Miniconda 是提供 Conda 和基础 Python 的轻量安装程序。先装好工具，后续才能练习创建和切换环境。

这台电脑目前是 Linux Mint 22.3、`x86_64` 架构，日常 Shell 是 zsh；编写本课时，终端找不到 `conda`。本课选用 Miniconda，在当前用户的家目录安装，不需要 `sudo`，也不会覆盖系统自带的 `/usr/bin/python3`。[Conda 安装说明](https://docs.conda.io/projects/conda/en/stable/user-guide/install/)指出，安装到用户可写目录不需要管理员权限。

## 核心内容

### 先确认系统与已有安装

在终端输入：

```bash
uname -s -m
echo "$SHELL"
command -v conda
ls -ld "$HOME/miniconda3"
```

`uname -s -m` 显示系统和 CPU 架构；本机应看到 `Linux x86_64`。`echo "$SHELL"` 显示正在使用的 Shell 路径，本机是 `/usr/bin/zsh`。`command -v conda` 检查终端能否找到 Conda；`ls -ld` 则显示目标目录本身的详细信息，用来判断默认安装位置是否已占用。若 `command -v conda` 没有输出，或 `ls` 提示目录不存在，这是尚未安装时的正常现象；若发现已有安装，先确认位置，不要再次运行安装程序。

### 下载并核对安装程序

本机架构对应官方的 `Miniconda3-latest-Linux-x86_64.sh`。用 `curl` 下载到家目录，保存为一个容易辨认的本地文件名：

```bash
curl -fL -o "$HOME/miniconda-linux.sh" "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
```

`-f` 使 HTTP 错误成为失败，`-L` 跟随跳转，`-o` 指定保存位置。下载后计算文件的 SHA-256 摘要：

```bash
sha256sum "$HOME/miniconda-linux.sh"
```

输出的第一段是 64 位十六进制摘要。打开[官方 Miniconda 安装程序索引](https://repo.anaconda.com/miniconda/)，找到 `Miniconda3-latest-Linux-x86_64.sh` 这一行，把 `SHA256` 列与本机输出逐字比较。摘要不一致时不要运行安装程序；官方 [Linux 安装步骤](https://docs.conda.io/projects/conda/en/stable/user-guide/install/linux.html)也要求先校验再安装。`latest` 对应的文件会更新，因此以下载时官方索引显示的摘要为准。

### 安装并初始化 zsh

确认摘要一致后，用 Bash 运行安装程序：

```bash
bash "$HOME/miniconda-linux.sh"
```

按屏幕提示阅读许可条款，选择是否接受，并确认安装位置。本课使用 `$HOME/miniconda3`；如果安装器给出的默认位置就是该目录，可以直接采用。安装器询问是否自动初始化 Shell 时，选择 `no`，随后明确为本机的 zsh 初始化：

```bash
"$HOME/miniconda3/bin/conda" init zsh
```

这里使用安装目录中的 Conda 程序，是因为当前终端还找不到 `conda`。`init zsh` 会更新当前用户的 zsh 启动配置，使以后打开的终端能够使用 Conda；它不负责创建学习环境。若安装时选择了别的目录，要把上述路径换成实际位置。完成后关闭并重新打开终端，让配置生效。新终端可能自动进入 Miniconda 自带的 `base` 环境，此时 `python3` 命令可能优先找到 Miniconda 中的版本，但系统的 `/usr/bin/python3` 文件未被覆盖。[`conda init` 文档](https://docs.conda.io/projects/conda/en/stable/commands/init.html)说明了 Shell 参数以及重启终端的要求。

### 在新终端确认结果

重新打开终端后运行：

```bash
conda --version
conda info --base
```

第一条应显示 Conda 版本；第二条应显示安装根目录，例如 `/home/ubzy/miniconda3`。还可以使用 `conda list` 查看基础环境中已有的软件包，确认 Conda 可以读取该环境。[Conda Linux 安装步骤](https://docs.conda.io/projects/conda/en/stable/user-guide/install/linux.html)把 `conda list` 作为安装后的检查命令。

若新终端仍提示找不到 `conda`，先核对安装路径和 `init zsh` 的输出，再确认终端确实已重新打开；不要重复运行安装程序。

## 示例

以本机安装前的检查为例，`uname -s -m` 返回 `Linux x86_64`，`echo "$SHELL"` 返回 `/usr/bin/zsh`，因此应选择 Linux `x86_64` 安装程序，并为 zsh 执行初始化。按上面的下载命令操作时，安装程序会保存在 `$HOME/miniconda-linux.sh`；安装时选用 `$HOME/miniconda3`。之后在新终端查看版本和根目录；具体版本号以实际下载到的安装程序为准，不需要与别人的输出相同。

## 小结（掌握范围）

- 能根据本机架构选择对应的 Miniconda 安装程序。
- 能从官方地址下载程序，并把本机 SHA-256 摘要与官方记录核对。
- 能在自己的家目录安装 Miniconda，知道 `conda init zsh` 的作用。
- 能在新终端用 Conda 版本和安装根目录判断是否安装成功。

## 课后小实操

### 实操一

在本机完成一次 Miniconda 安装与验证。练习时把下载文件保存为 `$HOME/miniconda-practice.sh`，与课堂示例使用不同的本地文件名；安装位置仍使用 `$HOME/miniconda3`。

**操作步骤**

先确认架构、Shell 和目标安装目录状态，再从官方地址下载对应程序。计算下载文件的 SHA-256 摘要，与官方索引中同名安装程序的记录核对，一致后才运行安装器。完成 zsh 初始化并重新打开终端，检查 Conda 版本、安装根目录，以及基础环境的软件包列表。若检查时发现 Conda 已安装，保留现有安装，直接完成验证。

请在运行结果中贴出架构与 Shell、摘要及对应的官方记录、Conda 版本、安装根目录，以及 `conda list` 的前几行实际输出。下载或安装遇到错误时，也请贴出原始报错。

**运行结果**

```text
❯ uname -s -m
Linux x86_64
❯ echo "$SHELL"
/usr/bin/zsh

❯ curl -fL -o "$HOME/miniconda-linux.sh" "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  188M  100  188M    0     0   9.9M      0  0:00:18  0:00:18 --:--:-- 10.9M
❯ sha256sum "$HOME/miniconda-linux.sh"
e8b25b92b262499141c5bd57a98d3c008024185fa951494b9cd9b6d94e72338b  /home/ubzy/miniconda-linux.sh
❯ a="e8b25b92b262499141c5bd57a98d3c008024185fa951494b9cd9b6d94e72338b"
❯ b=e8b25b92b262499141c5bd57a98d3c008024185fa951494b9cd9b6d94e72338b
❯ if [ "$a" = "$b" ]; then
      printf 'a=b? 是\n'
  else
      printf 'a=b? 否\n'
  fi
a=b? 是
❯ bash "$HOME/miniconda-linux.sh"

Welcome to Miniconda3 py314_26.7.1-1
... 略

❯ "$HOME/miniconda3/bin/conda" init zsh
no change     /home/ubzy/miniconda3/condabin/conda
no change     /home/ubzy/miniconda3/bin/conda
no change     /home/ubzy/miniconda3/bin/activate
no change     /home/ubzy/miniconda3/bin/deactivate
no change     /home/ubzy/miniconda3/etc/profile.d/conda.sh
no change     /home/ubzy/miniconda3/etc/fish/conf.d/conda.fish
no change     /home/ubzy/miniconda3/shell/condabin/Conda.psm1
no change     /home/ubzy/miniconda3/shell/condabin/conda-hook.ps1
no change     /home/ubzy/miniconda3/lib/python3.14/site-packages/xontrib/conda.xsh
no change     /home/ubzy/miniconda3/etc/profile.d/conda.csh
modified      /home/ubzy/.zshrc

==> For changes to take effect, close and re-open your current shell. <==

❯ conda --version
conda 26.7.1
❯ conda info --base
/home/ubzy/miniconda3
❯ conda list
# packages in environment at /home/ubzy/miniconda3:
#
# Name                      Version          Build               Channel
_libgcc_mutex               0.1              main
_openmp_mutex               5.1              52_gnu
anaconda-anon-usage         0.8.1            pyhb46e38b_100
anaconda-auth               0.15.2           py314h06a4308_0

```
