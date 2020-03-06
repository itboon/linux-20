# 执行文件

``` shell
#!/bin/bash

foo="linux-20"
ps
```

将上面的内容保存为 `foo.sh` 文件，有以下方式可以执行该文件：

- `./foo.sh` 创建子进程并执行文件，需要文件有可执行权限。
- `bash ./foo.sh` 创建子进程并执行文件。
- `. ./foo.sh` 在当前进程执行。
- `source ./foo.sh` 等同于 `. ./foo.sh`。

执行文件时如果文件路径不包含斜杠 `/`，那么会优先到 `$PATH` 下面去搜寻文件。因为 `.` 代表当前目录，`./foo.sh` 这种写法就明确了是当前目录下的文件，避免了不确定性。

第一行 `#!/bin/bash` 指定 `/bin/bash` 作为解释器，省略这一行将使用默认解释器。

## 当前进程和子进程的区别

``` shell-session
$  chmod a+x foo.sh
$  
$  unset foo; ./foo.sh; echo $foo
  PID TTY          TIME CMD
11411 pts/2    00:00:00 foo.sh
11412 pts/2    00:00:00 ps
22825 pts/2    00:00:09 bash

$  unset foo; . ./foo.sh; echo $foo
  PID TTY          TIME CMD
11414 pts/2    00:00:00 ps
22825 pts/2    00:00:09 bash
linux-20
```

可以看到，在当前进程中执行会把文件中定义的变量保留下来，而在子进程中执行则不会，这是最重要的区别。另外子进程不会继承父进程的局部变量，这也是一个因素。因此，当我们需要加载一个文件中的变量时则需要 `source` 的方式执行，`profile` 文件就需要这样执行；否则，优先在子进程中执行文件，这是常用的方式。