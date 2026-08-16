-- ~/.config/hypr/layout.lua

-- Double monitor: workspaces 1-5 on DP-2, 6-10 on DP-1.
-- The old .conf needed 10 near-identical lines; Lua turns it into a loop
-- (this is exactly the kind of thing the Lua config is meant to simplify).
for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2" })
end
for i = 6, 10 do
  hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1" })
end

hl.config({
  -- See https://wiki.hypr.land/Configuring/Dwindle-Layout/
  dwindle = {
    -- pseudotile = true, -- bound to mainMod + P below instead
    preserve_split = true,
  },

  -- See https://wiki.hypr.land/Configuring/Master-Layout/
  master = {
    new_status = "master",
  },

  -- hyprscrolling plugin layout (see plugins.lua for the plugin block)
  scrolling = {
    column_width = 0.5,
    explicit_column_widths = "0.5, 0.7, 0.75, 1.0",
    fullscreen_on_one_column = true,
    focus_fit_method = 1,
  },

  misc = {
    force_default_wallpaper = 0, -- 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = true,
  },
})
