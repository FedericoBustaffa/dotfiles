-- ~/.config/hypr/input.lua
-- See https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
  input = {
    kb_layout = "it",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification

    touchpad = {
      natural_scroll = true,
      disable_while_typing = true,
    },

    tablet = {
      output = "DP-1",
    },
  },
})

-- gestures = { workspace_swipe = false }  -- left disabled, as in the original

-- Per-device config (was: device { name = ...; sensitivity = ... })
-- NOTE: verify this table shape against the wiki -- the per-device schema
-- for hl.config() wasn't fully nailed down in the sources checked here.
hl.config({
  device = {
    name = "usb-optical-mouse",
    sensitivity = -0.5,
  },
})
