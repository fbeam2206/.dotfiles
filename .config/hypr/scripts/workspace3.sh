#!/bin/bash
# Super+3: focus workspace 3 if Steam already has a window there, otherwise
# launch Steam (the steam-workspace-3 window rule drops it on workspace 3).
#
# NOTE: since Hyprland 0.55+ the config is Lua, and `hyprctl dispatch` now takes
# a Lua *expression* rather than the old hyprlang keyword form. The previous
# `hyprctl dispatch workspace 3` silently died with a Lua syntax error, which is
# why Super+3 did nothing whenever Steam was already open.

if hyprctl clients -j | jq -e 'any(.[]; .class == "steam")' > /dev/null; then
  hyprctl dispatch 'hl.dsp.focus({ workspace = 3 })' > /dev/null
else
  steam-native
fi
