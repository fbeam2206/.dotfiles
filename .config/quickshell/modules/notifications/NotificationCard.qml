import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.modules.common
import qs.services

// One notification: icon, app name and age, summary, body, and action
// buttons. Clicking it runs the app's default action (usually "open the
// thing this is about"); the × dismisses it for good.
Rectangle {
  id: card

  required property Notification notification
  // Pop-ups are shorter and get closed instead of removed when clicked.
  property bool popup: false
  // Minute-ticking clock for the "5m" age label.
  property date now: new Date()

  readonly property bool hovered: hover.hovered
  readonly property bool critical: notification?.urgency === NotificationUrgency.Critical
  readonly property var buttons: notification?.actions.filter(a => a.identifier !== "default") ?? []

  signal closeRequested()

  implicitHeight: layout.implicitHeight + 2 * 12
  radius: Theme.notifRadius
  color: hovered ? Theme.notifCardHover : Theme.notifCardBackground
  border.width: 1
  border.color: critical ? Theme.notifCritical : Theme.notifBorder
  Behavior on color { ColorAnimation { duration: 120 } }

  // Notification image, else the app's icon (by name, path, or desktop entry).
  readonly property string iconSource: {
    const n = notification
    // The notification can be destroyed while its card is still sliding out.
    if (!n)
      return ""
    // Theme icons arrive as "image://icon/<name>"; only use them if the
    // icon theme actually has that icon, or it renders as a checkerboard.
    if (n.image.startsWith("image://icon/")) {
      const themed = Quickshell.iconPath(n.image.slice("image://icon/".length), true)
      if (themed)
        return themed
    } else if (n.image) {
      return n.image
    }
    const icon = n.appIcon || ""
    if (icon.startsWith("/"))
      return "file://" + icon
    if (icon.includes("://"))
      return icon
    return Quickshell.iconPath(icon, true)
        || Quickshell.iconPath(DesktopEntries.byId(n.desktopEntry)?.icon ?? "", true)
  }

  HoverHandler { id: hover }

  // Below the content, so the × and action buttons (MouseAreas too) take
  // their own clicks and this one only gets clicks on the rest of the card.
  MouseArea {
    anchors.fill: parent
    onClicked: {
      const main = card.notification?.actions.find(a => a.identifier === "default")
      if (main)
        main.invoke()
      card.closeRequested()
    }
  }

  RowLayout {
    id: layout
    anchors.fill: parent
    anchors.margins: 12
    spacing: 12

    Image {
      Layout.alignment: Qt.AlignTop
      Layout.preferredWidth: Theme.notifIconSize
      Layout.preferredHeight: Theme.notifIconSize
      visible: card.iconSource !== ""
      source: card.iconSource
      sourceSize.width: Theme.notifIconSize * 2
      sourceSize.height: Theme.notifIconSize * 2
      fillMode: Image.PreserveAspectFit
      asynchronous: true
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 3

      RowLayout {
        Layout.fillWidth: true
        spacing: 6

        Text {
          Layout.fillWidth: true
          text: card.notification?.appName || "Notification"
          elide: Text.ElideRight
          font.pointSize: Theme.fontSizeSmall - 3
          color: Theme.notifSubtext
        }
        Text {
          text: Notifs.age(card.notification, card.now)
          font.pointSize: Theme.fontSizeSmall - 3
          color: Theme.notifSubtext
        }
        // Dismiss. Always there in the center; on pop-ups only while hovered.
        Rectangle {
          Layout.preferredWidth: 20
          Layout.preferredHeight: 20
          radius: 6
          opacity: card.popup && !card.hovered ? 0 : 1
          color: closeHover.hovered ? Theme.notifCloseHover : Theme.notifButton

          Text {
            anchors.centerIn: parent
            text: "✕"
            font.pointSize: Theme.fontSizeSmall - 4
            color: Theme.notifText
          }
          HoverHandler { id: closeHover }
          MouseArea { anchors.fill: parent; onClicked: card.notification?.dismiss() }
        }
      }

      Text {
        Layout.fillWidth: true
        text: card.notification?.summary ?? ""
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        font.pointSize: Theme.fontSizeSmall
        font.weight: 600
        color: Theme.notifText
      }

      Text {
        Layout.fillWidth: true
        visible: text !== ""
        // Body may contain basic markup (<b>, <i>, <a href>); keep its line breaks.
        text: (card.notification?.body ?? "").replace(/\n/g, "<br>")
        textFormat: Text.StyledText
        wrapMode: Text.Wrap
        maximumLineCount: card.popup ? 3 : 6
        elide: Text.ElideRight
        font.pointSize: Theme.fontSizeSmall - 2
        color: Theme.notifSubtext
        linkColor: Theme.notifText
        onLinkActivated: (link) => Qt.openUrlExternally(link)
      }

      // The app's buttons, e.g. "Reply", "Mark as read".
      RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 4
        visible: card.buttons.length > 0
        spacing: 6

        Repeater {
          model: card.buttons

          delegate: Rectangle {
            id: actionButton
            required property NotificationAction modelData
            Layout.fillWidth: true
            implicitHeight: 28
            radius: 6
            color: actionHover.hovered ? Theme.notifButtonHover : Theme.notifButton

            Text {
              anchors.fill: parent
              anchors.leftMargin: 6
              anchors.rightMargin: 6
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              text: actionButton.modelData.text
              elide: Text.ElideRight
              font.pointSize: Theme.fontSizeSmall - 2
              color: Theme.notifText
            }
            HoverHandler { id: actionHover }
            MouseArea {
              anchors.fill: parent
              onClicked: {
                actionButton.modelData.invoke()
                card.closeRequested()
              }
            }
          }
        }
      }
    }
  }
}
