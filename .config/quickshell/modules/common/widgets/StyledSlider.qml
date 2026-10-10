import QtQuick
import QtQuick.Controls

// Thin rounded track with a dark fill up to the value and a round white handle.
// Works horizontally (the default) or with `orientation: Qt.Vertical`, where
// the fill grows up from the bottom. `thickness` is the track's width.
Slider {
  id: slide

  property color trackColor: "#9e9e9e"
  property color fillColor: "#1a1a1a"
  property int handleSize: 16
  property int thickness: 4

  hoverEnabled: true

  background: Rectangle {
    x: slide.leftPadding + (slide.vertical ? (slide.availableWidth - width) / 2 : 0)
    y: slide.topPadding + (slide.vertical ? 0 : (slide.availableHeight - height) / 2)
    implicitWidth: slide.vertical ? slide.thickness : 140
    implicitHeight: slide.vertical ? 140 : slide.thickness
    width: slide.vertical ? slide.thickness : slide.availableWidth
    height: slide.vertical ? slide.availableHeight : slide.thickness
    radius: slide.thickness / 2
    color: slide.trackColor

    Rectangle {
      // visualPosition runs top-to-bottom on a vertical slider, so use
      // position (bottom-to-top) for the fill's height there.
      width: slide.vertical ? parent.width : slide.visualPosition * parent.width
      height: slide.vertical ? slide.position * parent.height : parent.height
      y: slide.vertical ? parent.height - height : 0
      radius: parent.radius
      color: slide.fillColor
    }
  }

  handle: Rectangle {
    implicitWidth: slide.handleSize
    implicitHeight: slide.handleSize
    radius: width / 2
    color: slide.pressed ? "#f0f0f0" : "#f6f6f6"
    border.color: "#bdbebf"
    x: slide.leftPadding + (slide.vertical
        ? (slide.availableWidth - width) / 2
        : slide.visualPosition * (slide.availableWidth - width))
    y: slide.topPadding + (slide.vertical
        ? slide.visualPosition * (slide.availableHeight - height)
        : (slide.availableHeight - height) / 2)
  }
}
