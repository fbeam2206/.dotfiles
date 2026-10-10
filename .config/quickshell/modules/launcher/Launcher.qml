import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import "../common/functions/fuzzy.js" as Fuzzy
import qs.modules.common

// App launcher: type to fuzzy-search installed apps, Up/Down (or Tab) to pick,
// Enter to launch, Escape or a click outside to close.
// Toggled by the Hyprland bind `global, quickshell:launcherToggle`.
PanelWindow {
  id: launcher

  property bool open: false

  function toggle() {
    if (open) {
      open = false
      return
    }
    // Open on whichever monitor has focus right now.
    screen = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? screen
    open = true
    // Start fresh: empty search, top row selected, scrolled to the top.
    // Done after showing, since a hidden ListView may ignore the reposition,
    // and clearing the text alone doesn't reset these if it was already empty.
    search.text = ""
    hoverPos = null
    list.currentIndex = 0
    list.positionViewAtBeginning()
  }

  // Last mouse position seen over the rows, in window coordinates.
  // Rows only take the selection when the mouse has really moved: a row
  // appearing under a still cursor (on opening, or when arrowing scrolls the
  // list) would otherwise steal the selection.
  property var hoverPos: null
  function hoverRow(index, item, x, y) {
    const p = item.mapToItem(null, x, y)
    if (hoverPos !== null && (p.x !== hoverPos.x || p.y !== hoverPos.y))
      list.currentIndex = index
    hoverPos = p
  }

  function launch(entry) {
    if (!entry)
      return
    // DesktopEntry.execute() ignores Terminal=true, so wrap those ourselves.
    if (entry.runInTerminal)
      Quickshell.execDetached([Theme.terminal, "-e", ...entry.command])
    else
      entry.execute()
    open = false
  }

  GlobalShortcut {
    name: "launcherToggle"
    description: "Toggle the app launcher"
    onPressed: launcher.toggle()
  }

  Connections {
    target: GlobalState
    function onLauncherToggleRequested() { launcher.toggle() }
  }

  visible: open
  color: "transparent"
  // Cover the whole screen so a click anywhere outside the box closes it.
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "quickshell:launcher"
  WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

  readonly property var apps: [...DesktopEntries.applications.values]
      .filter(a => !a.noDisplay && !Theme.launcherHiddenApps.includes(a.id))
      .sort((a, b) => a.name.localeCompare(b.name))

  readonly property var results: search.text.trim() === ""
      ? apps
      : Fuzzy.filter(search.text, apps, a => [a.name, a.genericName, ...a.keywords])

  MouseArea {
    anchors.fill: parent
    onClicked: launcher.open = false
  }

  Rectangle {
    id: box
    anchors.centerIn: parent
    width: Theme.launcherWidth
    height: Theme.launcherHeight
    radius: Theme.launcherRadius
    color: Theme.launcherBackground
    border.color: Theme.launcherBorder

    // Big soft shadow, like Walker's box-shadow.
    layer.enabled: true
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: Theme.launcherShadowColor
      blurMax: Theme.launcherShadowRadius
      shadowBlur: 1.0
      shadowVerticalOffset: Theme.launcherShadowOffsetY
      autoPaddingEnabled: true
    }

    // Swallow clicks inside the box so they don't reach the close-on-click area.
    MouseArea { anchors.fill: parent }

    Column {
      id: column
      anchors.fill: parent
      anchors.margins: Theme.launcherPadding
      spacing: Theme.launcherSpacing

      TextField {
        id: search
        width: parent.width
        placeholderText: "Search..."
        font.pointSize: Theme.fontSize
        color: Theme.launcherText
        placeholderTextColor: Qt.alpha(Theme.launcherText, Theme.launcherSubtextOpacity)
        padding: Theme.launcherItemPadding
        // Grab the keyboard each time the launcher opens.
        focus: launcher.open
        onTextChanged: list.currentIndex = 0

        background: Rectangle {
          radius: Theme.launcherItemRadius
          color: Theme.launcherSearchBackground
        }

        Keys.onPressed: (event) => {
          switch (event.key) {
          case Qt.Key_Down:
          case Qt.Key_Tab:
            list.incrementCurrentIndex()
            break
          case Qt.Key_Up:
          case Qt.Key_Backtab:
            list.decrementCurrentIndex()
            break
          case Qt.Key_Return:
          case Qt.Key_Enter:
            launcher.launch(launcher.results[list.currentIndex])
            break
          case Qt.Key_Escape:
            launcher.open = false
            break
          default:
            return
          }
          event.accepted = true
        }
      }

      ListView {
        id: list
        width: parent.width
        // Fill the rest of the fixed-size box.
        height: column.height - search.height - column.spacing
        visible: count > 0
        clip: true
        model: launcher.results
        keyNavigationWraps: true
        highlightMoveDuration: 0
        boundsBehavior: Flickable.StopAtBounds

        highlight: Rectangle {
          radius: Theme.launcherItemRadius
          color: Theme.launcherHighlight
        }

        delegate: Item {
          id: row
          required property var modelData
          required property int index
          width: list.width
          height: Math.max(Theme.launcherIconSize, rowText.implicitHeight) + 2 * Theme.launcherItemPadding

          MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            onEntered: launcher.hoverRow(row.index, rowMouse, rowMouse.mouseX, rowMouse.mouseY)
            onPositionChanged: (mouse) => launcher.hoverRow(row.index, rowMouse, mouse.x, mouse.y)
            onClicked: launcher.launch(row.modelData)
          }

          // Icon names can be a full path or a theme name; iconPath(name, true)
          // returns "" when the theme doesn't have it, so we can fall back.
          readonly property string iconSource: {
            const icon = modelData.icon || ""
            if (icon.startsWith("/"))
              return "file://" + icon
            return Quickshell.iconPath(icon, true) || Quickshell.iconPath("application-x-executable", true)
          }

          Item {
            id: appIcon
            anchors.left: parent.left
            anchors.leftMargin: Theme.launcherItemPadding
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.launcherIconSize
            height: Theme.launcherIconSize

            IconImage {
              anchors.fill: parent
              visible: row.iconSource !== ""
              source: row.iconSource
            }

            // No icon anywhere: show the app's first letter instead.
            Rectangle {
              anchors.fill: parent
              visible: row.iconSource === ""
              radius: 8
              color: Theme.launcherIconBadge
              Text {
                anchors.centerIn: parent
                text: row.modelData.name.charAt(0).toUpperCase()
                font.pointSize: Theme.fontSizeSmall
                font.weight: 700
                color: Theme.launcherIconBadgeText
              }
            }
          }

          Column {
            id: rowText
            anchors.left: appIcon.right
            anchors.leftMargin: Theme.launcherItemPadding
            anchors.right: parent.right
            anchors.rightMargin: Theme.launcherItemPadding
            anchors.verticalCenter: parent.verticalCenter

            Text {
              width: parent.width
              text: row.modelData.name
              elide: Text.ElideRight
              font.pixelSize: Theme.launcherTextSize
              color: Theme.launcherText
            }
            Text {
              width: parent.width
              visible: text !== ""
              text: row.modelData.genericName || row.modelData.comment
              elide: Text.ElideRight
              font.pixelSize: Theme.launcherSubtextSize
              color: Theme.launcherText
              opacity: Theme.launcherSubtextOpacity
            }
          }
        }
      }

      // Centered in the space the list would take, like Walker's "No Results".
      Text {
        visible: list.count === 0
        width: parent.width
        height: list.height
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "No Results"
        font.pointSize: Theme.fontSize
        color: Theme.launcherText
      }
    }
  }
}
