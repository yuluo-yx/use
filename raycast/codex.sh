#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title codex
# @raycast.mode silent

# Documentation:
# @raycast.description open codex in Ghostty

# Mac 自带 terminal 写法
# osascript -e 'tell application "Terminal"
#     do script "codex"
#     activate
# end tell'

# Ghostty 写法
open -na Ghostty.app --args -e "zsh" "-l" "-c" "codex"
