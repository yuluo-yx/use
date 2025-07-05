set nobackup                        " 不生成备份文件
set number                          " 显示行号
set t_Co=256                        " 支持 256 色
set mouse=a                         " 启用鼠标支持
set autoindent                      " 自动缩进
set tabstop=4                       " 设置 Tab 键的宽度为 4 个空格
set shiftwidth=4                    " 设置缩进宽度为 4 个空格
set expandtab                       " 用空格替代 Tab
set softtabstop=4                   " 设定 Tab 键等效的空格数
set cursorline                      " 高亮显示光标所在的行
set nowrap                          " 不自动换行
set scrolloff=5                     " 光标上下移动时保持离顶部或底部至少 5 行
set sidescrolloff=30                " 光标左右移动时保持离行首或行尾至少 30 字符
set textwidth=1000                  " 设置最大文本宽度为 1000 字符，不会自动换行
set laststatus=2                    " 始终显示状态栏
set path+=**                        " 在当前目录及子目录下查找文件
set hlsearch                        " 高亮显示搜索结果
set wildmenu                        " 命令补全时在命令行显示选项菜单

syntax on                           " 开启语法高亮
hi MatchParen ctermbg=Yellow guibg=lightblue    " 高亮匹配的括号
highlight WhitespaceEOL ctermbg=red guibg=Yellow    " 高亮显示行尾空格
set visualbell                      " 视觉铃声，代替声音警告
set colorcolumn=100                 " 画一条垂直线在第 100 列
set updatetime=100                  " 更改事件发生后更新时间为 100 毫秒
set virtualedit=block               " 在可视块模式下允许在行尾移动
set autochdir                       " 根据当前文件自动切换目录
set exrc                            " 允许在本地目录中加载 .vimrc 文件
set secure                          " 只在安全模式下加载本地配置文件
set relativenumber                  " 显示相对行号
set list                            " 显示不可见字符
set listchars=tab:\|\ ,trail:▫     " 设置显示的不可见字符样式
set ttimeoutlen=0                   " 连续按键的超时时间为 0
set notimeout                       " 不设置按键超时
set viewoptions=cursor,folds,slash,unix " 设置保存视图的选项
set wrap                            " 自动换行
set tw=0                            " 不设置文本宽度，禁用自动换行
set indentexpr=                     " 不使用任何表达式进行缩进
set foldmethod=indent               " 使用缩进折叠代码
set foldlevel=99                    " 打开所有折叠
set foldenable                      " 启用代码折叠
set formatoptions-=tc               " 不在注释中自动换行
set splitright                      " 新窗口默认在右边打开
set splitbelow                      " 新窗口默认在下边打开
set noshowmode                      " 不显示当前模式（如INSERT等），因为状态栏中已显示
set ignorecase                      " 搜索时忽略大小写
set smartcase                       " 启用智能大小写匹配
set shortmess+=c                    " 不显示补全菜单的提示信息
set completeopt=longest,noinsert,menuone,noselect,preview " 设置补全选项
set lazyredraw                      " 启用懒惰重绘，加快性能

" plugin config
call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'luochen1990/rainbow'

call plug#end()

" nerdtree map config
map <C-n> :NERDTreeToggle<CR>

" coc config
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" rainbow config
let g:rainbow_active = 1
let g:rainbow_conf = {
\   'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick'],
\   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\   'guis': [''],
\   'cterms': [''],
\   'operators': '_,_',
\   'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\   'separately': {
\       '*': {},
\       'markdown': {
\           'parentheses_options': 'containedin=markdownCode contained',},
\       'lisp': {
\           'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],   },
\       'haskell': {
\           'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'], },
\       'vim': {
\           'parentheses_options': 'containedin=vimFuncBody',   },
\       'perl': {
\           'syn_name_prefix': 'perlBlockFoldRainbow', },
\       'stylus': {
\           'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'], },
\       'css': 0
\   }
\}
