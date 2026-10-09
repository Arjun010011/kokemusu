-- Kokemusu: solid grey borders, soft neutral shadows, slow and settled motion.
-- Note: `omarchy theme install` drops this file and regenerates the borders
-- from colors.toml, so the border colours live there too. Everything below is
-- loaded by install-extras.sh through ~/.config/hypr/kokemusu.lua.

local active_border_color = "rgba(6e6f69ee)"
local inactive_border_color = "rgba(2a2b29aa)"

hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 14,
    border_size = 2,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
    resize_on_border = false,
    allow_tearing = false,
  },

  decoration = {
    rounding = 12,
    rounding_power = 2.2,

    active_opacity = 1.0,
    inactive_opacity = 0.97,
    fullscreen_opacity = 1.0,

    -- Unfocused windows fade back a little, like stones further into the dusk.
    dim_inactive = true,
    dim_strength = 0.08,
    dim_special = 0.35,

    shadow = {
      enabled = true,
      range = 22,
      render_power = 4,
      color = "rgba(0a0b0a99)",
      color_inactive = "rgba(0a0b0a44)",
      offset = "0 5",
      scale = 1.0,
    },

    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      contrast = 0.9,
      brightness = 0.85,
      vibrancy = 0.05,
      vibrancy_darkness = 0.1,
      noise = 0.015,
      ignore_opacity = true,
      new_optimizations = true,
      xray = false,
      popups = true,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      gradients = false,
      col = {
        active = "rgba(2a2b29ff)",
        inactive = "rgba(161716cc)",
      },
      text_color = "rgb(cfcdc4)",
    },
  },

  animations = {
    enabled = true,
  },

  misc = {
    animate_manual_resizes = true,
    animate_mouse_windowdragging = false,
    background_color = "rgb(0e0f0e)",
  },
})

-- Frost the translucent shell surfaces: the bar, the island, and the popups,
-- menus and notifications that open from them.
hl.layer_rule({ match = { namespace = "^(omarchy-bar|dynamic-island)$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ match = { namespace = "^omarchy-(menu|clipboard|emojis|notifications|osd|polkit|reminders|keyboard-panel)$" }, blur = true, ignore_alpha = 0.5 })

-- Curves: everything settles like a leaf landing; nothing bounces.
hl.curve("mossOut", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
hl.curve("mossSoft", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.curve("mossRise", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("mossFade", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

-- Windows rise a little as they appear and sink back as they close.
hl.animation({ leaf = "windows", enabled = true, speed = 4.5, bezier = "mossRise" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.2, bezier = "mossRise", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "mossFade", style = "popin 95%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.5, bezier = "mossOut", style = "slide" })

-- Solid borders, so only the colour change animates.
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "mossOut" })
hl.animation({ leaf = "borderangle", enabled = false })

hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "mossSoft" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 3.2, bezier = "mossFade" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2.6, bezier = "mossFade" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 4, bezier = "mossSoft" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 4, bezier = "mossSoft" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 3, bezier = "mossSoft" })

-- Workspaces drift sideways and cross-fade instead of a full-screen slide.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "mossOut", style = "slidefade 10%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.8, bezier = "mossOut", style = "slidefadevert 16%" })

-- Bar, launcher, notifications: fade in while growing the last few percent.
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "mossOut", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "mossOut", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.6, bezier = "mossFade", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "mossFade" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2.4, bezier = "mossFade" })

hl.animation({ leaf = "zoomFactor", enabled = true, speed = 5, bezier = "mossOut" })
