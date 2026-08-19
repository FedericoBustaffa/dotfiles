-- ~/.config/hypr/hyprland.lua
--
-- Hyprland >= 0.55 loads hyprland.lua automatically if it exists (instead of
-- hyprland.conf). See https://wiki.hypr.land/Configuring/Start/
--
-- Modules are split the same way the old .conf sources were. `require()`
-- resolves paths relative to this file and the ".lua" extension is omitted.

require("monitors")
require("decorations")
require("animations")
require("input")
require("layout")
require("keybindings")
require("rules")
require("startup")
require("variables")

-- Old hyprland.conf had a plain `exec = notify-send ...` (runs on *every*
-- load/reload, unlike exec-once). "config.reloaded" fires on every reload,
-- including the first load, which is the closest equivalent.
hl.on("config.reloaded", function()
	hl.exec_cmd('notify-send "Hyprland Config Reload"')
end)
