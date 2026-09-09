-------------------------------------------------------------------------------
-- ENVIRONMENT VARIABLES  (was: hyprland/env.conf)
--
-- hl.env(NAME, VALUE) replaces `env = NAME,VALUE`. Both arguments are
-- strings. These are set before the display server initializes.
--
-- NOTE: since this session is managed by uwsm (the logout bind runs
-- `uwsm stop`), the wiki recommends putting env vars in ~/.config/uwsm/env
-- (format: `export KEY=VAL`) instead of the Hyprland config. They're kept
-- here for a faithful conversion — they lived in the Hyprland config before,
-- too. See: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
-------------------------------------------------------------------------------

hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("QT_STYLE_OVERRIDE", "kvantum-dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("GDK_BACKEND", "wayland,x11,*")

hl.env("STEAM_USE_WAYLAND", "1")
hl.env("HYPRCURSOR_THEME", "McMojaveCursor")
hl.env("HYPRCURSOR_SIZE", "40")
-- GTK_THEME left unset on purpose: it forces the named theme onto libadwaita
-- (GTK4) apps, where WhiteSur's gtk-4.0/gtk.css -- a stub that only imports
-- resource:///org/gnome/theme/gtk.css -- fails to resolve, leaving an empty
-- stylesheet and unstyled, see-through popover menus (e.g. Ghostty's right-
-- click menu). gtk-theme-name in ~/.config/gtk-{3,4}.0/settings.ini already
-- themes GTK3 and non-libadwaita GTK4 apps. Nautilus alone gets GTK_THEME
-- per-app instead: keybinds.lua (Alt+E), ~/.local/share/applications/
-- org.gnome.Nautilus.desktop and ~/.local/share/dbus-1/services/*.service.
-- hl.env("GTK_THEME", "WhiteSur-Dark-solid-grey")
-- hl.env("GTK_THEME", "Mojave-Dark")
hl.env("XCURSOR_THEME", "McMojave-Cursors-32")
hl.env("XCURSOR_SIZE", "40")
