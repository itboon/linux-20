# 初试 docker

## 关于 docker

![about-docker](about-docker.png)

docker image 是轻巧的、独立的、可执行的软件包，其中包括运行应用程序所需的一切：代码、系统工具、系统库和设置。这使得应用程序可以从一个计算环境快速可靠地迁移到另一个计算环境。

在 docker Engine 上运行的容器：

* **标准**：docker 创建了容器的行业标准，因此它可以在任何地方移植。
* **轻巧**：容器共享计算机的操作系统系统内核，从而提高了服务器效率，并降低了成本。
* **安全**：容器中的应用程序更安全，docker 提供了业界最强大的默认隔离功能。

## 安装 docker

docker 官方提供了安装脚本，并且支持 Aliyun 镜像，安装操作如下所示：

``` shell
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash ./get-docker.sh --mirror Aliyun
```

其他安装方式请参考[官方文档][install docker on debian]。

### 添加 registry mirrors

因为国内网络从 docker Hub 下载 image 会比较慢，所以配置镜像很有必要。将如下的配置写入到 `/etc/docker/daemon.json`，该文件可能需要创建。

```
{
    "registry-mirrors": [
        "https://chg8r6e9.mirror.aliyuncs.com",
        "https://registry.docker-cn.com"
    ]
}
```

重启 docker：`sudo systemctl restart docker`，然后拉取 image 试试，看速度如何。

``` shell
# 拉取 image
sudo docker image pull nginx
sudo docker image pull busybox:1.28

# 列出 image
sudo docker image ls

# 在线搜索 image
sudo docker search mysql
```

运行容器的时候会自动下载 image，拉取镜像的操作可以跳过。

## 第一个 docker 容器

``` shell
sudo docker run --rm busybox ip address
# docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

我们使用 `busybox` image 运行一个容器，它执行完 `ip address` 命令后就退出了，`--rm` 使它退出后就被删除了。接下来我们再执行一个容器，并且进入它的内部进行操作。

``` shell
sudo docker run --rm -it busybox sh
```

此时我们已经进入容器的 shell，试试执行几个命令:

``` shell-session
$  sudo docker run --rm -it busybox sh
/ # 
/ # ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
509: eth0@if510: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
/ # 
/ # ps
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    7 root      0:00 ps
/ # 
/ # echo "hello world" > hello.txt
/ # 
```

执行 `ip address` 可以看到容器的网络接口信息，此时在 docker 主机上可以 ping 通这个 ip 。执行 `ps` 我们看到容器只有 2 个进程，除了当前的 ps 进程，另一个就是我们启动容器时执行的 sh 。接着我们在容器里面写入一个 `hello.txt` 文件。

最后敲 `exit` 退出，退出后容器就被删除了。为什么要加 `--rm` ？因为运行的容器就是一个进程，任务完成后就退出，下次有新任务可以重新运行一个容器。在容器里面装一个包，写一个文件都不是持久的。接下来我们看看如何运行一个持续工作的容器。

## 持续运行的 docker 容器

``` shell-session
$  sudo docker run --name my-nginx -p 8005:80 -d nginx
a3f24f13ba3648df31c93a93d31856ea3713c59c323284ccc8ba467039b813cf
$  
```

上面第二行输出的是容器的 ID，表示容器已在后台运行。`-d` 决定容器在后台运行，`8005:80` 将容器的 80 端口映射到主机的 8005 端口，这个容器会持续在后台运行。此时可以通过网页浏览器访问 `http://your-docker-host:8005/` ,会显示 Nginx Welcome 页面。但这还不是我们的目的，我们需要建设一个站点，让我们继续。

``` shell
sudo docker rm -f my-nginx  # 首先删除上一步运行的容器

sudo mkdir -p /var/local/nginx-site
sudo docker run \
  --name my-nginx \
  -p 8005:80 \
  -v /var/local/nginx-site:/usr/share/nginx/html \
  -d nginx:1.16
```

`-v /var/local/nginx-site:/usr/share/nginx/html` 将主机的 `/var/local/nginx-site` 目录挂载到容器的 nginx 站点目录，但目前目录是空的，我们试试添加 2 个 html 文件。

``` shell
cat > index.html <<EOF
<html>
<h1>Welcome to my website</h1>
<a href="/thanks.html">Thanks</a> 
</html>
EOF

cat > thanks.html <<EOF
<html>
<a href="/">Home</a> 
<li>docker</li>
<li>Nginx</li>
</html>
EOF

sudo cp *.html /var/local/nginx-site
```

现在通过网页浏览器访问 `http://your-docker-host:8005/` ，按 `Ctrl + F5` 刷新，一个简易的站点建好了。执行 `sudo docker ps` 可以查看正在运行的容器。

## 应用升级

现在我们升级 nginx 版本，操作如下：

``` shell
sudo docker rm -f my-nginx

sudo docker run \
  --name my-nginx \
  -p 8005:80 \
  -v /var/local/nginx-site:/usr/share/nginx/html \
  -d nginx:1.17
```

看到没，简单粗暴！先把老版本的容器删除，然后使用新版本的 image 运行容器。容器里面所有的东西都是为了运行一个程序，不应该试图保存文件和配置。持久保存数据需要使用 Volumes 或 Bind mounts，上面的例子使用的是 Bind mounts，更多关于 docker 存储的知识请参考: [Manage data in docker][docker docs storage]

到目前为止还只是简单试用一下 docker，真正使用容器部署服务还需要继续学习，下一节我们介绍 docker Compose 。

[install docker on debian]: (https://docs.docker.com/install/linux/docker-ce/debian/)
[install docker on ubuntu]: (https://docs.docker.com/install/linux/docker-ce/ubuntu/)
[docker docs storage]: (https://docs.docker.com/storage/)