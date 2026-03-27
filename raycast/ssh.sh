#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title SSH Dev3
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️

# Documentation:
# @raycast.description SSH login to sh-dev3

# 配置证书登录之后使用
open -na Ghostty.app --args -e "zsh" "-l" "-c" "ssh user@host"
