#!/bin/bash

WALLPAPER_DIR="/home/graham/Pictures/Wallpapers/slideshow"
CACHE_FILE="/tmp/wallpaper_cache"

# Get all image files from the directory
mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

# Check if we have enough wallpapers
if [ ${#wallpapers[@]} -lt 2 ]; then
    echo "Error: Need at least 2 wallpapers in $WALLPAPER_DIR"
    exit 1
fi

# Read previous wallpapers if they exist
if [ -f "$CACHE_FILE" ]; then
    prev_wallpaper1=$(sed -n '1p' "$CACHE_FILE")
    prev_wallpaper2=$(sed -n '2p' "$CACHE_FILE")
else
    prev_wallpaper1=""
    prev_wallpaper2=""
fi

# Pick first wallpaper (different from previous)
wallpaper1="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
while [ "$wallpaper1" == "$prev_wallpaper1" ] && [ ${#wallpapers[@]} -gt 1 ]; do
    wallpaper1="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
done

# Pick second wallpaper (different from both previous and current first)
wallpaper2="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
while ([ "$wallpaper2" == "$wallpaper1" ] || [ "$wallpaper2" == "$prev_wallpaper2" ]) && [ ${#wallpapers[@]} -gt 2 ]; do
    wallpaper2="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
done

# Save current wallpapers to cache
echo "$wallpaper1" > "$CACHE_FILE"
echo "$wallpaper2" >> "$CACHE_FILE"

# Kill existing swaybg instances
killall swaybg 2>/dev/null

# Set wallpapers for each monitor
swaybg -o DP-5 -i "$wallpaper1" -m fill &
swaybg -o HDMI-A-5 -i "$wallpaper2" -m fill &

# Generate pywal theme from the first wallpaper and refresh caches
wal -i "$wallpaper1" -n

echo "Set wallpapers:"
echo "  DP-5: $wallpaper1"
echo "  HDMI-A-5: $wallpaper2"
echo "Pywal theme generated from: $wallpaper1"
