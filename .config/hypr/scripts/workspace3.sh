#!/bin/bash

if (pgrep steam > /dev/null); then
  if (hyprctl clients | grep steam > /dev/null); then
    hyprctl dispatch workspace 3 > /dev/null
  else
    steam-native
  fi
else
  steam-native
fi
