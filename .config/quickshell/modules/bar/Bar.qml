import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

PanelWindow {
  id: bar
  anchors {
    left: true
    right: true
    top: true
  }
  // Taller than the space it reserves, to leave room for the pill shadows.
  implicitHeight: Theme.barHeight + Theme.pillShadowRoom
  exclusiveZone: Theme.barHeight
  color: "transparent"

  // Only the pills take mouse input, so the transparent space around them
  // (including the shadow strip over windows) passes clicks through.
  mask: Region {
    item: leftPill
    Region { item: middlePill }
    Region { item: rightPill }
  }

  // All three pills share one top line and one height (Theme.pillHeight),
  // so they line up regardless of what each one contains.
  Left {
    id: leftPill
    anchors.top: parent.top
    anchors.topMargin: Theme.barTopMargin
    anchors.left: parent.left
    anchors.leftMargin: Theme.barSideMargin
  }
  Middle {
    id: middlePill
    anchors.top: parent.top
    anchors.topMargin: Theme.barTopMargin
    anchors.horizontalCenter: parent.horizontalCenter
  }
  Right {
    id: rightPill
    anchors.top: parent.top
    anchors.topMargin: Theme.barTopMargin
    anchors.right: parent.right
    anchors.rightMargin: Theme.barSideMargin
  }
}
