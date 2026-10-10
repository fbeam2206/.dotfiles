pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.services

// New notifications, stacked in the top-right corner under the bar. Each one
// slides in, closes itself after Notifs.timeoutFor() (paused while hovered),
// and stays in the notification center afterwards.
PanelWindow {
  id: window

  anchors { top: true; right: true }
  // Below the bar: the bar's exclusive zone already pushes us down.
  margins { top: Theme.notifMargin; right: Theme.notifMargin }
  implicitWidth: Theme.notifWidth
  implicitHeight: Math.max(1, stack.implicitHeight)
  visible: Notifs.popups.length > 0
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell:notifications"
  // Only the cards take clicks; the rest of the window lets them through.
  mask: Region { item: stack }

  Column {
    id: stack
    width: parent.width
    spacing: Theme.notifSpacing

    Repeater {
      // ScriptModel keeps existing cards (and their timers) when the list
      // changes, instead of rebuilding them all.
      model: ScriptModel { values: Notifs.popups.slice(0, Theme.notifMaxPopups) }

      delegate: Item {
        id: slot
        required property var modelData
        width: stack.width
        height: card.implicitHeight

        NotificationCard {
          id: card
          notification: slot.modelData
          popup: true
          width: parent.width
          height: parent.height
          onCloseRequested: Notifs.hidePopup(slot.modelData)

          // Slide in from the right edge once, when it first appears.
          NumberAnimation on x {
            from: Theme.notifWidth
            to: 0
            duration: Theme.notifAnimationDuration
            easing.type: Easing.OutCubic
          }
        }

        Timer {
          interval: Notifs.timeoutFor(slot.modelData)
          running: interval > 0 && !card.hovered
          onTriggered: Notifs.popupTimedOut(slot.modelData)
        }
      }
    }
  }
}
