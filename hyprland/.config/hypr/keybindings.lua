-- ~/.config/hypr/keybindings.lua
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local apps = require("applications")
local mainMod = "SUPER"

-- Some classic dispatchers (layoutmsg for the scrolling plugin, plain
-- workspace/movetoworkspace/pseudo/movewindow/resizewindow, ...) don't have
-- a confirmed typed hl.dsp.* signature in the docs available right now --
-- the Lua config only shipped in 0.55 (May 2026) and coverage is still
-- filling in. This helper calls them the classic way through hyprctl, which
-- still understands every dispatcher name regardless of which config
-- frontend is active. Swap these for native hl.dsp.* calls as the wiki's
-- Dispatchers page (https://wiki.hypr.land/Configuring/Dispatchers/) fills
-- in, or once `hyprctl dispatch <name>` confirms the exact call for you.
local function dispatch(name, arg)
	local cmd = "hyprctl dispatch " .. name
	if arg then
		cmd = cmd .. ' "' .. arg .. '"'
	end
	return hl.dsp.exec_cmd(cmd)
end

-- Basics
hl.bind(mainMod .. "+Return", hl.dsp.exec_cmd(apps.terminal))
hl.bind(mainMod .. "+Q", hl.dsp.window.close())
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(apps.fileManager))
hl.bind(mainMod .. "+B", hl.dsp.exec_cmd(apps.browser))
hl.bind(mainMod .. "+V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. "+SPACE", hl.dsp.exec_cmd(apps.menu))
hl.bind(mainMod .. "+BACKSPACE", hl.dsp.exec_cmd("wlogout"))
hl.bind(mainMod .. "+F12", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. "+SHIFT+R", hl.dsp.exec_cmd("~/dotfiles/scripts/reload.sh"))
hl.bind(mainMod .. "+F", hl.dsp.window.fullscreen())

hl.bind(mainMod .. "+P", dispatch("pseudo")) -- dwindle
-- hl.bind(mainMod .. "+J", dispatch("togglesplit")) -- dwindle

-- scrolling layout: move focus / columns
hl.bind(mainMod .. "+H", dispatch("layoutmsg", "move -col"))
hl.bind(mainMod .. "+L", dispatch("layoutmsg", "move +col"))
hl.bind(mainMod .. "+K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. "+R", dispatch("layoutmsg", "colresize +conf"))

-- Move window with mainMod + Shift + hjkl
hl.bind(mainMod .. "+SHIFT+H", dispatch("layoutmsg", "swapcol l"))
hl.bind(mainMod .. "+SHIFT+L", dispatch("layoutmsg", "swapcol r"))
hl.bind(mainMod .. "+SHIFT+K", dispatch("layoutmsg", "movewindowto u"))
hl.bind(mainMod .. "+SHIFT+J", dispatch("layoutmsg", "movewindowto d"))

-- Switch workspaces with mainMod + [0-9], move window with mainMod + SHIFT + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. "+" .. i, dispatch("workspace", tostring(i)))
	hl.bind(mainMod .. "+SHIFT+" .. i, dispatch("movetoworkspace", tostring(i)))
end
hl.bind(mainMod .. "+0", dispatch("workspace", "10"))
hl.bind(mainMod .. "+SHIFT+0", dispatch("movetoworkspace", "10"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. "+S", dispatch("togglespecialworkspace", "magic"))
hl.bind(mainMod .. "+SHIFT+S", dispatch("movetoworkspace", "special:magic"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. "+mouse_down", dispatch("workspace", "e+1"))
hl.bind(mainMod .. "+mouse_up", dispatch("workspace", "e-1"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
-- (was `bindm`, the "hold + drag" bind family -- verify the exact opts
-- against https://wiki.hypr.land/Configuring/Basics/Binds/, this mirrors
-- the classic dispatcher names via the fallback above)
hl.bind(mainMod .. "+mouse:272", dispatch("movewindow"))
hl.bind(mainMod .. "+mouse:273", dispatch("resizewindow"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { release = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { release = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { release = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { release = true })
