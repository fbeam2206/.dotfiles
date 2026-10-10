import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import qs.modules.common
import qs.modules.common.widgets
import "../common/functions/audio.js" as Audio

Rectangle {
  id: root
  radius: 30
  color: "transparent"
  // implicit*, not width/height: the parent RowLayout owns width/height.
  implicitWidth: label.width + labelGap + icon.width
  implicitHeight: icon.height - 2

  property int labelGap: 1

  // Current output device (speakers/headphones). Can be null until
  // PipeWire reports one, so every read below guards with ?.
  readonly property PwNode sink: Pipewire.defaultAudioSink

  // One place to read the volume, so the label, icon and wheel agree.
  readonly property real volume: sink?.audio?.volume ?? 0

  // Clamp to 0..1 and round to whole percents so repeated +0.01 steps
  // don't accumulate floating-point drift (0.1 + 0.2 != 0.3 in JS).
  function setVolume(v) {
    if (!sink?.audio)
      return
    sink.audio.volume = Math.round(Math.max(0, Math.min(1, v)) * 100) / 100
  }

  PwObjectTracker {
    objects: [ root.sink ]
  }

  // Audio popup, toggled by left-clicking the speaker icon; closed on clicks
  // outside the bar and the popup.
  property bool open: false

  HoverHandler { id: hover }

  // Output device and volume; hidden while the popup is open.
  Tooltip {
    target: root
    hovered: hover.hovered && !root.open
    text: (root.sink ? Audio.deviceName(root.sink, Theme.audioDeviceNames) : "No output device") + "\n"
        + (root.sink?.audio?.muted ? "Muted" : Math.round(root.volume * 100) + "%")
  }

  // Clicks outside the bar go to other windows, so the bar can't see them.
  // While the popup is open, Hyprland reports a click on any other window
  // as onCleared, and we close the popup then.
  HyprlandFocusGrab {
    windows: [ root.QsWindow.window, popup ]
    active: root.open
    onCleared: root.open = false
  }

  // Measures the widest possible label so the width doesn't jump
  // between "5%" and "100%" and shove the rest of the bar around.
  TextMetrics {
    id: widest
    font: label.font
    text: "100%"
  }

  Text {
    id: label
    width: widest.width
    anchors.left: root.left
    anchors.verticalCenter: root.verticalCenter
    horizontalAlignment: Text.AlignRight
    text: Math.round(root.volume * 100) + "%"
    font.weight: 500
    font.pointSize: Theme.fontSizeSmall

    layer.enabled: Theme.iconShadowEnabled
    layer.effect: IconShadow {}

    WheelHandler {
      // null target: don't let the handler move/scale anything itself;
      // we only want the wheel signal.
      target: null
      acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
      // Scroll not yet applied, in percent. setVolume rounds to whole
      // percents, so small touchpad/hi-res deltas are summed here until
      // they add up to a full step instead of being rounded away.
      property real pending: 0
      onWheel: (event) => {
        // A standard mouse notch reports angleDelta.y = 120, i.e. 1%.
        pending += event.angleDelta.y / 120
        const steps = Math.trunc(pending)
        if (steps !== 0) {
          pending -= steps
          root.setVolume(root.volume + 0.01 * steps)
        }
      }
    }
  }

  ImageIcon {
    id: icon
    width: 28
    height: 28
    anchors.left: label.right
    anchors.leftMargin: root.labelGap
    source: Quickshell.shellPath("assets/icons/" + Audio.speakerIcon(root.volume, root.sink?.audio?.muted ?? false))
    pressed: iconTap.pressed

    TapHandler {
      id: iconTap
      acceptedButtons: Qt.LeftButton
      onTapped: root.open = !root.open
    }
  }

  AudioPopup {
    id: popup
    target: root
    open: root.open
  }
}
