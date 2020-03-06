# chown 修改文件归属

chown - change file owner and group

`chown` 用于修改文件归属的用户和组 (owner 和 group)，需要注意：

- root 用户可以修改文件 owner 和 group。
- 文件 owner 可以将 group 修改为他所属的任意一个组。

!!! note
    修改文件 owner 需要 root 权限。

## 语法

```
chown [OPTION]... [OWNER][:[GROUP]] FILE...
```

`-R` 选项用于递归修改目录。

## chown 案例

``` bash
# 修改文件 owner 和 group
sudo chown root:root file

# 仅修改文件 owner
sudo chown root file

# 仅修改文件 group
sudo chown :root file

# 用户拥有 foo 文件，并且他属于 group-a 组时，可以这样修改
chown :group-a foo

# 在 /var/www 创建一个站点目录，并修改目录归属
sudo mkdir -p /var/www/foo-site
sudo chown -R www-data:www-data /var/www/foo-site
```

## chgrp

`chgrp` 也可以用来修改文件 group，例如：

``` bash
# 下面两条命令效果一样
chgrp root file
chown :root file
```