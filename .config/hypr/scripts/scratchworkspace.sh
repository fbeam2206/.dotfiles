#!/bin/bash

if pgrep electron; then
  hyprctl dispatch pin class:obsidian && hyprctl dispatch movetoworkspacesilent special:scratch,class:obsidian && hyprctl dispatch cyclenext floating workspace, special:scratch
else
  obsidian
  # /home/graham/.local/share/TriliumNotes-v0.99/Trilium/trilium
fi 
