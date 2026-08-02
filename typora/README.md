# Typora 配置

个人 Typora 主题配置文件，基于 yuluo-css 主题。

## 安装

将本目录下的文件复制到 Typora 的主题目录：

- `yuluo-css.css` → 主题根目录
- `github/` → 主题根目录下的 `github/` 子目录（存放 Open Sans woff2 字体文件）

### macOS 主题目录路径

```
~/Library/Application Support/abnerworks.Typora/themes/
```

可通过 Typora 菜单 `偏好设置 → 外观 → 打开主题文件夹` 快速定位。

## 文件说明

| 文件 | 说明 |
| --- | --- |
| `yuluo-css.css` | 主题样式文件 |
| `github/open-sans-v17-latin-ext_latin-regular.woff2` | Open Sans Regular 字体 |
| `github/open-sans-v17-latin-ext_latin-italic.woff2` | Open Sans Italic 字体 |
| `github/open-sans-v17-latin-ext_latin-700.woff2` | Open Sans Bold 字体 |
| `github/open-sans-v17-latin-ext_latin-700italic.woff2` | Open Sans Bold Italic 字体 |

## 依赖字体

主题中引用了 `Hannotate SC`（汉 annotate SC）中文字体，Typora 通过系统字体调用，未在本仓库中分发。如需启用该中文字体效果，请自行安装 `Hannotate.ttc` 到系统字体目录。
