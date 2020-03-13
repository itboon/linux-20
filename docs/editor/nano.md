# GNU nano

流行的命令行文本编辑器有 vim、emacs、nano，其中 vim 和 emacs 具有一定的上手难度同时也更强大。nano 比较小巧并且上手难度低，非常适合轻度需求的用户。

``` shell hl_lines="1 13 14"
  GNU nano 3.2                /etc/apt/sources.list                Modified

deb http://mirrors.aliyun.com/debian buster main
deb-src http://mirrors.aliyun.com/debian buster main
deb http://mirrors.aliyun.com/debian-security/ buster/updates main
deb-src http://mirrors.aliyun.com/debian-security/ buster/updates main
deb http://mirrors.aliyun.com/debian buster-updates main
deb-src http://mirrors.aliyun.com/debian buster-updates main




^G Get Help    ^O Write Out   ^W Where Is    ^K Cut Text    ^J Justify
^X Exit        ^R Read File   ^\ Replace     ^U Uncut Text  ^T To Spell
```

上面是 nano 「主编辑界面」，第一行显示程序版本、编辑的文件和是否被修改，最后两行显示常用的快捷键，倒数第三行会显示重要的消息。编辑完成后按 <kbd>CTRL</kbd> + <kbd>S</kbd> 保存，按 <kbd>CTRL</kbd> + <kbd>X</kbd> 退出。

## 快捷键

nano 完全使用键盘操作，界面底部显示部分常用快捷键，进入帮助页面 ( <kbd>Ctrl</kbd> + <kbd>G</kbd> ) 可查看更多。快捷键有「控制组合键」和「Meta 组合键」两种：

- 「控制组合键」使用 <kbd>CTRL</kbd>，在帮助文档里显示 `^`。例如 `^X` (退出操作) 同时按下 <kbd>Ctrl</kbd> + <kbd>X</kbd>。

- 「Meta 组合键」使用 <kbd>Alt</kbd>，在帮助文档里显示 `M-`。例如 `M-U` (撤销操作) 同时按下 <kbd>Alt</kbd> + <kbd>U</kbd>。

当 <kbd>CTRL</kbd> 或 <kbd>Alt</kbd> 组合键不能工作时，可以使用 <kbd>Esc</kbd> 代替。「控制组合键」按 2 次 <kbd>Esc</kbd> 再按目标按键；「Meta 组合键」按 1 次 <kbd>Esc</kbd> 再按目标按键。例如 "GNOME terminal" 使用 <kbd>Alt</kbd> + <kbd>数字</kbd> 切换标签，这时 nano 使用 <kbd>Alt</kbd> + <kbd>6</kbd> 进行复制操作将会冲突，可以先按 <kbd>Esc</kbd> 再按 <kbd>6</kbd> 进行复制。

!!! note "当心 <kbd>Esc</kbd>"
    按下 <kbd>Esc</kbd> 后编辑器进入非正常模式，接下来不可随意按其他键，要想恢复到正常的输入模式可以按 <kbd>Ctrl</kbd> + <kbd>C</kbd>。当无意按下 <kbd>Esc</kbd> 后需要特别注意。

### 快捷键参考

下列快捷键可用于「主编辑界面」：

#### 操作文件

- <kbd>CTRL</kbd> + <kbd>S</kbd> 保存文件
- <kbd>CTRL</kbd> + <kbd>O</kbd> 文件另存为
- <kbd>CTRL</kbd> + <kbd>X</kbd> 退出文件

#### 编辑

- <kbd>CTRL</kbd> + <kbd>K</kbd> 剪切 (当前行或者被标记的区域)
- <kbd>Alt</kbd> + <kbd>6</kbd> 复制 (当前行或者被标记的区域)
- <kbd>Alt</kbd> + <kbd>A</kbd> 开始或结束标记
- <kbd>CTRL</kbd> + <kbd>U</kbd> 粘贴
- <kbd>CTRL</kbd> + <kbd>Shift</kbd> + <kbd>Del</kbd> 删除左边的单词
- <kbd>CTRL</kbd> + <kbd>Del</kbd> 删除右边的单词
- <kbd>AltL</kbd> + <kbd>Del</kbd> 删除 (当前行或者被标记的区域)
- <kbd>Alt</kbd> + <kbd>U</kbd> 撤销上一次动作
- <kbd>CTRL</kbd> + <kbd>E</kbd> 恢复撤销的动作

#### 搜索和替换

- <kbd>CTRL</kbd> + <kbd>W</kbd> 开始正向搜索
- <kbd>CTRL</kbd> + <kbd>Q</kbd> 开始反向搜索
- <kbd>Alt</kbd> + <kbd>W</kbd> 向后搜索下一个匹配
- <kbd>Alt</kbd> + <kbd>Q</kbd> 向前搜索下一个匹配
- <kbd>CTRL</kbd> + <kbd>\</kbd> ( <kbd>Alt</kbd> + <kbd>R</kbd> ) 替换

#### 移动光标

- <kbd>Ctrl</kbd> + <kbd>→</kbd> 向后跳动一个单词
- <kbd>Ctrl</kbd> + <kbd>←</kbd> 向前跳动一个单词
- <kbd>Ctrl</kbd> + <kbd>A</kbd> 跳到行首
- <kbd>Ctrl</kbd> + <kbd>E</kbd> 跳到行尾
- <kbd>Ctrl</kbd> + <kbd>Y</kbd> ( <kbd>PageUp</kbd> ) 跳到上一页
- <kbd>Ctrl</kbd> + <kbd>V</kbd> ( <kbd>PageDown</kbd> ) 跳到下一页
- <kbd>Ctrl</kbd> + <kbd>\</kbd> ( <kbd>Ctrl</kbd> + <kbd>HOME</kbd> ) 跳到第一行
- <kbd>Ctrl</kbd> + <kbd>/</kbd> ( <kbd>Ctrl</kbd> + <kbd>END</kbd> ) 跳到最后一行

#### 帮助

- <kbd>Ctrl</kbd> + <kbd>C</kbd> 报告光标位置
- <kbd>Ctrl</kbd> + <kbd>G</kbd> 查看帮助

!!! note
    在不同界面快捷键的作用会有差别，比如进入搜索界面时可以开启正则表达式匹配，注意底部显示的常用快捷键，另外在不同界面按 <kbd>Ctrl</kbd> + <kbd>G</kbd> 会得到不同的帮助信息。

## 正则表达式搜索

nano 支持「扩展正则表达式」(ERE) 进行搜索，其规则与 `egrep` 一致。