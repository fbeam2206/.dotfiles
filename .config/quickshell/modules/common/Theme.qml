import QtQuick
import Quickshell
pragma Singleton

// Shared bar metrics. Change sizes here, not in individual modules.
Singleton {
  // Space above and below the pills in the reserved bar area.
  // Hyprland's gaps_out adds more below that.
  readonly property int barTopMargin: 7
  readonly property int barBottomMargin: 5
  readonly property int barSideMargin: 5
  // Every Pill is exactly this tall, whatever it contains.
  // 28 fits the tallest content (the 28px ImageIcon).
  readonly property int pillHeight: 28
  // Fill color of every Pill. Names ("lightgray") or "#AARRGGBB" both work.
  readonly property color pillColor: "#e3e3e3"
  // Space reserved for the bar (windows are pushed down by this much).
  readonly property int barHeight: barTopMargin + pillHeight + barBottomMargin
  // font.pointSize for bar text; keep text height under pillHeight.
  readonly property int fontSize: 14
  readonly property int fontSizeSmall: 13
  // How far clickable icons shrink while pressed (1.0 = no squish).
  readonly property real pressScale: 0.8

  // Drop shadow on TextIcon/ImageIcon (MultiEffect).
  readonly property bool iconShadowEnabled: true
  readonly property color iconShadowColor: "#80000000" // ARGB: 80 = 50% opaque black
  readonly property real iconShadowBlur: 0.4           // 0..1
  readonly property real iconShadowOffsetX: 1          // px
  readonly property real iconShadowOffsetY: 1          // px

  // Drop shadow under each Pill, a scaled-down version of the Hyprland
  // window shadow (range 60, offset 0 20, rgba(00000060)).
  readonly property bool pillShadowEnabled: true
  readonly property color pillShadowColor: "#60000000"
  readonly property int pillShadowRadius: 12   // blur size in px
  readonly property int pillShadowOffsetY: 4   // px, straight down like Hyprland's
  // Extra transparent space below the pills so the shadow isn't cut off.
  // The bar window grows by this much, but windows only move by barHeight.
  readonly property int pillShadowRoom: pillShadowEnabled ? pillShadowRadius + pillShadowOffsetY : 0

  // Hover tooltips (Tooltip.qml).
  readonly property int tooltipDelay: 500   // ms of hovering before it shows
  readonly property int tooltipGap: 6       // px between the pill and the tooltip
  readonly property int tooltipPadding: 8   // px of padding around the text

  // Audio popup (AudioPopup.qml), opened by clicking the speaker icon.
  readonly property color popupBackground: pillColor // same fill as the pills
  readonly property color popupText: "black"
  readonly property color popupSubtext: "#505050"   // "Output"/"Input" labels
  readonly property color popupHighlight: "#c4c4c4" // hovered/selected device row
  readonly property int popupWidth: 240
  // Shadow under the whole popup, same as the pill shadow.
  readonly property bool popupShadowEnabled: true
  readonly property color popupShadowColor: "#60000000"
  readonly property int popupShadowRadius: 12   // blur size in px
  readonly property int popupShadowOffsetY: 4   // px, straight down
  // Transparent space around the panel so the shadow isn't cut off.
  readonly property int popupShadowRoom: popupShadowEnabled ? popupShadowRadius + popupShadowOffsetY : 0
  readonly property int popupPadding: 12
  readonly property int audioSliderHeight: 140
  // Filled frame behind each of the output/input sliders and device pickers.
  readonly property color audioFrameColor: "#d4d4d4"
  readonly property int audioFrameRadius: 12
  readonly property int audioFramePadding: 10 // px above/below a slider frame's contents
  // Slight shadow under those frames, like a smaller pill shadow.
  readonly property bool audioFrameShadowEnabled: true
  readonly property color audioFrameShadowColor: "#40000000" // 25% black
  readonly property int audioFrameShadowRadius: 8   // blur size in px
  readonly property int audioFrameShadowOffsetY: 2  // px, straight down
  readonly property int popupAnimationDuration: 180 // ms to open/close the popup and device lists
  readonly property int hoverAnimationDuration: 120  // ms for a row's hover highlight to fade in/out
  // Short names for audio devices: full PipeWire name -> what to show.
  // Devices not listed just lose suffixes like "Analog Stereo" or "Mono".
  readonly property var audioDeviceNames: ({
    "DragonFly Red Analog Stereo": "DragonFly",
    "Elgato Wave XLR Mono": "Elgato Wave",
  })
  // Devices to leave out of the popup's device lists, by PipeWire node name
  // (find them with: wpctl status, or pw-dump | grep node.name).
  readonly property list<string> audioHiddenDevices: [
    "easyeffects_sink",
    "easyeffects_source",
  ]

  // Notifications: pop-ups and the notification center (modules/notifications).
  // Colors match the old swaync theme; "#AARRGGBB", so "b3" = 70% opaque.
  readonly property int notifWidth: 350
  readonly property int notifMargin: 7        // px from the screen edge and the bar
  readonly property int notifSpacing: 8       // px between cards
  readonly property int notifRadius: 10
  readonly property int notifIconSize: 40
  readonly property int notifMaxPopups: 4     // pop-ups on screen at once
  readonly property int notifTimeoutLow: 5        // s a pop-up stays up
  readonly property int notifTimeoutNormal: 10    // s
  readonly property int notifTimeoutCritical: 0   // s; 0 = until dismissed
  readonly property int notifAnimationDuration: 200 // ms
  readonly property color notifCenterBackground: "#b3141414"
  readonly property color notifCardBackground: "#b81c1c1c"
  readonly property color notifCardHover: "#bf262626"
  readonly property color notifBorder: "#1affffff"
  readonly property color notifButton: "#1affffff"
  readonly property color notifButtonHover: "#26ffffff"
  readonly property color notifCloseHover: "#59ff4646"
  readonly property color notifCritical: "#ccff5555"  // border on urgent notifications
  readonly property color notifText: "#f7ffffff"
  readonly property color notifSubtext: "#e0d2d2dc"

  // App launcher (Launcher.qml). Styled after the Walker "dark" theme
  // (~/.config/walker/themes/dark/style.css): a fixed-size box centered on
  // the screen. Font sizes are in px here, like Walker's CSS.
  readonly property int launcherWidth: 600
  readonly property int launcherHeight: 570
  readonly property int launcherPadding: 20      // inside the box
  readonly property int launcherSpacing: 10      // between the search field and the list
  readonly property int launcherRadius: 20       // the box's corners
  readonly property int launcherItemRadius: 10   // search field and row corners
  readonly property int launcherItemPadding: 10  // inside the search field and each row
  readonly property int launcherIconSize: 32
  readonly property int launcherTextSize: 16     // app names
  readonly property int launcherSubtextSize: 12  // app descriptions
  // Launcher colors.
  readonly property color launcherBackground: "#f2141414"       // the box; "f2" = 95% opaque
  readonly property color launcherBorder: "black"               // 1px outline around the box
  readonly property color launcherShadowColor: "#4d000000"      // box shadow, 30% black
  readonly property int launcherShadowRadius: 38                // px of blur
  readonly property int launcherShadowOffsetY: 19               // px, straight down
  readonly property color launcherSearchBackground: "#323232"   // search field fill
  readonly property color launcherText: "white"                 // typed text and app names
  readonly property real launcherSubtextOpacity: 0.5            // descriptions, placeholder, "No Results"
  readonly property color launcherHighlight: "#40000000"        // selected/hovered row, 25% black
  readonly property color launcherIconBadge: "#616161"          // letter badge for apps with no icon
  readonly property color launcherIconBadgeText: "black"        // the letter on that badge
  // Apps to leave out of the launcher (only the launcher; other menus still
  // show them). Use the app's ID: its .desktop filename without ".desktop".
  // Find them with: ls /usr/share/applications ~/.local/share/applications
  readonly property list<string> launcherHiddenApps: [
    // Avahi
    "avahi-discover",                  // Avahi Zeroconf Browser
    "bssh",                            // Avahi SSH Server Browser
    "bvnc",                            // Avahi VNC Server Browser
    // LXQt settings and tools
    "lxqt-about",                      // About LXQt
    "lxqt-admin-time",                 // Date and Time
    "lxqt-admin-user",                 // Users and Groups
    "lxqt-config",                     // LXQt Configuration Center
    "lxqt-config-appearance",          // Appearance
    "lxqt-config-brightness",          // Brightness
    "lxqt-config-file-associations",   // File Associations
    "lxqt-config-globalkeyshortcuts",  // Shortcut Keys
    "lxqt-config-input",               // Keyboard and Mouse
    "lxqt-config-locale",              // Locale
    "lxqt-config-monitor",             // Monitor
    "lxqt-config-notificationd",       // Notifications
    "lxqt-config-powermanagement",     // Power Management
    "lxqt-config-session",             // Session Settings
    "lxqt-leave",                      // Leave
    "pcmanfm-qt-desktop-pref",         // Desktop
    // Octopi helpers (Octopi itself stays)
    "octopi-cachecleaner",             // Octopi CacheCleaner
    "octopi-notifier",                 // Octopi Notifier
    "octopi-repoeditor",               // Octopi Repository Editor
    // Qt
    "qt5ct",                           // Qt5 Settings
    "qterminal",                       // QTerminal
    "qterminal-drop",                  // QTerminal Drop-down
    // Misc
    "lstopo",                          // Hardware Locality lstopo
    "protontricks",                    // Protontricks
    "xgps",                            // xgps
    "xgpsspeed",                       // xgpsspeed
  ]
  // Apps marked "run in terminal" (e.g. htop) open in this.
  readonly property string terminal: "ghostty"
}
