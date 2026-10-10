import QtQuick
import QtQuick.Effects
import qs.modules.common

Rectangle{
  id: back
  color: Theme.pillColor
  radius: 30
  // Explicit height, not implicitHeight: an explicit height wins over any
  // implicitHeight a module sets, so all pills stay the same height.
  // Modules should center their content vertically inside it.
  height: Theme.pillHeight

  // Floating shadow, like Hyprland windows. Needs Theme.pillShadowRoom of
  // space below the pill in the bar window, or the bottom gets cut off.
  layer.enabled: Theme.pillShadowEnabled
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowColor: Theme.pillShadowColor
    blurMax: Theme.pillShadowRadius
    shadowBlur: 1.0
    shadowHorizontalOffset: 0
    shadowVerticalOffset: Theme.pillShadowOffsetY
    autoPaddingEnabled: true
  }
}
