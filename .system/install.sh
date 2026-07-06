#!/usr/bin/env bash
# Restore/refresh system-level configuration from this directory.
# Idempotent — safe to re-run after changing anything under ~/.system.
#
#   sudo bash ~/.system/install.sh
#
# What this does NOT cover (see BOOTSTRAP.md): GRUB cmdline merge,
# BIOS settings, logins (Mullvad/Steam), secrets, user data.
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if [ "$(id -u)" -ne 0 ]; then
    echo "Run with sudo: sudo bash $0" >&2
    exit 1
fi

echo "== udev rules (Pulsar mouse, Wooting)"
install -Dm644 "$HERE/etc/udev/rules.d/50-x2v3_mouse.rules" /etc/udev/rules.d/50-x2v3_mouse.rules
install -Dm644 "$HERE/etc/udev/rules.d/70-wooting.rules"   /etc/udev/rules.d/70-wooting.rules
udevadm control --reload
udevadm trigger

echo "== package-list refresh hook"
install -Dm755 "$HERE/usr/local/bin/pkglists-refresh" /usr/local/bin/pkglists-refresh
install -Dm644 "$HERE/etc/pacman.d/hooks/pkglists.hook" /etc/pacman.d/hooks/pkglists.hook
/usr/local/bin/pkglists-refresh
echo "   lists refreshed:"
wc -l "$HERE"/pkglist.txt "$HERE"/aurlist.txt "$HERE"/flatpaklist.txt | sed 's/^/   /'

echo "== cs2-shield (staged in ~/.local/share/cs2-shield)"
CS2SHIELD="$(dirname "$HERE")/.local/share/cs2-shield/install.sh"
if [ -f "$CS2SHIELD" ]; then
    bash "$CS2SHIELD"
    cs2-shield auto on
else
    echo "   !! $CS2SHIELD not found — skipped" >&2
fi

echo
echo "Done. Remaining manual steps are listed in $HERE/BOOTSTRAP.md."
