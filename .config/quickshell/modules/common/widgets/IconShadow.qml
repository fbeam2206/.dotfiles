import QtQuick
import QtQuick.Effects
import qs.modules.common

// The shared drop shadow for bar icons and text, configured in Theme.qml.
// Use as:  layer.enabled: Theme.iconShadowEnabled
//          layer.effect: IconShadow {}
MultiEffect {
  shadowEnabled: true
  shadowColor: Theme.iconShadowColor
  shadowBlur: Theme.iconShadowBlur
  shadowHorizontalOffset: Theme.iconShadowOffsetX
  shadowVerticalOffset: Theme.iconShadowOffsetY
  autoPaddingEnabled: true // room around the item so the shadow isn't clipped
}
