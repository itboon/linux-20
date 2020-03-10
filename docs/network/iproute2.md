# 网络工具 iproute2

net-tools 是一款知名的老牌网络工具。Linux kernel 2.2 开始对网络子系统进行了重新设计，老牌的网络工具难以继续与之适配。iproute2 是基于新的网络子系统开发出来的工具，可以管理路由、网络接口、隧道、流量控制以及与网络相关的设备驱动程序。

下面是 iproute2 和 net-tools 相关命令的对照：

| iproute2 命令 | net-tools 命令 | 用途 |
| --- | --- | --- |
| `ip address`, `ip link` | `ifconfig` | 管理网络接口和地址 |
| `ip route` | `route` | 管理路由表 |
| `arp` | `ip neigh` | 管理 arp 表 |
| `ss` | `netstat` | 查看网络连接信息 |

## 语法介绍

`ip` 命令的语法如下：

```
ip [ OPTIONS ] OBJECT { COMMAND | help }

OBJECT := { link | address | addrlabel | route | rule | neigh | ntable | tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm | netns | l2tp | tcp_metrics | token | macsec }
```

`ip` 命令可以管理很多对象，上面已经列出来了。众多对象及其子命令要全部记住可不容易，所以 help 命令很有用，所有对象均支持 help 命令，例如 `ip help`、`ip link help`。

命令中的字段可以不敲完整，例如 `ip address` 可以敲成 `ip addr`、`ip a`；而 `ip addrlabel` 至少要敲出 `ip addrl`，因为命令识别有优先级顺序。直接敲 `ip address` 后面什么都没有，会被程序识别为 `ip address show`。

## 查看系统网络信息

查看「IP地址」、路由表和「ARP表」是最常规的需求，命令如下：

``` shell
# 查看「IP地址」
ip address

# 查看路由表
ip route

# 查看「ARP表」
ip neigh
```

执行后输出信息如下：

``` shell-session
$  ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:b6:13:16 brd ff:ff:ff:ff:ff:ff
    inet 192.168.121.142/24 brd 192.168.121.255 scope global dynamic eth0
       valid_lft 2285sec preferred_lft 2285sec
$  
$  ip route
default via 192.168.121.1 dev eth0 
192.168.121.0/24 dev eth0 proto kernel scope link src 192.168.121.142 
$  
$  ip neigh
192.168.121.1 dev eth0 lladdr 52:54:00:cd:70:3a REACHABLE
```

## 配置网络

这里我们通过一个小实验简单了解一下 iproute2 如何配置网络：

``` shell-session
$  sudo ip link add test-br type bridge
$  sudo ip address change 10.9.2.1/24 dev test-br
$  sudo ip link set test-br up
$  ip address show test-br 
96: test-br: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UNKNOWN group default qlen 1000
    link/ether 8a:8f:ab:0b:12:23 brd ff:ff:ff:ff:ff:ff
    inet 10.9.2.1/24 scope global test-br
       valid_lft forever preferred_lft forever
$  ping -c 1 10.9.2.1
PING 10.9.2.1 (10.9.2.1) 56(84) bytes of data.
64 bytes from 10.9.2.1: icmp_seq=1 ttl=64 time=0.066 ms

--- 10.9.2.1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.066/0.066/0.066/0.000 ms
$  
$  sudo ip link del test-br
```

我们把相关的命令单独列出来：

``` shell
# 创建网卡
sudo ip link add test-br type bridge

# 配置「IP地址」
sudo ip address change 10.9.2.1/24 dev test-br

# 启动网卡并查看网卡信息
sudo ip link set test-br up
ip address show test-br 

# 删除网卡
sudo ip link del test-br
```

上面对网卡进行增删改的操作都需要 root 权限，并且这些配置在重启后会失效。