

# Chrome 扩展

Grammarly 语法检查

DM Integration Module idm 下载扩展

JSON Formatter json 格式化查看

uBlock Origin Ad block

油猴 任意网站都可以使用的脚本管理工具

# Mac 

### 快捷键整理

在 terminal 中，快速切换到命令的行首，行尾和清空命令 ctrl a, ctrl e and ctrl q

截图到剪贴板 shift + command + control + 4 (不按 shift 存储为文件)

切换输入法：control + 空格 切换到上一个输入法

应用之间切换：command + tab

- command + ~ 向前选择

应用打开的窗口之间切换 command + ~ 

Command + h 隐藏当前窗口，效果等同于 command + w （关闭当前窗口）

Command + m 最小化当前窗口到 dock

Command + shift + z 反撤销

Command + q 退出选中的应用 

**Command +** **右箭头** 将光标移至当前行的行尾

**Command +** **左箭头** 将光标移至当前行的行首

**Command +** **下箭头** 将光标移至文稿末尾

**Command +** **上箭头** 将光标移至文稿开头

command + shift + 左箭头  选中光标之前内容

command + shift + 右箭头  选中光标之后内容

command + shift + 下箭头  选中光标向下内容

command + shift + 上箭头  选中光标向上内容

Control + tab 在浏览器中跳转到下一个页面

enter 重命名文件和文件夹内

Command + ctrl + f  将打开的应用全屏显示

- terminal 打开默认为小窗口，在 设置里自己调整下（属于使用洁癖）

Command + shift + . 显示隐藏文件

在 terminal 中打开当前路径下的 Finder :  open . 

### 应用整理

raycast 应用启动器 alfred 替代

snipaste 截图

- 自己调整快捷键，可能冲突 
  -  command + 1 截屏
  -  command + 2 截屏并自动复制

monitorcontrol 在 mac 中控制显示器

rectangle 窗口管理

deepl 翻译工具

- 选中文本 command + c + c

only switch 系统管理替代

scroll reverser 鼠标翻转

# IDEA （win mac 类似）

### 快捷键

1. 所有带下划线的Alt+下划线字符
2. 新建 alt+insert
3. 操作文件  右侧controller右侧的文档键
4. 选择maven模板：Alt+a
5. 打开代码窗口ctrl+shift+f12
6. 关闭当前窗口 ctrl+F4
7. 窗口之间的切换 Alt + 左右键
8. ctrl+I实现接口中的方法
9. 关闭或者放出侧边栏  ctrl+shift+F12
10. 复制一个类的全限定名称：ctrl+shift+alt+c
11. 复制光标所在的当前行 ctrl + d
12. 复制文件绝对路径 ctrl+shift+c
13. 复制文件的绝对路径和包名 alt+ctrl+shift+c
14. 撤销上一步的撤销操作  ctrl+shift+z
15. 删除当前行  ctrl+y
16. 在当前行之后开始新行 shift+enter
17. 在当前行之前开始新行 ctrl+alt+enter
18. 代码补全 ctrl+space
19. 格式化代码  ctrl+alt+L
20. 参数信息提醒 ctrl+p
21. 修改名称 shift+f6
22. 移动当前行 ctrl + shift + 上下键
23. 快速定位某个文件的某一行  ctrl+shift+N
24. 删除光标前面的单词或者是中文句子 ctrl+backsoace
25. 删除光标后面的单词或者中文句子 ctrl+delete
26. 取消缩进 shift+tab
27. ctrl+tab 打开编辑过的代码窗口
28. 打开翻译窗口 ctrl shift o
29. 翻译当前选中的单词 ctrl shift y
30. 安装了maven helper之后，使用 ctrl alt r来快速调出maven操作窗口

### 插件

Atom Metrinal icons 文件 icons

CodeGlance pro 代码地图

maven helper 快速分析 maven 依赖

Mybatis x 映射工具

translation 翻译工具

nyan progress bar 进度条

checkstyle  代码格式检查

# Vim 常用命令

### Vim 常用指令

#### 光标移动

- h 或退格: 左移一个字符
- l 或空格: 右移一个字符
- j: 下移一行
- k: 上移一行
- gg: 到文件头部。
- G: 到文件尾部。
- 0: 行首
- $: 行尾

#### 插入

- a: 在光标后插入
- i: 在当前行行首插入
- 命令模式下：u 撤销上次操作

#### 删除，复制，粘贴

- 全选当前所有内容 ggvG
- dd 删除当前行
- 删除光标之后的所有内容: 移动光标到指定位置 D / d$
- 删除光标之后的所有内容: 移动光标到指定位置 d0
- p/P: 在光标之后/之前粘贴
- y$: 从光标当前位置复制到行尾。
- y0: 从光标当前位置复制到行首。

#### 搜索

- :/ + 搜索字符
- n 向下检索
- N 向上检索

### 简易 vim 配置（服务器配置使用）

```vim
curl https://raw.githubusercontent.com/yuluo-yx/use/master/vim/_vimrc >> /etc/vim/vimrc
```





 
