# 管理用户和组

## 底层工具和前端工具

管理用户和组可以使用底层工具 `useradd`、`groupadd`、`usermod`，也可以使用 `adduser` 这种对用户友好的前端工具。前端工具适合交互式操作，上手简单；底层工具适合在脚本中使用，学习成本稍微高一点。

## 常用命令汇总

这里把管理用户和组的相关命令列出来，命令中 `jack` 是用户名，`group01` 是组名。个别命令会进入对话模式，请勿全部复制粘贴。

```
# 创建用户
sudo adduser jack

# 创建组
sudo addgroup group01

# root 强制修改用户密码
sudo passwd jack

# 修改自己的密码
passwd

# 将用户加入组
sudo adduser jack group01

# 删除组
sudo delgroup group01

# 删除用户
sudo deluser jack --remove-home
```

## adduser

下面演示如何创建一个用户、将用户加入组，最后删除用户：

``` shell-session
$  sudo adduser jack
Adding user `jack' ...
Adding new group `jack' (1004) ...
Adding new user `jack' (1003) with group `jack' ...
Creating home directory `/home/jack' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for jack
Enter the new value, or press ENTER for the default
	Full Name []: 
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: 
Is the information correct? [Y/n] 
$  id jack
uid=1003(jack) gid=1004(jack) groups=1004(jack)
$  sudo adduser jack sudo
Adding user `jack' to group `sudo' ...
Adding user jack to group sudo
Done.
$  id jack
uid=1003(jack) gid=1004(jack) groups=1004(jack),27(sudo)
$ sudo deluser jack --remove-home
Looking for files to backup/remove ...
Removing files ...
Removing user `jack' ...
Warning: group `jack' has no more members.
Done.
```

`adduser jack` 执行之后进入对话模式，输入密码两次，后面可以一路回车。默认会创建「home 目录」，并创建与用户同名的组。更多默认选项通过 `/etc/adduser.conf` 配置。

## useradd

- `-b`, `--base-dir` 指定新用户「home 目录」的基目录
- `-d`, `--home-dir` 指定新用户的「home 目录」
- `-m`, `--create-home` 创建「home 目录」
- `-M`, `--no-create-home` 不创建「home 目录」
- `-p`, `--password PASSWORD` 指定新用户的密码，可以是明文也可以是密文
- `-s`, `--shell SHELL` 新用户的「登录 shell」
- `-u`, `--uid UID` 指定新用户的 ID
- `-g`, `--gid GROUP` 指定新用户主组的名称或 ID

使用 `useradd` 创建一个常规用户：

```
# 创建 jack 用户，设置密码为 PASSWORD，并创建「home 目录」
useradd jack -p PASSWORD -m
```

### 创建非登录用户

创建非登录用户可指定 `-s /usr/sbin/nologin`，即禁用「登录 shell」，命令如下：

```
useradd jack -d /var/lib/jack -m -s /usr/sbin/nologin
```

## 修改密码

`passwd` 以对话模式修改密码，一次修改一个用户；`chpasswd` 可以批量修改密码，它从 stdin 读取用户名和密码。

`chpasswd` 使用方法如下：

``` shell-session
$  echo "jack:NewPassword" | sudo chpasswd
$  cat passwd.list 
jack:pw-jack
user01:pw-01
user02:pw-02
$  cat passwd.list  | sudo chpasswd
$  
```