# sed 流编辑器

sed (stream editor) 即流编辑器，它读取输入流 (文件或来自管道的输入)，并依照一系列命令对内容进行编辑修改，最后将结果写入标准输出。

sed 是很老牌的文本处理工具，它逐渐被其它工具所取代，例如 awk。但由于 sed 的几个命令非常简洁易用，比如替换、插入和删除，所以它仍然广受喜爱。

一个简单的文本替换案例：

``` shell-session
$  # 使用 sed
$  echo "A beautiful girl" | sed 's/girl/woman/'
A beautiful woman
$  
$  # 使用 awk
$  echo "A beautiful girl" | awk '{gsub(/girl/,"woman"); print $0}'
A beautiful woman
```

## sed 常用选项

- -E, --extended-regexp, 使用扩展正则表达式 (ERE)
- -e script, --expression=script, 添加 sed 执行的命令
- -i[SUFFIX], --in-place[=SUFFIX], 直接修改文件，如果提供了 SUFFIX 将会备份

sed 对文本进行修改的命令，默认只会将输出打印出来，加上 `-i` 直接对文件进行修改，例如：

``` bash
# 将替换后的文本打印出来
sed 's/foo/bar/' file

# 对文件进行文本替换
sed -i 's/foo/bar/' file

# 对文件进行文本替换，将会创建一个备份文件 file.sed
sed -i.sed 's/foo/bar/' file
```

`-i` 与其它选项一起使用时应分开写，例如 `-i -E` 不能写成 `-iE`，请看下面的例子：

``` bash
# 下面两条命令是等价的
sed -Ei '...' file
sed -E -i '...' file

# -iE 等价于 --in-place=E，会创建一个备份文件 fileE
sed -iE '...' file
```

## 正则表达式

GNU `sed -E` 使用 ERE 语法，与  [grep ERE 语法](../grep-regexp) 一致。

## 替换命令语法

替换命令的语法是 `s/regexp/replacement/`，例如：

``` shell-session
$  seq 31 36 | sed 's/33/replace/'
31
32
replace
34
35
36
$  # 替换行尾的数字 3 和 5
$  seq 31 36 | sed 's/[35]$/replace/'
31
32
3replace
34
3replace
36
```

### 自定义分割符

替换命令中的分割符 `/` 也可以用其他符号代替，例如：

``` shell-session
$  # 常规书写方式
$  echo "/bin/sh test.sh" | sed 's/\/bin\/sh/\/bin\/bash/'
/bin/bash test.sh
$  
$  # 自定义分割符
$  echo "/bin/sh test.sh" | sed 's%/bin/sh%/bin/bash%'
/bin/bash test.sh
$  echo "/bin/sh test.sh" | sed 's!/bin/sh!/bin/bash!'
/bin/bash test.sh
```

上面这个例子需要在正则表达式中多次书写 `/` 符号，如果是 `s/regexp/replacement/` 这样的写法，正则表达式里面好几个 `/` 需要加转义字符，写出来非常难看。改成 `s%regexp%replacement%` 这样的写法会简洁很多。

可以使用任意单个符号替代 `/`，恢复该符号的字面量需要加转义字符。

### 行内定位

sed 默认对每行第 1 次匹配进行替换，也可以全部替换或者选择性替换，例如：

``` shell-session
$  # 替换第 1 次匹配
$  echo "a dog and a cat" | sed 's/a/A/'
A dog and a cat
$  
$  # 替换第 3 次匹配
$  echo "a dog and a cat" | sed 's/a/A/3'
a dog and A cat
$  
$  # 替换所有匹配
$  echo "a dog and a cat" | sed 's/a/A/g'
A dog And A cAt
```

### 行定位

可以明确指定行数或行区间，例如：

``` shell-session
$  # 替换第三行
$  seq 6 | sed '3s/$/foo/'
1
2
3foo
4
5
6
$  # 从第三行到第五行
$  seq 6 | sed '3,5s/$/foo/'
1
2
3foo
4foo
5foo
6
$  # 从第三行到最后一行
$  seq 6 | sed '3,$s/^/foo/'
1
2
foo3
foo4
foo5
foo6
```

上例中，正则表达式 `/$/` 匹配行尾，此时替换命令可以在行尾添加文本。同样 `/^/` 可以实现行首添加文本。行区间 `3,$` 代表从第三行到最后一行。

## 删除行

命令 `d` 用于删除行，例如：

``` shell-session
$  seq 6 | sed '3d'
1
2
4
5
6
```

## 修改行

命令 `c` 用于修改行，例如：

``` shell-session
$  seq 6 | sed '3c\change'
1
2
change
4
5
6
$  echo -e "line 1\nline 2\nend"
line 1
line 2
end
$  echo -e "line 1\nline 2\nend" | sed '/line/c\change'
change
change
end
```

修改命令 `c` 与替换命令 `s` 不同，它相当于删除旧行再插入新行。

## 插入和附加新行

命令 `i` 在匹配的行前面插入新行。命令 `a` 在匹配的行后面附加新行。请看下面的例子：

``` shell-session
$  seq 6 | sed '6i\insert'
1
2
3
4
5
insert
6
$  seq 6 | sed '6a\append'
1
2
3
4
5
6
append
```

## 一次执行多条命令

`-e` 选项可以执行多条命令，例如：

``` shell-session
$  seq 6 | sed  -e '2d' -e '5d'
1
3
4
6
$  seq 6 | sed  -e '2d' -e '3i\insert' -e '5d'
1
insert
3
4
6
```

`;` 分割多条命令，例如：

``` shell-session
$  seq 6 | sed  -e '2d; 5d'
1
3
4
6
```

## sed 实践

### 修改 apt 源

``` shell-session hl_lines="13"
$  # 源文件
$  cat /etc/apt/sources.list 
deb http://deb.debian.org/debian buster main
deb-src http://deb.debian.org/debian buster main

deb http://deb.debian.org/debian-security/ buster/updates main
deb-src http://deb.debian.org/debian-security/ buster/updates main

deb http://deb.debian.org/debian buster-updates main
deb-src http://deb.debian.org/debian buster-updates main
$ 
$  # 修改文件
$  sudo sed -E -i.sed '/^deb/s%(https?|ftp)://[^/]+/%http://mirrors.aliyun.com/%' /etc/apt/sources.list
$  
$  # 修改后的文件
$  cat /etc/apt/sources.list
deb http://mirrors.aliyun.com/debian buster main
deb-src http://mirrors.aliyun.com/debian buster main

deb http://mirrors.aliyun.com/debian-security/ buster/updates main
deb-src http://mirrors.aliyun.com/debian-security/ buster/updates main

deb http://mirrors.aliyun.com/debian buster-updates main
deb-src http://mirrors.aliyun.com/debian buster-updates main
```

### 修改 profile 文件

``` shell-session hl_lines="9 13"
$  # 写入样例数据
$  sed -i '$a\export EDITOR=nano' ~/.profile
$  sed -i '$a\export EDITOR=vim' ~/.profile
$  grep 'export EDITOR=' ~/.profile
export EDITOR=nano
export EDITOR=vim
$  
$  # 删除配置项
$  sed -i '/^export EDITOR\s*=/d' ~/.profile
$  grep 'export EDITOR=' ~/.profile
$  
$  # 添加配置项
$  sed -i '$a\export EDITOR=/usr/bin/vim' ~/.profile
$  grep 'export EDITOR=' ~/.profile
export EDITOR=/usr/bin/vim
```

上面这个例子，配置文件有多行重复的配置项，可以先删除再添加。