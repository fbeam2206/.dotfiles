import QtQuick
import QtQuick.Layouts
import qs.modules.common

Text {
  font.pointSize: Theme.fontSize
  font.styleName: "Bold"
  color: "black"
  Layout.preferredWidth: this.width
  Layout.alignment: Qt.AlignHCenter

  // Clickable icons bind this to their MouseArea/TapHandler's pressed,
  // e.g. `pressed: ma.pressed`, to get the squish animation.
  property bool pressed: false

  // scale is a paint-only transform, so squishing doesn't move neighbors.
  scale: pressed ? Theme.pressScale : 1.0
  Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

  layer.enabled: Theme.iconShadowEnabled
  layer.effect: IconShadow {}
}
