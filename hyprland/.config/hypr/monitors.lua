-- ~/.config/hypr/monitors.lua
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Auto-detects which outputs are currently connected and applies the
-- matching layout, so the same dotfiles work docked (both monitors),
-- with only one external plugged in, or on a totally different machine
-- (e.g. a laptop with just an internal panel).
--
-- CAVEAT: hl.get_monitors() is a very new API (Lua config shipped in 0.55,
-- May 2026) and there's an open question upstream about exactly which
-- monitors it sees at config-parse time vs. after they've been enabled
-- (github.com/hyprwm/Hyprland/discussions/14645). Test this on your
-- machine with `hyprctl reload` and check `hyprctl monitors` afterwards;
-- if the detected set is empty on first boot, use the hostname-based
-- fallback commented at the bottom instead.

local function connected_outputs()
	local names = {}
	local ok, monitors = pcall(hl.get_monitors)
	if ok and monitors then
		for _, m in ipairs(monitors) do
			names[m.name] = true
		end
	end
	return names
end

local outputs = connected_outputs()

if outputs["DP-1"] and outputs["DP-2"] then
	-- Profile A: full desktop setup, both externals connected (docked)
	hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "1920x0", scale = 1.25 })
	hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "0x0", scale = 1 })
else
	-- Profile D: fallback -- unknown machine / laptop panel / anything else.
	-- Let Hyprland pick the preferred mode and auto-place/auto-scale it.
	hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
end

-- --- Alternative: hostname-based detection ---------------------------------
-- If hl.get_monitors() doesn't report outputs early enough on your machine,
-- switch to matching on the hostname instead (useful if these dotfiles are
-- shared between a desktop and a laptop, since the monitor names differ
-- less reliably than the machine identity does):
--
-- local hostname = (io.popen("hostname"):read("*l") or ""):gsub("%s+$", "")
--
-- if hostname == "desktop" then
--   hl.monitor({ output = "DP-1", mode = "2560x1440@120", position = "1920x0", scale = 1.25 })
--   hl.monitor({ output = "DP-2", mode = "1920x1080@60",  position = "0x0",    scale = 1 })
-- elseif hostname == "laptop" then
--   hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
-- end
