# 导出并复现 Conda 环境

## 引入

你现在的 `py-basics` 里有 Python、`setuptools` 和指定版本的 `wheel`。如果换一台电脑，或要另建一个同用途的环境，只记得环境名还不够；需要把安装要求保存成文件，再根据文件创建新环境。

本课使用 Conda 的环境 YAML。它能记录软件源和包要求，比常见的 pip 风格 `requirements.txt` 更适合描述这里的 Conda 环境。我们会复制一份练习环境，并核对关键包。[Conda 环境导出与共享说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#sharing-an-environment)

## 核心内容

### 导出自己明确安装的要求

先在终端查看导出内容，不写文件：

```bash
conda export -n py-basics --from-history --format=environment-yaml
```

`-n py-basics` 指定来源环境；`--from-history` 只导出曾明确要求安装的包，而不逐项列出 Conda 自动补齐的依赖；`--format=environment-yaml` 选择 YAML 格式。本机当前导出会列出 `python=3.14`、`setuptools` 和 `wheel=0.46.3`，而 `wheel` 带入的 `packaging` 不在显式要求中。复现时，Conda 会重新求解所需依赖。这个文件表达安装要求，不保证每个自动依赖都与原环境版本相同。[`conda export` 文档](https://docs.conda.io/projects/conda/en/stable/commands/export.html)

### 需要固定某个包的版本时

导出行 `- setuptools` 没有版本约束，所以复现时 Conda 会选择软件源中兼容的版本，不保证仍是 `83.0.0`。若要固定版本，把 YAML 中这一行写成：

```yaml
- setuptools=83.0.0
```

这会固定版本号。如果还要固定 Conda 构建，可以使用 `包名=版本=构建号`，例如本机记录中的 `setuptools=83.0.0=py314h06a4308_0`。构建号通常和 Python 版本及平台有关，跨平台分享时固定构建会降低兼容性。Conda 的包规格支持版本和构建字段；完整复现同一平台的所有包时，可使用 explicit 导出格式。[Conda 包规格说明](https://docs.conda.io/projects/conda/en/stable/user-guide/concepts/pkg-specs.html)、[环境导出格式说明](https://docs.conda.io/projects/conda/en/stable/user-guide/tasks/manage-environments.html#sharing-an-environment)

### 按复现目标选择导出方式

- **跨平台分享并保留指定版本**：使用 `--from-history`，再在 YAML 中为需要固定的包加版本，例如 `setuptools=83.0.0`。其他未固定的包和依赖仍由 Conda 重新求解。
- **记录当前环境中所有包的版本与构建**：省略 `--from-history`，完整导出 YAML：

  ```bash
  conda export -n py-basics --format=environment-yaml
  ```

  本机输出会包含 `setuptools=83.0.0=py314h06a4308_0`。它也会列出大量平台相关依赖，因此更适合相同平台的复现。
- **在同一平台精确复现整套 Conda 包**：导出 explicit 文件，其中记录了每个包的具体下载地址和构建：

  ```bash
  conda export -n py-basics --format=explicit --file "$HOME/py-basics-explicit.txt"
  ```

  这种格式是平台专用的；不要把 Linux 的 explicit 文件当作 Windows 或 macOS 环境文件使用。官方文档将 explicit 格式用于同平台的精确环境复现，并说明 `--from-history` 不适用于该格式。[Conda 导出格式说明](https://docs.conda.io/projects/conda/en/stable/commands/export.html#explicit-format-cep-23)

导出结果还包含 `name:` 和 `prefix:`。前者是原环境名；后者是本机原环境的绝对路径。为了让新文件只表达可复用的包要求，可在写文件时去掉 `prefix:` 行：

```bash
conda export -n py-basics --from-history --format=environment-yaml | sed '/^prefix:/d' > "$HOME/py-basics-example.yml"
cat "$HOME/py-basics-example.yml"
```

管道把导出文本交给 `sed`；`/^prefix:/d` 删除以 `prefix:` 开头的行；`>` 将剩余内容写入文件。`cat` 用来核对文件内容。运行前确认目标文件名尚未用于保存其他内容，因为 `>` 会覆盖同名文件。文件里的 `name: py-basics` 可以保留，创建复制环境时用命令行的 `-n` 指定新名字。

### 根据 YAML 创建新环境

以下用 `py-basics-copy` 作示例名称。先预览：

```bash
conda env create -n py-basics-copy -f "$HOME/py-basics-example.yml" --dry-run
```

`-f` 指向刚才保存的 YAML，`-n py-basics-copy` 指定新环境名，覆盖文件中的原名称；`--dry-run` 只展示计划。确认目标路径是新环境，且计划包含 Python、`setuptools`、`wheel` 后，再去掉 `--dry-run` 创建。[`conda env create` 文档](https://docs.conda.io/projects/conda/en/stable/commands/env/create.html)说明了命令行名称可以覆盖文件中的名称。

```bash
conda env create -n py-basics-copy -f "$HOME/py-basics-example.yml"
```

示例只说明命令格式，不需要额外创建 `py-basics-copy`；课后实操会使用另一份文件和不同环境名。创建过程可能重新下载软件包，也可能复用本机缓存。

### 核对复现结果

```bash
conda info --envs
conda list -n py-basics-copy python
conda list -n py-basics-copy setuptools
conda list -n py-basics-copy wheel
```

环境列表应同时出现原环境和新环境。新环境中的 Python 应为 3.14 系列，`setuptools` 应存在，`wheel` 应为 0.46.3；`setuptools` 在导出文件中没有指定版本，所以不要求与原环境的小版本完全相同。查询各包比粘贴整张软件包列表更便于核对。

## 示例

本机的 `py-basics` 导出后，去掉本机路径，关键内容如下：

```yaml
name: py-basics
channels:
  - defaults
dependencies:
  - python=3.14
  - setuptools
  - wheel=0.46.3
```

`channels` 指明软件包来源，`dependencies` 是需要 Conda 重新满足的安装要求。这里保留了 `wheel` 的指定版本，却没有列出它自动带入的 `packaging`；新环境创建时由 Conda 决定兼容的依赖版本。指定新环境名后，不会把文件中的 `name: py-basics` 当成要覆盖的目标。

## 小结（掌握范围）

- 会用 `conda export --from-history` 导出自己明确安装的包要求。
- 能读懂环境 YAML 中的名称、软件源和依赖，并去掉不适合复用的本机路径。
- 会根据 YAML 预览并创建不同名称的环境。
- 会核对新环境中的关键包，理解显式版本要求与自动依赖的区别。

## 课后小实操

### 实操一

把当前的 `py-basics` 导出为 `$HOME/py-basics-check.yml`，据此创建名为 `py-basics-demo` 的新环境。课堂示例使用 `py-basics-example.yml` 和 `py-basics-copy`；本题使用不同的文件名和环境名独立完成复现。

**操作步骤**

先确认目标 YAML 文件尚不存在，避免覆盖已有内容；若 `py-basics-demo` 已由本次实操创建，则直接用它完成后续核对。导出 `py-basics` 的显式安装要求，去掉原环境的 `prefix:` 行，并查看保存后的 YAML。预览从该文件创建新环境的计划，确认目标名称和拟安装的关键包；计划合适后再创建。最后检查原环境与新环境都存在，并核对新环境中的 Python、`setuptools` 和 `wheel`。

请在运行结果中贴出 YAML 的关键内容、创建预览中的目标路径与关键包、环境列表中原环境和 `py-basics-demo` 的两行，以及新环境中三个包的查询结果。无需粘贴完整下载日志；若计划指向原环境或出现错误，停止并保留原始输出。

**运行结果**

以下仅保留关键输出；重复的软件包明细和下载日志已省略。

```text
❯ conda export -n py-basics --from-history --format=environment-yaml \
> | sed '/^prefix:/d' > "$HOME/py-basics-check.yml"
❯ cat "$HOME/py-basics-check.yml"
name: py-basics
channels:
  - defaults
dependencies:
  - python=3.14
  - setuptools
  - wheel=0.46.3

❯ conda env create -n py-basics-demo -f "$HOME/py-basics-check.yml" --dry-run
## Package Plan ##
  environment location: /home/ubzy/miniconda3/envs/py-basics-demo
  added / updated specs:
    - python=3.14
    - setuptools
    - wheel=0.46.3
The following NEW packages will be INSTALLED:
  packaging          pkgs/main/linux-64::packaging-26.3-py314h06a4308_0
  python             pkgs/main/linux-64::python-3.14.7-h2bd7c14_101_cp314
  setuptools         pkgs/main/linux-64::setuptools-83.0.0-py314h06a4308_0
  wheel              pkgs/main/linux-64::wheel-0.46.3-py314h06a4308_0
DryRunExit: Dry run. Exiting.

❯ conda env create -n py-basics-demo -f "$HOME/py-basics-check.yml"
Proceed ([y]/n)? y
Executing transaction: done

❯ conda info --envs
base                 *   /home/ubzy/miniconda3
py-basics                /home/ubzy/miniconda3/envs/py-basics
py-basics-demo           /home/ubzy/miniconda3/envs/py-basics-demo

❯ conda list -n py-basics-demo
# packages in environment at /home/ubzy/miniconda3/envs/py-basics-demo:
# Name                     Version          Build               Channel
packaging                  26.3             py314h06a4308_0
python                     3.14.7           h2bd7c14_101_cp314
setuptools                 83.0.0           py314h06a4308_0
wheel                      0.46.3           py314h06a4308_0
```
