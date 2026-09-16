# Shell、终端与 TTY

## 学习目标

完成本篇后，应当能够：

- 区分终端、TTY、PTY、Shell 和普通命令行程序。
- 解释从键盘输入一条命令到程序开始运行的大致过程。
- 判断一条命令是 Shell 内建命令、别名、函数还是外部程序。
- 正确理解当前 Shell、登录 Shell、交互式 Shell 和非交互式 Shell。
- 使用进程号、父进程号和终端信息观察当前会话。

## 核心模型

```text
用户键盘输入
    ↓
终端模拟器
    ↓
PTY master ↔ PTY slave
                    ↓
                  Shell
                    ↓
       解析命令、展开参数、处理重定向
                    ↓
          内建命令或外部可执行程序
                    ↓
              输出返回终端
```

### 终端

早期终端是连接计算机的物理设备。现代 Linux 桌面和远程开发环境中看到的终端，通常是一个终端模拟器，例如 GNOME Terminal、Konsole、iTerm2 或 Windows Terminal。

终端主要负责：

- 接收键盘输入。
- 显示字符输出。
- 处理窗口大小、颜色和部分控制序列。
- 为前台程序提供一个终端设备。

终端本身不负责理解 `cd`、`ls` 或管道等 Shell 语法。

### TTY 与 PTY

TTY 是 Linux 对终端设备的一类抽象。PTY 是伪终端，由一对设备组成：

- PTY master 通常由终端模拟器或 SSH 服务端控制。
- PTY slave 表现得像一个终端设备，Shell 和其他前台程序连接到它。

执行下面的命令可以查看当前标准输入连接的终端设备：

```bash
tty
```

常见结果类似 `/dev/pts/0`。其中 `pts` 表示伪终端从设备。在没有分配终端的脚本、管道或自动化环境中，也可能得到 `not a tty`。

### Shell

Shell 是读取并解释命令的程序。常见 Shell 包括 Bash、Zsh、Dash 和 Fish。

Shell 主要负责：

- 显示提示符并读取输入。
- 解析命令及参数。
- 执行变量展开、通配符展开和命令替换。
- 建立重定向与管道。
- 执行内建命令。
- 查找并启动外部程序。
- 管理前台与后台任务。

### 命令行程序

`ls`、`ps` 和 `git` 等通常是独立的可执行程序。Shell 找到它们后启动新进程，并根据需要等待程序结束。

并非所有命令都是外部程序。例如 `cd` 必须由当前 Shell 自己执行，因为子进程无法改变父进程的当前工作目录。

## 一条命令是怎样执行的

以输入 `ls -la` 为例，可以建立下面的简化过程：

1. 终端模拟器把键盘输入传给 PTY。
2. Shell 从 PTY 读取到 `ls -la`。
3. Shell 将输入解析为命令 `ls` 和参数 `-la`。
4. Shell 判断它是否为别名、函数或内建命令。
5. 如果是外部命令，Shell 根据 `PATH` 查找可执行文件。
6. Shell 创建执行环境并启动程序。
7. `ls` 的标准输出通过 PTY 返回终端模拟器。
8. 程序结束后，Shell 记录退出状态并重新显示提示符。

这是后续理解进程、文件描述符、管道、重定向和信号的基础。

## 观察当前会话

### 当前 Shell 进程

```bash
ps -p "$$" -o pid,ppid,tty,stat,comm,args
```

需要关注：

- `PID`：当前 Shell 的进程号。
- `PPID`：启动当前 Shell 的父进程号。
- `TTY`：Shell 连接的终端。
- `STAT`：进程当前状态。
- `COMMAND` 或 `ARGS`：实际运行的程序与参数。

继续观察父进程：

```bash
parent_pid=$(ps -p "$$" -o ppid=)
ps -p "$parent_pid" -o pid,ppid,tty,stat,comm,args
```

不同环境中的父进程可能是终端模拟器、SSH 服务、`tmux`、容器入口进程或其他会话管理程序。

### 当前 Shell 与默认登录 Shell

```bash
printf 'SHELL=%s\n' "$SHELL"
ps -p "$$" -o comm=
```

`SHELL` 环境变量通常表示用户配置的默认登录 Shell，不保证就是当前正在运行的 Shell。观察当前进程比只读取 `SHELL` 更可靠。

### 是否为交互式 Shell

```bash
case $- in
  *i*) printf '%s\n' 'interactive shell' ;;
  *)   printf '%s\n' 'non-interactive shell' ;;
esac
```

交互式 Shell 面向用户会话，通常显示提示符并支持任务控制；非交互式 Shell 通常用于执行脚本或单条命令。

登录 Shell 与交互式 Shell 是两个不同维度。登录 Shell 表示它处于登录会话入口位置，并会按照对应 Shell 的规则读取启动文件；交互式 Shell 表示它正在与用户交互。

## 判断命令来自哪里

可以使用 `type` 或 `command -V` 检查 Shell 将如何解释一个命令：

```bash
type cd
type ls
type printf
command -V cd
command -V ls
```

可能的类型包括：

- alias：别名。
- function：Shell 函数。
- builtin：Shell 内建命令。
- 外部可执行文件：通过明确路径或 `PATH` 找到的程序。

查看 `PATH` 中的搜索目录：

```bash
printf '%s\n' "$PATH" | tr ':' '\n'
```

Shell 通常按照目录出现的先后顺序查找外部命令。因此，同名程序可能因为 `PATH` 顺序不同而解析到不同位置。

## 退出状态

程序或内建命令结束后会留下一个退出状态。通常以 `0` 表示成功，以非零值表示不同类型的失败。

```bash
true
printf 'true: %s\n' "$?"

false
printf 'false: %s\n' "$?"
```

`$?` 只保存最近一条命令的退出状态，因此应当在目标命令结束后立即读取。

退出状态是后续学习条件执行、Shell 脚本错误处理和自动化任务可靠性的基础。

## 动手实验

### 实验一：记录终端与进程关系

依次执行：

```bash
tty
ps -p "$$" -o pid,ppid,tty,stat,comm,args
```

记录并解释：

1. 当前终端设备是什么？
2. 当前 Shell 的 PID 和 PPID 是什么？
3. `ps` 显示的 Shell 名称与 `SHELL` 环境变量是否一致？

### 实验二：启动一个子 Shell

根据系统中已有的 Shell，选择执行 `bash` 或 `zsh`：

```bash
bash
ps -p "$$" -o pid,ppid,tty,stat,comm,args
exit
```

观察子 Shell 与原 Shell 的 PID、PPID 和 TTY：

- PID 应当发生变化。
- 子 Shell 的 PPID 应指向外层 Shell。
- 两层 Shell 通常连接到同一个 TTY。
- `exit` 只结束当前子 Shell，并返回外层 Shell。

### 实验三：区分内建命令与外部程序

```bash
type cd
type pwd
type ls
type ps
```

思考为什么 `cd` 必须是内建命令，以及 `pwd` 为什么可能同时存在内建版本和外部程序版本。

## 常见误区

### 终端就是 Shell

终端负责输入输出界面，Shell 负责解释和执行命令。可以在同一个终端中运行不同 Shell，也可以在没有交互终端的情况下运行 Shell 脚本。

### `SHELL` 就是当前 Shell

`SHELL` 通常表示默认登录 Shell。当前进程可能已经切换为其他 Shell，应结合 `ps` 观察。

### 所有命令都是可执行文件

别名、Shell 函数和内建命令不需要对应独立的可执行文件。使用 `type` 可以判断实际来源。

### 关闭终端一定会立即结束所有程序

关闭终端通常会影响该终端关联的会话和作业，但具体结果还受到信号处理、`nohup`、`tmux`、systemd 以及父子进程关系等因素影响。

## 自测问题

1. 终端模拟器、PTY 和 Shell 分别承担什么职责？
2. 为什么 `cd` 不能只实现为一个普通外部程序？
3. 为什么 `echo "$SHELL"` 不能可靠证明当前运行的是哪个 Shell？
4. Shell 在执行外部命令之前需要完成哪些工作？
5. 交互式 Shell 和登录 Shell 有什么区别？
6. `tty`、PID 和 PPID 分别能帮助观察什么？

## 本篇小结

```text
终端模拟器负责交互界面
  ↓
PTY 提供终端设备抽象
  ↓
Shell 读取并解释命令
  ↓
内建命令在当前 Shell 中执行
外部命令由 Shell 查找并启动
  ↓
程序输出回到终端，Shell 保存退出状态
```

返回：[Linux 与操作系统知识地图](../../知识地图.md)
