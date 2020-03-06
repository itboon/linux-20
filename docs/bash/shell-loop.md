# bash 循环语句

下面演示在 bash 中用不同的方法实现 5 次循环：

``` shell
for i in 1 2 3 4 5; do echo $i; done
for i in {1..5}; do echo $i; done
for i in $(seq 1 5); do echo $i; done
for ((i=1; i<=5; i++)); do echo $i; done

i=1; while ((i <= 5)); do echo $i; ((i++)); done
i=1; until ((i > 5)); do echo $i; ((i++)); done
```

## for

`for` 可用于遍历列表，每次迭代可执行一组命令。例如：

``` shell-session
$  for i in 1 2 3 4 5; do echo $i; done
1
2
3
4
5
$  for i in {1..5}; do echo $i; done
1
2
3
4
5
$  for i in $(seq 1 5); do echo $i; done
1
2
3
4
5
$  for i in bash dash zsh; do echo $i shell; done
bash shell
dash shell
zsh shell
```

for 循环可以通过多种途径获取列表，直接提供或者从命令获取，此外还可以提供连续的数字和字母列表 `{1..5}` `{a..z}`。

### 遍历目录

`/etc/profile` 中有一段 for 循环，它在 `/etc/profile.d/` 中遍历 `*.sh` 文件：

``` shell
for i in /etc/profile.d/*.sh; do
  if [ -r $i ]; then
    . $i
  fi
done
```

### C 语言风格

bash 提供类似 C 语言风格的 for 循环，请看下面的例子：

``` shell
for ((i=1; i<=5; i++)); do echo $i; done
```

`((i=1; i<=5; i++))` 双括号中有 3 个算术表达式。第 1 个表达式只执行一次，起到初始化的作用；第 2 个是条件表达式，条件为真则继续循环；第 3 个表达式每次循环执行一次。每个表达式都可以省略，但是 2 个分号不能少，例如：

``` shell
i=1; for ((; i<=5;)); do echo $i; ((i++)); done
```

中间那个条件表达式如果省略了，则无限循环。

## while & until

`for ((; i<=5;))` 这样的 for 循环可以用 `while` 或 `until` 代替，下面这几种写法效果一样：

``` shell
i=1; for ((; i<=5;)); do echo $i; ((i++)); done
i=1; while ((i<=5)); do echo $i; ((i++)); done
i=1; until ((i>5)); do echo $i; ((i++)); done
```

`while` 在测试条件为真的时候循环，`until` 在测试条件为假的时候循环，它们的区别仅此而已。

### while 逐行处理文本

`while` 用于逐行处理文本比较方便，例如：

``` shell-session
$  cat > test.list <<EOF                                                                  
119.29.29.29
223.5.5.5
10.7.8.9
EOF
$  cat test.list | while read line; do ping -c 1 $line &> /dev/null || echo $line offline; done
10.7.8.9 offline
```

## break & continue

对于循环语句 `for` `while` `until` 和 `select`，可以适当控制其流程。`break` 退出整个循环，`continue` 跳到下一次循环，请看下面的例子：

``` shell-session
$  for i in {1..5}; do ((i==4)) && break; echo $i; done
1
2
3
$  for i in {1..5}; do ((i==4)) && continue; echo $i; done
1
2
3
5
```

上面是两个 for 循环的例子，循环 5 次，在第 4 次循环时分别执行 `break` 和 `continue`。`break` 退出整个循环，而 `continue` 跳出第 4 次循环。