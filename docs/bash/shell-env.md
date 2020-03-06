# 环境变量

我们先通过实际操作来看看一些系统环境变量：

``` shell-session
$  echo $SHELL
/bin/bash
$  
$  echo $USER
linux-20
$  
$  echo $HOME
/home/linux-20
$  
$  echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/local/go/bin:/usr/local/nodejs/bin:/home/linux-20/go/bin:/home/linux-20/.local/bin
$  
$  printenv LANG
en_US.UTF-8
```

`echo $VAR` 可查看所有环境变量，`printenv VAR` 只可查看全局环境变量。

调用变量使用 `$` 加变量名，比如 `$USER`、`$PATH`，更规范的书写方式是 `${USER}`、`${PATH}`。我们通过一个例子看看两者的区别：

``` shell-session
$  echo $USER
linux-20
$  
$  echo $USER_book

$  echo ${USER}_book
linux-20_book
```

`$USER_book` 这个变量是不存在的，我们需要将 `_book` 作为普通字串放到 `$USER` 后面组成新的字串，此时必须书写为 `${USER}_book`。

可以看到，加大括号的书写方式比较清晰，而且能够明确界定变量字串和普通字串。

## 全局环境变量/局部环境变量

环境变量有两种，「全局环境变量」和「局部环境变量」。全局变量对当前 shell 及子 shell 有效，局部变量仅对当前 shell 有效。

`foo=bar` 即定义了局部环境变量 `foo`，它的值是 `bar`。定义全局环境变量，`foo=bar; export foo` (可以将多行命令写在一行，用分号隔开) 或者 `export foo=bar`。请看下面的例子：

``` shell-session
$  # 定义局部环境变量
$  foo=bar
$  echo $foo
bar
$  # 启动一个 bash 子进程，局部环境变量不会传递
$  bash
$  echo $foo

$  # 定义全局环境变量
$  export foo=bar
$  echo $foo
bar
$  # 再启动一个 bash 子进程，全局环境变量继续可用
$  bash
$  echo $foo
bar
$  # 退出 bash 子进程，回到初始 bash
$  exit
exit
$  exit
exit
```

`env` 或者 `printenv` 可输出所有全局环境变量，`set` 可输出所有环境变量 (输出结果会很长)。`unset VAR` 可删除环境变量。

## profile

退出 bash 进程后，该进程运行时定义的环境变量也就不存在了。定义永久的环境变量则需要保存到相应的配置文件，此配置文件也称 profile。

profile 有系统级的和用户级的，系统级的 profile 是 `/etc/profile`，用户级的 profile 通常是 `~/.profile` (`~` 表示当前用户的 home 目录)。

当启动交互式的登录 bash，首先加载系统 profile，然后加载用户 profile。用户 profile 是 `~/.bash_profile` `~/.bash_login` `~/.profile` 这三个文件中的一个，按顺序读取，首先读取成功的有效。因此这三个文件有一个就可以，建议使用 `~/.profile`，除了 bash 它还被其他多种 shell 程序支持。

用户 profile 中有这样的脚本：`if [ -f ~/.bashrc ]; then . ~/.bashrc; fi`，意思是如果 `~/.bashrc` 文件存在，则执行它。这段脚本默认是有的，可别轻易删除了。

### /etc/profile.d

`/etc/profile` 有如下配置：

``` shell
if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
```

这一段的作用是 `/etc/profile.d` 这个目录下所有以 `.sh` 结尾的文件都将作为系统 profile 加载。因此用户可以创建一个 `/etc/profile.d/local.sh` 文件，作为系统级的 profile 文件，这样管理会更加清晰。

## $PATH

`$PATH` 是非常重要的一个变量，当我们敲一个命令，系统会在 `$PATH` 定义的路径下搜索可执行文件。

`$PATH` 的值像这样 `/home/linux-20/bin:/usr/local/bin:/usr/bin:/bin`，多个路径用 `:` 隔开。执行命令时从左到右搜索，左边的优先级高。将用户的目录放前面，使得用户目录的程序比系统目录的程序优先执行。

我们使用的 `ls` `env` 等命令，它们完整的路径是 `/bin/ls` `/usr/bin/env`，错误配置 `$PATH` 将带来严重的后果，请看下面的例子：

```
$  # 启动一个 bash 子进程
$  bash
$  echo $PATH
/home/linux-20/bin:/usr/local/bin:/usr/bin:/bin
$  
$  # which 可以查看命令匹配到的可执行文件
$  which ls
/bin/ls
$  which env
/usr/bin/env
$  which which
/usr/bin/which
$  
$  # 重新配置 PATH
$  export PATH="/usr/bin"
$  which ls
$  which env
/usr/bin/env
$  ls
bash: ls: command not found
$  
$  # PATH 添加目录
$  export PATH=$PATH:/bin
$  echo $PATH
/usr/bin:/bin
$  which ls
/bin/ls
$  
$  # 删除 PATH
$  unset PATH
$  which env
bash: which: No such file or directory
$  
$  # 退出 bash 子进程
$  exit
exit
$  # 父进程不受影响
$  echo $PATH
/home/linux-20/bin:/usr/local/bin:/usr/bin:/bin
```

有些 Linux 程序提供二进制程序包，安装时只需下载并解压，然后配置 `$PATH` 即可。

比如安装 nodejs，通常的做法是将其二进制程序包解压到 `/usr/local/nodejs` 目录，然后在系统 profile 中加入一行 `export PATH=/usr/local/nodejs/bin:$PATH`。要在 `$PATH` 中增加目录，推荐这样操作：`export PATH=/newpath:$PATH` `export PATH=$PATH:/newpath`。

## 何时加 $ 符号

调用环境变量时需要加 `$` 符号，配置环境变量时则不需要。`export PATH=/newpath:$PATH` 中，前面的 PATH 表示定义一个环境变量，后面的 `$PATH` 表示调用已有的环境变量。