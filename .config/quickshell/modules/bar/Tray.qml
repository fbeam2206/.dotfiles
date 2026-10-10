import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.modules.common.widgets
pragma ComponentBehavior: Bound

Rectangle {
  id: root
  radius: 30
  color: "transparent"
  implicitWidth:  list.width + icon.width + icon.rightPadding
  implicitHeight: list.height

  property int spacing: 8
  property int iconCount: trayRepeater.count
  property int trayWidth: iconCount * 28 + 3
  // True while a tray icon's right-click menu is showing. The menu is its
  // own window, so moving into it ends trayHover; this keeps the tray open
  // (and the menu's anchor icon on screen) until the menu closes.
  property bool menuOpen: false

  // A HoverHandler on the tray itself, not a MouseArea: it stays hovered
  // while the pointer is over the tray icons (which have their own
  // HoverHandlers for tooltips). A MouseArea loses hover to them, which
  // made the tray close again partway through opening.
  HoverHandler {
    id: trayHover
  }

  states: State {
    name: "open"
    when: trayHover.hovered || root.menuOpen
    PropertyChanges {
      list.visible: true
      list.width: trayWidth

      trayLayout.width: icon.width + trayWidth
      trayRepeater.Layout.preferredWidth: trayWidth

      root.implicitWidth:  list.width + icon.width + icon.rightPadding + trayPadding.width
    }
  }


  transitions:
    Transition {
      NumberAnimation {
        properties: "width, implicitWidth"
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

  RowLayout {
    id: trayLayout
    width: icon.width

    TextIcon {
      id: icon
      text: ""
      rightPadding: 3
      Layout.alignment: Qt.AlignVCenter
      // Nudge the glyph left without changing the tray's layout/width.
      transform: Translate { x: -2 }
    }

    Rectangle {
      id: trayBackground
      Layout.preferredWidth: list.width
      Layout.alignment: Qt.AlignVCenter
      Layout.preferredHeight: list.height

      radius: height / 2
      color: "transparent"

      layer.enabled: width > 0
      layer.effect: InnerShadow {
        color: "#cc000000"      // ARGB: cc = 80% opaque black
        radius: 8               // blur distance in px, i.e. how far inward it fades
        samples: 17
        spread: 0.1             // 0 = soft falloff, 1 = hard band
        horizontalOffset: 0
        verticalOffset: 0       // nonzero offsets fake a light direction
      }

      RowLayout {
        id: list
        height: icon.height
        width: 0
        visible: false
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: 0
        

        Repeater {
          id: trayRepeater
          model: SystemTray.items
          
          delegate: Item {
            id: trayIcon
            required property SystemTrayItem modelData

            width: 22
            height: 22

            ImageIcon {
              anchors.fill: parent
              source: trayIcon.modelData.icon
              sourceSize.width: 22
              sourceSize.height: 22
              pressed: itemMouse.pressed
            }

            QsMenuAnchor {
              id: menuAnchor
              menu: trayIcon.modelData.menu
              anchor.item: trayIcon
              anchor.edges: Edges.Bottom            // flip to Edges.Top for a bottom bar
              anchor.gravity: Edges.Bottom | Edges.Right
              onVisibleChanged: root.menuOpen = visible
            }

            // If the app quits while its menu is open, closed may never fire.
            Component.onDestruction: if (menuAnchor.visible) root.menuOpen = false

            HoverHandler { id: itemHover }

            // The app's own tooltip if it has one, otherwise its name.
            Tooltip {
              target: trayIcon
              hovered: itemHover.hovered
              text: {
                const item = trayIcon.modelData
                const title = item.tooltipTitle || item.title || item.id
                return item.tooltipDescription ? title + "\n" + item.tooltipDescription : title
              }
            }

            MouseArea {
              id: itemMouse
              anchors.fill: parent
              acceptedButtons: Qt.LeftButton | Qt.RightButton
              // Left: the app's main action (usually show/hide its window),
              // or its menu if that's all it offers. Right: its menu, or its
              // secondary action if it has no menu.
              onClicked: (mouse) => {
                const item = trayIcon.modelData
                if (mouse.button === Qt.LeftButton) {
                  if (item.onlyMenu && item.hasMenu)
                    menuAnchor.open()
                  else
                    item.activate()
                } else if (mouse.button === Qt.RightButton) {
                  if (item.hasMenu)
                    menuAnchor.open()
                  else
                    item.secondaryActivate()
                }
              }
            }
          }
        }
      }
    }

    Rectangle {
      id: trayPadding
      Layout.preferredWidth: 3
      color: "transparent"
    }
  }
}

