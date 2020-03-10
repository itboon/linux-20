# dpkg 管理软件包

## 安装软件

`dpkg` 也可用于安装软件，例如安装 chrome 浏览器：

``` shell-session
下载
$  curl -L -o chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

安装
$  sudo dpkg -i chrome.deb

卸载
$  sudo dpkg -r chrome
```

## 查看已安装的软件包

`dpkg -l` 可查看已安装的软件包，因为输出信息较多，一般使用 grep 进行过滤，例如：

``` shell-session
$  dpkg -l | grep docker
ii  docker-ce                              5:19.03.7~3-0~debian-buster                  amd64        Docker: the open-source application container engine
ii  docker-ce-cli                          5:19.03.7~3-0~debian-buster                  amd64        Docker CLI: the open-source application container engine
ii  docker-compose                         1.21.0-3                                     all          Punctual, lightweight development environments using Docker
rc  docker.io                              18.09.1+dfsg1-7.1+deb10u1                    amd64        Linux container runtime
```

上面的输出信息中，以 `ii` 开头的是已安装的包，`rc` 开头表示该软件包已经被移除但是遗留了配置文件。

## 根据文件查询相关联的软件包

`dpkg -S` 可查询文件相关联的软件包。如果我主机上可用的命令在云主机上用不了，而且我也不清楚应该安装哪个包，此时就可以使用 `dpkg -S` 进行查询。

``` shell-session
$  which ip
/bin/ip
$  dpkg -S /bin/ip
iproute2: /bin/ip
$  
$  dpkg -S $(which ss)
iproute2: /bin/ss
$  dpkg -S $(which top)
procps: /usr/bin/top
$  dpkg -S $(which dig)
dnsutils: /usr/bin/dig
```

## 重置软件包配置

`dpkg-reconfigure` 用于重新配置已安装的软件包，例如重新配置语言环境、时区等：

``` shell
重新配置语言环境
$  sudo dpkg-reconfigure locales

重新配置时区
$  sudo dpkg-reconfigure tzdata
```