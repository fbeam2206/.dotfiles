pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.modules.common

// The notification daemon. Receives every notification apps send, keeps them
// for the notification center, and decides which show as pop-ups.
Singleton {
  id: root

  // Do Not Disturb: no pop-ups, still kept in the center. Saved in
  // PersistentProperties below so a config reload doesn't switch it off.
  property bool dnd: false
  property bool centerOpen: false

  // Everything in the center, newest first.
  readonly property var all: [...server.trackedNotifications.values].reverse()
  readonly property int count: server.trackedNotifications.values.length

  // Notifications currently showing as pop-ups, newest first.
  property var popups: []

  // When each notification arrived, by id; Notification has no timestamp.
  // Saved as JSON in PersistentProperties so ages survive config reloads
  // (a plain JS object can't be carried over to the reloaded config).
  property var receivedAt: ({})
  PersistentProperties {
    id: persist
    reloadableId: "notifs"
    property string receivedAtJson: "{}"
    property bool dnd: false
    onLoaded: {
      root.receivedAt = JSON.parse(receivedAtJson)
      root.dnd = dnd
    }
  }

  // Turning DND on also hides the pop-ups already on screen.
  onDndChanged: {
    persist.dnd = dnd
    if (dnd)
      popups = []
  }

  // Opening the center shows everything, so the pop-ups go away.
  onCenterOpenChanged: if (centerOpen) popups = []

  NotificationServer {
    id: server
    // Keep notifications across config reloads (not across restarts).
    keepOnReload: true
    persistenceSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: (n) => {
      n.tracked = true
      n.closed.connect(() => root.hidePopup(n))
      // After a config reload, kept notifications come through here again
      // (lastGeneration); they keep their time and don't pop up again.
      if (n.lastGeneration)
        return
      root.receivedAt[n.id] = Date.now()
      persist.receivedAtJson = JSON.stringify(root.receivedAt)
      if (!root.dnd && !root.centerOpen)
        root.popups = [n, ...root.popups]
    }
  }

  function hidePopup(n) {
    popups = popups.filter(p => p !== n)
  }

  // A pop-up's time ran out: it stays in the center, unless the app marked
  // it transient (meant to be shown, not kept).
  function popupTimedOut(n) {
    hidePopup(n)
    if (n.transient)
      n.expire()
  }

  function clearAll() {
    for (const n of [...server.trackedNotifications.values])
      n.dismiss()
  }

  // How long a pop-up stays up, in ms; 0 means until dismissed.
  // The app's own timeout wins, except critical ones always use the Theme's.
  function timeoutFor(n) {
    if (n.urgency === NotificationUrgency.Critical)
      return Theme.notifTimeoutCritical * 1000
    if (n.expireTimeout > 0)
      return n.expireTimeout * 1000
    return (n.urgency === NotificationUrgency.Low ? Theme.notifTimeoutLow : Theme.notifTimeoutNormal) * 1000
  }

  // "now", "5m", "2h", "3d" since the notification arrived.
  function age(n, now) {
    const t = n ? receivedAt[n.id] : 0
    if (!t)
      return ""
    const mins = Math.floor((now - t) / 60000)
    if (mins < 1) return "now"
    if (mins < 60) return mins + "m"
    if (mins < 1440) return Math.floor(mins / 60) + "h"
    return Math.floor(mins / 1440) + "d"
  }
}
