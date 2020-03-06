# docker compose

compose 可以很方便地部署和管理多容器的应用程序，通过编写一个 YAML 文件，然后使用一条简单的命令就可以完成容器部署。

## 安装

``` shell
sudo apt install docker-compose
```

## 初试 compose

首先创建一个 compose 项目目录，并切换进去：

``` shell
mkdir -p ~/my-compose/mysql && cd ~/my-compose/mysql
```

compose 的配置文件叫 compose file，使用 YAML 文件格式，通常命名为 `docker-compose.yml`。

我们创建 `docker-compose.yml` 文件，内容如下：

``` yaml
version: "3.4"

services:

  db:
    image: mysql:5.6
    volumes:
      - test_db:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root

  adminer:
    image: adminer
    ports:
      - "8006:8080"

volumes:
  test_db: {}
```

启动 compose：

``` shell-session
$  sudo docker-compose up -d
Creating network "mysql_default" with the default driver
Creating volume "mysql_test_db" with default driver
Creating mysql_db_1      ... done
Creating mysql_adminer_1 ... done
$  
```

现在可以通过 adminer web 页面管理 mysql 数据库。访问 <http://your-docker-host:8006/> ，输入服务器：`db` ，用户名和密码都是 `root` ，登录后可以创建一个数据库试试。

上面的 compose file 定义了 2 个容器，`db` 和 `adminer`，它们可以互相解析得到 IP 地址。因此，adminer 可以直接用 `db` 作为目标主机名，连接 mysql。adminer 映射了一个端口 `"8006:8080"`，这样我们可以通过主机的 8006 端口访问 adminer。

接下来我们把 compose file `image: mysql:5.6` 改成 `image: mysql:5.7` ，然后启动 compose：

```
$  sudo docker-compose up -d
Recreating mysql_db_1 ... 
Recreating mysql_db_1 ... done
$  
```

adminer 容器没有变更，会继续运行。db 容器使用了新版本的 image，会进行删除重建，这也就完成了升级操作。因为 mysql 的数据目录挂载了 volume，新的 mysql 容器会继续使用这个 volume，数据是持久保存的。对 docker image 进行升级是非常容易的，但是用户需要评估自己的环境是否可以升级。上面的例子，如果把 mysql 版本改成 `8.0` 就会出问题，这里我们不延伸讨论如何升级 mysql。

我们再看看 compose 其他常用的命令：

``` shell-session
列出容器
$  sudo docker-compose ps

停止服务
$  sudo docker-compose stop

停止服务并删除资源，会删除启动时创建的容器和网络
$  sudo docker-compose down

加上 -v 会把 volume 也一起删除，请慎重考虑再操作
$  sudo docker-compose down -v

使用指定的 compose file
$  sudo docker-compose -f /foo/bar.yml up -d
```

通过实验我们看到，使用 compose 管理容器确实很方便，比直接使用 docker 容易多了。下面我们再来看一个 web + db 的典型案例。

## 部署 WordPress

创建项目目录：

``` shell
mkdir -p ~/my-compose/wordpress && cd ~/my-compose/wordpress 
```

写入 `docker-compose.yml` 文件，内容如下：

``` yaml
version: "3.4"

services:
  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: somewordpress
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress
    ports:
      - "8007:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
volumes:
  db_data: {}
```

上面这个配置文件定义了好几个环境变量 `environment`，这是为 WordPress 连接数据库准备的。将配置文件写入容器会略显笨拙，通过环境变量传递参数就灵活多了。

启动 compose：

``` shell-session
$  sudo docker-compose up -d
Creating network "wordpress_default" with the default driver
Creating volume "wordpress_db_data" with default driver
Creating wordpress_db_1 ... done
Creating wordpress_wordpress_1 ... done
$  
```

启动完成后就可以使用 WordPress 了，通过映射的 `8007` 端口访问。很好很强大！但是使用 docker 渐渐就会发现，开箱即用的 image 是有限的，很多时候并没有合适的 image 供我们下载。这个问题也好解决，下面我们就来看一下自己构建 image 的案例。

## 自己构建 Image

创建项目目录:

``` shell
mkdir -p ~/my-compose/mkdocs && cd ~/my-compose/mkdocs
```

写入 `docker-compose.yml`，内容如下：

``` yaml
version: "3.4"

services:
  mkdocs:
    build: .
    ports:
      - "8008:80"
    volumes:
      - ./:/mkdocs:ro
```

上面这个 compose file 略有不同，它没有指定 `image`，而是改成了 `build: .`。这时，compose 会使用 `dockerfile` 构建 image。并且我们将当前的项目目录以只读权限挂载到容器的 `/mkdocs`。`dockerfile` 文件如下所示：

``` dockerfile
FROM python:3.8

RUN set -ex \
    ; pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    ; pip install --no-cache-dir mkdocs mkdocs-material \
    ; mkdir -p /mkdocs

WORKDIR /mkdocs
EXPOSE 80

CMD [ "mkdocs", "serve", "-a", "0.0.0.0:80" ]
```

这是一个简短的 dockerfile，主要有 2 个指令，`FROM` 和 `RUN`。FROM 指示基础 image，这里将基于 `python：3.8` 构建新的 image。RUN 执行 shell 命令，多条命令用分号隔开，这里主要就是安装 Mkdocs。`WORKDIR` `EXPOSE` 和 `CMD` 指示相关运行环境。这里不过多介绍 dockerfile，我们继续完成实验。

创建 Mkdocs 项目文件并启动 compose：

``` shell
# 写入主配置文件 mkdocs.yml
cat > mkdocs.yml <<EOF
site_name: "My Docs"
theme:
  name: "material"
EOF

# 创建 docs 目录
mkdir -p docs

# 在 docs 目录写入 markdown 文档
# 这里从网络下载 2 个文档，也可以手写或拷贝自己的文档
curl -L https://github.com/mkdocs/mkdocs/raw/master/docs/index.md -o docs/index.md
curl -L https://github.com/mkdocs/mkdocs/raw/master/docs/user-guide/writing-your-docs.md -o docs/guide.md

# 启动 compose
sudo docker-compose up -d --build
```

第一次启动会构建 image，速度由电脑性能和网速决定，我的电脑耗时 35 秒。构建完成后会在本地生成一个 image，compose 使用这个 image 启动容器。如果 dockerfile 变更了，再次启动 compose 会重新构建。启动完成后可以领略 Mkdocs 了，通过映射的 `8008` 端口访问。

## compose 项目名

compose 默认使用目录名作为项目名，我们通过一个小实验看看其中的陷阱。

创建项目目录 `old-project`，写入 compose file 并启动 compose：

``` shell
# 创建项目目录
mkdir -p ~/my-compose/old-project && cd ~/my-compose/old-project

# 创建 compose file
cat > docker-compose.yml <<EOF
version: "3.4"
services:
  nginx:
    image: nginx
EOF

# 启动 compose
sudo docker-compose up -d
```

得到如下输出：

```
Creating network "old-project_default" with the default driver
Creating old-project_nginx_1 ... done
```

将项目目录重命名为 `new-project`，然后再次启动：

``` shell
cd ~
# 重命名目录
mv ~/my-compose/old-project ~/my-compose/new-project
cd ~/my-compose/new-project

# 启动 compose
sudo docker-compose up -d
```

得到如下输出：

```
Creating network "new-project_default" with the default driver
Creating new-project_nginx_1 ... done
```

这是启动了一个新项目，因为目录名改了，项目名默认由目录名决定。要想继续管理 old-project 项目，需要这样操作：

``` shell
# 列出容器
sudo docker-compose -p old-project ps

# 停止服务并删除资源
sudo docker-compose -p old-project down
```

重命名目录会带来麻烦，我们可能不知不觉就去管理一个新项目了。如果我们每次都通过 `-p` 明确指定项目名，似乎有点心累。Github 上有人提议将项目名固定保存，但经过漫长的讨论仍然没有结果，我们继续观望吧。

## 清理 compose

本节我们启动了几个 compose 项目，现在可以将它们逐一清理掉以释放资源。尤其是主机网络端口，我们经常会重复使用同一个端口，导致启动出错。切换到每个项目目录执行 `sudo docker-compose down -v`，注意，加上 `-v` 会将 volume 一起删除，数据库都灰飞烟灭了。

本节我们创建了下列 compose 项目：

``` shell-session
$  ls ~/my-compose/
mkdocs  mysql  new-project  wordpress
```