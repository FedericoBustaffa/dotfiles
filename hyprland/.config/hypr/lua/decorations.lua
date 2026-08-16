-- ~/.config/hypr/decorations.lua
-- See https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    gaps_in = 4,
    gaps_out = 8,
    border_size = 0,

    -- see https://wiki.hypr.land/Configuring/Basics/Variables/#colors
    ["col.active_border"]   = "rgba(8faec9ff)",
    ["col.inactive_border"] = "rgba(595959aa)",

    -- resizing windows by clicking and dragging borders/gaps
    resize_on_border = true,

    -- see https://wiki.hypr.land/Configuring/Tearing/ before enabling
    allow_tearing = false,

    layout = "scrolling",
  },

  decoration = {
    rounding = 10,
    rounding_power = 20,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = false,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    -- see https://wiki.hypr.land/Configuring/Basics/Variables/#blur
    blur = {
      enabled = true,
      size = 5,
      passes = 5,
      vibrancy = 0.5,
    },
  },
})
