# 文件权限基础

## 查看文件权限

`ls -l` 可查看文件权限，例如：

``` shell-session
$  ls -l /home
drwxr-xr-x  2 root         root          4096 12月 12 18:16 docker-bound
-rw-r--r--  1 guest        root             0 1月  16 14:31 foo.txt
drwxr-xr-x 20 guest        guest         4096 5月   4  2019 guest
```

| 文件类型和权限 | 硬链接数量    | owner | group |
| ----- | --- | --- | --- |
| drwxr-xr-x | 2 | root  | root  |
| -rw-r--r-- | 1 | guest | root  |
| drwxr-xr-x | 8 | guest | guest |

第一段信息 `drwxr-xr-x`，其中第一位表示文件类型，后面 9 位表示文件权限。这 9 位每 3 位一组，共 3 组，分别表示 "owner/group/其他用户"权限。

文件类型字符含义：

- `-` 普通文件
- `d` 目录 (目录也是文件，它的类型是目录)
- `l` 符号链接

文件权限字符含义：

- `r` 读权限
- `w` 写权限
- `x` 执行权限 (如果是目录则表示搜寻权限)
- `-` 占位符，表示没有该位权限

案例解析：

- `drwxr-xr-x` 表示一个目录，owner 具有全部读写执行权限，group 和其他用户只有读和执行权限。
- `-rw-r--r--` 表示一个普通文件，owner 具有读写权限，group 和其他用户只有读权限。
- `-rwxrwxrwx` 表示一个普通文件，所有用户具有全部读写执行权限。

### 目录的权限

文件权限中的 `x` 我们通常说执行权限，但目录文件的 "执行权限" 有些复杂。

可以这样来理解，目录是一个包含若干文件名的列表。`x` 表示搜寻列表的权限，而仅有这个权限是没有用的，`x` 应该与 `r/w` 结合起来控制目录的权限。正常的目录权限应该是 `rwx`、`r-x`、`---`。

- `r-x` 表示可以读取和搜寻文件列表，但不能在目录下增加、删除以及重命名文件。
- `rwx` 表示具有完整的权限。

如果目录的权限是 `r--` 或者 `--x`，则是异常的。

## 特殊权限

- set-user-ID，文件被执行时以文件 owner 运行。
- set-group-ID，文件被执行时以文件 group 运行。对于目录，在目录下创建的文件将与目录的 group 一致，这个特性便于目录共享。
- 防删标记，限制只有文件的 owner 可以删除文件。

``` shell-session hl_lines="8 9"
$  mkdir foo bar
$  chmod +t,ug+s foo bar
$  ls -l
drwsr-sr-t 2 linux-20 linux-20 4096 1月  18 12:22 bar
drwsr-sr-t 2 linux-20 linux-20 4096 1月  18 12:22 foo
$  chmod a-x foo
$  ls -l
drwsr-sr-t 2 linux-20 linux-20 4096 1月  18 12:22 bar
drwSr-Sr-T 2 linux-20 linux-20 4096 1月  18 12:22 foo
```

上面的例子，`-rwsr-sr-t` 中 `s`、`t` 表示特殊权限。因为这个符号占用了 `x` 的位置，为了区分，小写字母 `s`、`t` 表示包含 `x` 权限，大小字母 `S`、`T` 表示不含 `x` 权限。

