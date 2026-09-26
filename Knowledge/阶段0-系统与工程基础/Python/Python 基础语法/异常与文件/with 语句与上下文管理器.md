# with 语句与上下文管理器

## 引入

有些操作需要在开始时取得资源，结束时释放资源。若中途发生异常，收尾步骤仍要执行。`with` 把这套进入、退出流程交给一个对象管理，文件关闭、临时目录清理和锁释放都可以这样完成。

## 核心内容

### `with` 的基本写法

```text
with 上下文管理器 as 名称:
    使用资源
```

这里的“上下文管理器”是支持 `with` 协议的对象。进入代码块前，Python 调用它的 `__enter__()`；如果写了 `as 名称`，该名称接收 `__enter__()` 的返回值。离开代码块时，Python 调用 `__exit__()`。不需要接收返回值时，`as` 可以省略。

只要 `__enter__()` 正常完成，即使代码块中出现异常，也会调用 `__exit__()`。异常是否继续向外传递，由上下文管理器的 `__exit__()` 决定。`with` 本身负责调用这些方法，具体的清理动作由对象实现。

### 临时目录：离开时清理

标准库 `tempfile` 中的 `TemporaryDirectory` 会创建临时目录，并在离开 `with` 块时清理它：

```python
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    print(f"临时目录：{directory}")
```

这里的 `directory` 是 `__enter__()` 返回的目录路径。`with` 块结束后，目录会被清理。

### 锁：离开时释放

标准库 `threading` 中的锁也支持 `with`。进入代码块时加锁，离开时解锁：

```python
from threading import Lock

lock = Lock()
with lock:
    print("处理需要加锁的共享数据")
```

这里不需要接收 `__enter__()` 的返回值，因此省略了 `as`。这类收尾过程相当于把常见的 `try`/`finally` 写法封装进对象中。

### 缩进不会创建新的作用域

`with` 块和 `if`、`for` 块一样，不会单独建立变量作用域。`as` 后面的名称在块外仍可访问，但资源可能已经关闭、删除或释放；不能因为名称还在，就认为资源仍可使用。

## 示例

下面的简单类展示 `with` 实际调用的方法：

```python
class Notice:
    def __enter__(self):
        print("进入")
        return "已准备好"

    def __exit__(self, exc_type, exc_value, traceback):
        print("退出")
        return False

with Notice() as status:
    print(status)
```

运行时依次输出“进入”“已准备好”“退出”。没有异常时，`__exit__()` 的三个异常参数都是 `None`；若块内有异常，返回 `False` 表示不吞掉异常，让它继续向外传递。

## 小结（掌握范围）

- 能理解 `with ... as ...` 会在进入和离开代码块时调用上下文管理器的方法。
- 知道 `as` 接收 `__enter__()` 的返回值，也可以省略。
- 知道 `TemporaryDirectory` 用它清理临时目录，`Lock` 用它释放锁。
- 知道代码块发生异常时仍会执行退出方法，且 `with` 块不会创建新的变量作用域。
