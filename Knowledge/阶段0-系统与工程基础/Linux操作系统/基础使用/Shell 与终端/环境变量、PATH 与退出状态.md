# 环境变量、PATH 与退出状态

## 引入

命令可以读取当前用户、主目录和程序搜索路径等信息，也会在结束时告诉 Shell 自己是否执行成功。环境变量负责把配置传给程序，`PATH` 决定外部命令从哪里查找，退出状态则表示命令执行结果。

把这三部分联系起来后，就能解释“为什么某个命令在这个终端里能运行、换个环境却找不到”，也能让后续命令根据前一步是否成功决定是否继续。

## 核心内容

### Shell 变量

Shell 变量是在当前 Shell 中保存的名称和值：

~~~bash
course_name='Linux Shell'
printf '%s\n' "$course_name"
~~~

变量赋值时，等号两边不能有空格。读取变量时，在名称前加 `$`；变量作为文本或路径使用时，通常应写在双引号中。

变量名一般由字母、数字和下划线组成，但不能以数字开头。普通 Shell 变量常使用小写名称，环境变量通常使用大写名称，这是一种常见约定，并非语法强制要求。

### 环境变量与 `export`

普通 Shell 变量只保存在当前 Shell 中。环境变量会传给从当前 Shell 启动的程序。

可以用 `export` 把变量放入环境：

~~~bash
COURSE_NAME='Linux Shell'
export COURSE_NAME
~~~

也可以合并成一行：

~~~bash
export COURSE_NAME='Linux Shell'
~~~

关系可以简化为：

~~~text
当前 Shell 中的变量
        ↓ export
当前 Shell 的环境变量
        ↓ 启动程序时继承
子进程或外部命令
~~~

`export` 不会把变量永久写入系统配置，它只影响当前 Shell 以及之后由它启动的程序。关闭终端后，这次设置通常会消失。

### 查看和删除变量

`printf` 可以显示当前 Shell 中的变量：

~~~bash
printf '%s\n' "$COURSE_NAME"
~~~

`printenv` 用来读取环境变量：

~~~bash
printenv COURSE_NAME
~~~

如果变量没有被导出，`printenv` 通常不会显示内容，并返回非零退出状态。

`unset` 可以从当前 Shell 中删除变量：

~~~bash
unset COURSE_NAME
~~~

常见环境变量包括：

| 变量 | 常见含义 |
| --- | --- |
| `HOME` | 当前用户的主目录 |
| `USER` | 当前用户名 |
| `SHELL` | 用户配置的默认登录 Shell |
| `PATH` | 外部命令的搜索目录 |
| `LANG` | 语言和区域设置 |

### `PATH` 如何查找命令

`PATH` 是一组用冒号分隔的目录：

~~~bash
printf '%s\n' "$PATH"
~~~

内容通常类似：

~~~text
/usr/local/bin:/usr/bin:/bin
~~~

输入一个外部命令时，Shell 会按照从左到右的顺序，在这些目录中寻找同名的可执行文件。找到第一个符合条件的文件后，就使用它。

例如输入：

~~~bash
ls
~~~

Shell 可能先检查 `/usr/local/bin/ls`，再检查 `/usr/bin/ls`。如果在 `/usr/bin` 找到，就执行那个文件。

Shell 内建命令、别名和函数的解析还会经过其他规则；本课中的 `PATH` 主要讨论外部程序的查找。

### 用 `command -v` 查看命令来源

`command -v` 会显示 Shell 准备使用的命令来源：

~~~bash
command -v ls
command -v git
~~~

对于外部程序，结果通常是完整路径，例如：

~~~text
/usr/bin/ls
/usr/bin/git
~~~

如果命令不存在，`command -v` 通常没有输出，并返回非零退出状态。它适合排查“命令是否安装”“Shell 实际会运行哪一个程序”等问题。

`command -v` 是本课需要掌握的简洁检查方式；更详细的 `command -V` 可以在需要时再使用。

### 临时扩展 `PATH`

如果自己安装的程序位于 `$HOME/bin`，可以临时把该目录放到搜索路径前面：

~~~bash
export PATH="$HOME/bin:$PATH"
~~~

这里保留了原来的 `$PATH`，并把新目录放在最前面，因此同名程序会优先从 `$HOME/bin` 查找。

不要直接写成下面这样：

~~~bash
export PATH="$HOME/bin"
~~~

这种写法会丢掉原有搜索目录，导致 `ls`、`git` 等常用外部命令可能无法找到。

当前目录通常不会自动包含在 `PATH` 中。要运行当前目录下的程序，一般明确写出相对路径：

~~~bash
./my-program
~~~

这种设计可以避免 Shell 意外执行当前目录中的同名文件。

### 命令的退出状态

每个命令结束时都会返回一个整数状态：

- `0` 通常表示成功。
- 非零值表示命令未成功完成，具体数字由命令定义。

`$?` 保存最近一条命令的退出状态：

~~~bash
true
printf 'true 的退出状态：%s\n' "$?"

false
printf 'false 的退出状态：%s\n' "$?"
~~~

`true` 是一个总是成功的命令，返回 0；`false` 是一个总是失败的命令，返回非零状态。

`$?` 只保存最近一条命令的状态。读取它之前如果又执行了其他命令，原来的状态就会被覆盖，因此应当紧接着检查。

### 根据退出状态决定是否继续

`&&` 表示左侧命令成功后才执行右侧命令：

~~~bash
command -v git && printf 'git 可以使用\n'
~~~

`||` 表示左侧命令失败后才执行右侧命令：

~~~bash
command -v command_that_should_not_exist || printf '命令不存在\n'
~~~

这种写法适合执行前置检查。例如，确认程序存在后再继续，或者在命令失败时输出明确提示。

## 示例：检查命令并读取退出状态

~~~bash
command -v git
printf 'git 检查结果：%s\n' "$?"

command -v command_that_should_not_exist
printf '不存在命令的检查结果：%s\n' "$?"
~~~

第一条检查通常会显示 Git 的路径并返回 0；第二条检查通常不显示路径并返回非零状态。这里必须在每次 `command -v` 后立即读取 `$?`。

## 小结（掌握范围）

本课必须掌握：

- 能区分普通 Shell 变量和环境变量。
- 会使用 `export` 导出环境变量，使用 `printenv` 查看环境变量，使用 `unset` 删除变量。
- 知道 `PATH` 是按从左到右顺序查找外部命令的一组目录。
- 会使用 `command -v` 检查命令来源或判断命令是否存在。
- 能看懂 `export PATH="$HOME/bin:$PATH"`，并知道不能随意覆盖原有 `PATH`。
- 知道退出状态 0 通常表示成功，非零表示未成功完成。
- 会在目标命令后立即使用 `$?` 查看退出状态。
- 会使用 `&&` 在成功后继续，使用 `||` 在失败后处理。

## 课后小实操

### 实操一

观察普通 Shell 变量在导出前后的区别，并使用退出状态确认 `printenv` 是否成功找到环境变量。

**操作步骤**

~~~bash
COURSE_NAME='Linux Shell'
printf '当前 Shell 中的值：%s\n' "$COURSE_NAME"

printenv COURSE_NAME
printf '导出前的退出状态：%s\n' "$?"

export COURSE_NAME
printenv COURSE_NAME
printf '导出后的退出状态：%s\n' "$?"

unset COURSE_NAME
~~~

导出前的 `printenv` 通常不会显示变量值，并返回非零状态；导出后应当显示 `Linux Shell` 并返回 0。

**运行结果**

~~~bash
❯ COURSE_NAME='Linux Shell'
❯ printf '当前 Shell 中的值：%s\n' "$COURSE_NAME"
当前 Shell 中的值：Linux Shell
❯ printenv COURSE_NAME
❯ printf '导出前的退出状态：%s\n' "$?"
导出前的退出状态：1
❯ export COURSE_NAME
❯ printenv COURSE_NAME
Linux Shell
❯ printf '导出后的退出状态：%s\n' "$?"
导出后的退出状态：0
❯ unset COURSE_NAME

~~~

**概括**
shell变量只服务于shell，而环境变量可以作为程序的输入。export把shell变量导出为环境变量。printenv打印的是环境变量则返回0,不是则返回1

### 实操二

检查两个命令能否通过 `PATH` 找到，并根据退出状态输出不同提示。这个流程可用于排查软件是否已安装或当前环境是否配置正确。

**操作步骤**

~~~bash
printf '当前 PATH：\n%s\n' "$PATH"

command -v git
printf 'git 的退出状态：%s\n' "$?"

command -v command_that_should_not_exist
printf '不存在命令的退出状态：%s\n' "$?"

command -v git && printf 'git 可以使用\n'
command -v command_that_should_not_exist || printf '命令不存在\n'
~~~

**运行结果**

~~~text
❯ printf '当前 PATH：\n%s\n' "$PATH"
当前 PATH：
/home/ubzy/.local/bin:/home/ubzy/cann-dev/bin:/home/ubzy/bin:/usr/local/bin:/home/ubzy/.local/bin:/home/ubzy/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
❯ command -v git
/usr/bin/git
❯ printf 'git 的退出状态：%s\n' "$?"
git 的退出状态：0
❯ command -v command_that_should_not_exist
❯ printf '不存在命令的退出状态：%s\n' "$?"
不存在命令的退出状态：1
❯ command -v git && printf 'git 可以使用\n'
/usr/bin/git
git 可以使用
❯ command -v command_that_should_not_exist || printf '命令不存在\n'
命令不存在

~~~

**概括**
1. shell利用PATH依次在每个路径中查找外部命令，使用第一个找到的路径
2. command -v 告诉该命令的位置，$? 返回命令的运行状态结果
3. && || 和编程中的意义相同，有截断操作

