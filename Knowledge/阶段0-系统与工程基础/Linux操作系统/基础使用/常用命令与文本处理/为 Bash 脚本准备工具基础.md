# 为 Bash 脚本准备工具基础

## 引入

一个 Bash 脚本通常不是自己完成所有工作，而是把多个已有命令组织起来：先查找文件，再统计数量；先生成结果，再保存报告；一个命令成功后才继续下一步。

在正式学习脚本语法前，先掌握几种常见的命令组合方式：

- 用命令替换把一个命令的输出放进另一个命令中。
- 用 `&&`、`||` 和 `;` 根据命令是否成功决定下一步。
- 用 `tee` 同时在终端查看结果并保存结果。
- 用 `xargs` 把标准输入中的多行内容转换成另一个命令的参数。

这些能力是把“手动执行的一串命令”逐步变成“可重复执行的脚本”的基础。

## 核心内容

### 用命令替换取得命令输出

命令替换的写法是 `$(...)`。括号里的命令会先执行，它的输出会替换到外层命令中：

~~~
file_count=$(find /tmp -maxdepth 1 -type f | wc -l)
printf '临时目录中的文件数量：%s\n' "$file_count"
~~~

执行过程可以理解为：

1. 执行 `find /tmp -maxdepth 1 -type f | wc -l`。
2. 把统计结果放入变量 `file_count`。
3. 用 `printf` 输出这个结果。

变量展开时要保留双引号：

~~~
result=$(printf 'api worker\n')
printf '结果是：%s\n' "$result"
~~~

命令替换适合取得一个命令的结果，再把结果交给变量、判断或下一个命令。不要把它和反引号写法混用；现代 Bash 中优先使用 `$(...)`，因为可以嵌套，阅读也更清楚。

### 根据退出状态继续执行

命令除了产生输出，还会产生退出状态。通常退出状态为 `0` 表示成功，非 `0` 表示失败。

`&&` 表示“前一个命令成功，才执行后一个命令”：

~~~
mkdir -p /tmp/command-chain-practice && printf '目录已创建\n'
~~~

`||` 表示“前一个命令失败，才执行后一个命令”：

~~~
test -f /tmp/command-chain-practice/input.txt || printf '输入文件不存在\n'
~~~

`;` 表示“前一个命令结束后，无论成功还是失败，都继续执行”：

~~~
printf '第一步结束\n' ; printf '第二步开始\n'
~~~

常见用途是把前置条件和后续动作连起来：

~~~
test -f input.txt && printf '开始处理文件\n' || printf '无法处理：文件不存在\n'
~~~

这里的 `test -f input.txt` 检查路径是否为普通文件。`&&` 和 `||` 适合简单的成功/失败分支；复杂判断会在 Bash 脚本主题中使用 `if` 等语法详细学习。

### 用 `tee` 一边查看一边保存

普通重定向会把结果写入文件，终端看不到结果：

~~~
printf 'api\nworker\n' > /tmp/services.txt
~~~

`tee` 会把标准输入复制两份：一份写入文件，一份继续输出到终端：

~~~
printf 'api\nworker\n' | tee /tmp/services.txt
~~~

这样既能立即看到结果，又能留下文件供后续命令使用。默认情况下，`tee` 会覆盖目标文件；使用 `-a` 可以追加：

~~~
printf 'database\n' | tee -a /tmp/services.txt
~~~

`tee` 常用于记录命令输出、生成中间文件和排查管道中的实际数据。

### 用 `xargs` 把输入转换成参数

管道默认把前一个命令的标准输出交给后一个命令的标准输入，但有些命令更适合接收“命令行参数”。`xargs` 就是把输入内容转换为后续命令的参数：

~~~
printf '/tmp/a.txt\n/tmp/b.txt\n' | xargs -n 1 file
~~~

可以把它理解成近似执行：

~~~
file /tmp/a.txt
file /tmp/b.txt
~~~

`-n 1` 表示每次只取一个输入项，执行一次 `file`。不使用 `-n 1` 时，`xargs` 通常会尽量把多个输入项合并到一次命令调用中，以减少启动次数。

文件名可能包含空格或换行时，使用普通换行分隔输入不够安全。此时让 `find` 使用空字符分隔，`xargs` 使用 `-0` 接收：

~~~
find /tmp -maxdepth 1 -type f -print0 | xargs -0 file
~~~

这里的 `-print0` 和 `-0` 必须配套使用。它们能让带空格的文件名作为一个完整参数传递给 `file`。

## 示例：生成并检查一份文件报告

下面的命令模拟一个脚本前置流程：创建练习文件，统计文件数量，把统计结果保存并显示，再使用 `xargs` 批量查看文件类型。

~~~
work=/tmp/script-tools-practice
mkdir -p "$work/reports"
printf 'api response\n' > "$work/api.log"
printf 'worker response\n' > "$work/worker log.txt"

file_count=$(find "$work" -type f | wc -l)
printf 'file count: %s\n' "$file_count" | tee "$work/reports/summary.txt"

find "$work" -type f -print0 | xargs -0 file | sort
~~~

这个流程中，`find` 提供文件列表，`wc` 统计数量，`printf` 生成报告，`tee` 保存并显示报告，`xargs` 把文件列表转换成 `file` 的参数，最后再交给 `sort` 排序。

## 小结（掌握范围）

本课必须掌握：

- 会使用 `$(...)` 获取命令输出，并把结果保存到变量。
- 知道变量展开时使用双引号，例如 `"$result"`。
- 知道退出状态中 `0` 通常表示成功，非 `0` 表示失败。
- 会使用 `&&` 表示成功后继续，使用 `||` 表示失败后执行，使用 `;` 表示无论结果都继续。
- 会使用 `tee` 同时显示并保存管道输入，知道 `tee -a` 用于追加。
- 理解 `xargs` 会把标准输入转换为后续命令的参数。
- 处理可能包含空格的文件名时，会配套使用 `find -print0 | xargs -0`。

## 课后小实操

### 实操一

创建几个本地文件，使用命令替换统计普通文件数量，并通过 `tee` 同时显示和保存统计结果；再用 `&&` 确认报告已经生成。

**操作步骤**

~~~
work=/tmp/script-tools-practice-one
mkdir -p "$work"
printf 'api\n' > "$work/api.txt"
printf 'worker\n' > "$work/worker.txt"

count=$(find "$work" -maxdepth 1 -type f | wc -l)
printf 'file count: %s\n' "$count" | tee "$work/summary.txt"
test -f "$work/summary.txt" && printf 'summary created\n'
~~~

**运行结果**

~~~text
❯ work=/tmp/script-tools-practice-one
❯ mkdir -p "$work"
❯ printf 'api\n' > "$work/api.txt"
❯ printf 'worker\n' > "$work/worker.txt"
❯ count=$(find "$work" -maxdepth 1 -type f | wc -l)
❯ printf 'file count: %s\n' "$count" | tee "$work/summary.txt"
file count: 3
❯ test -f "$work/summary.txt" && printf 'summary created\n'
summary created
~~~

### 实操二

创建一个带空格的文件名，使用 `find -print0 | xargs -0 file` 批量查看文件类型，观察它仍然会被当成一个完整路径处理。

**操作步骤**

~~~
work=/tmp/script-tools-practice-two
mkdir -p "$work"
printf 'normal file\n' > "$work/normal.txt"
printf 'file with spaces\n' > "$work/file with spaces.txt"

find "$work" -type f -print0 | xargs -0 file | sort
~~~

**运行结果**

~~~text
❯ work=/tmp/script-tools-practice-two
❯ mkdir -p "$work"
❯ printf 'normal file\n' > "$work/normal.txt"
❯ printf 'file with spaces\n' > "$work/file with spaces.txt"
❯ find "$work" -type f -print0 | xargs -0 file | sort
/tmp/script-tools-practice-two/file with spaces.txt: ASCII text
/tmp/script-tools-practice-two/normal.txt:           ASCII text

~~~
