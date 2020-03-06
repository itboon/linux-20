# chmod 修改文件权限

chmod - change file mode bits

`chmod` 用于修改文件权限，普通用户可以修改自己的文件权限，root 可以修改任意文件权限。

## 语法

```
chmod [OPTION]... MODE[,MODE]... FILE...
```

## chmod 符号模式

符号模式看上去非常直观，下面是几个简单的例子：

``` bash
# 设置所有用户可读写
chmod a=rw file

# 清空其他用户的写权限
chmod o-w file

# 增加 onwer 执行权限
chmod u+x file

# owner 可读写，group 和其他用户没有权限
chmod u=rw,go= file
```

符号模式有三个部分，分别是用户、操作符和权限，可以使用如下字符：

```
[ugoa][+-=][rwxXst]
```

用户部分：

- `u` user (onwer)
- `g` group
- `o` 其他用户
- `a` 所有用户，等同于 `ugo`

操作符：

- `+` 增加新权限
- `-` 删除已有权限 
- `=` 修改权限，`=` 后面留空表示修改后的权限为空

权限部分可以使用常规的权限符号 `rwx`，和特殊权限符号 `st`。另外还可以使用大写 `X` 代替小写 `x`。大写 `X` 只对目录和已有执行权限的文件有效果，请看下面的例子：

``` shell-session
$  mkdir foo; touch foo.txt
$  chmod o-x foo foo.txt
$  ls -l
drwxr-xr-- 2 linux-20 linux-20 4096 1月  17 13:56 foo
-rw-r--r-- 1 linux-20 linux-20    0 1月  17 15:34 foo.txt
$  
$  chmod o+X foo foo.txt
$  ls -l
drwxr-xr-x 2 linux-20 linux-20 4096 1月  17 13:56 foo
-rw-r--r-- 1 linux-20 linux-20    0 1月  17 15:34 foo.txt
```

上例中，对于目录文件 `foo`，`o+X` 等于 `o+x`；而对于没有执行权限的普通文件 `foo.txt`，`o+X` 没有效果。

## chmod 数字模式

数字模式是一种替代方案，下面是一个简单的例子：

``` bash
# 将文件设置为 owner 可读写，其他用户具有只读权限
chmod 644 file
```

数字模式需要将权限位转换为对应的数值，请看下面的对应关系：

```
数值      权限

4000      Set user ID
2000      Set group ID
1000      防删标记

          # owner：
 400      读
 200      写
 100      执行

          # group:
  40      读
  20      写
  10      执行

          # 其他用户：
   4      读
   2      写
   1      执行
```

需要哪些权限，就将对应的数值累加起来。比如 owner 读和写，group 读，其他用户读，即 `400 + 200 + 40 + 4 = 644`。

实践案例：

``` shell-session
$  mkdir foo private public
$  # private 目录，只有 onwer 具有权限
$  chmod 0700 private
$  # public 目录，所有用户具有权限，但只有 owner 可删除
$  chmod 1777 public
$  ls -l
总用量 12
drwxr-xr-x 2 linux-20 linux-20 4096 1月  18 13:36 foo
drwx------ 2 linux-20 linux-20 4096 1月  18 13:36 private
drwxrwxrwt 2 linux-20 linux-20 4096 1月  18 13:36 public
```

## 目录递归

修改目录权限时，默认只对目录本身有效，目录下的文件不受影响。`chmod -R` 递归修改目录下所有文件和子文件夹的权限。

``` shell-session hl_lines="3 5 6"
$  mkdir -p private/foo
$  touch private/foo.txt
$  chmod -R u=rwX,go= private
$  ls -l private
drwx------ 2 linux-20 linux-20 4096 1月  18 14:32 foo
-rw------- 1 linux-20 linux-20    0 1月  18 14:32 foo.txt
```

上例中创建了一个私有目录 `private`，并设置 owner 具有读写权限，其他用户不能访问。这里使用了 `u=rwX`，即目录具有 `rwx` 权限，而普通文件具有 `rw-` 权限。通过这个例子我们看到，递归修改目录权限时，使用大写 `X` 比较合适。