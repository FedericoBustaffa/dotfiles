-- ~/.config/hypr/keybindings.lua
-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local apps = require("applications")
local mainMod = "SUPER"

-- Every compositor action below goes through the classic dispatcher name via `hyprctl dispatch`, instead of the newer typed hl.dsp.* functions.
-- Reason: the typed dispatchers (hl.dsp.window.close, hl.dsp.focus, ...)
-- have signatures that aren't fully confirmed in the docs yet (0.55 shipped
-- May 2026, coverage is still filling in). If a typed call doesn't exist or
-- has the wrong shape, Lua throws at config-load time and Hyprland ABORTS
-- THE REST OF THE FILE -- which silently kills every bind declared after
-- it. This fallback avoids that risk entirely: `hyprctl dispatch <name>
-- <args>` is the same mechanism hyprctl has always used and works
-- regardless of which config frontend (lua or hyprlang) is active.

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
hl.bind(mainMod .. "+F", hl.dsp.window.fullscreen({ action = "toggle" }))

hl.bind(mainMod .. "+P", hl.dsp.window.pseudo({ action = "toggle" })) -- dwindle
-- hl.bind(mainMod .. "+J", dispatch("togglesplit")) -- dwindle

-- scrolling layout: move focus / columns
hl.bind(mainMod .. "+H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. "+R", hl.dsp.layout("colresize +conf"))

-- Move window with mainMod + Shift + hjkl
hl.bind(mainMod .. "+SHIFT+H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+SHIFT+L", hl.dsp.layout("swapcol r"))
-- hl.bind(mainMod .. "+SHIFT+K", hl.dsp.layout("movewindowto u"))
-- hl.bind(mainMod .. "+SHIFT+J", hl.dsp.layout("movewindowto d"))

-- Switch workspaces with mainMod + [0-9], move window with mainMod + SHIFT + [0-9]
for i = 1, 9 do
	hl.bind(mainMod .. "+" .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. "+ SHIFT +" .. i, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. "+ 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. "+ SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Special workspace (scratchpad)
-- hl.bind(mainMod .. "+S", dispatch("togglespecialworkspace", "magic"))
-- hl.bind(mainMod .. "+SHIFT+S", dispatch("movetoworkspace", "special:magic"))

-- Scroll through existing workspaces with mainMod + scroll
-- hl.bind(mainMod .. "+mouse_down", dispatch("workspace", "e+1"))
-- hl.bind(mainMod .. "+mouse_up", dispatch("workspace", "e-1"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
-- (was `bindm`, the "hold + drag" bind family. If this doesn't drag
-- correctly, it's the one remaining piece to double check against
-- https://wiki.hypr.land/Configuring/Basics/Binds/ -- `bindm` behaves
-- differently from a normal press-bind and the Lua equivalent might need
-- an explicit option like `{ mouse = true }` in hl.bind's opts table.)
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

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

hl.bind(mainMod .. "+N", hl.dsp.exec_cmd("swaync-client -t -sw"))
