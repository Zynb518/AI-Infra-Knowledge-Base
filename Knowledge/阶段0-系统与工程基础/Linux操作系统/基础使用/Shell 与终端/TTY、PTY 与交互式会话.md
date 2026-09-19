# TTY、PTY 与交互式会话

## 引入

本课只围绕一个问题展开：

> 终端窗口和 Shell 是两个独立程序，它们究竟通过什么连接？

答案是 PTY。PTY 是一条由软件创建的双向虚拟终端连接；Shell 使用其中的 slave 端，而这个 slave 端向 Shell 提供 TTY 接口。

先记住这句结论，再从一次真实的命令输入过程理解每个概念。

## 核心内容

### 先分清四个对象

| 对象 | 它是什么 | 主要职责 |
| --- | --- | --- |
| 终端模拟器 | 图形窗口程序 | 接收键盘输入、显示字符 |
| Shell | 命令解释程序 | 读取并执行命令 |
| TTY | Linux 的终端设备接口 | 提供终端输入输出、控制字符和前台任务等行为 |
| PTY | 软件创建的伪终端 | 用 master/slave 两端连接终端程序与 Shell |

最容易混淆的是：

- 终端模拟器不是 Shell。
- TTY 不是终端窗口。
- PTY 不是一个命令，而是一对由内核管理的虚拟终端端点。

### 输入一条 `ls` 时发生了什么

现代桌面终端中的连接可以简化为：

~~~text
键盘和屏幕
    ↕
终端模拟器
    ↕
PTY master
    ↕
PTY slave：/dev/pts/0
    ↕
Shell 与当前前台任务
~~~

当你输入 `ls` 并按 Enter：

1. 终端模拟器收到键盘字符 `l`、`s` 和回车。
2. 终端模拟器把这些字符写入 PTY master。
3. 内核通过 PTY 把字符送到 slave 端。
4. Shell 从 PTY slave 读到 `ls`，然后启动 `ls` 程序。
5. `ls` 把结果写回 PTY slave。
6. 终端模拟器从 PTY master 读出结果并显示在窗口中。

因此，Shell 并不直接连接键盘和屏幕。它连接的是 PTY slave；终端模拟器控制另一侧的 PTY master。

### TTY 到底是什么

TTY 最初是 teletypewriter 的缩写，指早期的物理终端。现代 Linux 保留了这个名字，用它表示一套由内核提供的终端设备接口和行为。

对 Shell 来说，TTY 像一个“终端插口”。连接这个插口后，程序不仅可以读写字符，还能获得普通管道没有的终端能力：

- 获取终端窗口大小。
- 识别 `Ctrl-C`、`Ctrl-Z` 等控制字符。
- 记录哪个任务位于前台。
- 配合作业控制向前台任务发送信号。
- 根据终端模式处理输入字符。

常见的 TTY 设备包括：

| 设备 | 含义 |
| --- | --- |
| `/dev/tty1` | Linux 本机虚拟控制台 |
| `/dev/ttyS0` | 串口终端 |
| `/dev/pts/0` | PTY 的 slave 端 |

所以：

> TTY 是 Linux 提供给程序使用的终端接口，不是你看到的窗口。

### PTY 到底是什么

PTY 是 pseudo-terminal，即“伪终端”。它不依赖真实串口或物理终端，而是完全由软件创建。

一个 PTY 必须成对出现：

| PTY 端点 | 谁通常使用 | 作用 |
| --- | --- | --- |
| master | 终端模拟器、SSH 服务端、tmux 等 | 控制虚拟终端，收发字符 |
| slave | Shell 和前台程序 | 表现为一个标准 TTY 设备 |

在 Linux 中，slave 端通常有可见路径：

~~~text
/dev/pts/0
/dev/pts/1
/dev/pts/2
~~~

不同终端会话通常获得不同编号。Shell 通常只需要知道自己的 slave 端，不需要知道 master 由哪个程序控制。

“伪”表示它没有对应的物理终端；对 Shell 来说，它仍然表现得像一个真实 TTY。

所以：

> PTY 是用软件实现的一类 TTY。它通过 master/slave 两端，把终端模拟器和 Shell 连接起来。

### TTY 与 PTY 的关系

可以用两句话区分：

~~~text
TTY：规定一个终端设备应该向程序提供什么接口和行为。
PTY：在软件中创建这种终端，并提供 master 与 slave 两端。
~~~

两者不是互相竞争的概念：

- TTY 是更大的终端设备概念。
- PTY 是现代终端会话中最常见的软件实现。
- PTY slave 对 Shell 表现为 TTY。
- 并非所有 TTY 都是 PTY，例如串口终端 `/dev/ttyS0`。

### `tty` 命令检查什么

`tty` 检查自己的标准输入是否连接到终端设备：

~~~bash
tty
~~~

常见输出是：

~~~text
/dev/pts/0
~~~

它表达的是：

> 当前 `tty` 命令的标准输入连接到 PTY slave `/dev/pts/0`。

它不表示 Shell 本身就是 `/dev/pts/0`，也不表示 `/dev/pts/0` 是终端窗口。它只是 Shell 和程序使用的虚拟终端设备端点。

### 用 `ps` 查看 Shell 的控制终端

下面的命令查看当前 Shell：

~~~bash
ps -p "$$" -o pid,tty,comm
~~~

其中：

- `ps` 查看进程信息。
- `$$` 是当前 Shell 的 PID。
- `-p "$$"` 只选择当前 Shell。
- `-o pid,tty,comm` 显示 PID、控制终端和命令名称。

结果可能是：

~~~text
    PID TT       COMMAND
   3250 pts/0    zsh
~~~

这里的 `pts/0` 通常对应 `tty` 输出的 `/dev/pts/0`。

两条命令观察的角度略有不同：

- `tty` 查看标准输入连接的终端设备。
- `ps` 的 TTY 列查看进程的控制终端。

普通交互式终端中二者通常一致。如果 `ps` 显示 `?`，表示该进程没有控制终端，这在容器或自动化环境中可能出现。

### 为什么管道不是 TTY

直接运行：

~~~bash
tty
~~~

标准输入来自 PTY slave，因此通常输出 `/dev/pts/N`。

通过管道运行：

~~~bash
printf 'test\n' | tty
~~~

连接变成了：

~~~text
printf 的标准输出 → 管道 → tty 的标准输入
~~~

此时 `tty` 的标准输入是管道，不再是终端设备，所以它会报告 `not a tty` 或本地化后的同类提示。

即使提示仍显示在终端窗口中，也不矛盾：

- `tty` 的标准输入连接管道。
- `tty` 的标准输出仍连接终端。

标准输入和标准输出本来就是两条独立通道。

### TTY 为什么能处理 `Ctrl-C` 和 `Ctrl-Z`

PTY 不只传递普通文字。终端模拟器把控制字符写入 master 后，slave 一侧的 TTY 逻辑会识别它们，并把信号发送给当前前台任务：

~~~text
Ctrl-C
  ↓
终端模拟器
  ↓
PTY master → PTY slave
  ↓
TTY 识别控制字符
  ↓
向前台任务发送 SIGINT
~~~

`Ctrl-Z` 的路径类似，但通常产生 `SIGTSTP`，用于暂停前台任务。

这就是 PTY 与普通管道的重要区别：PTY slave 不仅是字节通道，还表现为具有作业控制能力的 TTY。

### 交互式与非交互式 Shell

交互式 Shell 面向用户持续工作，通常会：

- 显示提示符。
- 从终端读取命令。
- 提供历史记录和补全。
- 支持前台、后台与作业控制。

非交互式 Shell 通常执行脚本或单条命令，然后退出：

~~~bash
sh -c 'printf "hello\n"'
~~~

`sh -c` 表示让 `sh` 执行后面的命令字符串。

交互模式和 TTY 经常一起出现，但不是同一个判断：

- “是否交互”描述 Shell 的运行模式。
- “是否有 TTY”描述输入输出是否连接终端设备。

### SSH 中的 PTY

交互式 SSH 登录通常会在远程主机上创建 PTY：

~~~text
本地终端
    ↕
SSH 网络连接
    ↕
远程 sshd
    ↕
远程 PTY master ↔ PTY slave
                         ↕
                     远程 Shell
~~~

直接登录：

~~~bash
ssh server
~~~

通常需要远程 PTY，以便使用提示符、作业控制和控制键。

执行单条远程命令时：

~~~bash
ssh server 'some-command'
~~~

通常不需要 PTY。`ssh -t` 用于明确请求分配远程 PTY：

~~~bash
ssh -t server 'some-command'
~~~

本课只需要理解 `-t` 与“为远程程序提供终端环境”有关。

## 示例：用当前会话验证模型

~~~bash
tty
ps -p "$$" -o pid,tty,comm
~~~

如果输出分别包含 `/dev/pts/0` 和 `pts/0`，可以对应到：

~~~text
终端模拟器
    ↕
PTY master
    ↕
PTY slave：/dev/pts/0
    ↕
当前 Shell：zsh
~~~

这证明的不是“Shell 等于 PTY”，而是“Shell 正通过 PTY slave 使用 TTY 接口”。

## 小结（掌握范围）

本课必须掌握：

- 终端模拟器负责键盘输入和字符显示，Shell 负责解释并执行命令。
- TTY 是 Linux 提供给程序使用的终端设备接口，不是终端窗口。
- PTY 是软件创建的一类 TTY，由 master 和 slave 两端组成。
- 终端模拟器通常使用 PTY master，Shell 和前台程序通常使用 PTY slave。
- `/dev/pts/N` 是 PTY slave 的设备路径。
- `tty` 查看标准输入连接的终端；`/dev/pts/0` 不代表 Shell 本身。
- 管道不是 TTY，因此 `printf 'test\n' | tty` 会报告输入不是终端。
- TTY 会识别控制字符，并把 `SIGINT`、`SIGTSTP` 等信号发送给前台任务。
- 交互式 Shell 与“连接 TTY”密切相关，但二者不是同一个概念。
- SSH 的 `-t` 用于请求远程 PTY。

## 课后小实操

### 实操一

查看当前终端设备，并确认当前 Shell 进程连接的 TTY。这个操作适合排查多个终端、SSH 会话或终端复用环境中的连接关系。

**操作步骤**

~~~bash
printf '标准输入对应的终端：\n'
tty

printf '当前 Shell 进程：\n'
ps -p "$$" -o pid,tty,comm
~~~

**运行结果**

~~~text
❯ printf '标准输入对应的终端：\n'
标准输入对应的终端：
❯ tty
/dev/pts/0
❯ printf '当前 Shell 进程：\n'
当前 Shell 进程：
❯ ps -p "$$" -o pid,tty,comm
    PID TT       COMMAND
   3250 pts/0    zsh
~~~

**概括**

请用一段话概括：`tty` 显示了什么，`$$` 代表什么，以及 `ps` 中的 TTY 列与 `/dev/pts/N` 有什么关系。

### 实操二

比较终端输入与管道输入，让 `tty` 分别检查两种标准输入来源。

**操作步骤**

~~~bash
printf '直接运行 tty：\n'
tty

printf '把管道接到 tty 的标准输入：\n'
printf 'test\n' | tty
printf '上一条管道的退出状态：%s\n' "$?"
~~~

第二次 `tty` 可能显示 `not a tty` 或对应的本地化提示，并返回非零退出状态。

**运行结果**

~~~text

~~~

**概括**

请用一段话概括：为什么直接运行 `tty` 能显示 `/dev/pts/N`，而通过管道运行时会报告输入不是 TTY；同时说明标准输入与标准输出为什么可以连接到不同位置。
