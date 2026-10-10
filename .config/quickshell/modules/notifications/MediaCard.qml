import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.modules.common

// Now playing for one media player: album art, title, artist and
// previous / play-pause / next. Replaces swaync's "mpris" widget.
Rectangle {
  id: card

  required property MprisPlayer player

  implicitHeight: row.implicitHeight + 2 * 10
  radius: Theme.notifRadius
  color: Theme.notifCardBackground
  border.width: 1
  border.color: Theme.notifBorder

  RowLayout {
    id: row
    anchors.fill: parent
    anchors.margins: 10
    spacing: 12

    // Album art; a plain tile when the player doesn't provide any.
    Rectangle {
      Layout.preferredWidth: 56
      Layout.preferredHeight: 56
      radius: 6
      color: Theme.notifButton
      clip: true

      Image {
        anchors.fill: parent
        source: card.player.trackArtUrl
        sourceSize.width: 112
        sourceSize.height: 112
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 2

      Text {
        Layout.fillWidth: true
        text: card.player.trackTitle || card.player.identity
        elide: Text.ElideRight
        font.pointSize: Theme.fontSizeSmall
        font.weight: 600
        color: Theme.notifText
      }
      Text {
        Layout.fillWidth: true
        visible: text !== ""
        text: card.player.trackArtist
        elide: Text.ElideRight
        font.pointSize: Theme.fontSizeSmall - 2
        color: Theme.notifSubtext
      }

      RowLayout {
        spacing: 4
        // Nerd Font icons: previous, play/pause, next.
        MediaButton {
          glyph: String.fromCodePoint(0xF04AE) // skip previous
          enabled: card.player.canGoPrevious
          onClicked: card.player.previous()
        }
        MediaButton {
          glyph: String.fromCodePoint(card.player.isPlaying ? 0xF03E4 : 0xF040A) // pause / play
          enabled: card.player.canTogglePlaying
          onClicked: card.player.togglePlaying()
        }
        MediaButton {
          glyph: String.fromCodePoint(0xF04AD) // skip next
          enabled: card.player.canGoNext
          onClicked: card.player.next()
        }
      }
    }
  }

  component MediaButton: Rectangle {
    id: button
    property string glyph
    signal clicked()

    implicitWidth: 32
    implicitHeight: 24
    radius: 6
    opacity: enabled ? 1 : 0.4
    color: mouse.containsMouse && enabled ? Theme.notifButtonHover : Theme.notifButton

    Text {
      anchors.centerIn: parent
      text: button.glyph
      font.pointSize: Theme.fontSizeSmall
      color: Theme.notifText
    }
    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      onClicked: if (button.enabled) button.clicked()
    }
  }
}
