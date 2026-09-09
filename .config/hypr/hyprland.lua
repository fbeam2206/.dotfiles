-------------------------------------------------------------------------------
-- Hyprland main config (Lua) — converted from hyprland.conf on 2026-07-26
--
-- Since Hyprland 0.55 the old "hyprlang" .conf syntax is deprecated in favor
-- of Lua. Because this file (hyprland.lua) exists, Hyprland will load it
-- INSTEAD of hyprland.conf. The choice is made once at startup, so the switch
-- happens the next time Hyprland starts — the currently running session keeps
-- using hyprland.conf. To go back to the old config, just rename or delete
-- this file. The old .conf files are left untouched as a reference/fallback.
--
-- Docs:    https://wiki.hypr.land/Configuring/
-- Example: https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
--
-- ─── 60-second Lua crash course ────────────────────────────────────────────
--  * "--" starts a comment (what "#" used to be). --[[ ... ]] is a block
--    comment.
--  * Everything Hyprland-related lives in the global `hl` table:
--      hl.config({...})       set options (was the category { ... } blocks)
--      hl.monitor({...})      monitors    (was monitorv2 { ... })
--      hl.bind(...)           keybinds    (was bind = ...)
--      hl.window_rule({...})  rules       (was windowrule { ... })
--  * { } is a "table" — Lua's all-purpose container. It's used both as a
--    list ({1, 2, 3}) and as key/value pairs ({ gaps_in = 4 }).
--  * Strings need quotes: layout = "hy3". Numbers and true/false don't.
--    "on"/"off"/"yes"/"1" from the old syntax become true/false.
--  * ".." glues strings together:  mainMod .. " + Q"  →  "ALT + Q"
--  * `local x = ...` declares a variable visible only in this file
--    (replaces the old $variable = ... syntax).
--  * Trailing commas inside tables are allowed and harmless.
-- ────────────────────────────────────────────────────────────────────────────

---------------------
--- FILE SOURCING ---
---------------------
-- require() loads another file, relative to this one ("hyprland/general" is
-- ~/.config/hypr/hyprland/general.lua). Each require()d file runs in its own
-- protected scope: an error in one file won't stop the others from loading.

require("hyprland/general")    -- Look & feel, input, misc options
require("hyprland/animations") -- Animation overrides
require("hyprland/execs")      -- Exec on startup
require("hyprland/rules")      -- Window + workspace + layer rules
require("hyprland/keybinds")   -- Keybinds
require("hyprland/plugins")    -- Plugins (hy3, hyprexpo, hyprbars)
require("hyprland/env")        -- Environment variables

-- Quickshell (was already commented out in the old config; the referenced
-- .conf would need porting to Lua before it could be require()d)
-- require("quickshell/hyprland-layer-config")

----------------
--- MONITORS ---
----------------
-- Replaces the old `monitorv2 { }` blocks: one hl.monitor() call per output,
-- same field names and values as before.
-- Docs: https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Main 1440p 360 Hz display, kept in SDR (sRGB, 8-bit)
hl.monitor({
    output              = "DP-5",
    mode                = "2560x1440@360",
    position            = "0x0",
    scale               = 1,
    supports_wide_color = 1,      -- force wide-color-gamut support on
    supports_hdr        = 0,      -- 0 = auto
    bitdepth            = 8,
    cm                  = "srgb", -- color-management preset
    vrr                 = 0,
})

-- Secondary 1080p display, below the main one
hl.monitor({
    output   = "HDMI-A-5",
    mode     = "1920x1080",
    position = "320x1440",
    scale    = 1,
    bitdepth = 10,
    vrr      = 0,
})
