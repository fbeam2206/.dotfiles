#!/bin/bash

pkill swaybg

IMAGE_DIR="$HOME/Pictures/Wallpapers/slideshow/"

# Select Wallpaper
selectedImage=$(find "$IMAGE_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | fzf --preview 'chafa {}')

# Select Monitor
selectedMonitor=$(hyprctl monitors -j | jq -r '.[].name' | fzf --prompt="Select Monitor: ")

# Set Wallpaper
swaybg -o "$selectedMonitor" -i "$selectedImage" &

# Select Wallpaper
selectedImageTwo=$(find "$IMAGE_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | fzf --preview 'chafa {}')

# Select Monitor
selectedMonitorTwo=$(hyprctl monitors -j | jq -r '.[].name' | fzf --prompt="Select Monitor: ")

# Set Wallpaper
swaybg -o "$selectedMonitorTwo" -i "$selectedImageTwo" & disown
