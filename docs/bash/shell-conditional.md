# shell 条件语句

## if

if 语句的语法如下：

``` shell
if test-commands; then
  commands...
elif test-commands; then
  commands...
else
  commands...
fi
# elif 是可选的并且可以有多条
# else 是可选的
```

if 语句在测试命令 `test-commands` 返回值为零时 (即条件为真时) 执行 `then` 后面的命令。当所有条件都不满足时，则执行 `else` 子句。其中 `elif` 是可选的并且可以有多条，用来提供更多条件测试。`else` 也是可选的。请看下面的例子：

``` shell
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
```

这里使用 if 语句确保文件存在再执行。`[ -f "$HOME/.bashrc" ];` 这个条件表达式用于判断文件是否存在。`. "$HOME/.bashrc"` 等同于 `source "$HOME/.bashrc"`，用于在当前 shell 执行文件。

借助分号可以将上面的命令写到一行：

``` shell
if [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi
```

## 常用条件判断

- `-f file` 文件存在且为普通文件。
- `-d file` 文件存在且为目录文件。
- `-e file` 文件存在。
- `s1 = s2` 字符串相等。
- `s1 != s2` 字符串不等。
- `n1 OP n2` 数字比较，OP 可以是这些：`-eq` `-ne` `-lt` `-le` `-gt` `-ge`，分别判断 `n1` 是否等于、不等于、小于、小于等于、大于、大于等于 `n2`。

## 条件表达式

常规的条件表达式有两种写法，`test expression` 和 `[ expression ]` (方括号里面前后各有一个空格，不能少)。请看下面的例子：

``` shell-session
$  [ -d /etc ] && echo true
true
$  [ -d /foo ] && echo true
$  [ 5 -gt 3 ] && echo true
true
$  echo "$USER $(id -u)"
linux-20 1002
$  [ $(id -u) -ge 1000 ] && echo true
true
$  [ $USER != root ] && echo true
true
```

这里在条件表达式后面加上 `&& echo true`，若条件为真则执行 `echo`，它相当于简短的 if 语句 `if [ -d /etc ]; then echo true; fi`。

条件表达式可以进行与或非处理：

- `[ ! expression ]` 否定判断。
- `[ expression1 -a expression2 ]` 两个表达式都为真。
- `[ expression1 -o expression2 ]` 两个表达式中任意一个为真。

### 双方括号 `[[ expression ]]`

bash 可以用双放括号代替方括号，它提供了增强特性，支持正则表达式，例如：

``` shell-session
$  [[ $USER =~ ^linux ]] && echo hello $USER
hello linux-20
```

`[[ $USER =~ ^linux ]]` 如果用户名以 `linux` 开头则为真。关于正则表达式将在 grep 章节介绍，这里只简单了解一下。

### 双括号 `(( expression ))`

双括号表达式即算术表达式，它有以下特点：

- 支持算术运算符。
- 支持多个表达式，表达式之间用逗号 `,` 分开。
- 双括号里面调用变量可省略 `$` 符号。
- 双括号里前后的空格可以省略。

调用算术表达式的结果使用 `$(( expression ))` 。

``` shell-session
$  echo $((3 + 7)), $((3 * 7))
10, 21
$  i=1; ((i=i+5, i=i*2)); echo $i
12
$  i=1; ((i++, i++)); echo $i
3
$  i=100; ((i==100)) && echo true
true
$  i=100; ((i>=5)) && echo true
true
$  (($(id -u) != 0)) && echo "I am not root"
I am not root
```

## case

`case` 是 if 语句的变种，一般用于对变量进行分类比对，例如：

``` shell
echo ${LANG:0:2}
case ${LANG:0:2} in
  zh) lang=Chinese;;
  en) lang=English;;
  *)  lang=unkown;;
esac
echo "You are using $lang"
```

上面执行后将得到如下输出：

``` shell-session
$  echo ${LANG:0:2}
en
$  case ${LANG:0:2} in
>   zh) lang=Chinese;;
>   en) lang=English;;
>   *)  lang=unkown;;
> esac
$  echo "You are using $lang"
You are using English
```

`case` 经常用于 shell 脚本的交互设计，根据用户的输入控制脚本的流程，例如：

``` shell
echo -n "Continue [Yes/No]"; read answer
case $answer in
  y | yes) echo "doing something";;
  n | no) echo "doing nothing";;
  * ) echo "unknown answer";;
esac
```

## select

`select` 可用来制作菜单，它经常与 `case` 配合使用，例如：

``` shell
echo "Choose a shell: "
select shell in "ash" "bash" "zsh" "Exit"
do
  case $shell  in
    ash) echo "ash is Almquist shell";;
    bash) echo "bash is Bourne-Again shell";;
    zsh) echo "zsh is Z shell";;
    Exit) break;;
    *) echo unkown;;
  esac
done
```