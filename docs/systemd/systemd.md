# systemd 和 systemctl

systemd 是许多「Linux 发行版」默认的 init 程序。init 是操作系统的「一号进程」，内核加载完成后首先运行该进程，接着由它完成后面的系统启动。

除了作为初始化进程外，systemd 还提供其他的功能。包括电源管理、日志记录、系统配置、网络配置、网络时间同步和域名解析等。

## 命令行工具

`systemctl` 是 systemd 最重要的命令行工具，用于管理操作系统的基础运作。

此外还有下列这些常用的工具：

- `journalctl` 查看日志。
- `systemd-analyze` 分析系统启动过程。
- `resolvectl` 域名解析，管理 systemd 域名服务 (systemd-resolved)。
- `hostnamectl` 管理主机名。
- `localectl` 管理区域和语言。
- `timedatectl` 管理时钟。
- `loginctl` 管理用户登录。

有些工具需要在相应的后端服务运行的情况下才可以使用，比如 `journalctl` 对应的后端服务是 `systemd-journald.service`，使用 man 可以查询。

## unit

systemd 管理的单元叫 "unit"，unit 可以是服务 (`.service`)、挂载点 (`.mount`), 设备 (`.device`)、sockets (`.socket`) 等，例如 `systemd-networkd.service`、`boot.mount`。

输入命令时 `.service` 后缀可省略。

## 常用命令汇总

### systemctl

下面以管理 `systemd-timesyncd.service` 为例，列出 `systemctl` 常用命令。

``` shell-session
控制类的操作需要 root 权限，例如 start/stop/enable/mask 等

查看状态
$  systemctl status systemd-timesyncd

启动
$  systemctl start systemd-timesyncd

停止
$  systemctl stop systemd-timesyncd

重启
$  systemctl restart systemd-timesyncd

重载配置
$  systemctl reload systemd-timesyncd

设置开机启动
$  systemctl enable systemd-timesyncd

禁用开机启动
$  systemctl disable systemd-timesyncd

检查运行状态
$  systemctl is-active systemd-timesyncd

检查是否开机启动
$  systemctl is-enabled systemd-timesyncd

屏蔽 (服务无法被启动直到 unmask 解除屏蔽)
$  systemctl mask systemd-timesyncd

解除屏蔽
$  systemctl unmask systemd-timesyncd
```

systemctl 还可以管理电源：

``` shell-session
重启
$  systemctl reboot

关机
$  systemctl shutdown

挂起 (系统状态保存到内存，不断电)
$  systemctl suspend

休眠 (系统状态保存到硬盘，然后断电)
$  systemctl hibernate
```

通过 polkit 可实现本地登录的普通用户使用 `systemctl` 进行电源管理。安装 plokit：

```
$  sudo apt install policykit-1
```

### systemd-analyze

`systemd-analyze` 用于分析系统启动过程，常用命令如下：

``` shell-session
分析系统启动过程
$  systemd-analyze

分析 units 启动时花费的时间
$  systemd-analyze blame
```

### journalctl

`journalctl` 用于查看日志，常用命令如下：

``` shell-session
查看日志
$  journalctl

查看日志，时间晚的排在前面
$  journalctl -r

查看某个单元的日志
$  journalctl -u systemd-timesyncd
```

!!! note
    Debian 需要将用户加入 `systemd-journal` 组才可执行 `journalctl`，或者调用 root 权限。
