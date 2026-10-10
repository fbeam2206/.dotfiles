import QtQuick
import QtQuick.Layouts
import qs.modules.common

Image {
  sourceSize.width: 28
  sourceSize.height: 28
  Layout.alignment: Qt.AlignHCenter

  // Same squish-on-press as TextIcon; bind to a MouseArea/TapHandler's pressed.
  property bool pressed: false

  scale: pressed ? Theme.pressScale : 1.0
  Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }

  layer.enabled: Theme.iconShadowEnabled
  layer.effect: IconShadow {}
}
