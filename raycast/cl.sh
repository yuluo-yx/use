#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title cl
# @raycast.mode silent

# Documentation:
# @raycast.description open claude code in Ghostty

# Mac 自带 terminal 写法
# osascript -e 'tell application "Terminal"
#    do script "cl"
#    activate
# end tell'

# Ghostty 写法
open -na Ghostty.app --args -e "zsh" "-l" "-c" "claude --dangerously-skip-permissions --append-system-prompt \"\$(cat ~/.claude/system-prompt.txt)\""
