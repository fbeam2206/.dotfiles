import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets

Pill {
  id: rec
  implicitWidth: container.width

  Process {
    id: openWalker 
    command: ["sh", "-c", "~/.config/walker/menus/menu.sh"]
    running: false
  }

  RowLayout {
    id: container
    anchors.centerIn: parent

    TextIcon {
      id: start
      text: ""
      leftPadding: rec.radius / Math.PI
      // The glyph's ink isn't centered in its advance width, so when it's alone
      // offset the right padding by the side-bearing difference to make the
      // visible gap on the right match the left.
      rightPadding: activeWindow.visible ? 0
        : leftPadding + startMetrics.tightBoundingRect.x
          - (startMetrics.advanceWidth - startMetrics.tightBoundingRect.x - startMetrics.tightBoundingRect.width)
      TextMetrics {
        id: startMetrics
        font: start.font
        text: start.text
      }
      pressed: startMouse.pressed
      // Left-click: app launcher. Right-click: the walker system menu.
      MouseArea {
        id: startMouse
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
          if (mouse.button === Qt.RightButton)
            openWalker.running = !openWalker.running
          else
            GlobalState.launcherToggleRequested()
        }
      }
    }
    ActiveWindow{
      id: activeWindow
      rightPadding: rec.radius / Math.PI
    }
  }
}
