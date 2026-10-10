import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.modules.common
import qs.modules.common.widgets
import "../common/functions/audio.js" as Audio

// Drop-down under the speaker icon: output and input volume sliders side by
// side, and below them the current output/input device, each of which opens
// a list of the other devices to switch to. Clicking a slider's icon mutes it.
PopupWindow {
  id: popup

  required property Item target
  property bool open: false

  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property PwNode source: Pipewire.defaultAudioSource

  // Real hardware/virtual devices only; isStream nodes are apps playing or
  // recording. Theme.audioHiddenDevices are left out.
  readonly property var devices: Pipewire.nodes.values
      .filter(n => n.audio && !n.isStream && !Theme.audioHiddenDevices.includes(n.name))
  readonly property var sinks: devices.filter(n => n.isSink)
  readonly property var sources: devices.filter(n => !n.isSink)

  // popupHighlight at 0% opacity, for rows that aren't hovered. Plain
  // "transparent" is clear black, so fading to it would flash darker.
  readonly property color highlightClear: Qt.rgba(Theme.popupHighlight.r, Theme.popupHighlight.g, Theme.popupHighlight.b, 0)

  // Which device list is expanded: "output", "input" or "" (none).
  property string expanded: ""
  onOpenChanged: if (!open) expanded = ""

  PwObjectTracker {
    objects: [ popup.sink, popup.source ]
  }

  // 0 = closed, 1 = fully open. Animates both ways, and the window stays
  // mapped until the closing animation has finished.
  property real reveal: open ? 1 : 0
  Behavior on reveal {
    NumberAnimation { duration: Theme.popupAnimationDuration; easing.type: Easing.OutCubic }
  }

  visible: reveal > 0
  color: "transparent"

  // Distance from the target's right edge to the right end of the bar
  // (the right pill's edge). Recomputed on each open, since mapToItem
  // isn't a live binding.
  readonly property real barRightGap: {
    open
    const win = target.QsWindow.window
    return win ? win.width - Theme.barSideMargin - target.mapToItem(null, target.width, 0).x : 0
  }

  anchor.item: target
  // Hang the popup down and to the left from the target's bottom-right
  // corner, pushed right so the panel's right edge lines up with the bar's.
  anchor.edges: Edges.Bottom | Edges.Right
  anchor.gravity: Edges.Bottom | Edges.Left
  // The shadow room would otherwise poke past the screen edge and make the
  // compositor slide the popup back in, breaking the alignment.
  anchor.adjustment: PopupAdjustment.None
  anchor.margins.right: -(barRightGap + Theme.popupShadowRoom)
  // Same placement as Tooltip: just below the pill, not the icon. The
  // window starts popupShadowRoom higher so the panel itself stays put.
  anchor.margins.bottom: -((Theme.pillHeight - target.height) / 2 + Theme.tooltipGap) + Theme.popupShadowRoom

  // Resizing a Wayland popup every frame flickers, so the window is always
  // as tall as the popup with its longest device list open, and only the
  // panel inside it animates. The mask lets clicks through the empty part.
  // popupShadowRoom on every side leaves space for the shadow.
  implicitWidth: Theme.popupWidth + 2 * Theme.popupShadowRoom
  implicitHeight: content.implicitHeight - outputPicker.shownListHeight - inputPicker.shownListHeight
      + Math.max(outputPicker.fullListHeight, inputPicker.fullListHeight)
      + 2 * Theme.popupPadding + 2 * Theme.popupShadowRoom
  mask: Region { item: clipper }

  // Unrolls the panel downwards from the bar as `reveal` goes 0 -> 1.
  // The shadow is drawn from the clipped result, so it unrolls too.
  Item {
    id: clipper
    x: Theme.popupShadowRoom
    y: Theme.popupShadowRoom
    width: Theme.popupWidth
    height: panel.height * popup.reveal
    opacity: popup.reveal
    clip: true

    layer.enabled: Theme.popupShadowEnabled
    layer.effect: MultiEffect {
      shadowEnabled: true
      shadowColor: Theme.popupShadowColor
      blurMax: Theme.popupShadowRadius
      shadowBlur: 1.0
      shadowVerticalOffset: Theme.popupShadowOffsetY
      autoPaddingEnabled: true
    }

    Rectangle {
      id: panel
      width: parent.width
      height: content.implicitHeight + 2 * Theme.popupPadding
      radius: 16
      color: Theme.popupBackground

      ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.popupPadding
        spacing: Theme.popupPadding

        // Output and input frames split the width evenly.
        RowLayout {
          Layout.fillWidth: true
          spacing: Theme.popupPadding

          VolumeColumn {
            node: popup.sink
            title: "Output"
            iconFile: Audio.speakerIcon(node?.audio?.volume ?? 0, node?.audio?.muted ?? false)
          }
          VolumeColumn {
            node: popup.source
            title: "Input"
            iconFile: Audio.micIcon(node?.audio?.muted ?? false)
          }
        }

        DevicePicker {
          id: outputPicker
          Layout.fillWidth: true
          key: "output"
          title: "Output"
          current: popup.sink
          nodes: popup.sinks
          onPicked: (node) => Pipewire.preferredDefaultAudioSink = node
        }
        DevicePicker {
          id: inputPicker
          Layout.fillWidth: true
          key: "input"
          title: "Input"
          current: popup.source
          nodes: popup.sources
          onPicked: (node) => Pipewire.preferredDefaultAudioSource = node
        }
      }
    }
  }

  // Soft shadow under the slider and device picker frames.
  component FrameShadow: MultiEffect {
    shadowEnabled: true
    shadowColor: Theme.audioFrameShadowColor
    blurMax: Theme.audioFrameShadowRadius
    shadowBlur: 1.0
    shadowVerticalOffset: Theme.audioFrameShadowOffsetY
    autoPaddingEnabled: true
  }

  // A filled frame holding the percentage on top, vertical slider, then an
  // icon that toggles mute.
  component VolumeColumn: Rectangle {
    id: column
    property PwNode node
    property string title
    property string iconFile
    readonly property real volume: node?.audio?.volume ?? 0

    // Same clamping/rounding as the bar's volume widget.
    function setVolume(v) {
      if (node?.audio)
        node.audio.volume = Math.round(Math.max(0, Math.min(1, v)) * 100) / 100
    }

    // Equal preferred widths + fillWidth = both frames the same size.
    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: inner.implicitHeight + 2 * Theme.audioFramePadding
    radius: Theme.audioFrameRadius
    color: Theme.audioFrameColor
    layer.enabled: Theme.audioFrameShadowEnabled
    layer.effect: FrameShadow {}

    ColumnLayout {
      id: inner
      anchors.centerIn: parent
      spacing: 6

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: column.node?.audio?.muted ? "Muted" : Math.round(column.volume * 100) + "%"
        font.pointSize: Theme.fontSizeSmall
        font.weight: 500
        color: Theme.popupText
      }

      StyledSlider {
        id: slider
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: Theme.audioSliderHeight
        orientation: Qt.Vertical
        enabled: column.node?.audio != null
        from: 0
        to: 1.0
        stepSize: 0.01
        wheelEnabled: true
        onMoved: column.setVolume(value)
      }

      // Follow the device's volume, except while the user is dragging.
      Binding {
        target: slider
        property: "value"
        value: column.volume
        when: !slider.pressed
        restoreMode: Binding.RestoreNone
      }

      ImageIcon {
        Layout.alignment: Qt.AlignHCenter
        width: 24
        height: 24
        sourceSize.width: 24
        sourceSize.height: 24
        source: Quickshell.shellPath("assets/icons/" + column.iconFile)
        pressed: muteTap.pressed

        TapHandler {
          id: muteTap
          onTapped: if (column.node?.audio) column.node.audio.muted = !column.node.audio.muted
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: column.title
        font.pointSize: Theme.fontSizeSmall - 3
        color: Theme.popupSubtext
      }
    }
  }

  // "Output  DragonFly  v" row in a filled frame; clicking it lists every
  // device to pick from, and the frame grows to hold the list.
  component DevicePicker: Rectangle {
    id: picker
    property string key
    property string title
    property PwNode current
    property var nodes: []
    readonly property bool isOpen: popup.expanded === key
    // Height of the device list when open, and its current (animating) height.
    readonly property real fullListHeight: options.implicitHeight
    readonly property real shownListHeight: listClip.implicitHeight
    signal picked(PwNode node)

    implicitHeight: inner.implicitHeight
    radius: Theme.audioFrameRadius
    color: Theme.audioFrameColor
    layer.enabled: Theme.audioFrameShadowEnabled
    layer.effect: FrameShadow {}

    ColumnLayout {
      id: inner
      anchors.fill: parent
      // No spacing: with the list closed it would leave a strip under the
      // header. The list's topPadding makes the gap instead.
      spacing: 0

      // Highlights run edge to edge, so each one rounds only the corners it
      // shares with the frame: the header's bottom ones only while no list
      // shows below it (tracking the slide, not the click).
      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 34
        topLeftRadius: picker.radius
        topRightRadius: picker.radius
        bottomLeftRadius: listClip.implicitHeight > 0 ? 0 : picker.radius
        bottomRightRadius: bottomLeftRadius
        color: headerHover.hovered || picker.isOpen ? Theme.popupHighlight : popup.highlightClear
        Behavior on color { ColorAnimation { duration: Theme.hoverAnimationDuration } }

        HoverHandler { id: headerHover }
        TapHandler { onTapped: popup.expanded = picker.isOpen ? "" : picker.key }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 6
          spacing: 8

          // Fixed width so both device names start at the same x.
          Text {
            Layout.preferredWidth: titleWidth.width
            text: picker.title
            font.pointSize: Theme.fontSizeSmall - 3
            color: Theme.popupSubtext

            TextMetrics {
              id: titleWidth
              font.pointSize: Theme.fontSizeSmall - 3
              text: "Output"
            }
          }
          Text {
            Layout.fillWidth: true
            text: Audio.deviceName(picker.current, Theme.audioDeviceNames)
            elide: Text.ElideRight
            font.pointSize: Theme.fontSizeSmall
            font.weight: 600
            color: Theme.popupText
          }
          Image {
            source: Quickshell.shellPath("assets/icons/expand_more_black.svg")
            sourceSize.width: 20
            sourceSize.height: 20
            rotation: picker.isOpen ? 180 : 0
            Behavior on rotation { NumberAnimation { duration: 150 } }
          }
        }
      }

      // The list is always built; this box animates its height to slide it
      // open and closed, clipping whatever doesn't fit yet.
      Item {
        id: listClip
        Layout.fillWidth: true
        implicitHeight: picker.isOpen ? options.implicitHeight : 0
        clip: true
        Behavior on implicitHeight {
          NumberAnimation { duration: Theme.popupAnimationDuration; easing.type: Easing.OutCubic }
        }

        Column {
          id: options
          width: parent.width
          topPadding: 2
          spacing: 2

          Repeater {
            model: picker.nodes

            delegate: Rectangle {
              id: option
              required property PwNode modelData
              readonly property bool isCurrent: modelData === picker.current

              required property int index
              readonly property bool isLast: index === picker.nodes.length - 1

              width: options.width
              implicitHeight: 30
              bottomLeftRadius: isLast ? picker.radius : 0
              bottomRightRadius: bottomLeftRadius
              color: optionHover.hovered ? Theme.popupHighlight : popup.highlightClear
              Behavior on color { ColorAnimation { duration: Theme.hoverAnimationDuration } }

              HoverHandler { id: optionHover }
              TapHandler {
                onTapped: {
                  picker.picked(option.modelData)
                  popup.expanded = ""
                }
              }

              RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6

                Text {
                  Layout.fillWidth: true
                  text: Audio.deviceName(option.modelData, Theme.audioDeviceNames)
                  elide: Text.ElideRight
                  font.pointSize: Theme.fontSizeSmall - 1
                  font.weight: option.isCurrent ? 600 : 400
                  color: Theme.popupText
                }
                Image {
                  visible: option.isCurrent
                  source: Quickshell.shellPath("assets/icons/check_black.svg")
                  sourceSize.width: 18
                  sourceSize.height: 18
                }
              }
            }
          }
        }
      }
    }
  }
}
