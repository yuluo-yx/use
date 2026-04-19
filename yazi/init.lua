-- ~/.config/yazi/init.lua
local dir = os.getenv("HOME") .. "/.config/yazi/_extensions/"
dofile(dir .. "linemode.lua")
dofile(dir .. "header.lua")
dofile(dir .. "status.lua")
dofile(dir .. "plugin-setup.lua")