# bash 常用快捷键

快捷键可以帮助我们轻松操作 shell，例如 <kbd>Ctrl</kbd> + <kbd>A</kbd> 使光标移动到行首。有时候无意按下一组快捷键却不知情则会很苦恼，例如 <kbd>Ctrl</kbd> + <kbd>S</kbd> 会暂停终端输出，<kbd>Ctrl</kbd> + <kbd>Z</kbd> 会暂停当前的前台进程。所以掌握一部分常用快捷键是很有必要的。

## 快捷键注意事项

当快捷键不能用时，有两个地方需要检查：

- 是否存在快捷键冲突
- 终端程序的键盘设置

!!! note "「Alt 组合键」替代方案"
    「Alt 组合键」经常与终端程序冲突，可以使用 <kbd>Esc</kbd> 替代，例如 <kbd>Alt</kbd> + <kbd>F</kbd> 改为先按一次 <kbd>Esc</kbd> 再按 <kbd>F</kbd>

## 编辑命令行

### 移动光标

- <kbd>Ctrl</kbd> + <kbd>A</kbd> 移动到行首。
- <kbd>Ctrl</kbd> + <kbd>E</kbd> 移动到行尾。
- <kbd>Alt</kbd> + <kbd>F</kbd> 向前移动一个单词。
- <kbd>Alt</kbd> + <kbd>B</kbd> 向后移动一个单词。

### 删除字符

- <kbd>Alt</kbd> + <kbd>Del</kbd> 删除从光标到单词开头 (如果不可用请尝试 <kbd>Alt</kbd> + <kbd>Backspace</kbd>，或者检查终端程序快捷键设置)。
- <kbd>Alt</kbd> + <kbd>D</kbd> 删除从光标到单词末尾。
- <kbd>Ctrl</kbd> + <kbd>K</kbd> 删除到行尾。
- <kbd>Ctrl</kbd> + <kbd>W</kbd> 删除从光标到前面的空格。
- <kbd>Ctrl</kbd> + <kbd>Y</kbd> 将最近一次删除的字符在光标的位置粘贴。

### 历史命令

- <kbd>↑</kbd> 调出上一个命令，持续按 <kbd>↑</kbd> / <kbd>↓</kbd> 在历史命令中切换。
- <kbd>Ctrl</kbd> + <kbd>R</kbd> 在历史命令中搜索，搜索中继续按 <kbd>Ctrl</kbd> + <kbd>R</kbd> 向前翻。

## 控制进程

- <kbd>Ctrl</kbd> + <kbd>C</kbd> 中断当前的前台进程。
- <kbd>Ctrl</kbd> + <kbd>Z</kbd> 暂停当前的前台进程。可使用 `fg` 命令继续运行。
- <kbd>Ctrl</kbd> + <kbd>D</kbd> "end-of-file" (EOF)，当一行中没有任何字符时 <kbd>Ctrl</kbd> + <kbd>D</kbd> 被识别为 EOF。

## 管理终端输出

- <kbd>Ctrl</kbd> + <kbd>L</kbd> 清除屏幕。
- <kbd>Ctrl</kbd> + <kbd>S</kbd> 暂停终端输出。
- <kbd>Ctrl</kbd> + <kbd>Q</kbd> 恢复终端输出。

