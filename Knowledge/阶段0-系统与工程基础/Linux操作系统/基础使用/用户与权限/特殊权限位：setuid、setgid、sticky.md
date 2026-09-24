# 特殊权限位：setuid、setgid、sticky

## 引入

普通权限串用 `rwx` 控制所有者、所属组和其他用户能做什么。Linux 还支持三个特殊权限位：setuid、setgid 和 sticky。它们会改变程序运行时使用的身份，或改变共享目录中谁能删除文件。

这些位可能带来额外权限。本课只用只读命令检查已有对象，不修改系统文件或权限。

## 核心内容

### 在 ls -l 输出中识别特殊位

特殊位会显示在原本的执行权限位置：

```text
-rwsr-xr-x   setuid：所有者的执行位位置显示 s
-rwxr-sr-x   setgid：所属组的执行位位置显示 s
drwxrwxrwt   sticky：其他用户的执行位位置显示 t
```

小写 `s` 或 `t` 表示特殊位已设置，且该位置的普通执行位也已设置。大写 `S` 或 `T` 表示特殊位已设置，但对应的执行位没有设置。`ls -l` 的第一个字符仍表示对象类型，例如普通文件是 `-`、目录是 `d`。

### setuid：程序以文件所有者的有效身份运行

当一个带 setuid 位的可执行文件运行时，执行进程的有效用户身份会变成该文件的所有者；登录用户和当前 Shell 不会永久变成这个身份。例如，常见 Linux 系统中的 `passwd` 程序带有 setuid 位，使它能够按设计更新受保护的密码信息。

这就是 `ls -l` 中所有者执行位位置出现 `s` 的原因。若文件所有者是 `root`，它可能让程序在运行期间获得较高权限，因此不要给随意挑选的程序添加 setuid 位。Linux 也会忽略脚本上的 setuid/setgid 位；执行身份变化还可能受文件系统和进程安全设置限制。[execve(2)](https://man7.org/linux/man-pages/man2/execve.2.html)

### setgid：程序使用文件所属组，目录传递组关系

在可执行文件上，setgid 会使运行进程使用文件所属组对应的有效组身份。它显示在所属组的执行位位置，例如 `-rwxr-sr-x`。

在目录上，setgid 的常见用途不同：在其中新建的文件会继承该目录的所属组；新建的子目录也会继承 setgid 位。这样共享目录中的成员更容易通过同一组权限协作。已有文件的所属组不会因此自动改变。[inode(7)](https://man7.org/linux/man-pages/man7/inode.7.html)

### sticky：限制共享目录中的删除和重命名

对目录设置 sticky 位后，即使目录允许多个用户写入，普通用户也不能随意删除或重命名其他用户的文件。文件所有者、目录所有者和特权进程仍可执行这些操作。

`/tmp` 是常见例子：它通常允许用户创建临时文件，同时带有 sticky 位，防止用户互相删除对方的文件。sticky 位限制的是目录中的删除和重命名，不是文件内容的读写权限。[inode(7)](https://man7.org/linux/man-pages/man7/inode.7.html)

### 特殊位的数字写法

沿用数字权限的位图思想，特殊位写在普通 `rwx` 三位组之前：setuid 的权值是 `4`，setgid 是 `2`，sticky 是 `1`。后面三位仍按所有者、所属组和其他用户表示普通权限。

```text
4755：setuid + 普通权限 755
2755：setgid + 普通权限 755
1777：sticky + 普通权限 777
```

本课只要求会读懂已有特殊位，不在系统对象上练习设置或清除它们。GNU `chmod` 手册也将它们定义为八进制模式的首位。[chmod(1)](https://man7.org/linux/man-pages/man1/chmod.1.html)

## 示例

下面只检查对象的权限串，不运行这些程序，也不修改权限：

```bash
ls -l /usr/bin/passwd /usr/bin/crontab
ls -ld /var/mail /tmp
```

示意输出中的关键部分可能类似：

```text
-rwsr-xr-x ... /usr/bin/passwd
-rwxr-sr-x ... /usr/bin/crontab
drwxrwsr-x ... /var/mail
drwxrwxrwt ... /tmp
```

第一行在所有者执行位位置显示 `s`，表示 setuid；第二行在所属组执行位位置显示 `s`，表示 setgid；第三行是带 setgid 的目录；第四行在其他用户执行位位置显示 `t`，表示 sticky。不同发行版可能没有这些路径，或显示不同权限；应以本机实际输出为准。

## 小结（掌握范围）

本课必须掌握：

- 能在 `ls -l` 输出中识别 setuid、setgid 和 sticky 所在的位置。
- 知道 `s/S`、`t/T` 大小写还反映了对应的普通执行位是否设置。
- 能解释可执行文件上的 setuid/setgid 如何影响运行进程的有效身份。
- 知道目录上的 setgid 会让新对象继承目录组，sticky 会限制共享目录中的删除和重命名。
- 能读懂特殊权限数字 `4`、`2`、`1` 位于普通三位权限之前。
- 知道特殊位可能扩大权限影响，本课只检查，不随意设置。

## 课后小实操

### 实操一

用只读检查观察本机上的特殊权限位，并解释它们分别出现在哪个权限位置。

**操作步骤**

检查 `/usr/bin/passwd`、`/usr/bin/crontab`、`/var/mail` 和 `/tmp` 的长格式信息。对每个存在的对象记录类型、所有者、所属组、权限串和可识别的特殊位；说明文件路径与目录路径上的 setuid、setgid 或 sticky 应如何解释。

有些路径可能不存在或是符号链接，按实际输出记录即可，不要为了得到预期结果安装软件、运行这些程序或修改权限。实操只使用只读查看命令。

先把查看命令写入代码区，再执行并填写真实输出。

**代码**

```bash
ls -l /usr/bin/passwd /usr/bin/crontab
ls -ld /var/mail /tmp
```

**运行结果**

```text
❯ ls -l /usr/bin/passwd /usr/bin/crontab
-rwxr-sr-x 1 root crontab 39664  3月 31  2024 /usr/bin/crontab
-rwsr-xr-x 1 root root    64152  5月 30  2024 /usr/bin/passwd
❯ ls -ld /var/mail /tmp
drwxrwxrwt 19 root root 20480  9月 24 14:14 /tmp
drwxrwsr-x  2 root mail  4096  1月  9  2026 /var/mail

```

|你看到的对象|它解决的问题|
|---|---|
|`/usr/bin/passwd` 的 setuid|普通用户不能直接改受保护的密码文件。运行 `passwd` 时，程序临时使用文件所有者 `root` 的有效身份；程序再限制普通用户只能改自己的密码。|
|`/usr/bin/crontab` 的 setgid|用户 crontab 文件放在受保护的目录里。程序临时使用 `crontab` 组的身份，替用户安全地更新自己的任务表，用户不用直接写那个受保护的目录。[Debian crontab 手册](https://manpages.debian.org/bullseye/cron/crontab.1.en.html)|
|`/var/mail` 目录的 setgid|邮件目录中新建的文件继承 `mail` 组，方便邮件程序按组权限管理邮件文件。[inode(7)](https://man7.org/linux/man-pages/man7/inode.7.html)|
|`/tmp` 的 sticky|所有人都能在公共临时目录里创建文件，但 sticky 限制用户删除或重命名别人的文件。[inode(7)](https://man7.org/linux/man-pages/man7/inode.7.html)|

可以把三者记成三句话：**setuid 让程序临时用文件所有者的身份；setgid 让程序用文件所属组的身份，或让目录里的新文件继承组；sticky 让共享目录可写，但保护彼此的文件。**

