-------------------------------------------------------------------------------
-- WINDOW / WORKSPACE / LAYER RULES  (was: hyprland/rules.conf)
--
-- hl.window_rule({ ... }) replaces windowrule { }. Inside the table:
--   name  = "..."   optional label. Only needed if you want to toggle the
--                   rule at runtime (hl.window_rule() returns a handle with
--                   :set_enabled(true/false)). The old numbered names
--                   (windowrule-0, -1, ...) were replaced with descriptive
--                   ones; nothing references them, so this is safe.
--   match = { ... } the conditions (was match:class = ..., etc.).
--                   ALL conditions must match. Values are RegEx strings.
--   everything else = the effects to apply. Old on/off become true/false,
--                   "size = W H" becomes size = { W, H }, etc.
--
-- ORDER MATTERS: rules are evaluated top to bottom, last match wins.
-- One quirk carried over from upstream: all NAMED rules are evaluated before
-- all anonymous ones — every rule here is named, so order is preserved as-is.
--
-- Docs: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--       https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-------------------------------------------------------------------------------

--------------------------------
--- WINDOWS AND WORKSPACES  ----
--------------------------------

hl.window_rule({
    name  = "myapp-float",
    match = { title = "^(MyApp)(.*)$" },
    float = true,
})

-- Pause Hypridle when an app is fullscreen; also ignore maximize requests
-- from apps. You'll probably like this.
hl.window_rule({
    name  = "idle-inhibit-fullscreen",
    match = { class = ".*" },
    idle_inhibit   = "fullscreen",
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland (was already commented out):
-- hl.window_rule({
--     name  = "fix-xwayland-drags",
--     match = { class = "^$", title = "^$", xwayland = true, float = true,
--               fullscreen = false, pin = false },
--     no_focus = true,
-- })

--- STEAM ---

hl.window_rule({
    name      = "steam-workspace-3",
    match     = { class = "^(steam)$" },
    workspace = "3",
})

-- Float the Steam Friends List…
hl.window_rule({
    name  = "steam-friends-float",
    match = { title = "^(Friends List)(.*)$" },
    float = true,
})

-- …and give it a fixed size without stealing focus
hl.window_rule({
    name             = "steam-friends-size",
    match            = { title = "^(Friends List)(.*)$" },
    size             = { 350, 800 },
    no_initial_focus = true,
})

hl.window_rule({
    name             = "steam-launching-nofocus",
    match            = { title = "^(Launching...)(.*)$" },
    no_initial_focus = true,
})

-- Games open on regular workspace 1: a special workspace blocks Hyprland's
-- solitary/direct-scanout path (SPECIAL/WORKSPACES blockers). content = game
-- tags the surface so render.direct_scanout = 2 (auto) considers it
-- (XWayland clients cannot tag themselves).
hl.window_rule({
    name       = "steam-games",
    match      = { class = "^(steam_app_)(.*)$" },
    monitor    = "DP-5",
    workspace  = "1",
    tile       = true,
    fullscreen = true,
    immediate  = true, -- allow tearing
    no_anim    = true,
    content    = "game",
})

hl.window_rule({
    name       = "cs2-game",
    match      = { class = "^(cs2)(.*)$" },
    monitor    = "DP-5",
    workspace  = "1",
    tile       = true,
    fullscreen = true,
    immediate  = true,
    no_anim    = true,
    content    = "game",
})

--- MISC APPS ---

-- Float CoreCtrl
hl.window_rule({
    name  = "corectrl-float",
    match = { class = "^(org.corectrl.CoreCtrl)$" },
    float = true,
})

-- KeePassXC
hl.window_rule({
    name  = "keepassxc-float",
    match = { class = "^(org.keepassxc.KeePassXC)$" },
    float = true,
})

-- Audio mixer (pavucontrol): float, size, center
hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    float = true,
})

hl.window_rule({
    name  = "pavucontrol-size",
    match = { class = "^(org.pulseaudio.pavucontrol)$" },
    size  = { 900, 700 },
})

hl.window_rule({
    name   = "pavucontrol-center",
    match  = { class = "^(org.pulseaudio.pavucontrol)$" },
    center = true,
})

-- Easy Effects: float, size, center
hl.window_rule({
    name  = "easyeffects-float",
    match = { title = "^(Easy Effects)$" },
    float = true,
})

hl.window_rule({
    name  = "easyeffects-size",
    match = { title = "^(Easy Effects)$" },
    size  = { 1000, 700 },
})

hl.window_rule({
    name   = "easyeffects-center",
    match  = { title = "^(Easy Effects)$" },
    center = true,
})

-- Trilium → scratch special workspace
-- move expressions: each coordinate is its own string; the old
-- ((monitor_w*0.05)) double-parens aren't needed anymore
hl.window_rule({
    name             = "trilium-scratchpad",
    match            = { class = "^(trilium)(.*)$" },
    float            = true,
    size             = { 1200, 800 },
    workspace        = "special:scratch",
    move             = { "monitor_w*0.05", "monitor_h*0.05" },
    no_initial_focus = true,
})

-- Obsidian → scratch special workspace
hl.window_rule({
    name             = "obsidian",
    match            = { class = "^(obsidian)(.*)$" },
    float            = true,
    size             = { 1200, 800 },
    workspace        = "special:scratch",
    move             = { "monitor_w*0.05", "monitor_h*0.05" },
    no_initial_focus = true,
})

--- DISCORD ---

hl.window_rule({
    name              = "discord-popout",
    match             = { initial_title = "^(Discord Popout)(.*)$" },
    size              = { 1400, 800 },
    float             = true,
    keep_aspect_ratio = true,
})

-- NOTE: "discrod" is a typo carried over from the old config (the two rules
-- also shared the name windowrule-18 there). It likely never matches; change
-- to "discord" if this sizing rule was meant to work.
hl.window_rule({
    name              = "discord-sidebar",
    match             = { initial_title = "^(discrod)(.*)$" },
    size              = { 324, 1060 },
    keep_aspect_ratio = false,
})

hl.window_rule({
    name      = "discord-workspace-2",
    match     = { class = "^(discord)$" },
    workspace = "2",
})

hl.window_rule({
    name              = "vesktop-popout",
    match             = { initial_title = "^(vesktop)(.*)$" },
    size              = { 1400, 800 },
    keep_aspect_ratio = true,
})

hl.window_rule({
    name      = "vesktop-workspace-2",
    match     = { class = "^(vesktop)$" },
    workspace = "2",
})

--- FIREFOX ---

hl.window_rule({
    name              = "firefox-pip",
    match             = { initial_title = "^(Picture-in-Picture)(.*)$" },
    float             = true,
    pin               = true, -- visible on all workspaces
    size              = { 1400, 800 },
    keep_aspect_ratio = true,
    opaque            = true,
    border_size       = 0,
})

hl.window_rule({
    name  = "floorp-size",
    match = { initial_title = "^(Ablaze Floorp)(.*)$" },
    size  = { 1200, 800 },
})

--- TERMINALS ---

hl.window_rule({
    name  = "kitty-float",
    match = { initial_title = "^(kitty)(.*)$" },
    float = true,
    size  = { 1200, 800 },
})

hl.window_rule({
    name   = "alacritty-float",
    match  = { initial_title = "^(Alacritty)(.*)$" },
    float  = true,
    size   = { 1200, 800 },
    center = true,
})

hl.window_rule({
    name   = "ghostty-float",
    match  = { initial_title = "^(Ghostty)(.*)$" },
    float  = true,
    size   = { 1200, 800 },
    center = true,
})

--- NAUTILUS ---

hl.window_rule({
    name  = "nautilus-float",
    match = { class = "^(org.gnome.Nautilus)(.*)$" },
    float = true,
    size  = { 950, 600 },
})

--- ALBERT ---

hl.window_rule({
    name  = "albert-settings-float",
    match = { initial_title = "^(Settings — Albert)(.*)$" },
    float = true,
    size  = { 800, 600 },
})

--- STICKY NOTES ---

hl.window_rule({
    name  = "sticky-notes-float",
    match = { initial_title = "^(Sticky Notes)(.*)$" },
    float = true,
    size  = { 360, 500 },
})

hl.window_rule({
    name      = "sticky-notes-workspace-3",
    match     = { initial_class = "^(com.vixalien.sticky)$" },
    workspace = "3",
})

hl.window_rule({
    name             = "sticky-notes-nofocus",
    match            = { initial_class = "^(com.vixalien.sticky)(.*)$" },
    no_initial_focus = true,
})

--- GPARTED ---

hl.window_rule({
    name  = "gparted-float",
    match = { initial_title = "^(GParted)(.*)$" },
    float = true,
    size  = { 1200, 800 },
})

--- WAYPAPER ---

hl.window_rule({
    name  = "waypaper-float",
    match = { title = "^(Waypaper)$" },
    float = true,
    size  = { 785, 1000 },
})

-----------------------
--- WORKSPACE RULES ---
-----------------------
-- Was: workspace = 1, monitor:DP-5, default:true  (etc.)
-- The per-workspace lines (monitor/gaps/persistent) are merged into one
-- hl.workspace_rule() call per workspace — same effect, less repetition.

hl.workspace_rule({ workspace = "1", monitor = "DP-5",     default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-5", gaps_out = 10, gaps_in = 5, persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-5", gaps_out = 10, gaps_in = 5 })

-- Strip all eye candy from windows on the special:game workspace
hl.window_rule({
    name     = "game-ws-norounding",
    match    = { workspace = "special:game" },
    rounding = 0,
})

hl.window_rule({
    name    = "game-noblur",
    match   = { workspace = "special:game" },
    no_blur = true,
})

hl.window_rule({
    name      = "game-noshadow",
    match     = { workspace = "special:game" },
    no_shadow = true,
})

hl.window_rule({
    name    = "game-noanim",
    match   = { workspace = "special:game" },
    no_anim = true,
})

hl.window_rule({
    name   = "game-nodim",
    match  = { workspace = "special:game" },
    no_dim = true,
})

hl.window_rule({
    name   = "game-opaque",
    match  = { workspace = "special:game" },
    opaque = true,
})

-- Carried over verbatim: bare "scratch" is probably not a valid workspace
-- matcher (the scratchpad lives on "special:scratch"), so this rule likely
-- never matched in the old config either. Kept for fidelity — change the
-- match to "special:scratch" if you want every window there floated.
hl.window_rule({
    name  = "scratch-float",
    match = { workspace = "scratch" },
    float = true,
})

--- DIALOG WINDOWS — float + center these ---

hl.window_rule({
    name   = "dialog-open-file",
    match  = { title = "^(Open File)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-select-file",
    match  = { title = "^(Select a File)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-choose-wallpaper",
    match  = { title = "^(Choose wallpaper)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-open-folder",
    match  = { title = "^(Open Folder)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-save-as",
    match  = { title = "^(Save As)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-library",
    match  = { title = "^(Library)(.*)$" },
    center = true,
    float  = true,
})

hl.window_rule({
    name   = "dialog-file-upload",
    match  = { title = "^(File Upload)(.*)$" },
    center = true,
    float  = true,
})

-- Float anything whose initial class starts with "com."
hl.window_rule({
    name  = "com-apps-float",
    match = { initial_class = "^(com.)(.*)$" },
    float = true,
})

-------------------
--- LAYER RULES ---
-------------------
-- Same idea as window rules, but for layer surfaces (bars, launchers,
-- notifications, …). Matching is by namespace — check `hyprctl layers`.

hl.layer_rule({
    name         = "qs-notification-center-blur",
    match        = { namespace = "quickshell:notificationCenter" },
    blur         = true,
    ignore_alpha = 0.5, -- don't blur pixels more transparent than this
})

hl.layer_rule({
    name         = "qs-notification-popups-blur",
    match        = { namespace = "quickshell:notifications" },
    blur         = true,
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name  = "syspower-blur",
    match = { namespace = "^(syspower)(.*)$" },
    blur  = true,
})

hl.layer_rule({
    name         = "waybar-ignore-alpha",
    match        = { namespace = "^(waybar)(.*)$" },
    ignore_alpha = 0,
})

-- Chromium: keep it tiled and unblurred
hl.window_rule({
    name    = "chromium-noblur",
    match   = { class = "^(Chromium)(.*)$" },
    no_blur = true,
    tile    = true,
})
