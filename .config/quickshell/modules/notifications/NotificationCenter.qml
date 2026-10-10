pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Wayland
import qs.modules.common
import qs.services

// Panel in the top-right corner: media players, a header with Do Not Disturb
// and "Clear all", then every notification, newest first. Toggled by the bar's
// bell or the Hyprland bind `global, quickshell:notificationCenterToggle`;
// closes on Escape or a click anywhere else.
PanelWindow {
  id: window

  // Other windows that clicking shouldn't close the panel (the bar, so its
  // bell button can toggle it instead of closing and instantly reopening it).
  property list<QtObject> grabWith: []

  GlobalShortcut {
    name: "notificationCenterToggle"
    description: "Toggle the notification center"
    onPressed: Notifs.centerOpen = !Notifs.centerOpen
  }

  // 0 = closed, 1 = open; the panel slides in from the right edge.
  property real reveal: Notifs.centerOpen ? 1 : 0
  Behavior on reveal {
    NumberAnimation { duration: Theme.notifAnimationDuration; easing.type: Easing.OutCubic }
  }

  // Ticks every minute while open, for the "5m" ages on each card.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
    enabled: Notifs.centerOpen
  }

  anchors { top: true; right: true; bottom: true }
  margins { top: Theme.notifMargin; right: Theme.notifMargin; bottom: Theme.notifMargin }
  exclusionMode: ExclusionMode.Normal
  implicitWidth: Theme.notifWidth
  visible: reveal > 0
  color: "transparent"
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell:notificationCenter"
  WlrLayershell.keyboardFocus: Notifs.centerOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  mask: Region { item: panel }

  HyprlandFocusGrab {
    windows: [ window, ...window.grabWith ]
    active: Notifs.centerOpen
    onCleared: Notifs.centerOpen = false
  }

  Rectangle {
    id: panel
    // Slides right by its own width (plus the margin) as reveal goes 1 -> 0.
    x: (1 - window.reveal) * (width + Theme.notifMargin)
    opacity: window.reveal
    width: parent.width
    // As tall as its content, up to the full height of the window.
    height: Math.min(parent.height, content.implicitHeight + 2 * Theme.notifSpacing)
    radius: Theme.notifRadius
    color: Theme.notifCenterBackground
    border.width: 1
    border.color: Theme.notifBorder

    focus: Notifs.centerOpen
    Keys.onEscapePressed: Notifs.centerOpen = false

    ColumnLayout {
      id: content
      anchors.fill: parent
      anchors.margins: Theme.notifSpacing
      spacing: Theme.notifSpacing

      Repeater {
        model: Mpris.players.values.filter(p => p.canControl)
        delegate: MediaCard {
          required property MprisPlayer modelData
          player: modelData
          Layout.fillWidth: true
        }
      }

      // Header: title, Do Not Disturb switch, Clear all.
      RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        spacing: 8

        Text {
          Layout.fillWidth: true
          text: "Notifications"
          font.pointSize: Theme.fontSizeSmall + 1
          font.weight: 600
          color: Theme.notifText
        }

        Text {
          text: "Do Not Disturb"
          font.pointSize: Theme.fontSizeSmall - 3
          color: Theme.notifSubtext
        }
        Toggle {
          checked: Notifs.dnd
          onToggled: Notifs.dnd = !Notifs.dnd
        }

        Rectangle {
          implicitWidth: clearLabel.implicitWidth + 16
          implicitHeight: 24
          radius: 6
          opacity: Notifs.count > 0 ? 1 : 0.4
          color: clearMouse.containsMouse && Notifs.count > 0 ? Theme.notifButtonHover : Theme.notifButton

          Text {
            id: clearLabel
            anchors.centerIn: parent
            text: "Clear all"
            font.pointSize: Theme.fontSizeSmall - 3
            color: Theme.notifText
          }
          MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Notifs.clearAll()
          }
        }
      }

      ListView {
        id: list
        Layout.fillWidth: true
        // Grow with the cards, then scroll once the panel hits full height.
        Layout.preferredHeight: contentHeight
        Layout.fillHeight: true
        visible: count > 0
        clip: true
        spacing: Theme.notifSpacing
        boundsBehavior: Flickable.StopAtBounds
        model: ScriptModel { values: Notifs.all }

        delegate: NotificationCard {
          required property var modelData
          notification: modelData
          now: clock.date
          width: list.width
          height: implicitHeight
        }

        // Cards slide out to the right when dismissed, and the rest close up.
        remove: Transition {
          NumberAnimation { property: "x"; to: list.width; duration: Theme.notifAnimationDuration; easing.type: Easing.InCubic }
        }
        displaced: Transition {
          NumberAnimation { property: "y"; duration: Theme.notifAnimationDuration; easing.type: Easing.OutCubic }
        }
      }

      Text {
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        visible: Notifs.count === 0
        horizontalAlignment: Text.AlignHCenter
        text: Notifs.dnd ? "No notifications · Do Not Disturb is on" : "No notifications"
        font.pointSize: Theme.fontSizeSmall - 1
        color: Theme.notifSubtext
      }
    }
  }

  // Small on/off switch.
  component Toggle: Rectangle {
    id: toggle
    property bool checked: false
    signal toggled()

    implicitWidth: 36
    implicitHeight: 20
    radius: height / 2
    color: checked ? Theme.notifText : Theme.notifButton
    Behavior on color { ColorAnimation { duration: 120 } }

    Rectangle {
      width: 14
      height: 14
      radius: 7
      y: 3
      x: toggle.checked ? toggle.width - width - 3 : 3
      color: toggle.checked ? "#1c1c1c" : Theme.notifText
      Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
    MouseArea {
      anchors.fill: parent
      onClicked: toggle.toggled()
    }
  }
}
