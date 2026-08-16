-- ~/.config/hypr/startup.lua
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- exec-once has no direct keyword in Lua -- instead, subscribe to the
-- "hyprland.start" event, which fires once per session (config reloads do
-- NOT re-trigger it, matching the old exec-once semantics).

hl.on("hyprland.start", function()
	local apps = require("applications")

	hl.exec_cmd("~/dotfiles/scripts/dotsync.sh")

	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
	hl.exec_cmd("mako")
	hl.exec_cmd("hyprsunset --temperature 4000")
	hl.exec_cmd("hyprpm reload")

	hl.exec_cmd(apps.terminal)

	-- was: exec-once = [workspace 1 silent] $browser
	-- The "open on workspace 1" part is now handled by the window rule for
	-- class "zen"/"firefox" in rules.lua, so a plain exec is enough here.
	hl.exec_cmd(apps.browser)

	-- hl.exec_cmd("obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland")

	hl.exec_cmd("onedrive --sync")
end)
