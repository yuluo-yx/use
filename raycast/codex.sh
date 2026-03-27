#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title cl
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ./claude-code-favicon.ico

# Documentation:
# @raycast.description open claude code

# Mac 自带 terminal 写法
# osascript -e 'tell application "Terminal"
#     do script "codex"
#     activate
# end tell'

# Ghosty 写法
open -na Ghostty.app --args -e "zsh" "-l" "-c" "codex"
