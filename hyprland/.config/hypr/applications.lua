-- ~/.config/hypr/applications.lua
--
-- Lua has no direct equivalent of hyprlang's `$var = value` globals, so this
-- is a plain module returning a table. Anything that needs these programs
-- (startup.lua, keybindings.lua, ...) does: local apps = require("applications")

return {
	terminal = "kitty",
	fileManager = "nautilus",
	menu = 'quickshell -n -p "$HOME/dotfiles/quickshell/.config/quickshell/app-launcher"',
	browser = "zen-browser",
}
