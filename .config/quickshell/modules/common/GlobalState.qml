import QtQuick
import Quickshell
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
  id: state
  property bool barOpen: true
  property bool sysTrayOpen: true

  // Emit to open/close the app launcher from anywhere (e.g. the start button).
  signal launcherToggleRequested()
}
