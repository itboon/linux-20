# 基于 systemd 部署服务

## 准备工作

常用的域名查询命令 `dig` 和 `nslookup` 包含在 dnsutils 中，需要安装这个包：

``` shell
sudo apt install dnsutils
```

## 试用 coredns

``` shell
# 切换到临时创建的工作目录
mkdir -p /tmp/coredns && cd /tmp/coredns

# 下载和解压
curl -L -o coredns.tgz https://github.com/coredns/coredns/releases/download/v1.6.7/coredns_1.6.7_linux_amd64.tgz
tar -xf coredns.tgz
chmod a+rx coredns

# 创建配置文件
# 绑定 5300 端口，避免与其他服务冲突
cat > Corefile <<EOF
.:5300 {
    forward . 119.29.29.29:53 223.5.5.5:53
    cache 120
    errors
    log
}
EOF

# 运行 coredns
./coredns
```

然后新开一个终端窗口进行域名查询：

``` shell
dig www.qq.com @127.0.0.1 -p 5300
```

此时 coredns 会输出日志：

``` shell-session
$  ./coredns 
.:5300
CoreDNS-1.6.7
linux/amd64, go1.13.6, da7f65b
[INFO] 127.0.0.1:50303 - 39010 "A IN www.qq.com. udp 51 false 4096" NOERROR qr,rd,ra 198 2.007213203s
^C[INFO] SIGINT: Shutting down
$  
```

最后可按 <kbd>CTRL</kbd> + <kbd>C</kbd> 中断进程。

使用 coredns 很简单，下载后创建一个简单的配置文件就可以运行。以这样的方式运行程序达到快速试用的目的，想要规范地部署还需要多做一些工作。

## 部署 coredns

``` shell
# 需要以 root 执行

# 添加运行 coredns 的用户
useradd coredns -b /var/lib -m -s /usr/sbin/nologin

# 下载和解压
curl -L -o /tmp/coredns.tgz https://github.com/coredns/coredns/releases/download/v1.6.7/coredns_1.6.7_linux_amd64.tgz
tar -xf /tmp/coredns.tgz -C /usr/local/bin/
chmod a+rx /usr/local/bin/coredns

mkdir -p /etc/coredns
# 写入 coredns 配置文件
# 这里绑定到 127.0.5.3，避免与其他服务冲突
tee /etc/coredns/Corefile <<EOF > /dev/null
. {
    bind 127.0.5.3
    forward . 119.29.29.29:53 223.5.5.5:53
    cache 120
    errors
    log
}
EOF

# 写入 systemd unit 文件
tee /etc/systemd/system/coredns.service <<EOF > /dev/null
[Unit]
Description=CoreDNS DNS server
Documentation=https://coredns.io
After=network.target

[Service]
PermissionsStartOnly=true
LimitNOFILE=1048576
LimitNPROC=512
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true
User=coredns
WorkingDirectory=~
ExecStart=/usr/local/bin/coredns -conf=/etc/coredns/Corefile
ExecReload=/bin/kill -SIGUSR1 $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start coredns
systemctl status coredns
```

域名查询测试:

``` shell
dig www.qq.com @127.0.5.3
```

!!! note
    以 systemd 部署的服务有 2 个配置文件，一个是 systemd unit 文件，另一个是程序的配置文件。修改前者需要执行 `systemctl daemon-reload` 使配置生效，修改后者需要执行 `systemctl reload UNIT` 或者 `systemctl restart UNIT` 使配置生效。