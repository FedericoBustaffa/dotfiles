-- ~/.config/hypr/rules.lua
-- See https://wiki.hypr.land/Configuring/Window-Rules/

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Waybar
hl.window_rule({ match = { class = "^(Waybar)$" }, float = true })

-- Matplotlib floating windows
hl.window_rule({ match = { class = "^(python3)$" }, float = true })

-- Bluetooth manager
hl.window_rule({ match = { class = "^(io.github.kaii_lb.Overskride)$" }, float = true, size = "1280 720" })

-- Network manager
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true, size = "640 480" })

-- Workspace bindings
hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(zen)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(org.pwmt.zathura)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(sioyek)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(mpv)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(spotify)$" }, workspace = "3" })
hl.window_rule({ match = { class = "^(dev.zed.Zed)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(code)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(kitty)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(com.mitchellh.ghostty)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(obsidian)$" }, workspace = "9" })
hl.window_rule({ match = { class = "^(Notion)$" }, workspace = "10" })

-- Layers
hl.layer_rule({
	name = "no_anim_for_selection",
	match = { namespace = "selection" },
	no_anim = true,
})

hl.layer_rule({
	name = "notification-animations",
	match = { namespace = "swaync-control-center" },
	animation = "slide top",
})
