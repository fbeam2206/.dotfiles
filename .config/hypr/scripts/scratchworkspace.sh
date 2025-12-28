#!/bin/bash

if pgrep trilium; then
  hyprctl dispatch pin class:trilium && hyprctl dispatch movetoworkspacesilent special:scratch,class:trilium && hyprctl dispatch cyclenext floating workspace, special:scratch
else
  /home/graham/.local/share/TriliumNotes-v0.99/Trilium/trilium
fi 
