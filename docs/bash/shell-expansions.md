# shell 字符扩展

「shell 字符扩展」支持用简洁的输入代替冗余的命令，比如 `cd ~`、`mkdir foo/bar/{a,b,c}`，这些技巧是非常有帮助的。

bash 支持以下字符扩展：

- 大括号扩展
- 波浪号扩展
- 变量扩展
- 命令置换
- 算术扩展
- 文件名扩展

## 大括号扩展

大括号扩展可以帮助批量生成字符串，例如：

``` shell-session
$  echo test-{1,2,3,foo}
test-1 test-2 test-3 test-foo
$  
$  mkdir -p ~/test/foo-a ~/test/foo-b
$  mkdir -p ~/test/brace-{a,b,c}
$  ls ~/test
brace-a  brace-b  brace-c  foo-a  foo-b
```

批量操作文件和目录时，如果它们有相同的前缀或后缀，使用大括号扩展会非常方便。

## 波浪号扩展

波浪号扩展使用简单的符号取代 home 目录和工作目录的值，常用的有下面这些：

- `~` 当前用户的 home 目录，等于 `$HOME` 的值。
- `~username` 特定用户的 home 目录。
- `~+` 当前工作目录，等于 `$PWD` 的值。
- `~-` 上一个工作目录，等于 `$OLDPWD` 的值。

`~` 作为扩展使用时必须放在单词开头，放在单词中间将被识别为普通符号。它后面的字符仍然是有特殊含义的，直到斜杠 `/` 为止。因此，`~foo` 将被识别为 foo 用户的 home 目录，如果用户不存在则保持其字面值不变。请看下面的例子：

``` shell-session
$  echo ~
/home/linux-20
$  echo ~/foo
/home/linux-20/foo
$  echo ~foo
~foo
$  echo ~root
/root
```

## 变量扩展

可以截取变量的一部分字符

- `${var:-word}` 当变量为空时，替换为 `:-` 后面的字符；当变量不为空时替换为变量的值。
- `${var:=word}` 当变量为空时，使用 `:=` 后面的字符为变量赋值；然后替换为变量的值。
- `${var:offset}` `${var:offset:length}` 裁剪变量的值。

调用一个空的变量会导致出错，可以使用 `${var:-word}` 或 `${var:=word}` 提供备用值，两者区别是前者不对变量赋值而后者赋值。

`${var:offset:length}` 可以对变量的值进行裁剪，请看下面的例子：

``` shell-session
$  foo=12345abcfoo
$  echo $foo
12345abcfoo
$  echo ${foo:2}
345abcfoo
$  echo ${foo: -3}
foo
$  echo ${foo:2:6}
345abc
$  echo ${foo:2:3}
345
$  echo ${foo: -6:3}
abc
$  echo ${foo: -6:-2}
abcf
$  echo ${foo::5}
12345
```

## 命令置换

命令的输出可作为命令的一部分，这叫命令置换，请看下面的例子：

``` shell-session
$  ls -l $(which sh)
lrwxrwxrwx 1 root root 4 Jan 18  2019 /bin/sh -> dash
$  ls -l `which sh`
lrwxrwxrwx 1 root root 4 Jan 18  2019 /bin/sh -> dash
```

`ls -l $(which sh)` 这里将先执行 `which sh`，然后将其输出替换到命令中，即 `ls -l /bin/sh`。

`$(command)` 和 `` `command` `` (反引号包裹) 这两种用法都可以，前者便于阅读。

!!! note
    反引号 `` ` `` 在键盘上数字 `1` 前面，阅读时不便于识别，因此不推荐使用。

## 算术扩展

算术扩展 `$(( expression ))` 可以获取算术表达式得到的值，请看下面的例子：

``` shell-session
$  echo $(( 3+7 ))
10
$  echo $(( 3*7 ))
21
$  i=5; echo $(( i+3 ))
8
```

## 文件名扩展

文件名扩展支持「shell 模式匹配」

### shell 模式匹配

下列字符在模式匹配中具有特殊含义：

- `*` 匹配任意字符，包括空字符。
- `?` 匹配一个任意字符。
- `[…]` 匹配一个包含在列表中的字符。支持区间写法，例如 `[abcde]` 可以写成 `[a-e]`，`5678` 可以写成 [5-8]。

请看下面的例子：

``` shell-session
$  touch foo-{a,ab,1}
$  
$  ls foo-*
foo-1  foo-a  foo-ab
$  ls foo-?
foo-1  foo-a
$  ls foo-[a-z]
foo-a
$  ls foo-[a-z]*
foo-a  foo-ab
$  
$  rm foo-*
$  ls foo-*
ls: cannot access 'foo-*': No such file or directory
$  
```

模式匹配在创建文件时不被支持，因为创建包含任意字符的文件是不合理的；其他文件操作均支持模式匹配。