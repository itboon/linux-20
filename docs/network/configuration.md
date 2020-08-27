# 配置网络

## 选择网络配置工具

配置「Linux 操作系统」的网络有以下几款主流的配置工具可供选择：

| 配置工具 | 简介 |
| --- | --- |
| systemd-networkd | systemd 是许多发行版默认的 init 程序，其中 systemd-networkd 组件可用于网络配置管理，配置文件在 `/etc/systemd/network/`。 |
| ifupdown | Debian 标准的网络配置工具，配置文件在 `/etc/network/interfaces`。 |
| NetworkManager | 一款容易上手的网络配置工具，使用 `nmcli` 和 `nmtui` 进行配置，并支持图形界面，很多桌面版 Linux 使用此工具。 |
| netplan | 通过 YAML 文件管理网络配置，支持 systemd-networkd 和 NetworkManager 作为后端程序，配置文件在 `/etc/netplan/*.yaml`。(Ubuntu Server 18.04 默认使用此工具) |

桌面环境建议使用 NetworkManager；在服务器上建议使用默认的配置工具，或者切换到 systemd-networkd。

### iproute2

iproute2 是「Linux 操作系统」上强大的网络工具，例如 `ip address`、`ip route` 命令可用于查看主机网络信息。但是这种底层网络工具配置起来有些麻烦，我们会在下一节介绍它。

## 准备工作

首先敲 `ip address` 查看一下网卡信息。

进行网络配置之前先看看操作系统有哪些程序已经在工作了，避免造成冲突。比如查看一下相关的配置文件：

```
wc -l /etc/systemd/network/*.network /etc/network/interfaces /etc/netplan/*.yaml
grep -v '^#' /etc/systemd/network/*.network /etc/network/interfaces /etc/netplan/*.yaml
```

选用一款配置工具即可，将不需要的配置文件处理掉。

!!! warning
    通过网络连接到计算机时，进行网络配置要非常小心，操作不当将会很尴尬。

## 配置网络

### systemd-networkd

在 `/etc/systemd/network` 目录下创建 `.network` 文件，例如 `/etc/systemd/network/50-eth0.network`。下面是 eth0 网卡使用 DHCP 的配置：

```
[Match]
Name=eth0

[Network]
DHCP=ipv4
```

使用「静态 IP 地址」的配置：

```
[Match]
Name=eth0

[Network]
Address=192.168.0.15/24
Gateway=192.168.0.1
DNS=119.29.29.29
DNS=223.5.5.5
```

然后启动 systemd-networkd 服务使配置生效，并设置为开机启动：

``` shell
sudo systemctl restart systemd-networkd
sudo systemctl enable systemd-networkd
```

### ifupdown

编辑 `/etc/network/interfaces`，下面是 eth0 网卡使用 DHCP 的配置：

```
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp
```

使用「静态 IP 地址」的配置：

```
auto eth0
iface eth0 inet static
  address 192.168.0.15/24
  gateway 192.168.0.1
  dns-nameservers 119.29.29.29 223.5.5.5
```

配置文件变更以后，输入下面的命令使配置生效：

``` shell
sudo ifdown eth0; sudo ifup eth0
```

### netplan

编辑 `/etc/netplan/config.yaml`，下面是 eth0 网卡使用 DHCP 的配置：

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true
```

使用「静态 IP 地址」的配置：

```
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 192.168.0.15/24
      gateway4: 192.168.0.1
      nameservers:
          addresses: [119.29.29.29, 223.5.5.5]
```

配置文件变更以后，输入下面的命令使配置生效：

``` shell
sudo netplan apply
```

## 配置 DNS

按照上面的网络配置，通过 DHCP 获取或者静态配置的方式设定了 DNS，相应的后端程序读取配置后，将「DNS服务器」写入 `/etc/resolv.conf`，此时操作系统可进行域名解析了。

DHCP 是动态的，或者用户需要在不同的网络之间切换，这些因素导致 `/etc/resolv.conf` 需要动态调整。如果看到该文件像下面这样，以软链接的形式存在，则说明 DNS 可能由某款程序管理，用户不应该直接修改该文件。

```
$  ls -l /etc/resolv.conf 
lrwxrwxrwx 1 root root 37 Feb 29 12:20 /etc/resolv.conf -> /run/systemd/resolve/stub-resolv.conf
```

上面 `/run/systemd/resolve/` 这个目录由 systemd-resolved 管理。

### systemd-resolved

systemd-resolved 是 systemd 的一个组件，不需要单独安装，直接将服务启用即可，然后将 `/etc/resolv.conf` 作为软链接指向 `/run/systemd/resolve/stub-resolv.conf`，操作如下：

``` shell
sudo systemctl enable systemd-resolved
sudo systemctl restart systemd-resolved
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

`/run/systemd/resolve/stub-resolv.conf` 内容如下：

```
# This file is managed by man:systemd-resolved(8). Do not edit.
# …

nameserver 127.0.0.53
options edns0
```

上面可以看到 `nameserver` 是 `127.0.0.53`，因为 systemd-resolved 包含一个「DNS服务」，它监听 `127.0.0.53`。此时操作系统的域名解析请求全部发到这个服务，再由它进行后续的解析。`resolvctl status` (老版本使用 `systemd-resolve --status`) 可以查看服务状态，输出信息如下：

``` shell-session
$ resolvectl status || systemd-resolve --status
Global
       LLMNR setting: yes
MulticastDNS setting: yes
  DNSOverTLS setting: no
      DNSSEC setting: allow-downgrade
    DNSSEC supported: yes
  Current DNS Server: 119.29.29.29
         DNS Servers: 119.29.29.29
                      223.5.5.5
…
```

上面可以看到，systemd-resolved 后端使用 `119.29.29.29` 作为「DNS服务器」，通过 `/etc/systemd/resolved.conf` 这个文件进行管理，配置如下：

```
[Resolve]
DNS=119.29.29.29 223.5.5.5
DNSSEC=false
```

默认情况下 `DNS=` 为空，这时会使用网卡的 DNS，即动态管理，也可以像上面那样配置为静态的。修改了配置后需要重启服务才能生效 `sudo systemctl restart systemd-resolved`。

### 锁定 /etc/resolv.conf

如果长期使用固定的 DNS，也可以直接配置 `/etc/resolv.conf`，然后将其锁定，以确保它不被其他程序修改掉。像下面这样操作:

``` shell
sudo rm -f /etc/resolv.conf
echo "nameserver 119.29.29.29" | sudo tee /etc/resolv.conf
echo "nameserver 223.5.5.5" | sudo tee -a /etc/resolv.conf
sudo chattr +i /etc/resolv.conf
```

`chattr +i` 可锁定文件，此时文件不可修改，`lsattr /etc/resolv.conf` 可以看到文件有个 `i` 属性，`chattr -i /etc/resolv.conf` 可解除锁定。
