-------------------------------------------------------------------------------
-- LOOK AND FEEL + INPUT  (was: hyprland/general.conf)
--
-- hl.config() takes one table shaped like { category = { option = value } }.
-- It can be called any number of times, anywhere; each call only changes the
-- options you pass in (everything else keeps its current value).
-- Full option list: https://wiki.hypr.land/Configuring/Basics/Variables/
-------------------------------------------------------------------------------

hl.config({
    general = {
        gaps_in  = 4,
        -- The old "2,12,12,12" was CSS order: top, right, bottom, left.
        -- In Lua a gaps value is either a single number or this table:
        gaps_out = { top = 2, right = 12, bottom = 12, left = 12 },

        border_size = 0,

        allow_tearing = true,
        layout        = "hy3", -- needs the hy3 plugin loaded; Hyprland falls
                               -- back to dwindle when it isn't (see plugins.lua)
    },

    decoration = {
        rounding = 8,

        dim_inactive = true,
        dim_strength = 0.15,

        -- Windows 11-style shadow: wide, soft, pure black at low opacity and
        -- pushed downward so the bottom edge carries most of the weight.
        --   range          how far (px) the shadow reaches out from the window
        --   render_power   falloff curve: 1 = linear, higher = fades faster
        --   offset         { x, y } shift of the whole shadow; +y = downward
        --   color          rgba(RRGGBBAA); the AA byte sets the darkness
        shadow = {
            enabled        = true,
            range          = 60,
            render_power   = 2,
            offset         = { 0, 20 },
            color          = "rgba(00000060)", -- focused window   (~38% black)
            color_inactive = "rgba(00000030)", -- unfocused windows (~19% black)
            sharp          = false,
            scale          = 1.0,
        },

        blur = {
            enabled        = true,
            size           = 1,
            passes         = 5,
            vibrancy       = 0.1696,
            popups         = true,
            ignore_opacity = false,
        },
    },

    group = {
        groupbar = {
            render_titles = false,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        enable_swallow          = false,
        font_family             = "SF Pro Display",
    },

    cursor = {
        default_monitor = "DP-5",
        -- off: setcursor would sync the hyprcursor theme name (McMojaveCursor)
        -- into gsettings, but GTK apps need the xcursor theme name
        -- (McMojave-Cursors-32)
        sync_gsettings_theme = false,
        enable_hyprcursor    = true,
        inactive_timeout     = 30,
    },

    -------------
    --- INPUT ---
    -------------
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        force_no_accel = true,

        follow_mouse  = 2, -- 2 = cursor focus detached from keyboard focus
        accel_profile = "flat",

        sensitivity = -0.8, -- -1.0 – 1.0, 0 means no modification

        touchpad = {
            natural_scroll = false,
        },
    },

    render = {
        direct_scanout = 2, -- 2 = auto (on for content type "game")
        cm_auto_hdr    = 1, -- auto-switch to HDR in fullscreen when needed
    },

    ecosystem = {
        no_donation_nag = true,
    },

    -- Force XWayland to use proper scaling
    xwayland = {
        force_zero_scaling = true,
    },

    quirks = {
        prefer_hdr = 1, -- report HDR mode as preferred (1 = always)
    },

    debug = {
        vfr = false,
    },
})

-------------------------------------------------------------------------------
-- ANIMATIONS — base set (hyprland/animations.lua overrides some of these,
-- exactly like the old file-sourcing order did)
--
--   old: bezier    = myBezier, 0.05, 0.9, 0.1, 1.05
--   new: hl.curve("myBezier", { type = "bezier", points = {{x1,y1},{x2,y2}} })
--
--   old: animation = windows, 1, 7, myBezier
--   new: hl.animation({ leaf = "windows", enabled = true, speed = 7,
--                       bezier = "myBezier" })
--
-- `speed` is still measured in ds (deciseconds): speed = 7 → 700 ms.
-- Docs: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
-------------------------------------------------------------------------------

hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

hl.animation({ leaf = "windows",     enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",      enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",        enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 6,  bezier = "default" })
