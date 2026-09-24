# 用户身份、UID 与 GID

## 引入

Linux 判断“你是谁”时，不只使用用户名，还会使用数字身份标识。文件权限和进程权限最终都要关联到这些数字身份。

因此，排查权限问题的第一步通常不是修改权限，而是先确认当前身份：

- 当前用户名是什么。
- 当前用户的 UID 是多少。
- 当前主组是什么，GID 是多少。
- 当前用户还属于哪些附加组。

本课只观察身份信息，不创建、删除或修改任何用户和用户组。

## 核心内容

### 用户名和 UID

使用 whoami 查看当前用户名：

~~~bash
whoami
~~~

用户名方便人阅读，但 Linux 内核和文件系统主要使用 UID 识别用户。

使用 id 查看完整身份信息：

~~~bash
id
~~~

输出通常类似：

~~~text
uid=1000(ubzy) gid=1000(ubzy) groups=1000(ubzy),27(sudo)
~~~

其中：

- uid=1000(ubzy)：当前用户的 UID 和用户名。
- gid=1000(ubzy)：当前用户的主组 GID 和组名。
- groups=...：当前用户所属的全部用户组。

用户名可能改变，但 UID 是系统识别用户的重要依据。通常 root 用户的 UID 是 0。

### 主组和附加组

一个用户至少有一个主组，也可以属于多个附加组。

主组通常用于新建文件时确定文件的初始所属组。附加组则会影响用户能否通过组权限访问文件或目录。

分别查看 UID、主组 GID 和组名：

~~~bash
id -u
id -g
id -gn
~~~

查看当前用户所属的全部组名：

~~~bash
id -nG
~~~

也可以使用 groups：

~~~bash
groups
~~~

groups 适合快速查看组名；id 能同时提供 UID、GID 和组的数字信息。

### 查看登录会话和查看身份不是一回事

whoami 和 id 关注的是“当前命令以谁的身份运行”：

~~~bash
whoami
id
~~~

who 关注的是“当前系统有哪些登录会话”：

~~~bash
who
~~~

一个用户可以有多个登录会话，因此 who 的行数不一定等于用户数量，也不一定等于当前命令的身份信息。

### 查询指定用户的身份

如果知道一个用户名，可以把用户名作为 id 的参数：

~~~bash
id root
~~~

这不会切换身份，只是查询指定用户的 UID、主组和附加组信息。查询不存在的用户时，id 会返回非零退出状态并显示错误信息。

### 为什么权限排查要先确认身份

同一个文件对不同用户可能有不同的访问结果。即使两个终端看起来都在操作同一个路径，只要当前用户、主组或附加组不同，命令结果就可能不同。

排查访问问题时，可以先记录：

~~~bash
printf 'user=%s\n' "$(whoami)"
printf 'uid=%s\n' "$(id -u)"
printf 'primary gid=%s\n' "$(id -g)"
printf 'groups=%s\n' "$(id -nG)"
~~~

这类信息可以作为后续检查文件所有者、所属组和权限位的基础。

## 示例：生成一份当前身份摘要

下面的命令把多个身份查询结果组合成一份简短摘要：

~~~bash
printf 'user=%s uid=%s gid=%s groups=%s\n' \
  "$(whoami)" \
  "$(id -u)" \
  "$(id -g)" \
  "$(id -nG)"
~~~

这里使用命令替换把命令输出放入 printf 的参数中。每次查询都只读取当前身份，不会修改系统。

## 小结（掌握范围）

本课必须掌握：

- 知道用户名和 UID 都可以表示用户，UID 是系统使用的重要数字标识。
- 会使用 whoami 查看当前用户名。
- 会使用 id 查看当前用户的 UID、主组、GID 和全部组。
- 会使用 id -u 查看 UID，使用 id -g 查看主组 GID。
- 会使用 id -gn、id -nG 或 groups 查看组名。
- 能区分主组和附加组的基本作用。
- 能区分 whoami、id 查看当前身份，与 who 查看登录会话。
- 会使用 id 用户名查询指定用户的身份信息。
- 知道权限排查前应先确认当前用户和所属组。

## 课后小实操

### 实操一

制作一份当前身份观察记录，分别记录用户名、UID、主组名称、主组 GID 和全部组名。

**操作步骤**

不要修改任何系统配置。根据课堂中介绍的 whoami、id 和 groups，设计一组只读命令，满足以下要求：

- 每项信息单独输出。
- 输出中包含清晰的字段名称。
- 同时观察数字标识和名称信息。
- 将实际命令写入代码区，再执行这些命令。

**代码**

~~~bash
printf 'whoami=%s\n' "$(whoami)"
printf 'uid=%s\n' "$(id -u)"
printf 'gid=%s\n' "$(id -g)"
printf 'group name=%s\n' "$(id -gn)"
printf 'groups=%s\n' "$(groups)"
printf 'id -nG=%s\n' "$(id -nG)"
printf 'who=%s\n' "$(who)"
~~~

**运行结果**

~~~text
❯ printf 'whoami=%s\n' "$(whoami)"
whoami=ubzy
❯ printf 'uid=%s\n' "$(id -u)"
uid=1000
❯ printf 'gid=%s\n' "$(id -g)"
gid=1000
❯ printf 'group name=%s\n' "$(id -gn)"
group name=ubzy
❯ printf 'groups=%s\n' "$(groups)"
groups=ubzy adm cdrom sudo dip plugdev users lpadmin sambashare libvirt kvm
❯ printf 'id -nG=%s\n' "$(id -nG)"
id -nG=ubzy adm cdrom sudo dip plugdev users lpadmin sambashare libvirt kvm
❯ printf 'who=%s\n' "$(who)"
who=ubzy     tty7         2026-09-22 20:09 (:0)

~~~
