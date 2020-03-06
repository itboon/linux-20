# shell 基础命令简介

## 最基础的命令 echo cd pwd ls cat

- `echo` 显示一行文本
- `cd` 切换目录
- `pwd` 查看当前所在目录
- `ls` 查看目录信息，通常用来查看目录下有哪些文件
- `cat` 串联文件并打印，通常用来阅读文本文件

例如：

``` shell-session
$  echo "Basic Commands"
Basic Commands
$  echo "查看文件"
查看文件
$  cat /etc/os-release 
PRETTY_NAME="Debian GNU/Linux 10 (buster)"
NAME="Debian GNU/Linux"
VERSION_ID="10"
VERSION="10 (buster)"
VERSION_CODENAME=buster
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
$  
$  echo "切换到用户主目录"
切换到用户主目录
$  cd ~
$  
$  echo "查看当前所在目录"
查看当前所在目录
$  pwd
/home/linux-20
$  
$  echo "查看当前目录信息"
查看当前目录信息
$  ls
图片  文档  下载  音乐  桌面  backup  bin  download  lib
... 
$  
$  echo "查看根目录信息"
查看根目录信息
$  ls /
bin  dev  home  mnt  run  tmp  var  etc  lib  root  sbin  usr
... 
```

!!! note
    `$` 是 shell 提示符，表示该行是 shell 命令，不以该符号开头的行是输出信息。上面第一行 `$  echo "Basic Commands"` 中 `echo "Basic Commands"` 是用户输入的命令，第二行 `Basic Commands` 是输出的信息。

### 简单创建文本文件

`echo` 还可用于创建文本文件，请看下面的例子：

``` shell-session
$  echo "some text" > example.txt 
$  cat example.txt 
some text
$  echo "new text" > example.txt 
$  cat example.txt 
new text
$  echo "append" >> example.txt
$  cat example.txt 
new text
append
```

若文件已存在，使用 `>` 总是覆盖文件，使用 `>>` 可附加一行。

### ls 显示更多信息

ls 最常用的选项有：

- `-a` 显示所有文件，包括隐藏文件
- `-l` 使用长列表格式，将显示更多文件信息

``` shell-session
$  ls -al ~
total 148
drwxr-xr-x 3 linux-20 linux-20  4096 Feb 16 14:11 .
drwxr-xr-x 9 root     root      4096 Feb 18 12:57 ..
-rw-r--r-- 1 linux-20 linux-20    70 Jan 19 17:21 .bash_aliases
-rw------- 1 linux-20 linux-20  1420 Feb 16 20:52 .bash_history
-rw-r--r-- 1 linux-20 linux-20   220 Jan 19 17:18 .bash_logout
-rw-r--r-- 1 linux-20 linux-20  3590 Jan 19 17:24 .bashrc
-rw-r--r-- 1 linux-20 linux-20   971 Jan 21 16:05 .profile
-rw------- 1 linux-20 linux-20  7537 Feb 16 13:18 .viminfo
-rw------- 1 linux-20 linux-20    82 Feb 16 14:11 .zsh_history
-rw-r--r-- 1 linux-20 linux-20  1295 Feb 16 14:06 .zshrc
-rw------- 1 linux-20 linux-20  1420 Feb 12 21:39 download
-rw------- 1 linux-20 linux-20  1420 Feb 16 20:56 project
...
```

## 目录和文件操作

- `mkdir` 创建目录
- `touch` 修改文件时间戳，也可用于创建空文件
- `cp` 复制文件
- `mv` 移动文件
- `rm` 删除文件

``` shell-session
$  mkdir linux-20
$  cd linux-20
$  
$  touch foo
$  cp foo foo-2
$  ls
foo  foo-2
$  mv foo bar
$  ls
bar  foo-2
$  rm bar foo-2
```

### ln 创建文件链接

`ln` 用于创建文件链接，默认创建硬链接，`ln -s` 可以创建软链接。请看下面的例子：

``` shell-session
$  # 创建 foo 文件，并为其创建硬链接和软链接
$  touch foo
$  ln foo foo-ln
$  ln -s foo bar
$  ls -l
lrwxrwxrwx 1 linux-20 linux-20 3 Feb 18 16:49 bar -> foo
-rw-r--r-- 2 linux-20 linux-20 0 Feb 18 16:49 foo
-rw-r--r-- 2 linux-20 linux-20 0 Feb 18 16:49 foo-ln
$  echo "text for foo" > foo
$  echo "append for bar" >> bar
$  cat foo-ln
text for foo
append for bar
$  cat bar
text for foo
append for bar
```

`ls -l` 可以明显看到软链接的关系，而硬链接不能直观看出来。不管是硬链接还是软链接，都可以对其读写，使得一个文件有多个访问路径。

## 查看文件内容

前面已经介绍了使用 `cat` 查看文件内容，`cat` 一次性将文件内容打印出来，如果文件有数页或更多时则不太好用。这里还有几个命令可以查看文件：

- `more` 通过翻页的形式查看文件
- `head` 查看文件开头几行
- `tail` 查看文件末尾几行

`head` 和 `tail` 默认输出 10 行，使用 `-n` 参数可指定行数，例如 `head -n 1 /etc/os-release` 只输出第一行。

## 进程管理 top ps kill

`top` 可查看所有进程和系统资源信息，进入后可翻页，按 `q` 退出。

`ps` 可以查看当前进程 (当前 shell 进程和此时运行的 ps 进程)，`ps -ef` 可以查看所有进程并输出更多信息。

`pgrep` 可以根据名称搜索进程，`pgrep -l firefox` 搜索包含关键字 firefox 的进程。`-l` 仅显示进程名，需要完整显示进程可使用 `-a` (显示进程完整路径和参数)。默认只匹配进程名 (`-l` 显示的字串)，`-f` 可完整匹配 (`-a` 显示的字串)。请看下面的例子：

``` shell-session
$  pgrep -l firefox
26658 firefox-esr
$  
$  pgrep -lf firefox
26658 firefox-esr
26705 Web Content
26747 Web Content
26908 WebExtensions
$  
$  pgrep -af firefox
26658 /usr/lib/firefox-esr/firefox-esr
26705 /usr/lib/firefox-esr/firefox-esr -contentproc -childID 1 -isForBrowser -prefsLen 1 -prefMapSize 188430 -parentBuildID 20200206211857 -greomni /usr/lib/firefox-esr/omni.ja -appomni /usr/lib/firefox-esr/browser/omni.ja -appdir /usr/lib/firefox-esr/browser 26658 true tab
...
```

`kill <pid>` 可终止进程，`kill -9 <pid>` 可强制杀死进程，pid 可通过 `top`、`ps`、`pgrep` 看到。

## 查看系统资源

### free

`free` 可查看物理内存和 swap 使用情况，默认输出的数据以 KB 为单位，`-h` 选项自动进行单位换算使输出结果便于阅读，`-w` 支持宽列表输出，输出信息如下：

``` shell-session
$  free -hw
              total        used        free      shared     buffers       cache   available
Mem:          7.7Gi       4.3Gi       1.2Gi       544Mi       629Mi       1.5Gi       2.6Gi
Swap:          14Gi       853Mi        14Gi
```

下面是输出信息中的部分字段的解释：

- `total` 总内存容量。
- `free` 空闲的内存。
- `cache` 用于读取磁盘的内存缓存 (page cache and slabs)。这些内存可自动回收以供新的程序运行。
- `available` 系统评估的可供运行新程序的内存容量 (MemAvailable in /proc/meminfo)

### df

`df` 可查看磁盘使用情况，`-h` 选项自动进行单位换算使输出结果便于阅读，`-T` 选项输出文件系统类型，输出信息如下：

``` shell-session
$  df -hT
Filesystem            Type      Size  Used Avail Use% Mounted on
/dev/mapper/VG01-root ext4       28G   11G   16G  41% /
/dev/sda1             ext2      938M  109M  782M  13% /boot
/dev/sda2             vfat      953M   32M  921M   4% /boot/efi
/dev/mapper/VG01-var  ext4       55G   10G   43G  20% /var
/dev/mapper/VG01-home ext4      314G  217G   82G  73% /home
tmpfs                 tmpfs     3.9G  174M  3.7G   5% /dev/shm
…
```

## 网络工具

### ip address

`ip address` 可查看网络接口和「ip地址」，输出信息如下：

``` shell-session
$  ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp2s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq state DOWN group default qlen 1000
    link/ether 68:f7:28:44:ff:25 brd ff:ff:ff:ff:ff:ff
3: wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether d0:7e:35:6a:df:ec brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.4/24 brd 192.168.3.255 scope global dynamic noprefixroute wlp3s0
       valid_lft 598755sec preferred_lft 598755sec
$  
```

### curl 下载文件

下载文件可使用 `curl` 工具，命令格式如下：

``` shell
curl https://github.com/itboon/storage/raw/master/vim/vimrc -L -o vimrc.tmp
```

`curl` 默认只将数据打印出来，`-o` 用于保存为文件。`-L` 用于支持网页重定向。

## tar 打包和压缩

`tar` 是一款打包工具，打包后的文件称为「tar包」。下面是最常用的几项操作：

``` shell
# 将 foo 目录打包为 foo.tar
tar -c -f foo.tar foo

# 打包并使用 gzip 压缩
tar -c -g -f foo.tar.gz foo

# 列出「tar包」里面的文件
tar -t -f foo.tar

# 从「tar包」释放文件
tar -x -f foo.tar

# 释放文件到指定文件夹
tar -x -f foo.tar -C /tmp
```

选项解释：

- `-c` 创建「tar包」。
- `-t` 列出「tar包」里面的文件。
- `-x` 从「tar包」释放文件。
- `-f` 指定「tar包」文件名。

`tar` 还支持简洁的写法，例如：

``` shell
tar cf foo.tar foo
tar tf foo.tar
tar xf foo.tar
```
