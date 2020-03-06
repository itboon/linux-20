# 选择 shell

目前最流行的 shell 程序是 bash，全称 "Bourne-Again shell"，它是很多「Linux 发行版」默认的「登录 shell」，此外还有其他几款知名的 shell：

- Bourne shell：曾经最流行的 shell，bash 的名字来自于它。
- ash (Almquist shell)：一款 BSD 许可的 Bourne shell 替代产品，体积小巧，通常在资源受限的环境中使用。
- dash (Debian Almquist shell)：debian 版本的 ash。
- zsh (Z shell)：目前很流行的一款 shell，它在 Bourne shell 的基础上做了很多改进，并包含 bash 和其他一些 shell 的功能。2019年10月发布的 macOS Catalina 使用 zsh 作为默认 shell。
- Busybox: 它将大量的 Unix 工具集成在一起，其中包括 shell 程序，用的是 ash (Almquist shell)。

以上这些 shell 均符合 POSIX 规范，在不同 shell 之间切换是受支持的。但使用某款 shell 增强的功能，可能在其他 shell 上不受支持。

!!! note
    本书使用 bash 作为「默认 shell」。

## 切换 shell

要切换到其他 shell，直接运行该程序即可，例如：

``` shell-session
$  # 从 bash 切换到 zsh
$  zsh
$
$  # 退出 zsh，返回到 bash
linux-20@sdeb ~ % exit
$ 
```

`/etc/shells` 登记了可用的登录 shell，`echo $SHELL` 查看「默认 shell」：

``` shell-session
$  cat /etc/shells
# /etc/shells: valid login shells
/bin/sh
/bin/dash
/bin/bash
/bin/rbash
/bin/zsh
$
$  echo $SHELL
/bin/bash
```

`usermod` 或者 `chsh` 可修改「默认 shell」：

``` shell
usermod -s /bin/zsh linux-20
chsh    -s /bin/zsh linux-20
```
