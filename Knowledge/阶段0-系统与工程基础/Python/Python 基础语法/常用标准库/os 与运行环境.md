# os 与运行环境

## 引入

前一课的 [pathlib](<./pathlib 路径操作.md>) 侧重用路径对象定位文件。`os` 提供更广的操作系统接口，例如查看工作目录、读取环境变量、了解当前进程，以及遍历目录。这些信息常用于脚本配置和运行环境检查。

## 核心内容

### 当前工作目录：`getcwd()` 与 `chdir()`

`os.getcwd()` 返回当前 Python 进程的工作目录字符串。相对路径会从这里开始解析；`os.chdir(path)` 可以改变这个目录。

```python
import os
from tempfile import TemporaryDirectory

original = os.getcwd()
print("原目录：", original)

with TemporaryDirectory() as temporary:
    try:
        os.chdir(temporary)
        print("临时目录：", os.getcwd())
    finally:
        os.chdir(original)

print("已恢复：", os.getcwd() == original)
```

示例先保存原目录，再进入临时目录，最后用 `finally` 恢复。`chdir()` 改变的是当前 Python 进程的工作目录，不会替你改变启动它的终端所在目录；进程中其他使用相对路径的代码也会受影响。

### 环境变量：`environ` 与 `getenv()`

`os.environ` 是当前进程环境变量的映射，键和值都是字符串。`os.environ.get(name)` 或 `os.getenv(name)` 可读取变量；缺失时可指定默认值。对 `os.environ` 赋值会修改当前进程的环境。

```python
import os

print(os.environ.get("HOME", "未设置 HOME"))
print(os.getenv("PYTHON_OS_LESSON_MISSING", "默认值"))

name = "PYTHON_OS_LESSON_FLAG"
previous = os.environ.get(name)
try:
    os.environ[name] = "on"
    print(os.getenv(name))
finally:
    if previous is None:
        os.environ.pop(name, None)
    else:
        os.environ[name] = previous
```

示例读取 `HOME`，再设置一个演示变量，最后恢复原值。通过 Python 修改的环境变量不会回写到启动 Python 的终端；后续从该进程启动的子进程可以继承它。

### 进程与系统信息

`os.getpid()` 返回当前进程 ID，`os.getppid()` 返回父进程 ID；`os.cpu_count()` 返回系统的逻辑 CPU 数，无法确定时可能是 `None`。`os.name` 在 Linux 上通常是 `"posix"`，它不是发行版名称。

```python
import os

print("系统接口类型：", os.name)
print("当前进程：", os.getpid())
print("父进程：", os.getppid())
print("逻辑 CPU：", os.cpu_count())

if os.name == "posix":
    print("用户 ID：", os.getuid())
    print("有效用户 ID：", os.geteuid())
```

`getuid()` 与 `geteuid()` 是 Unix 系统接口，分别对应实际用户 ID 和有效用户 ID。它们能把你在 Linux 中学过的用户与权限概念连接到 Python 程序。

### 目录内容与递归遍历

`os.listdir(path)` 返回一个目录下的名称列表；`os.walk(path)` 递归遍历目录树，每轮得到当前目录、子目录名称列表和文件名称列表。`os.path.join()` 拼接字符串路径，作用类似 `pathlib.Path` 的 `/`。

```python
import os
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as temporary:
    root = Path(temporary)
    child = root / "chapter"
    child.mkdir()
    (root / "top.txt").write_text("顶层", encoding="utf-8")
    (child / "inside.txt").write_text("子目录", encoding="utf-8")

    print("直接子项：", sorted(os.listdir(root)))
    print("拼接路径：", os.path.join(temporary, "chapter", "inside.txt"))

    for current, folders, files in os.walk(root):
        print(Path(current).relative_to(root), sorted(folders), sorted(files))
```

`listdir()` 只给出直接子项的名称；`walk()` 会继续进入 `chapter`。目录枚举顺序不固定，示例用 `sorted()` 让输出更容易核对。

## 示例

下面组合工作目录、环境变量、进程信息和目录列表，生成一份简短的运行环境记录。示例文件位于自动清理的临时目录中：

```python
import os
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as temporary:
    root = Path(temporary)
    (root / "run.log").write_text("启动\n", encoding="utf-8")
    (root / "readme.txt").write_text("示例\n", encoding="utf-8")

    report = {
        "cwd": os.getcwd(),
        "home": os.getenv("HOME", "未设置"),
        "pid": os.getpid(),
        "files": sorted(os.listdir(root)),
    }
    print(report)
```

输出中的工作目录、主目录和进程 ID 取决于实际运行环境；`files` 包含刚创建的两个文件名。

## 小结（掌握范围）

- 能用 `getcwd()` 查看当前工作目录，理解 `chdir()` 对相对路径的影响。
- 能用 `environ`、`getenv()` 读取环境变量，并在需要时修改、恢复当前进程的变量。
- 能用 `getpid()`、`getppid()`、`cpu_count()` 查看运行环境，知道 `getuid()`、`geteuid()` 是 Unix 接口。
- 能用 `listdir()` 查看直接子项，用 `walk()` 递归遍历，并用 `os.path.join()` 拼接字符串路径。
