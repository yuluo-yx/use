# Zsh  插件使用指南

## z 

z 是一个快速目录跳转的工具，在终端中按下 z 并回车，会看到跳转过的目录。

此时只需要 z 目录末尾路径即可完成跳转：

```shell
$ z       
5218       /Users/shown/workspace/java/open_source
6949       /Users/shown/workspace/java/open_source/spring-ai-alibaba
10469      /Users/shown/workspace/golang/open_source/ai-gateway
13811      /Users/shown/.sdkman

z open_source 即可跳转到目录中去。
```

## Thefuck

theFuck 是一个快速纠正终端输入错误命令的工具，每当输错时，心里总会说他妈的（fuck）。此时只需要 fuck 下，即可纠正。(theFuck 快捷键可以自定义配置，默认是两次 esc 即可纠正)

```shell
$ gti status

git status
```



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
/Users/shown/workspace/java/open_source/spring-ai-alibaba copied to clipboard.
```

copybuffer会自动映射到 ctrl + o快捷键，用于复制当前终端显示的命令
## kubectl

提供 kubectl 的补全操作以及其他额外功能等。
