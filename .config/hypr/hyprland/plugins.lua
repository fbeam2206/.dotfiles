-------------------------------------------------------------------------------
-- PLUGINS  (was: hyprland/plugins.conf)
--
-- Plugin options live under plugin.<name> inside hl.config(), mirroring the
-- old plugin { <name> { … } } blocks.
--
-- Each block is wrapped in `if hl.plugin.<name> ~= nil then … end` (the
-- wiki-recommended pattern) so nothing errors while a plugin isn't loaded.
-- As of this conversion NO plugins are loaded — `hyprpm list` shows every
-- plugin disabled and `hyprctl plugin list` is empty — so all three blocks
-- below are currently dormant. Once a plugin is enabled (hyprpm enable <name>
-- + hyprpm reload) its config applies again; if it doesn't seem to, run
-- `hyprctl reload`.
--
-- NOTE on hyprexpo: it was retired from the official hyprland-plugins repo.
-- Your hyprpm still has an old copy; if you want it long-term, community
-- forks exist (e.g. github.com/sandwichfarm/hyprexpo).
--
-- Docs: https://wiki.hypr.land/Plugins/Using-Plugins/
-------------------------------------------------------------------------------

--- HY3 (tiling layout; general.layout = "hy3" is set in general.lua) ---

if hl.plugin.hy3 ~= nil then
    hl.config({
        plugin = {
            hy3 = {
                autotile = {
                    enable         = true,
                    trigger_width  = 1254, -- split vertically if a window would get squished below this width
                    trigger_height = 0,
                    workspaces     = "not:2", -- autotile everywhere except workspace 2
                },
            },
        },
    })
end

--- HYPREXPO (workspace overview) ---

if hl.plugin.hyprexpo ~= nil then
    hl.config({
        plugin = {
            hyprexpo = {
                columns          = 2,
                gap_size         = 5,
                bg_col           = "rgb(111111)",
                workspace_method = "center current", -- [center/first] [workspace] e.g. first 1 or center m+1
            },
        },
    })
end

--- HYPRBARS (window title bars) ---

if hl.plugin.hyprbars ~= nil then
    hl.config({
        plugin = {
            hyprbars = {
                bar_height = 20,
            },
        },
    })

    -- Buttons are added right → left. The old `hyprbars-button = color,
    -- size, icon, on-click` keyword became hl.plugin.hyprbars.add_button().
    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(ff4040)",
        size     = 10,
        icon     = "󰖭",
        action   = "hyprctl dispatch killactive",
    })

    hl.plugin.hyprbars.add_button({
        bg_color = "rgb(eeee11)",
        size     = 10,
        icon     = "",
        action   = "hyprctl dispatch fullscreen 1",
    })
end
