#!/usr/bin/env bash
# Installs the cs2-shield script + systemd unit. Run once: sudo bash install.sh
set -e
here="$(cd "$(dirname "$0")" && pwd)"

install -Dm755 "$here/cs2-shield"               /usr/local/bin/cs2-shield
install -Dm644 "$here/cs2-shield.service"       /etc/systemd/system/cs2-shield.service
install -Dm644 "$here/cs2-shield-auto.service"  /etc/systemd/system/cs2-shield-auto.service
systemctl daemon-reload

echo
echo "Installed:"
echo "  /usr/local/bin/cs2-shield"
echo "  /etc/systemd/system/cs2-shield.service"
echo "  /etc/systemd/system/cs2-shield-auto.service"
echo
echo "Usage:"
echo "  sudo cs2-shield auto on   # auto-arm: shield follows CS2 launch/exit (recommended)"
echo "  sudo cs2-shield auto off  # back to manual"
echo "  sudo cs2-shield on/off    # manual override"
echo "  cs2-shield status         # show current state (no sudo needed)"
