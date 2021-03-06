# Linux 目录结构简介

什么文件存放在哪个目录，目录的结构如何组织，这在 Linux 上面是有规范的，下面简要介绍一下：

| 目录 | 描述 |
| --- | --- |
| `/` | 根目录 |
| `/bin` | 存放主要的二进制文件，例如 `/bin/ls` `/bin/cat` |
| `/sbin` | 类似 `/bin`，存放系统相关的二进制文件，多适用系统管理员，例如 `/sbin/mkfs` |
| `/usr` | 存放次要的只读数据 (这个目录很重要，并非字面意义的"次要") |
|     `/usr/bin` | 存放二进制文件 (与 `/bin` 的区分比较模糊) |
|     `/usr/local` | 存放本地数据，此目录下可以有 `bin` `lib` 等子目录 |
| `/opt` | 存放可选的应用程序软件包 |
| `/boot` | 存放 boot loader 文件 |
| `/dev` | 存放设备文件，例如 `/dev/cdrom` `/dev/tty` |
| `/lib` | 存放基础库文件，这是许多 bin 文件的依赖项 |
| `/etc` | 存放基础配置文件，例如 `/etc/hosts` `/etc/profile` |
| `/root` | root 用户主目录 |
| `/home` | 用户主目录，例如 `/home/user01` `/home/linux-20` |
| `/var` | 存放易变的数据 (某些特殊用户的主目录会放在这个目录下，例如 `/var/mail`) |
|     `/var/lib` | 存放程序需要持久保存的数据，例如 database 数据文件 |
|     `/var/log` | 存放日志文件 |
| `/tmp` | 存放临时文件，系统重启后不必保留 |

在今天看来，有些目录的用途与其名称是不匹配的，例如 `/etc` `/usr`。很多名称是早期定义的，一直沿用至今，但是其用途或许已经改变了。