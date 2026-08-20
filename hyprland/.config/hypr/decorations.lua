-- ~/.config/hypr/decorations.lua
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
	general = {
		border_size = 2,
		gaps_in = 4,
		gaps_out = 8,

		-- see https://wiki.hypr.land/Configuring/Basics/Variables/#colors
		col = {
			active_border = "rgba(8faec9ff)",
			inactive_border = "rgba(595959aa)",
		},

		layout = "scrolling",

		-- resizing windows by clicking and dragging borders/gaps
		resize_on_border = true,

		-- see https://wiki.hypr.land/Configuring/Tearing/ before enabling
		allow_tearing = false,

		snap = {
			enabled = false,
		},
	},

	decoration = {
		rounding = 5,
		rounding_power = 5,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		-- see https://wiki.hypr.land/Configuring/Basics/Variables/#blur
		blur = {
			enabled = true,
			size = 2,
			passes = 1,
			ignore_opacity = true,
			new_optimizations = true,
			xray = true,
			noise = 0.0117,
			contrast = 0.8916,
			brightness = 1.0,
			vibrancy = 0.1696,
			vibrancy_darkness = 0.0,
			special = false,
			popups = false,
			popups_ignorealpha = 0.2,
			input_methods = false,
			input_methods_ignorealpha = 0.2,
		},

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			sharp = false,
			color = "rgba(1a1a1aee)",
			offset = { 0, 0 },
			scale = 1.0,
		},

		glow = {
			enabled = false,
			range = 10,
			render_power = 3,
			color = "rgba(ee33ccff)",
		},

		motion_blur = {
			enabled = false,
			samples = 7,
		},

		wobble = {
			enabled = true,
      mesh = 12,
      stiffness = 200,
      damping = 12,
      mass = 1,
      intensity = 0.2,
      value_epsilon 0.25,
		},
	},
})
