#!/bin/bash

if (pgrep discord > /dev/null); then
  if (hyprctl clients | grep discrod > /dev/null); then
    hyprctl dispatch workspace 2 > /dev/null
  else
    discord
  fi
else
  steam-native
fi
