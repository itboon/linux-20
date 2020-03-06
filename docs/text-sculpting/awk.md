# gawk 基础用法

awk 是一款用于处理文本的编程语言工具。它提供了比较强大的功能：可以进行正则表达式的匹配，流控制、数学运算符、进程控制语句还有内置的变量和函数。

gawk 即 GNU awk，是许多 Linux 发行版默认的 awk 程序。

## 安装

``` bash
sudo apt install gawk
```

## gawk 正则表达式

gawk 使用 ERE 语法，与  [grep ERE 语法](../grep-regexp) 基本一致，有两点需要注意：

- awk 正则表达式写在 2 个 `/` 中间，书写普通斜杠符号需要加转义字符：`\/`。
- 因为 `\b` 在 awk 语言里被定义为 backspace，所以 gawk 使用 `\y` 代替 `\b` 作为锚点符号，匹配单词的边缘。

## gawk 代替 grep 和 sed

gawk 可以用于文本搜索和文本替换，一定程度上可代替 grep 和 sed，请看下面的例子。

用于文本搜索：

``` bash
# 查看发行版
cat /etc/os-release | gawk '/PRETTY/'
cat /etc/os-release | grep 'PRETTY'

# 过滤注释行或空白行
cat ~/.profile | gawk '!/^\s*(#|$)/'
cat ~/.profile | egrep -v '^\s*(#|$)'
```

用于文本替换：

``` shell-session
$  echo "A beautiful girl" | gawk '{gsub(/girl/,"woman"); print $0}'
A beautiful woman
$  
$  echo "A beautiful girl" | sed 's/girl/woman/'
A beautiful woman
```

gawk 是比较全能的文本处理工具，但是在一些基本的用途中，其简洁性不如 grep 和 sed，如何选择则根据个人习惯。

## 字段分割

awk 根据字段分割符划分文本行，并将如下变量分配给数据字段：

- `$0` 代表整行文本
- `$1` 代表行中的第 1 个数据字段
- `$2` 代表行中的第 2 个数据字段
- `$n` 代表行中的第 n 个数据字段

默认的分割符是空格或者制表符，可以使用 `-F` 选项指定分割符，请看下面的例子：

``` bash
# 使用默认分割符，打印第二个字段
cat /etc/apt/sources.list | gawk '{print $2}'

# 指定分割符，打印第一个字段
cat /etc/passwd | gawk -F : '{print $1}'
```

### 按指定数据字段进行匹配

awk 可以指定数据字段进行文本匹配，而不是整行匹配，请看下面的例子：

``` bash
# 搜索包含 bin 的行
cat /etc/passwd | gawk -F : '/bin/'

# 搜索第一个字段包含 bin 的行，即用户名包含 bin
cat /etc/passwd | gawk -F : '$1 ~ /bin/'
```

## 数学表达式

数学表达式支持 `==` `>` `>=` `<` `<=` 这些数学符号，例如：

``` bash
# 找出 uid 大于等于 1000 的用户
cat /etc/passwd | gawk -F : '$3 >= 1000'
```

`==` 也可以用于字符串精确匹配，例如：

``` bash
# 使用数学表达式找出 bin 用户
cat /etc/passwd | gawk -F : '$1 == "bin"'

# 使用正则表达式找出 bin 用户
cat /etc/passwd | gawk -F : '$1 ~ /^bin$/'
```

## 布尔表达式

布尔操作符 `||` (or), `&&` (and), `!` (not), 例如：

``` bash
# 大于等于 1000 或等于 0
cat /etc/passwd | gawk -F : '$3 >= 1000 || $3 == 0'

# 大于等于 1000 或且小于 2000
cat /etc/passwd | gawk -F : '$3 >= 1000 && $3 < 2000'

# 不小于 1000
cat /etc/passwd | gawk -F : '!($3 < 1000)'

# 不匹配三位数及以下
cat /etc/passwd | gawk -F : '$3 !~ /^[0-9]{1,3}$/'
```

## printf 格式化打印

printf 支持更灵活的打印输出，例如：

``` bash
# 按指定宽度打印用户名和 uid，实现等宽排列
cat /etc/passwd | gawk -F : '{printf "%-20s %5s\n", $1, $3}'
```

将得到用户名和 uid 整齐的输出格式，如下所示：

```
root                     0
daemon                   1
nobody               65534
systemd-timesync       100
systemd-network        101
```

gawk 中 printf 的用法跟C语言一样:

```
printf "%-20s %5s\n", $1, $3
```

这个例子中 2 个 `%s` 是字符串指示符，输出时被后面对应位置的变量替换，中间的数字 `20` 和 `5` 代表输出字段的最小宽度，默认右对其，数字前加 `-` 代表左对其。

下面再看一个例子：

``` bash
cat /etc/group | gawk -F : '{printf "%-20s %-10s Members: %s\n", $1, $3, $4}'
```

将得到组名，gid，组成员整齐的输出格式，如下所示：

```
root                 0          Members: 
ssl-cert             109        Members: postgres
scanner              119        Members: saned,jack
docker               130        Members: jack
```

##  awk 语法

运行 awk：

``` bash
# 命令行运行
awk 'program' input-file1 input-file2 …

# 从程序源文件运行，使用 -f 选项
awk -f program-file input-file1 input-file2 …
```

awk program 格式：

```
pattern { action }
pattern { action }
…
```

案例：

``` bash
# 以下几种写法效果一样
awk -F : '$3 >= 1000 {print}' /etc/passwd
cat /etc/passwd | gawk -F : '$3 >= 1000 {print}'
cat /etc/passwd | gawk -F : '$3 >= 1000 {print $0}'
# {print} 等同于 {print $0}，可省略不写
cat /etc/passwd | gawk -F : '$3 >= 1000'
```

## awk 其他进阶用法

``` bash
# if 语句
cat /etc/passwd | gawk -F : '{if ($1 == "bin") print $0}'

# 调用 shell 环境变量
cat /etc/passwd | gawk -F : '{if ($1 == ENVIRON["USER"]) print $0}'

# 字符函数，转换为小写字母
cat /etc/os-release | gawk 'tolower($0) ~ /pretty/'
env | gawk '{print tolower($0)}'
```