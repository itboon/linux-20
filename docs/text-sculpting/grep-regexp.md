# grep 与正则表达式

grep 是一款非常流行的文本搜索工具，它根据正则表达式对文本进行搜索，并输出匹配的行或文本。

## grep 典型案例

``` bash
# 查看发行版
cat /etc/os-release | grep 'PRETTY'

# 查看 CPU 型号
cat /proc/cpuinfo | grep 'model name'

# 查看内核参数
sudo sysctl -a | grep 'swap'
```

得到如下输出：

``` shell-session
$  # 查看发行版
$  cat /etc/os-release | grep 'PRETTY'
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
$  
$  # 查看 CPU 型号
$  cat /proc/cpuinfo | grep 'model name'
model name	: Intel(R) Core(TM) i7-5500U CPU @ 2.40GHz
$  
$  # 查看内核参数
$  sudo sysctl -a | grep 'swap'
vm.swappiness = 60
```

## 正则表达式

`grep '.sh'` 这个表达式就超出了字面的含义，请看下面这个例子：

``` shell-session
$  ls -a ~ | grep '.sh'
.bashrc
setup.sh
.ssh
$  ls -a ~ | grep '\.sh'
setup.sh
```

grep 使用正则表达式进行匹配，因为 `.` 在正则表达式里有特殊含义，它匹配一个任意字符，所以 `.ssh` `.bashrc` 文件也匹配到了。

正则表达式是使用 grep 的基础，它有不同规范，下面将介绍 Linux 中常见的 ERE 和 BRE。

## ERE 和 BRE

| 简称 | 全称 | 解释 |
| ---- | ---- | ---- |
| BRE | basic regular expressions | 基础正则表达式 (过时的) |
| ERE | extended regular expressions | 扩展正则表达式 (现代的) |

如果从字面理解，基础这个字眼让 BRE 显得具有一定地位，但实质上 BRE 的存在只是为了兼容一些老旧的软件。

GNU `grep` 对 BRE 和 ERE 进行了扩展，使得它们之间的差别很小，那就是转义字符的使用:

- `?` `+` `|` `{` `}` `(` `)`
- `\?` `\+` `\|` `\{` `\}` `\(` `\)`

BRE 中前者表示字面量，后者具有特殊含义。而 ERE 则相反，前者具有特殊含义，后者表示字面量。例如列出文件名以 `config` 或者 `conf` 或者 `cfg` 结尾的文件：

``` bash
# 使用 ERE
ls -a | grep -E '(config|conf|cfg)$'
    
# 使用 BRE
ls -a | grep '\(config\|conf\|cfg\)$'
```

!!! note
    GNU `grep` 对 BRE 进行了扩展，它并不完全符合 POSIX 规范。在 POSIX 规范中 BRE 不支持 `\?`、`\+`、`\|` 这些元字符。

## 推荐使用 ERE

ERE 的风格被现代应用程序广泛支持，推荐使用 **ERE**。

* `grep` 默认使用 BRE，`grep -E` 或者 `egrep` 使用 ERE
* `sed` 默认使用 BRE，`sed -E` 使用 ERE
* `gawk` 使用 ERE

`egrep` 等同于 `grep -E`，下文将统一使用 `egrep`。

## grep ERE 语法

### 转义字符

转义字符 `\` 指示后面的字符具有特殊含义或者恢复该字符的字面量。本身具有特殊含义的字符前面加 `\` 则恢复字面量，例如 `\.`。某些普通字符前面加 `\` 则具有特殊含义。

`\b` `\B` `\<` `\>` `\s` `\S` `\w` `\W` 这些符号具有特殊含义，下面马上就会介绍。POSIX ERE 规范中并不支持这些特殊符号，它们属于 GNU grep 的扩展。

### 字符集合

字符集合匹配一个属于集合中的字符。

| 字符集合 | 描述 | 表达式样例 |
| -------- | ---- | ---------- |
| `.` | 匹配一个任意字符，包括换行符。 | |
| `[` *list* `]` | 匹配一个在列表中的字符。 | `[RrB]ose` 匹配 "Rose" "rose" "Bose" |
| `[^` *list* `]` | 匹配一个不在列表中的字符。 | `a[^0-9]c` 匹配 "aFc" 不匹配 "a3c" |
| `\s` | 匹配空白符 (空格、制表符和换行符)。 (GNU 扩展) | |
| `\S` | 匹配非空白符，与 `\s` 相反。 (GNU 扩展) | |
| `\w` | 匹配单词字符 (英文字母或者数字)。 (GNU 扩展) | |
| `\W` | 匹配非单词字符，与 `\w` 相反。 (GNU 扩展) | |

### 数量符

数量符限定前面的实例匹配的次数。

| 数量符 | 描述 | 表达式样例 |
| ------ | ---- | ---------- |
| `*` | 前面的实例匹配 0 次或多次。 | `ab*c` 匹配 "ac" "abc" "abbc" |
| `+` | 前面的实例匹配 1 次或多次。 | |
| `?` | 前面的实例匹配 0 次或 1 次。 | |
| `{` *n* `}` | 前面的实例匹配 n 次。 | |
| `{` *n,* `}`  | 前面的实例匹配 n 次或更多。 | |
| `{` *n* `,` *m* `}` | 前面的实例匹配大于等于 n 次且小于等于 m 次。 | |

### 锚点

锚点匹配一个定位。

| 锚点 | 描述 | 表达式样例 |
| ---- | ---- | ---------- |
| `^` | 匹配一行开头 | |
| `$` | 匹配一行结尾 | |
| `\b` | 匹配单词边缘。 (GNU 扩展) | `good\b` 匹配 "good night" 不匹配 "goodbye" |
| `\B` | 匹配非单词边缘，与 `\b` 相反。 (GNU 扩展) | |
| `\<` | 匹配单词开头。 (GNU 扩展) | |
| `\>` | 匹配单词结尾。 (GNU 扩展) | |

### 分组

| 符号 | 描述 | 表达式样例 |
| ---- | ---- | ---------- |
| `( )` | 分割一个子表达式 | `a(bc){3}` 匹配 "abcbcbc" |

### 或表达式

| 符号 | 描述 | 表达式样例 |
| ---- | ---- | ---------- |
| `|` | 匹配任意一个被 `|` 分割的部分 | `cat|dog` 匹配 "cat" "dog", `th(e|is|at)` 匹配 "the" "this" "that" |

## grep 常用选项

- -E, --extended-regexp, 使用扩展正则表达式 (ERE)
- -i, --ignore-case, 忽略大小写
- -v, --invert-match, 反选，即选择未匹配的行
- -w, --word-regexp, 单词匹配模式
- -r, --recursive, 递归读取整个目录的文件进行匹配
- -o, --only-matching, 仅打印行中匹配的部分
- -q, --quiet, --silent, 静默模式，一旦发现匹配即退出并返回状态码 `0`

## grep 实践

### 文本搜索小游戏

例如有这样一个文件：

```
I use Linux.
Jack uses macOS.
Most people choose Windows 10.

["linux", "macos", "win10"]
```

使用 grep 搜索指定的行，得到如下输出：

``` shell-session
$  # 搜索含有 macOS 的行，不区分大小写
$  egrep -i 'macos' file
Jack uses macOS.
["linux", "macos", "win10"]
$  
$  # 搜索含有 use 的行
$  egrep 'use' file
I use Linux.
Jack uses macOS.
$  
$  # 搜索含有单词 use 的行
$  # 可以使用 \b 界定单词的边缘
$  egrep '\buse\b' file
I use Linux.
$  # 也可以使用 grep -w 单词匹配模式
$  egrep -w 'use' file
I use Linux.
$  
$  # 搜索含有 win10 或者 windows 10 或者 windows10 的行，不区分大小写
$  egrep -i '(win|windows |windows)10' file
Most people choose Windows 10.
["linux", "macos", "win10"]
$  egrep -i 'win(dows ?)?10' file
Most people choose Windows 10.
["linux", "macos", "win10"]
$  
$  # 搜索 windows 后面带有两位数字的行，不区分大小写
$  egrep -i 'windows ?[0-9]{2}' file
Most people choose Windows 10.
```

### 文件名搜索

ls 与 grep 配合使用可以帮助我们列出指定类型的文件：

``` bash
# 列出所有 YAML 文件 (文件名以 .yaml 或者 .yml 结尾)
ls -a | egrep '\.ya?ml$'

# 列出文件名以 config 或者 conf 或者 cfg 结尾的文件
ls -a | egrep '(config|conf|cfg)$'

# 列出所有文件，过滤掉目录
ls -al | egrep '^-'

# 列出 /etc 目录(包括子目录) 下文件名包含 release 的文件
sudo ls -alR /etc | egrep -i 'release'
```

### 查看系统信息并过滤

``` bash
# 查看 CPU 型号、内核数和线程数
cat /proc/cpuinfo | egrep 'model name|cpu cores|siblings'
cat /proc/cpuinfo | egrep 'model name|cpu cores|siblings' | sort | uniq
# "| sort | uniq" 排序并去重

# 查看 /etc/group 并搜索指定组
cat /etc/group | egrep '^groupname'
cat /etc/group | egrep '^(sudo|docker)'

# 查看内核参数
sudo sysctl -a | egrep 'swap'
sudo sysctl -a | egrep 'tcp.*control'

# 列出所有系统用户
cat /etc/passwd | egrep -o '^[^:]+'
```

### 过滤注释行和空白行

查看配置文件时，为了一目了然，有时需要过滤掉注释行和空白行。假定以 # 开头的行属于注释行，若干空白符加 # 开头的也算。

正则表达式匹配注释行 `^\s*#` 和空白行 `^\s*$`，然后使用 `-v` 选项反选。合并在一起就是 `egrep -v '^\s*(#|$)'`，例如：

``` bash
egrep -v '^\s*(#|$)' ~/.profile
```

### 日志搜索

下面是 apache httpd 日志的部分信息：

```
127.0.1.1:80 127.0.0.1 - - [09/Dec/2019:09:21:19 +0800] "GET / HTTP/1.1" ...
127.0.1.1:80 127.0.0.1 - - [09/Dec/2019:10:59:06 +0800] "GET / HTTP/1.1" ...
127.0.1.1:80 127.0.0.1 - - [09/Dec/2019:11:05:08 +0800] "GET / HTTP/1.1" ...
127.0.1.1:80 127.0.0.1 - - [10/Dec/2019:09:02:08 +0800] "GET / HTTP/1.1" ...
```

搜索指定时间段的日志：

``` bash
# 搜索某一天的日志egrep '^export EDITOR\b' ~/.profile
egrep '\[09/Dec/2019:' file

# 搜索某一天 10:00-11:59 之间的日志
egrep '\[09/Dec/2019:1[0-1]' file
```

### 目录搜索

`grep -r` 会递归读取整个目录进行匹配，下面看几个例子：

``` bash
# 在 /etc/apt 中搜索 vscode
egrep -i 'vscode' -r /etc/apt

# 在内核配置文件中搜索 ipv4
# 搜索范围包括 /etc/sysctl.conf 和 /etc/sysctl.d
egrep -i 'ipv4' -r /etc/sysctl.d /etc/sysctl.conf 
# 将注释行也过滤掉
egrep -i '^\s*[^#]*ipv4' -r /etc/sysctl.d /etc/sysctl.conf
```

## grep 串联

可以将多个 grep 进行串联以代替一个复杂的正则表达式，例如：

``` bash
# 搜索关键字再把注释行去掉
egrep 'ipv4' -r /etc/sysctl.d /etc/sysctl.conf | egrep -v '^\s*#'
```