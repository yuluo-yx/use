#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title cl
# @raycast.mode silent

# Optional parameters:
# @raycast.icon ./claude-code-favicon.ico

# Documentation:
# @raycast.description open claude code

osascript -e 'tell application "Terminal"
    do script "cl"
    activate
end tell'
