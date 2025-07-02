set nobackup                  " 取消生成备份文件
set number                    " 设置行号
set t_Co=256                  " 256 色显示
set mouse=a                   " 支持使用鼠标
set autoindent                " 按下回车键后，下一行的缩进会自动跟上一行的缩进保持一致
set tabstop=4                 " Tab 空格数
set shiftwidth=4              " 每一级缩进的空格数
set expandtab                 " 自动将 Tab 转为空格
set softtabstop=4             " Tab 转为多少个空格
set cursorline                " 光标所在行高亮
set nowrap                    " 关闭自动折行
set scrolloff=5               " 垂直滚动时，光标距离顶部/底部的距离（单位：行）
set sidescrolloff=30          " 水平滚动时，光标距离行首或行尾的距离（单位：字符）
set textwidth=1000            " 设置行宽，即一行显示多少字符
set laststatus=2              " 显示状态栏
set path+=**                  " 设置搜索文件时显示全部并以 tab 跳转文件
set hlsearch                  " 搜索时，高亮显示搜索结果
set wildmenu                  " 命令模式下补全
syntax on                     " 语法高亮
hi MatchParen ctermbg=Yellow guibg=lightblue " 括号高亮匹配
highlight WhitespaceEOL ctermbg=red guibg=Yellow " 显示行尾的空格
