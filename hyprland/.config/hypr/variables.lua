-- ~/.config/hypr/variables.lua
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("GDK_BACKEND", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")

hl.config({
	general = {},
	xwayland = {
		enabled = true,
		use_nearest_neighbor = true,
	},
})
