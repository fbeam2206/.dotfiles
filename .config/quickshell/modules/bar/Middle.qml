import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common.widgets

Pill {
  id: rec
  implicitWidth: container.width

  // Ticks once a minute, on the minute.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  RowLayout {
    id: container
    anchors.centerIn: parent

    TextIcon {
      id: time
      // 12-hour time with leading zero, e.g. "03:42 PM".
      text: Qt.formatDateTime(clock.date, "hh:mm AP")
      rightPadding: rec.radius / Math.PI
      leftPadding: rec.radius / Math.PI
      Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    }
  }
}
