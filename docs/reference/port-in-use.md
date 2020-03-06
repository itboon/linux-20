# 检查网络端口被哪个程序占用

## 操作简介

``` bash
# 查看进程占用的 80 端口
sudo ss -tlnp | grep ":80\b"

# 查看 Docker 占用的 80 端口
sudo docker ps | grep ":80->"
```

## 问题详解

一台主机上，如果 2 个程序绑定相同 `ip_address:port`，是无法同时运行的，我们经常需要在安装程序之前检查端口是否空闲。运行 Docker 容器映射端口时，也会存在同样的问题。下面是运行 Docker 容器重复映射 80 端口的报错：

```
$ docker run -p 80:80 -d nginx
...
Error starting userland proxy: listen tcp 0.0.0.0:80: bind: address already in use.
```

这里我们用网络工具 `ss` 来进行排查，它是 `netstat` 的替代者。`ss -tln` 可以查看主机正在监听的 TCP 端口，通过过滤器可以筛选出 80 端口：

``` bash
sudo ss -tlnp sport = :80

# 或者使用 grep 进行过滤
sudo ss -tlnp | grep ":80\b"
```

```
$ sudo ss -tlnp | grep ":80\b"   
LISTEN    0    128    *:80    *:*    users:(("docker-proxy",pid=13256,fd=4))
```

没有输出表示端口空闲。如果输出包括 `apache` 或者 `nginx`，则需要停掉相关的服务。上面的输出包含 `docker` 相关进程，还需要找到对应的容器：

``` bash
sudo docker ps | grep ":80->"
```

```
$ sudo docker ps | grep ":80->"
d25cdf73b351    nginx    "nginx -g 'daemon of…"    0.0.0.0:80->80/tcp   nginx-test
```

发现容器 `d25cdf73b351` 映射了 80 端口，然后停止或删除容器：`sudo docker stop d25cdf73b351`

## ss 常用选项介绍

```
-n, --numeric       不解析服务名，始终显示端口数字
-a, --all           显示所有 sockets
-l, --listening     显示监听的 sockets
-p, --processes     显示所属进程，需要 root 权限
-t, --tcp           仅显示 tcp sockets
-u, --udp           仅显示 udp sockets
```