import QtQuick
import qs.modules.common.widgets
import qs.services

// Notification center button. Left-click opens the center, right-click
// toggles Do Not Disturb. Same icons as the old swaync/waybar button: one
// glyph when there are notifications, another for none or Do Not Disturb.
TextIcon {
  id: root

  // The volume SVG has built-in whitespace on its right; this matches it
  // so the gap to the tray icon looks the same as the gap to the speaker.
  rightPadding: 5

  // Nerd Font glyphs U+F03C (has notifications) and U+F039 (none / DND).
  text: Notifs.count > 0 && !Notifs.dnd ? "\uf03c" : "\uf039"

  pressed: mouse.pressed

  HoverHandler { id: hover }

  Tooltip {
    target: root
    hovered: hover.hovered && !Notifs.centerOpen
    text: (Notifs.count === 0 ? "No notifications"
          : Notifs.count === 1 ? "1 Notification"
          : Notifs.count + " Notifications")
        + (Notifs.dnd ? "\nDo Not Disturb" : "")
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
      if (mouse.button === Qt.LeftButton)
        Notifs.centerOpen = !Notifs.centerOpen
      else
        Notifs.dnd = !Notifs.dnd
    }
  }
}
