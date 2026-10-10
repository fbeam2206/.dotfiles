-------------------------------------------------------------------------------
-- KEYBINDINGS  (was: hyprland/keybinds.conf)
--
-- hl.bind(keys, dispatcher, opts)
--   keys       one string: mods and key joined with " + ",
--              e.g. "ALT + SHIFT + Q" (was: bind = ALT SHIFT, Q, ...)
--   dispatcher what to do — built from the hl.dsp.* factories below, or a
--              plain Lua function for scripted behavior
--   opts       optional table of flags. The old bind-suffix letters map to:
--                bindd  → { description = "..." }
--                bindel → { locked = true, repeating = true }
--                bindl  → { locked = true }
--                binddm → { mouse = true, description = "..." }
--
-- Old dispatcher → new factory cheat sheet (the ones used in this file):
--   exec …                    hl.dsp.exec_cmd("…")
--   killactive                hl.dsp.window.close()
--   togglegroup               hl.dsp.group.toggle()
--   movefocus l/r/u/d         hl.dsp.focus({ direction = "l" })
--   movewindow l/r/u/d        hl.dsp.window.move({ direction = "l" })
--   movetoworkspace N         hl.dsp.window.move({ workspace = N })
--   movewindoworgroup l/r     hl.dsp.window.move({ direction = "l", group_aware = true })
--   changegroupactive b/f     hl.dsp.group.prev() / hl.dsp.group.next()
--   togglefloating            hl.dsp.window.float({ action = "toggle" })
--   fullscreen                hl.dsp.window.fullscreen()
--   workspace N               hl.dsp.focus({ workspace = N })
--   togglespecialworkspace X  hl.dsp.workspace.toggle_special("X")
--   movewindow  (mouse bind)  hl.dsp.window.drag()
--   resizewindow (mouse bind) hl.dsp.window.resize()
--
-- Descriptions still show up in `hyprctl binds`.
-- Docs: https://wiki.hypr.land/Configuring/Basics/Binds/
--       https://wiki.hypr.land/Configuring/Basics/Dispatchers/
-------------------------------------------------------------------------------

--------------------
--- MY PROGRAMS  ---
--------------------
-- `local` variables replace the old $terminal / $fileManager / $menu
--local terminal    = "alacritty"
local terminal    = "ghostty"
-- GTK_THEME here is per-app on purpose (global GTK_THEME breaks Ghostty popovers, see env.lua).
-- Same treatment in ~/.local/share/applications/org.gnome.Nautilus.desktop + dbus-1/services.
local fileManager = "env GTK_THEME=WhiteSur-Dark-solid-grey nautilus"
local menu        = "walker"

-------------------
--- KEYBINDINGS ---
-------------------

-- Sets "Alt" as the main modifier.
-- (The old value "L-ALT" only worked because Hyprland substring-matches mod
-- names — "L-ALT" contains "ALT". Modifiers can't distinguish left from
-- right, so this always meant plain ALT.)
local mainMod = "ALT"

--[[ HY3 dispatchers — the old commented-out hy3 binds, translated.
When the hy3 plugin is loaded it exposes dispatcher factories under
hl.plugin.hy3; uncomment (and comment out the plain equivalents below):

local hy3 = hl.plugin.hy3
hl.bind(mainMod .. " + Q", hy3.kill_active(),                          { description = "Kill Active Window" })
hl.bind(mainMod .. " + B", hy3.make_group("opposite", { ephemeral = true })) -- dwindle
hl.bind(mainMod .. " + N", hy3.make_group("tab", { toggle = true }))
hl.bind(mainMod .. " + T", hy3.toggle_focus_layer(),                   { description = "Toggle Focus Layer" })

-- Move focus with mainMod + VIM keys
hl.bind(mainMod .. " + H", hy3.move_focus("l"))
hl.bind(mainMod .. " + L", hy3.move_focus("r"))
hl.bind(mainMod .. " + J", hy3.move_focus("d"))
hl.bind(mainMod .. " + K", hy3.move_focus("u"))

-- Move window with mainMod + SHIFT + VIM keys
hl.bind(mainMod .. " + SHIFT + H", hy3.move_window("l"))
hl.bind(mainMod .. " + SHIFT + L", hy3.move_window("r"))
hl.bind(mainMod .. " + SHIFT + J", hy3.move_window("d"))
hl.bind(mainMod .. " + SHIFT + K", hy3.move_window("u"))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    hl.bind(mainMod .. " + SHIFT + " .. (i % 10), hy3.move_to_workspace(i))
end
hl.bind(mainMod .. " + SHIFT + S", hy3.move_to_workspace("special:scratch"))
]]

-- If Hy3 breaks, use these (currently active, same as the old config):
hl.bind(mainMod .. " + Q", hl.dsp.window.close(), { description = "Kill Active Window" })

-- NOTE: carried over as-is — the old bind ran a shell command literally
-- called "togglefocuslayer" (`exec, togglefocuslayer`), which probably
-- doesn't exist. It was likely meant to be hy3's toggle_focus_layer()
-- (see the hy3 block above).
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("togglefocuslayer"), { description = "Toggle Focus Layer" })

hl.bind(mainMod .. " + A", hl.dsp.group.toggle(), { description = "Toggle Window Group" })

-- Move focus with mainMod + VIM keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }), { description = "Move Focus Left" })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }), { description = "Move Focus Right" })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }), { description = "Move Focus Up" })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }), { description = "Move Focus Down" })

-- Move window with mainMod + SHIFT + VIM keys
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }), { description = "Move Window Left" })
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }), { description = "Move Window Right" })
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }), { description = "Move Window Up" })
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }), { description = "Move Window Down" })

-- Move active window to a workspace with mainMod + SHIFT + [0-9].
-- A Lua for-loop replaces the ten copy-pasted lines: i runs 1..10, and
-- `i % 10` (remainder) turns workspace 10 into key "0".
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),
        { description = "Move to Workspace " .. i })
end

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:scratch" }),
    { description = "Move to Workspace scratch" })

-- (the left/right descriptions were swapped in the old config; fixed here)
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ direction = "r", group_aware = true }),
    { description = "Move Window into Group Right" })
hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ direction = "l", group_aware = true }),
    { description = "Move Window into Group Left" })
hl.bind(mainMod .. " + bracketleft",  hl.dsp.group.prev(), { description = "Switch Group Active - Left" })
hl.bind(mainMod .. " + bracketright", hl.dsp.group.next(), { description = "Switch Group Active - Right" })

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal),    { description = "Open Terminal" })
hl.bind(mainMod .. " + M",      hl.dsp.exec_cmd("uwsm stop"), { description = "Logout" })
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager), { description = "Open File Manager" })
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }), { description = "Toggle Floating Window State" })
hl.bind(mainMod .. " + D",      hl.dsp.global("quickshell:launcherToggle"), { description = "Open App Launcher" })
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen(),   { description = "Fullscreen Active Window" })
hl.bind(mainMod .. " + CTRL + S",
    hl.dsp.exec_cmd("slurp | grim -g - $(xdg-user-dir PICTURES)/$(date +'screenshot_%Y-%m-%d-%H%M%S.png')"),
    { description = "Screenshot" })
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"), { description = "Color Picker" })
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("wayscriber --daemon-toggle"), { description = "Toggle Annotation Overlay" })

-- Switch workspaces with mainMod + [0-9].
-- Workspace 3 is special: it runs your script instead (same as before).
for i = 1, 10 do
    local key = i % 10
    if i == 3 then
        hl.bind(mainMod .. " + " .. key, hl.dsp.exec_cmd("~/.config/hypr/scripts/workspace3.sh"),
            { description = "Move Focus to Workspace 3" })
    else
        hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }),
            { description = "Move Focus to Workspace " .. i })
    end
end
-- hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("scratch"))

-- Special workspace (scratchpad) for games
hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("game"), { description = "Toggle Game Workspace" })

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + LMB/RMB and dragging
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Click + Drag LMB to Move" })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Click + Drag RMB to Resize" })

-- Multimedia keys for volume and LCD brightness
-- (bindel = works on the lockscreen + repeats while held)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),    { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                         { locked = true, repeating = true })

-- Requires playerctl (bindl = works on the lockscreen)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

------------------
--- MISC BINDS ---
------------------

-- The old line `bindd = $mainMod SHIFT, Lock, BACKSPACE, exec, hyprlock` had
-- the key and description swapped (there is no "Lock" key), so it can never
-- have fired. Fixed as mainMod + SHIFT + BACKSPACE:
hl.bind(mainMod .. " + SHIFT + BACKSPACE", hl.dsp.exec_cmd("hyprlock"), { description = "Lock" })

-- DPMS from a keybind is discouraged (can misbehave mid-keypress), so the
-- wiki recommends deferring it with a one-shot timer. This replaces the old
-- `exec, sleep 1 && hyprctl dispatch dpms toggle <monitor>` — passing a Lua
-- function as the dispatcher lets us do it natively.
hl.bind(mainMod .. " + U", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "HDMI-A-5" }))
    end, { timeout = 1000, type = "oneshot" })
end, { description = "Turn Secondary Display Off" })

hl.bind(mainMod .. " + I", function()
    hl.timer(function()
        hl.dispatch(hl.dsp.dpms({ action = "toggle", monitor = "DP-5" }))
    end, { timeout = 1000, type = "oneshot" })
end, { description = "Turn Main Display Off" })

-- Re-apply the SDR (sRGB) profile on DP-5 with VRR on. The old bind shelled
-- out to `hyprctl keyword monitor …`; in Lua we can just call hl.monitor()
-- directly from the bind.
hl.bind(mainMod .. " + O", function()
    hl.monitor({ output = "DP-5", mode = "2560x1440@360", position = "0x0", scale = 1, cm = "srgb", vrr = 1 })
end, { description = "Change Main Display Color" })

-- Disabled: DP-5 is kept permanently in SDR (sRGB 8-bit); this re-enabled HDR 10-bit.
-- hl.bind(mainMod .. " + SHIFT + O", function()
--     hl.monitor({ output = "DP-5", mode = "2560x1440@360", position = "0x0", scale = 1, bitdepth = 10, vrr = 1 })
-- end, { description = "Change Back Main Display Color" })

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("/home/graham/.config/hypr/scripts/scratchWS.py"), { description = "Open Notes" })
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("~/.config/hypr/scripts/shufflewal-dp-5.sh"), { description = "Shuffle Wallpaper" })
hl.bind(mainMod .. " + SPACE", hl.dsp.global("quickshell:notificationCenterToggle"), { description = "Open Notification Center" })
