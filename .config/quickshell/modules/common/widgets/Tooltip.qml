import QtQuick
import Quickshell
import qs.modules.common

// Hover tooltip shown below a bar item. It's its own popup window, so the
// bar window's height doesn't clip it. Usage:
//   HoverHandler { id: hover }
//   Tooltip { target: someItem; hovered: hover.hovered; text: "..." }
PopupWindow {
  id: tip
  required property Item target
  property bool hovered: false
  property string text: ""

  // Only appear after hovering for Theme.tooltipDelay ms; hide right away.
  property bool shown: false
  onHoveredChanged: {
    if (hovered) {
      delay.restart()
    } else {
      delay.stop()
      shown = false
    }
  }
  Timer {
    id: delay
    interval: Theme.tooltipDelay
    onTriggered: tip.shown = true
  }

  visible: shown && text !== ""

  anchor.item: target
  anchor.edges: Edges.Bottom
  anchor.gravity: Edges.Bottom
  // Negative margin extends the anchor down past the bottom of the pill,
  // so the tooltip sits Theme.tooltipGap below the pill, not the item.
  anchor.margins.bottom: -((Theme.pillHeight - target.height) / 2 + Theme.tooltipGap)

  color: "transparent"
  implicitWidth: label.implicitWidth + 2 * Theme.tooltipPadding
  implicitHeight: label.implicitHeight + Theme.tooltipPadding

  Rectangle {
    anchors.fill: parent
    radius: Math.min(height / 2, 12)
    color: "lightgray"

    Text {
      id: label
      anchors.centerIn: parent
      text: tip.text
      horizontalAlignment: Text.AlignHCenter
      font.pointSize: Theme.fontSizeSmall
      color: "black"
    }
  }
}
