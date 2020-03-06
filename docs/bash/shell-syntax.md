# bash 语法

## 注释

一行中 `#` 及其后面的字符会被 shell 忽略，这被称为注释。

``` shell-session
$  # echo foo
$  echo foo # comments
foo
```

## 引号

引号将字符包裹起来恢复其字面量，单引号里面所有特殊字符均恢复字面量，而双引号则保留 `$` `` ` `` `\` 这 3 个符号的特殊含义 (`` ` `` 是反引号)。请看下面的例子：

``` shell-session
$  echo foo # bar
foo
$  echo "foo # bar"
foo # bar
$  echo 'foo # bar'
foo # bar
$  
$  echo "$USER"
linux-20
$  echo '$USER'
$USER
```

`echo foo # bar` 其中 `# bar` 为注释，用引号包裹起来则恢复 `#` 字面量。双引号中仍然可以使用变量，而单引号不可以。

## 转义字符

转义字符可恢复特殊字符的字面量，例如：

``` shell-session
$  echo "$USER"
linux-20
$  echo "\$USER"
$USER
$  echo "\"foo\""
"foo"
```

### 换行符 \n

`echo` 可以一次输出多行文本，请看下面的例子：

``` shell-session
$  echo "foo\nbar"
foo\nbar
$  echo -e "foo\nbar"
foo
bar
```

`echo -e` 开启转义序列，可识别换行符 `\n`、制表符 `\t` 等符号。

## 命令序列

可以在一行书写多条独立的命令，它们会按顺序执行，这需要下列符号支持：

- `;` 多条命令写在一行用 `;` 隔开，将按顺序执行。
- `&&` 若前面的命令返回值为非零 (执行成功)，则继续执行后面的命令。
- `||` 若前面的命令返回值为零 (执行失败)，则继续执行后面的命令。
- `&` 可将多条命令隔开，类似`;`，不同点在于此符号放在命令末尾将调用子进程异步执行该命令，也称为后台任务。

例如：

``` shell-session
$  echo foo; echo bar
foo
bar
$  echo foo && echo bar
foo
bar
$  echo foo || echo bar
foo
$  
$  echofoo && echo bar
-bash: echofoo：未找到命令
$  echofoo || echo bar
-bash: echofoo：未找到命令
bar
```

### 后台任务

`&` 可用于执行后台任务，请看下面的例子：

``` shell-session
$  sleep 3; echo foo
foo
$  sleep 3& echo foo
[1] 26056
foo
$  jobs
[1]+  已完成               sleep 3
$  
$  sleep 100& sleep 500&
[1] 26108
[2] 26109
$  fg 1
sleep 100
^C
$  jobs
[2]+  运行中               sleep 500 &
$  kill %2
$  jobs
[2]+  已终止               sleep 500
```

`sleep 3; echo foo` 会延迟 3 秒再执行 `echo`；将 `;` 换成 `&` 则 `sleep` 在子进程执行，不会阻塞后面的命令。

`jobs` 可列出活动的后台任务，`fg` 可将后台任务切换到前台 (然后按 `Ctrl` + `C` 可终止)，`kill` 可直接终止后台任务。

## 命令返回值

一条命令执行完成后会得到一个返回值 (exit status)，这个值保存在 `$?`，请看下面的例子：

```
$  echo foo; echo $?
foo
0
$  echofoo; echo $?
-bash: echofoo：未找到命令
127
$  echofoo && echo $?
-bash: echofoo：未找到命令
```

返回值为零表示执行成功，非零表示执行失败。`&&` 需要前一条命令的返回值为零才执行后面的命令。
