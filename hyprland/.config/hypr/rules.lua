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

-- Display settings
hl.window_rule({
	match = { class = "^io[.]github[.]dotfiles[.]DisplaySettings$", title = "^Display settings$" },
	float = true,
	size = { "monitor_w*0.6", "monitor_h*0.6" },
	center = true,
})

-- Workspace bindings
hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(zen)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^(org.pwmt.zathura)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(sioyek)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(mpv)$" }, workspace = "2" })
hl.window_rule({ match = { class = "^(spotify)$" }, workspace = "3" })
hl.window_rule({ match = { class = "^(dev.zed.Zed)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(code|com[.]microsoft[.]VSCode)$" }, workspace = "7" })
hl.window_rule({ match = { class = "^(kitty)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(com.mitchellh.ghostty)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(obsidian|md[.]obsidian[.]Obsidian)$" }, workspace = "8" })
hl.window_rule({ match = { class = "^(Notion)$" }, workspace = "10" })

-- Layers
hl.layer_rule({
	name = "quickshell_overlay_fade",
	match = { namespace = "^power-menu$" },
	animation = "fade",
})

hl.layer_rule({
	name = "quickshell_edge_overlays",
	match = { namespace = "^(wallpaper-picker|bluetooth-manager|network-manager|app-launcher|notification-center|theme-picker)$" },
	-- QML slides the cards in and out before hiding their layers.
	no_anim = true,
})

hl.layer_rule({
	name = "no_anim_for_selection",
	match = { namespace = "selection" },
	no_anim = true,
})

hl.layer_rule({
	name = "notification-animations",
	match = { namespace = "^notification-toast$" },
	animation = "slide top",
})
