# pathlib 路径操作

## 引入

路径经常需要拼接、检查和查找。`pathlib` 提供 `Path` 对象，让这些操作围绕同一个路径完成。创建 `Path` 对象只表示一条路径，不会立即创建文件或目录。

## 核心内容

### 构造路径并查看组成部分

```python
from pathlib import Path

root = Path.cwd()                 # 当前工作目录
home = Path.home()                # 当前用户的主目录
note = root / "notes" / "today.md"

print(root)
print(home)
print(note)
print(note.name)                  # today.md
print(note.stem)                  # today
print(note.suffix)                # .md
print(note.parent)                # notes 所在目录的完整路径
print(note.relative_to(root))     # notes/today.md
print(note.resolve())             # 解析后的绝对路径
print(Path("~/notes").expanduser())  # 展开 ~
```

`/` 用来拼接路径，不需要自己拼接斜杠。`Path("notes/today.md")` 是相对路径，按当前工作目录解释。`relative_to(root)` 得到相对于 `root` 的路径；`resolve()` 得到解析后的绝对路径；`expanduser()` 将 `~` 展开为主目录。上面的代码只构造和显示路径，不会创建 `today.md`。

### 检查路径和文件信息

| 写法                    | 作用         |
| --------------------- | ---------- |
| `path.exists()`       | 路径是否存在     |
| `path.is_file()`      | 是否为文件      |
| `path.is_dir()`       | 是否为目录      |
| `path.stat().st_size` | 文件大小，单位为字节 |

例如，要读取文件大小，应先确认它是文件；对不存在的路径调用 `stat()` 会报错。路径对象可以表示尚未存在的目标，检查结果才会访问实际文件系统。

下面在临时目录中创建一个样本文件，再检查三条路径。`write_text()` 的写法稍后会详细介绍：

```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    root = Path(directory)
    sample = root / "sample.txt"
    sample.write_text("中文\n", encoding="utf-8")
    missing = root / "missing.txt"

    print(root.exists(), root.is_dir())      # True True
    print(sample.exists(), sample.is_file()) # True True
    print(missing.exists())                  # False
    print(len("中文\n"), sample.stat().st_size) # 3 个字符，7 字节
```

`stat().st_size` 返回字节数；它不会把 UTF-8 字符数当成文件大小。

### 查看目录和查找文件

| 写法                     | 作用               |
| ---------------------- | ---------------- |
| `folder.iterdir()`     | 遍历目录中的直接子项       |
| `folder.glob("*.md")`  | 查找当前目录中匹配模式的子路径  |
| `folder.rglob("*.md")` | 递归查找目录及子目录中匹配的路径 |

这些方法得到的是 `Path` 对象，可继续查看 `.name` 或调用 `.is_file()` 筛选文件。查找结果不保证顺序；需要稳定顺序时可以用 `sorted()`。

下面先建立一个有子目录的临时目录，再比较三种查找范围：

```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    root = Path(directory)
    (root / "top.md").touch()
    chapter = root / "chapter"
    chapter.mkdir()
    (chapter / "inside.md").touch()
    (chapter / "other.txt").touch()

    print(sorted(path.name for path in root.iterdir()))
    print(sorted(path.name for path in root.glob("*.md")))
    print(sorted(str(path.relative_to(root)) for path in root.rglob("*.md")))
```

三行结果分别包含直接子项、当前目录的 Markdown 路径，以及包含子目录在内的 Markdown 路径。`relative_to(root)` 让递归结果显示相对于根目录的位置。

### 创建目录和读写文件

| 写法                                          | 作用                                   |
| ------------------------------------------- | ------------------------------------ |
| `folder.mkdir(parents=True, exist_ok=True)` | 创建目录，也创建缺失的父目录；目录已存在时继续              |
| `path.touch()`                              | 创建空文件，或更新已有文件的修改时间                   |
| `path.read_text(encoding="utf-8")`          | 读取整个文本文件并返回字符串                       |
| `path.write_text(text, encoding="utf-8")`   | 写入字符串；已有文件会被覆盖                       |
| `path.open(mode, encoding="utf-8")`         | 像内置 `open()` 一样按 `r`、`w`、`a` 等模式打开文件 |

`read_text()` 和 `write_text()` 适合简短文本；需要逐行处理时，仍可使用 `with path.open(...) as file`。`write_text()` 会覆盖旧内容，使用前要确认目标路径。

下面创建多层目录和空文件，再写入、追加并读回文本：

```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    root = Path(directory)
    folder = root / "notes" / "daily"
    folder.mkdir(parents=True, exist_ok=True)

    empty = folder / "empty.txt"
    empty.touch()
    print(empty.exists())

    memo = folder / "memo.txt"
    memo.write_text("第一行\n", encoding="utf-8")
    with memo.open("a", encoding="utf-8") as file:
        file.write("第二行\n")
    print(memo.read_text(encoding="utf-8"))
```

`mkdir()` 创建目录，`touch()` 创建空文件；`write_text()` 写入第一行，`open("a")` 在后面追加第二行，`read_text()` 最后读回全部内容。

### 重命名和删除

`path.rename(new_path)` 把文件或目录改到新路径，并返回新路径对象。`path.unlink()` 删除文件或符号链接；`folder.rmdir()` 删除空目录。它们会改变文件系统，应在确认目标后使用。

下面只操作临时目录里的文件，依次重命名、删文件、删空目录：

```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as directory:
    root = Path(directory)
    folder = root / "drafts"
    folder.mkdir()
    source = folder / "draft.txt"
    source.write_text("草稿", encoding="utf-8")

    target = source.rename(folder / "final.txt")
    print(source.exists(), target.exists())  # False True

    target.unlink()
    folder.rmdir()
    print(folder.exists())                    # False
```

`rmdir()` 只能删除空目录，因此这里先用 `unlink()` 删除目录中的文件。

## 示例

下面在临时目录中依次创建目录、写入文件、查找、重命名和删除。`TemporaryDirectory` 会在 `with` 结束时清理临时目录：

```python
from pathlib import Path
from tempfile import TemporaryDirectory

with TemporaryDirectory() as temporary:
    root = Path(temporary)
    notes = root / "notes"
    notes.mkdir()

    original = notes / "today.txt"
    original.write_text("复习 pathlib", encoding="utf-8")

    print(original.name, original.suffix)
    print(original.exists(), original.is_file())
    print([path.name for path in notes.glob("*.txt")])

    renamed = original.rename(notes / "review.txt")
    print(renamed.read_text(encoding="utf-8"))

    renamed.unlink()
    notes.rmdir()
```

代码会找到 `today.txt`，随后读出重命名后的内容。删除文件后，`notes` 成为空目录，才可以调用 `rmdir()`。

## 小结（掌握范围）

- 能用 `Path`、`/`、`cwd()`、`home()` 构造路径，并读取文件名、后缀和父目录。
- 能用 `exists()`、`is_file()`、`is_dir()` 检查路径，用 `iterdir()`、`glob()`、`rglob()` 查找内容。
- 能用 `mkdir()`、`read_text()`、`write_text()`、`open()` 完成常见目录与文件操作。
- 知道 `rename()`、`unlink()`、`rmdir()` 的用途，并区分文件删除与空目录删除。
