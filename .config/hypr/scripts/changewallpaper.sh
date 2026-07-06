#!/bin/bash

pkill swaybg

IMAGE_DIR="$HOME/Pictures/Wallpapers/slideshow/"
CURRENT_WAL=$(cat "$HOME/.config/hypr/hyprland/execs.conf" | grep "swaybg")

# Select Wallpaper
selectedImage=$(find "$IMAGE_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) -exec basename {} \; | SHELL=/bin/bash fzf --preview "chafa --size \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} '$IMAGE_DIR/{}'")

# Select Monitor
selectedMonitor=$(hyprctl monitors -j | jq -r '.[].name' | fzf --prompt="Select Monitor: ")

# Select Wallpaper
selectedImageTwo=$(find "$IMAGE_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) -exec basename {} \; | SHELL=/bin/bash fzf --preview "chafa --size \${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} '$IMAGE_DIR/{}'")

# Select Monitor
selectedMonitorTwo=$(hyprctl monitors -j | jq -r '.[].name' | fzf --prompt="Select Monitor: ")

# Set Wallpaper
if [[ -n "$selectedImage" && -n "$selectedImageTwo" ]]; then
  swaybg -o "$selectedMonitor" -i "$IMAGE_DIR/$selectedImage" &
  swaybg -o "$selectedMonitorTwo" -i "$IMAGE_DIR/$selectedImageTwo" & wal -i "$IMAGE_DIR/$selectedImage" & disown
  # Save Selection
  sed -i "s|^exec-once = swaybg.*|exec-once = swaybg -o $selectedMonitor -i $IMAGE_DIR/$selectedImage \& swaybg -o $selectedMonitorTwo -i $IMAGE_DIR/$selectedImageTwo|" "$HOME/.config/hypr/hyprland/execs.conf"
elif [[ -z "$selectedImage" || -z "$selectedImageTwo" ]]; then
  eval "${CURRENT_WAL#exec-once = } & disown"
fi
