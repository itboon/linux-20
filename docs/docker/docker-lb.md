# docker 反向代理和负载均衡

## 准备工作

### 检查 TCP 80 端口是否空闲

在 docker 主机执行下面的命令，检查 TCP 80 端口是否空闲：

``` shell
ss -tln | grep ':80\b'
```

没有任何输出表示端口空闲。如果有如下输出表示端口已经被占用，需要停掉相关服务以释放端口，或者使用其他空闲的端口进行实验。

```
LISTEN    0         128                      *:80                     *:*       
```

## 创建 traefik 网络

traefik 与被代理的服务需要网络互联，我们创建一个专用的 docker 网络：

``` shell
sudo docker network create traefik-bridge
```

## 部署 traefik

``` shell
mkdir -p ~/my-compose/traefik && cd ~/my-compose/traefik
```

创建 `docker-compose.yml` 文件，内容如下：

``` yaml
version: "3.4"

services:

  traefik:
    image: "traefik:v2.1"
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
    ports:
      - "80:80"
      - "9901:8080"
    networks:
      - traefik-bridge
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

networks:
  traefik-bridge:
    external: true
```

然后启动项目：

``` shell
sudo docker-compose up -d
```

## 部署站点

``` shell
mkdir -p ~/my-compose/whoami && cd ~/my-compose/whoami
```

创建 `docker-compose.yml` 文件，内容如下：

``` yaml
version: "3.4"

services:

  whoami:
    image: "containous/whoami"
    networks:
      - traefik-bridge
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`whoami.example.com`)"
      - "traefik.http.services.whoami.loadbalancer.server.port=80"

networks:
  traefik-bridge:
    external: true
```

然后启动项目：

``` shell
sudo docker-compose up -d --scale whoami=3
```

上面我们启动了 3 个 whoami 容器，用来演示负载均衡的效果。启动完成后使用 `curl --resolve` 模拟访问 `http://whoami.example.com`：

``` shell
curl --resolve 'whoami.example.com:80:127.0.0.1' http://whoami.example.com
```

多次执行我们将得到不同容器的响应，如下所示：

``` shell-session
$  curl --resolve 'whoami.example.com:80:127.0.0.1' http://whoami.example.com
Hostname: 1c5d68c07e11
…
$  curl --resolve 'whoami.example.com:80:127.0.0.1' http://whoami.example.com
Hostname: 534749b49fa5
…
$  curl --resolve 'whoami.example.com:80:127.0.0.1' http://whoami.example.com
Hostname: c5cad68fd97b
…
$  curl --resolve 'whoami.example.com:80:127.0.0.1' http://whoami.example.com
Hostname: 1c5d68c07e11
…
```

traefik 与 dokcer 集成后，可自动发现 docker 容器并配置负载均衡，部署 docker 容器时只需添加 label 即可。

## 部署 WordPress:

部署 WordPress，使用 `wordpress.example.com` 域名进行反向代理，Compose file 如下：

``` yaml
version: "3.4"

services:

  db:
    image: mysql:5.7
    volumes:
      - db_data:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: wordpress

  wordpress:
    depends_on:
      - db
    image: wordpress
    networks:
      - default
      - traefik-bridge
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: wordpress
      WORDPRESS_DB_NAME: wordpress
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.wordpress.rule=Host(`wordpress.example.com`)"
      - "traefik.http.services.wordpress.loadbalancer.server.port=80"

volumes:
  db_data: {}

networks:
  traefik-bridge:
    external: true
```