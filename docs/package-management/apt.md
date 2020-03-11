# 使用 apt 安装软件

## apt 和 dpkg

Debian 软件包管理由多个层级组成。底层由 dpkg 和相关程序组成。处在上层的是「apt 系列工具」，例如 apt、apt-get、apt-cache。用户使用最频繁的命令当属 `apt` 和 `dpkg`。

apt 旨在为最终用户提供一种简单有效的处理软件包的方法。它将软件包集中存储在软件仓库，用户可以集中获取软件而无需到分散的站点逐个下载，可以用一条简单的命令批量完成软件的安装、升级和移除。

`dpkg` 也可用于安装和移除软件包，但是没有 apt 方便。面对 apt 无法胜任的工作，我们才会选择它。

## 常用示例

### 安装 busybox 然后卸载

``` shell
sudo apt update
sudo apt install busybox
sudo apt remove busybox
```

### 升级所有已安装的软件包

``` shell
sudo apt update
sudo apt upgrade
```

### 查看软件包细节

``` shell
apt show nginx
```

## apt 常用命令介绍

- `update` 更新可用软件包列表。
- `upgrade` 升级已安装的软件包，现有软件包不会被删除。
- `full-upgrade` 执行 `upgrade` 进行升级。此命令进行完整的升级，必要情况下会删除已安装的软件包。
- `list` 根据名称列出软件包。
- `search` 搜索软件包描述。
- `show` 显示软件包细节。
- `install` 安装软件包。
- `remove` 移除软件包。
- `purge` 移除软件包并删除配置文件。
- `autoremove` 卸载所有自动安装且不再使用的软件包。

!!! note
    `upgrade` 可升级所有已安装的软件包，即更新操作系统。升级操作系统大版本通常需要删除一些遗弃的软件包，因此需要使用 `full-upgrade`，例如从 Debian 9 升级到 Debian 10。

## 配置 apt 源

apt 从一个或多个「软件仓库」(源) 下载软件包并将其安装到你的计算机上。源通常是网络服务器，例如官方的 DebianStable 仓库。因为网速问题，我们通常会选择国内的镜像服务器（腾讯软件源、阿里云开源镜像站、清华大学开源软件镜像站），或者使用私有的服务器。

### 配置国内镜像源

这里以 Debian 10 和 Ubuntu 18.04 为例，其他版本请参考相应的文档：<https://mirrors.cloud.tencent.com/>

#### Debian 10

``` shell
sudo tee /etc/apt/sources.list <<EOF
deb https://mirrors.aliyun.com/debian buster main
deb-src https://mirrors.aliyun.com/debian buster main
deb https://mirrors.aliyun.com/debian-security/ buster/updates main
deb-src https://mirrors.aliyun.com/debian-security/ buster/updates main
deb https://mirrors.aliyun.com/debian buster-updates main
deb-src https://mirrors.aliyun.com/debian buster-updates main
EOF
sudo apt update
```

上面的操作可以稍微改进一下，将主机地址和系统版本替换为变量，如下：

``` shell
aptHost="mirrors.cloud.tencent.com"
release="buster"
sudo tee /etc/apt/sources.list <<EOF
deb http://${aptHost}/debian ${release} main
deb-src http://${aptHost}/debian ${release} main
deb http://${aptHost}/debian-security ${release}/updates main
deb-src http://${aptHost}/debian-security ${release}/updates main
deb http://${aptHost}/debian ${release}-updates main
deb-src http://${aptHost}/debian ${release}-updates main
EOF
sudo apt update
```

#### Ubuntu 18.04

可以直接从网站下载配置文件，然后放到系统目录，操作如下：

```
curl -o sources.list http://mirrors.cloud.tencent.com/repo/ubuntu18_sources.list
sudo mv sources.list /etc/apt/
sudo apt update
```

!!! note
    `apt update` 根据 sources.list 更新可用软件包列表，修改配置文件后执行 update 才能正式生效。用户可以每次安装或升级软件时都执行一次 update，也可以仅在重要的操作前执行。本书其他地方可能会忽略这一步。

### 添加第三方源

下面是安装 vscode 的步骤：

``` shell
# 安装 GPG
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/

# 添加源
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

# 更新可用软件包列表
sudo apt update

# 安装 vscode
sudo apt install code
```

第三方软件源可以写入 `/etc/apt/sources.list`，但更好的安排是在 `/etc/apt/sources.list.d` 目录下创建一个 list 文件，当不需要时可以删除相应的文件而避免频繁修改一个主配置文件。当 `/etc/apt/sources.list.d/vscode.list` 被删除后，vscode 仍然可以正常使用，但无法被 `apt upgrade` 升级。