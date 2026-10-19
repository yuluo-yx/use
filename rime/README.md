# 鼠须管配置

当前使用的小鹤双拼配置，基于[雾凇拼音](https://github.com/iDvel/rime-ice)。默认保持中文模式，同时提供英文候选与单词前缀补全。

## 输入体验

| 操作 | 结果 |
| --- | --- |
| `nihc` + 空格 | 你好 |
| `vswf` + 空格 | 中文 |
| `ulpb` + 空格 | 双拼 |
| `github` + 空格 | GitHub |
| `github` + 回车 | 原始字母 `github` |
| `gith` | 补全 GitHub、GitHub Pages、GitHub Actions 等 |
| `dock` | 补全 docker、Dockerfile 等 |
| 有候选时按分号 `;` | 选择第二候选 |
| 有候选时按单引号 `'` | 选择第三候选 |
| Ctrl + 反引号或 F4 | 打开方案菜单；Mac 功能键设置不同可能需要 Fn + F4 |

只启用小鹤双拼一个方案。英文词库作为次翻译器挂载，中文初始权重为 1.2，英文为 0.8；Shift、Caps Lock 不负责中英文模式切换。空格选择候选，回车提交原始输入。

保留 Emoji、简繁切换、日期、计算器和部件拆字等雾凇功能。浅色使用 `light_blue`，深色使用 `dark_coral`，候选横排，每页 6 个。

## 文件布局

`config/` 是可复制到 `~/Library/Rime/` 的完整配置源文件，约 48 MiB；词库一并收录，恢复时无需临时下载。

| 文件或目录 | 用途 |
| --- | --- |
| `default.custom.yaml` | 唯一启用方案、候选数量和模式切换键 |
| `double_pinyin_flypy.custom.yaml` | 中文模式默认值、英文补全、回车和快捷选词 |
| `melt_eng.custom.yaml` | 英文拼写规则适配小鹤双拼 |
| `squirrel.custom.yaml` | 浅蓝／暗珊瑚皮肤、字体、间距 |
| `radical_pinyin.custom.yaml` | 部件拆字适配小鹤双拼 |
| `custom_phrase_double.txt` | 手动短语：`d` → done、`ai` → any idea、`wdyt` → what do you think |
| `cn_dicts/`、`en_dicts/` | 中英文词库源文件 |
| `lua/`、`opencc/` | Lua 功能及 Emoji 转换数据 |

未收录 `build/`、个人用户词库、`user.yaml`、`installation.yaml`、日志和调试脚本。`lua/lunar.db` 是农历功能需要的随附数据，并非个人输入记录。

## 安装或恢复

先安装鼠须管。以下操作只复制配置，不安装或替换输入法程序，也不修改 macOS 输入源登记。

在仓库根目录执行：

```bash
mkdir -p "$HOME/Library/Rime-backups"
rime_backup_dir="$(mktemp -d "$HOME/Library/Rime-backups/import-$(date +%Y%m%d-%H%M%S)-XXXXXX")"
if [ -d "$HOME/Library/Rime" ]; then
  ditto "$HOME/Library/Rime" "$rime_backup_dir/Rime"
fi
mkdir -p "$HOME/Library/Rime"
ditto rime/config "$HOME/Library/Rime"
printf '配置备份：%s\n' "$rime_backup_dir"
```

复制会覆盖同名配置和手动短语，保留目录中其他文件及个人用户词库。无数据迁移，配置直接替换。

然后在菜单栏选择鼠须管，点「重新部署」。首次编译完整中文词库需要等待。配置写入与部署成功并不等于当前客户端已加载，最后在文本编辑中试打上表的 `nihc`、`github` 和 `gith`。

所有配置、词库和编译结果都放在 `~/Library/Rime/`，不要写入 `/Library/Input Methods/Squirrel.app/Contents/SharedSupport/`；向已签名应用包添加运行数据会破坏包完整性。

若首次安装或替换输入法程序后，系统菜单仍未出现鼠须管，保存工作并退出登录、重新登录，再在系统设置的「键盘 → 文本输入 → 编辑」中添加鼠须管。仅修改这里的配置通常只需重新部署。
