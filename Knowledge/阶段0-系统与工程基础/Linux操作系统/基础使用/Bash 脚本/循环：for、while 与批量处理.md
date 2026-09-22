# 循环：for、while 与批量处理

## 引入

脚本经常需要对一组服务、多个文件或一批输入逐个执行相同的动作。如果把相同命令复制很多遍，输入数量一变化，脚本就需要重新修改。

循环可以让一段命令重复执行：

- for 适合遍历一组已经准备好的内容。
- while 适合在条件命令成功时持续执行。

本课会把循环和前面学过的位置参数、条件判断、用户输入及算术运算结合起来。

## 核心内容

### 使用 for 遍历固定列表

for 会依次取出列表中的每一项，放入循环变量：

~~~bash
for service in api worker database; do
  printf 'service: %s\n' "$service"
done
~~~

执行过程是：

1. service 取值 api，执行循环体。
2. service 取值 worker，执行循环体。
3. service 取值 database，执行循环体。
4. 列表处理完成，循环结束。

循环变量只在当前脚本执行过程中保存每一项内容。使用时仍然要加双引号。

### 使用 for 遍历全部位置参数

前面学过的 "$@" 可以和 for 结合，逐个处理脚本收到的参数：

~~~bash
for item in "$@"; do
  printf 'argument: %s\n' "$item"
done
~~~

这里的 "$@" 会保留每个参数的边界。如果某个参数中包含空格，仍然会作为一个完整参数交给循环变量。

例如运行：

~~~bash
bash process-items.sh 'api gateway' worker
~~~

循环会执行两次，第一次的 item 是 api gateway，第二次的 item 是 worker。

### 使用 while 按条件重复

while 会先执行条件命令，条件成功时执行循环体；循环体结束后再次检查条件：

~~~bash
count=1

while [ "$count" -le 3 ]; do
  printf 'count: %s\n' "$count"
  count=$((count + 1))
done
~~~

这里：

- [ "$count" -le 3 ] 判断 count 是否小于或等于 3。
- $((count + 1)) 执行整数计算。(()) 代表算术计算
- 每次循环都增加 count，最终条件失败，循环结束。

如果循环体没有改变条件相关的值，while 可能会无限执行。因此设计 while 时要明确“什么变化会让条件最终失败”。

### 使用 while 逐行读取文件

read 可以放在 while 的条件位置，用于逐行读取文件：

~~~bash
while read -r service; do
  printf 'service from file: %s\n' "$service"
done < /tmp/bash-course/services.txt
~~~

每次 read 成功读取一行，循环体就执行一次；文件读完后，read 返回失败，while 结束。

末尾的 < /tmp/bash-course/services.txt 把文件内容连接到整个 while 循环的标准输入。这个例子中的每一行是一个服务名称，因此可以直接读取并处理。

### 循环中使用条件判断

循环体内可以使用 if 对每一项进行筛选：

~~~bash
for service in api worker database; do
  if [ "$service" = 'worker' ]; then
    printf 'selected: %s\n' "$service"
  fi
done
~~~

这样可以遍历所有内容，但只对满足条件的项目执行特定动作。

### for 和 while 的选择

| 循环 | 适合场景 |
| --- | --- |
| for | 已经有一组明确的参数、名称或列表 |
| while | 需要根据条件持续执行，或逐行读取输入 |

如果输入项已经在 "$@" 或固定列表中，优先考虑 for；如果每次循环都需要重新判断条件，或者输入来自文件，优先考虑 while。

## 示例：批量检查命令行参数

下面的脚本逐个检查传入的路径，并根据路径类型输出不同信息：

~~~bash
#!/usr/bin/env bash

for path in "$@"; do
  if [ -f "$path" ]; then
    printf 'file: %s\n' "$path"
  elif [ -d "$path" ]; then
    printf 'directory: %s\n' "$path"
  else
    printf 'not found: %s\n' "$path"
  fi
done
~~~

同一个判断逻辑不需要复制多遍，传入多少个路径，循环就处理多少次。

## 小结（掌握范围）

本课必须掌握：

- 会使用 for 遍历固定列表。
- 会使用 for item in "$@" 逐个处理全部位置参数。
- 知道 "$@" 可以保留包含空格的参数边界。
- 会使用 while 根据条件重复执行。
- 会使用 $((...)) 进行基础整数计算。
- 知道 while 循环体必须让条件相关的值发生变化，避免无限循环。
- 会使用 while read -r line; do ... done < file 逐行读取简单文本文件。
- 能在循环内部使用 if 对输入项进行筛选。
- 能根据输入形式选择 for 或 while。

## 课后小实操

### 实操一

创建一个脚本，为传入的每个参数编号并输出。这个练习不直接复制课堂中的固定列表或路径检查，而是把位置参数、for 和整数计算组合起来。

**操作步骤**

创建 /tmp/bash-course/number-items.sh，并将下面的内容写入文件：

~~~bash
#!/usr/bin/env bash

number=1
for item in "$@"; do
  printf '%s: %s\n' "$number" "$item"
  number=$((number + 1))
done
~~~

回到终端执行：

~~~bash
bash /tmp/bash-course/number-items.sh api 'test environment' database
~~~

**运行结果**

~~~text
❯ bash /tmp/bash-course/number-items.sh api 'test environment' database
1: api
2: test environment
3: database

~~~

### 实操二

创建一个服务列表文件，其中包含空行；再创建脚本逐行读取，只统计非空行。这个练习用于把 while、read、if 和计数组合起来。

**操作步骤**

创建输入文件：

~~~bash
printf 'api\n\nworker\napi gateway\n\n' > /tmp/bash-course/service-list.txt
~~~

创建 /tmp/bash-course/count-services.sh，并将下面的内容写入文件：

~~~bash
#!/usr/bin/env bash

count=0
while read -r service; do
  if [ -n "$service" ]; then
    printf 'service: %s\n' "$service"
    count=$((count + 1))
  fi
done < /tmp/bash-course/service-list.txt

printf 'non-empty count: %s\n' "$count"
~~~

回到终端执行：

~~~bash
bash /tmp/bash-course/count-services.sh
~~~

**运行结果**

~~~text
❯ bash /tmp/bash-course/count-services.sh
service: api
service: worker
service: api gateway
non-empty count: 3

~~~
