# 「I/O 流」管道和重定向

## I/O 流

shell 使用 3 种标准「I/O 流」，每种流与一种文件描述符相关联：

- stdout 是标准输出流，显示来自命令的输出。文件描述符为 1。
- stderr 是标准错误流，显示来自命令的错误输出。文件描述符为 2。
- stdin 是标准输入流，向命令提供输入。文件描述符为 0。

## 输出重定向

使用 `>>` 或 `>` 将输出流重定向到文件。如果文件不存在则创建文件；如果文件已存在的话，`>` 覆盖文件，`>>` 附加文本到文件。例如：

``` shell
echo "some text" > foo.txt
echo "append" >> foo.txt

ps >> ps.output
```

上面是将 stdout 重定向到文件，下面演示对 stderr 的处理：

``` shell-session
$  ls /usr  > output.txt 
$  
$  # 报错的输出是 stderr，它不同于 stdout
$  ls /not-exist > output.txt 
ls: cannot access '/not-exist': No such file or directory
$  
$  # stdout 和 stderr 重定向到不同文件
$  ls /usr /not-exist > stdout.txt 2> stderr.txt
$  
$  cat stderr.txt
ls: cannot access '/not-exist': No such file or directory
$  
$  # stdout 和 stderr 都输出到一个文件，下面两条命令效果一样
$  ls /usr /not-exist &> output.txt
$  ls /usr /not-exist > output.txt 2>&1
$  cat output.txt
ls: cannot access '/not-exist': No such file or directory
/usr:
bin
lib
local
...
```

上例中 `2>&1`，2 和 1 分别是 stderr 和 stdout，即将 stderr 重定向到 stdout。`ls /usr /not-exist > output.txt 2>&1` 这一行的意思是将 stdout 重定向到 output.txt，且 stderr 重定向到 stdout，即全部重定向到文件。如果写成 `2>1` 则表示 stderr 重定向到 `1` 这个文件，所以有了 `2>&1` 这样特别的语法。

### 屏蔽输出

屏蔽输出只需要重定向到 `/dev/null`，例如：

``` shell-session
$  ls /not-exist
ls: cannot access '/not-exist': No such file or directory
$  
$  # 屏蔽 stderr
$  ls /not-exist 2> /dev/null
$  
$  # 屏蔽所有输出
$  ls /usr /not-exist &> /dev/null
```

## 输入重定向

我们先来看一个输入重定向的例子：

``` shell-session
$  sort <<EOF
> beef
> cheese
> apple
> EOF
apple
beef
cheese
```

sort 命令用于对问本行进行排序，可以从文件读取文本，也可以从 stdin 读取文本。`<<EOF` 表示前面的命令将从 stdin 读取文本，接下来终端显示提示符 `>` 表示用户可以输入文本，最后敲 `EOF` 结束重定向 (`EOF` 可以替换为其他字符，开始和结束标记必须保持一样)。

另一个普遍的用途就是一次性写入多行文本到文件，例如写入一个 `foo.txt` 文件：

``` shell
cat > foo.txt <<EOF
This is line one.
This is line two.
EOF

# 另一种写法
cat <<EOF > foo.txt
This is line one.
This is line two.
EOF
```

## 管道

管道符号 `|`（英文名：pipeline）可以将多个命令串联起来，每一个进程的 stdout 作为下一个进程的 stdin，在 shell 中使用频率很高。比如一个命令输出的内容很多，我们可以用管道加上 `more` 便可以分页阅读，或者使用 `grep` 进行过滤。

``` shell
ps -ef | more
ps -ef | head
ps -ef | grep init

# 排序去重并统计行数
cat file | sort | uniq | wc-l
```

`sort` 排序、`uniq` 去重、`wc -l` 统计行数，这些都是 shell 常用的命令，用管道组合各种命令将更奇妙。

## tee 命令

`tee` 经常与管道组合起来使用，可在 stdout 正常输出的同时另外保存一份到文件。例如将 ping 得到的结果保存到文件：

``` shell-session
$  ping -c 3 www.baidu.com | tee ping.log
PING www.a.shifen.com (180.101.49.11) 56(84) bytes of data.
64 bytes from 180.101.49.11 (180.101.49.11): icmp_seq=1 ttl=52 time=17.1 ms
64 bytes from 180.101.49.11 (180.101.49.11): icmp_seq=2 ttl=52 time=19.4 ms
64 bytes from 180.101.49.11 (180.101.49.11): icmp_seq=3 ttl=52 time=16.7 ms

--- www.a.shifen.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 16.736/17.737/19.396/1.186 ms
$  
$  cat ping.log
PING www.a.shifen.com (180.101.49.11) 56(84) bytes of data.
64 bytes from 180.101.49.11 (180.101.49.11): icmp_seq=1 ttl=52 time=17.1 ms
...
```

`tee` 每次覆盖文件，`tee -a` 可附加文本到文件。

## 重定向和 sudo

正常的重定向无法配合 `sudo` 使用，解决的方法是通过 root 调用一个子 shell，在这个子 shell 里面进行重定向。例如：

``` shell-session
$  sudo echo "some text" >> /root/foo.txt
bash: /root/foo.txt: 权限不够
$  
$  sudo bash -c 'echo "some text" >> /root/foo.txt'
$  sudo cat /root/foo.txt
some text
```

另外 `tee` 命令可以与 `sudo` 配合使用，例如：

``` shell-session
$  echo "append" | sudo tee -a /root/foo.txt
append
$  sudo cat /root/foo.txt
some text
append
$  # tee 写入文件并将 stdout 屏蔽
$  echo "append again" | sudo tee -a /root/foo.txt > /dev/null
```

!!! warning
    把文件覆盖了就等于删除了，所以这类操作要小心，追加写入使用 `>>`、`tee -a`