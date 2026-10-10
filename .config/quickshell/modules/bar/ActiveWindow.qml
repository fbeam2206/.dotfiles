import QtQuick
import Quickshell.Hyprland
import qs.modules.common.widgets

TextIcon {
  readonly property var activeWin: Hyprland.toplevels.values.find(a => a.activated)
  // initialTitle is only exposed through the IPC object, which is filled in by refreshToplevels()
  readonly property var winTitle: activeWin?.lastIpcObject?.initialTitle || activeWin?.title || ""

  text: winTitle
  // Hidden items are skipped by layouts, so an empty title takes up no space
  visible: winTitle !== ""

  onActiveWinChanged: Hyprland.refreshToplevels()
}
