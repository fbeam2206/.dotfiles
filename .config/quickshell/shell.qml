//@ pragma UseQApplication
import Quickshell
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications

// Entry point. Start with `qs` (this is Quickshell's default config folder).
ShellRoot {
  Bar { id: bar }
  Launcher {}

  // Notification daemon UI (replaces swaync). Shown on the bar's monitor.
  NotificationPopups { screen: bar.screen }
  NotificationCenter {
    screen: bar.screen
    grabWith: [ bar ]
  }
}
