# Zsh  插件使用指南

zsh 框架用 oh-my-zsh 听说 zim 也不错，比前者更快。

## z 

z 是一个快速目录跳转的工具，在终端中按下 z 并回车，会看到跳转过的目录。
和 autojump 功能相似，

此时只需要 z 目录末尾路径即可完成跳转：

```shell
$ z       
5218       /workspace/java/open_source
6949       /workspace/java/open_source/spring-ai-alibaba
10469      /workspace/project/open_source/ai-gateway
13811      /home/user/.sdkman

z open_source 即可跳转到目录中去。
```

## Typo

> thefuck 的替代品。比 thefuck 更好用。

typo：https://github.com/yuluo-yx/typo。

## web-search

通过命令行使用搜索引擎。

```text
# 打开google搜索引擎
goolge

# 打开baidu搜索引擎
baidu

# 打开bing搜索引擎
bing

# 打开google搜索引擎，并搜索关键字idea
goolge idea

# 打开baidu搜索引擎，并搜索关键字idea
baidu idea

# 打开bing搜索引擎，并搜索关键字idea
bing idea
```

##  zsh-syntax-highlighting

经典插件，高亮插件。

## zsh-autosuggestions

经典插件，自动补全。

## copypath，copybuffer

zsh自带的插件

copypath可以用来将当前目录快速复制到剪切板

```shell
$ copypath       
/workspace/java/open_source/spring-ai-alibaba copied to clipboard.
```

copybuffer会自动映射到 ctrl + o快捷键，用于复制当前终端显示的命令

## kubectl

提供 kubectl 的补全操作以及其他额外功能等。

## fzf

模糊搜索，ff 模糊搜索文件并预览。

`ctrl r` 模糊搜索 history；
开头匹配 `^git` 搜索所有以 git 开头的命令；
以特定单词结尾的搜索：`git$`，搜索以 git 结尾的命令；
`ctrl t` 搜索文件；
模糊补全：kill ** + <tab>，搜索进程名，自动补全进程 id；** 可以接任何命令，vim cat 等；

将 ff 搜索到的文件传给 vim: `vim `ff`` 或 `vim $(fzf)`，明显 `ff` 更好使。

fzf 接管道符：`alias gco="git branch | fzf | xargs git checkout"` 快速搜索并切换分支 

> 在服务器上时很多场景下没有 zsh 只有 bash，同样可以用 ctrl r 搜索。回车执行，多次 ctrl r 向上搜索。

## eza

代替 ls，ls 输出更丰富些。

```shell
brew install eza

eza -l
eza -D 显示目录
```

设置 alias：`alias ls="eza"`
