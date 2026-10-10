import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets

Pill {
  id: rec
  implicitWidth: container.implicitWidth

  RowLayout {
    id: container
    anchors.centerIn: parent

    Volume { id: volume }

    Notifications { id: notifications }

    Tray { id: systray }
  }
}
