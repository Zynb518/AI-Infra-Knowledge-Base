# 条件判断：if、test 与 case

## 引入

前面的脚本已经可以接收参数、读取输入和获取退出状态，但它们还不能根据情况选择不同的动作。

实际脚本经常需要判断：

- 文件是否存在。
- 用户是否提供了参数。
- 输入是否等于某个值。
- 一个数字是否达到要求。

Bash 使用命令的退出状态进行判断。条件命令返回 0 时表示条件成立，返回非 0 时表示条件不成立。本课学习 test、if 和 case，把这些判断组织成脚本分支。

## 核心内容

### 使用 test 检查条件

test 是一个用于判断条件的命令。最常见的文件判断包括：

~~~bash
test -f /tmp/bash-course/variables.sh
test -d /tmp/bash-course
~~~

- -f：路径存在，并且是普通文件。
- -d：路径存在，并且是目录。

test 不一定直接打印文字，而是通过退出状态表示结果。因此可以查看它的状态：

~~~bash
test -d /tmp/bash-course
printf 'status: %s\n' "$?"
~~~

也可以使用方括号写法，方括号本身也是一个命令：

~~~bash
[ -f /tmp/bash-course/variables.sh ]
printf 'status: %s\n' "$?"
~~~

方括号和内部内容之间必须有空格，最后的右方括号也必须单独作为一个参数。下面的写法不正确：

~~~bash
[-f /tmp/bash-course/variables.sh]
~~~

### 判断字符串和数字

字符串比较和数字比较使用不同的操作符：

~~~bash
environment='test'

[ "$environment" = 'test' ]
printf 'string status: %s\n' "$?"

count=3
[ "$count" -ge 2 ]
printf 'number status: %s\n' "$?"
~~~

常用操作符包括：

| 操作符 | 用途 |
| --- | --- |
| -n string | 字符串非空 |
| -z string | 字符串为空 |
| string1 = string2 | 字符串相等 |
| string1 != string2 | 字符串不相等 |
| number1 -eq number2 | 数字相等 |
| number1 -gt number2 | 第一个数字大于第二个 |
| number1 -ge number2 | 第一个数字大于或等于第二个 |

字符串变量要加双引号，数字变量也建议加双引号。字符串使用 = 比较，数字使用 -eq、-gt、-ge 等操作符比较。

### 使用 if 选择分支

if 会根据条件命令的退出状态选择要执行的代码：

~~~bash
if [ -f "$1" ]; then
  printf 'regular file\n'
else
  printf 'not a regular file\n'
fi
~~~

结构可以这样理解：

- if 后面放一个条件命令。
- 条件命令成功时执行 then 到 else 或 fi 之间的内容。
- 条件命令失败时执行 else 到 fi 之间的内容。
- fi 表示 if 结构结束。

可以使用 elif 增加更多分支：

~~~bash
if [ "$1" = 'api' ]; then
  printf 'API service\n'
elif [ "$1" = 'worker' ]; then
  printf 'worker service\n'
else
  printf 'unknown service\n'
fi
~~~

if 判断的不是某个特定命令，而是条件命令的退出状态。除了方括号，也可以直接判断其他命令：

~~~bash
if grep -q 'api' /tmp/services.txt; then
  printf 'api was found\n'
else
  printf 'api was not found\n'
fi
~~~

### 使用 case 匹配多个固定选项

当一个变量需要和多个固定值比较时，case 通常比很多层 elif 更清楚：

~~~bash
case "$1" in
  api)
    printf 'API service\n'
    ;;
  worker)
    printf 'worker service\n'
    ;;
  *)
    printf 'unknown service\n'
    ;;
esac
~~~

case 结构的基本组成是：

- case 后面放要匹配的值。
- 每个模式后面使用右括号。
- 每个分支以两个分号结束。
- 星号模式可以匹配其他所有情况。
- esac 表示 case 结构结束。

case 也支持简单的通配模式：

~~~bash
case "$1" in
  *.log)
    printf 'log file\n'
    ;;
  *.conf|*.ini)
    printf 'configuration file\n'
    ;;
  *)
    printf 'other file\n'
    ;;
esac
~~~

这里的 *.conf|*.ini 表示匹配以 .conf 或 .ini 结尾的名称。

### 条件中的常见注意事项

写条件判断时，重点注意以下几点：

- [ 和 ] 两侧要有空格。
- 变量默认使用双引号。
- 字符串比较使用 =，数字比较使用 -eq、-gt、-ge 等操作符。
- 条件分支中的命令仍然会产生退出状态。
- 每个 if 必须使用 fi 结束，每个 case 必须使用 esac 结束。

## 示例：检查输入路径的类型

下面的脚本接收一个路径参数，并分别判断它是普通文件、目录，还是不存在：

~~~bash
#!/usr/bin/env bash

path="$1"

if [ -f "$path" ]; then
  printf 'regular file: %s\n' "$path"
elif [ -d "$path" ]; then
  printf 'directory: %s\n' "$path"
else
  printf 'path not found: %s\n' "$path"
fi
~~~

运行时把不同路径作为第一个参数，脚本就会进入不同分支。

## 小结（掌握范围）

本课必须掌握：

- 知道条件判断依赖命令的退出状态，0 通常表示条件成立。
- 会使用 test 或 [ ] 检查普通文件和目录。
- 会使用 -n、-z、=、!= 判断字符串。
- 会使用 -eq、-gt、-ge 进行基础数字比较。
- 会使用 if、elif、else 和 fi 组织条件分支。
- 会使用 case、模式、两个分号和 esac 处理多个固定选项。
- 知道 [ ] 内部和两侧必须保留空格。
- 条件中的变量默认加双引号，字符串和数字使用不同的比较操作符。

## 课后小实操

### 实操一

创建一个脚本，根据用户提供的运行模式输出不同提示。这个练习改变课堂中的文件类型判断，练习参数数量判断、字符串比较和 elif 分支。

**操作步骤**

创建 /tmp/bash-course/mode-message.sh，并将下面的内容写入文件：

~~~bash
#!/usr/bin/env bash

if [ "$#" -eq 0 ]; then
  printf 'mode is missing\n'
elif [ "$1" = 'verbose' ]; then
  printf 'verbose mode enabled\n'
else
  printf 'normal mode: %s\n' "$1"
fi
~~~

回到终端执行：

~~~bash
bash /tmp/bash-course/mode-message.sh verbose
bash /tmp/bash-course/mode-message.sh quiet
bash /tmp/bash-course/mode-message.sh
~~~

**运行结果**

~~~text
❯ bash /tmp/bash-course/mode-message.sh verbose
verbose mode enabled
❯ bash /tmp/bash-course/mode-message.sh quiet
normal mode: quiet
❯ bash /tmp/bash-course/mode-message.sh
mode is missing

~~~

### 实操二

创建一个脚本，根据文件名后缀分类输入名称。这个练习改变课堂中的服务名匹配，练习 case 的通配模式和多个模式合并。

**操作步骤**

创建 /tmp/bash-course/classify-name.sh，并将下面的内容写入文件：

~~~bash
#!/usr/bin/env bash

case "$1" in
  *.log)
    printf 'log input: %s\n' "$1"
    ;;
  *.conf|*.ini)
    printf 'configuration input: %s\n' "$1"
    ;;
  *)
    printf 'other input: %s\n' "$1"
    ;;
esac
~~~

回到终端执行：

~~~bash
bash /tmp/bash-course/classify-name.sh service.log
bash /tmp/bash-course/classify-name.sh app.ini
bash /tmp/bash-course/classify-name.sh README.md
~~~

**运行结果**

~~~text
❯ bash /tmp/bash-course/classify-name.sh service.log
log input: service.log
❯ bash /tmp/bash-course/classify-name.sh app.ini
configuration input: app.ini
❯ bash /tmp/bash-course/classify-name.sh README.md
other input: README.md

~~~
