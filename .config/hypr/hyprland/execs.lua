-------------------------------------------------------------------------------
-- AUTOSTART  (was: hyprland/execs.conf)
--
-- `exec-once` is replaced by running commands on the "hyprland.start" event,
-- which fires exactly once when Hyprland starts (NOT on config reloads — so
-- this behaves like exec-once, not exec).
--
--   hl.on(event, fn)  registers a callback for an event
--   hl.exec_cmd(cmd)  spawns a process asynchronously via `sh -c`
--                     (no need for `& disown`; `&&`, `&`, `~` etc. all work)
--
-- Docs: https://wiki.hypr.land/Configuring/Basics/Autostart/
-------------------------------------------------------------------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle & swaync")
    hl.exec_cmd("waypaper --restore")
    -- hl.exec_cmd("swaybg -o DP-5 -i /home/graham/Pictures/Wallpapers/slideshow//a_group_of_dark_leaves.jpg & swaybg -o HDMI-A-5 -i /home/graham/Pictures/Wallpapers/slideshow//178385.png")

    hl.exec_cmd("mullvad-vpn")
    hl.exec_cmd("elephant")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("xrdb -merge ~/.Xresources")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hyprctl setcursor McMojaveCursor 40")
    -- No hyprpm plugins are in use, so `hyprpm reload -n` is gone: with every
    -- plugin disabled it only ever fired the "plugins failed to load / out of
    -- date" notification at login. Re-add it here if you ever enable one.

    hl.exec_cmd("wlsunset -l 33.5 -L -86.8 -T 6500 -t 3800")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("mullvad-exclude steam -silent -nochatui -nofriendsui")
    hl.exec_cmd("wayscriber --daemon")
end)
