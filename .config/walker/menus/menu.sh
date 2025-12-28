#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$SCRIPT_DIR:$PATH"

back_to_exit=false


BackTo(){
  local parent_menu="$1"

  if [[ "$back_to_exit" == "true" ]]; then
    exit 0
  elif [[ -n "$parent_menu" ]]; then
    "$parent_menu"
  else
    ShowMainMenu
  fi
}

Menu(){
  local prompt="$1"
  local options="$2"
  local extra="$3"
  local preselect="$4"

  read -r -a args <<<"$extra"

  if [[ -n "$preselect" ]]; then
    local index
    index=$(echo -e "$options" | grep -nxF "$preselect" | cut -d: -f1)
    if [[ -n "$index" ]]; then
      args+=("-c" "$index")
    fi
  fi
  echo -e "$options" | launch-walker --dmenu --width 295 --minheight 1 --maxheight 600 -p "$prompt" "${args[@]}" 2>/dev/null
}

Terminal(){
  alacritty -e "$@"
}

PresentTerminal(){
  launch-floating-terminal "$1"
}

Install(){
  PresentTerminal "echo 'Installing $1...'; sudo pacman -S --noconfirm $2"
}

AurInstall(){
  PresentTerminal "echo 'Installing $1 from AUR...'; yay -S --noconfirm $2"
}

ShowLearnMenu(){
  case $(Menu "Learn" "  Keybindings\n  Hyprland\n󰣇  Arch\n  Neovim\n󱆃  Bash") in
  *Keybindings*) show-keybindings ;;
  *Hyprland*) launch-webapp "Hyprland Wiki" "https://wiki.hypr.land/" ;;
  *Arch*) launch-webapp "Arch Wiki" "https://wiki.archlinux.org/title/Main_page" ;;
  *Bash*) launch-webapp "Bash Wiki" "https://devhints.io/bash" ;;
  *Neovim*) launch-webapp "Neovim Keymaps" "https://www.lazyvim.org/keymaps" ;;
  *) ShowMainMenu ;;
  esac
}

ShowTriggerMenu(){
  case $(Menu "Trigger" "  Capture\n  Share\n󰔎  Toggle") in
  *Capture*) ShowCaptureMenu ;;
  *Share*) ShowShareMenu ;;
  *Toggle*) ShowToggleMenu ;;
  *) ShowMainMenu ;;
  esac
}

ShowCaptureMenu(){
    case $(Menu "Capture" "  Screenshot\n  Screenrecord\n󰃉  Color") in
  *Screenshot*) ShowScreenShotMenu ;;
  *Screenrecord*) show_screenrecord_menu ;;
  *Color*) pkill hyprpicker || hyprpicker -a ;;
  *) show_trigger_menu ;;
  esac
}

ShowScreenShotMenu(){
  case $(Menu "Screenshot" "  Snap with Editing\n  Straight to Clipboard") in
  *Editing*) omarchy-cmd-screenshot smart ;; #TODO
  *Clipboard*) omarchy-cmd-screenshot smart clipboard ;; #TODO
  *) show_capture_menu ;;
  esac
}

ShowToggleMenu(){
  case $(Menu "Toggle" "󱄄  Screensaver\n󰔎  Nightlight\n󱫖  Idle Lock\n󰍜  Top Bar") in
  *Screensaver*) omarchy-toggle-screensaver ;; 
  *Nightlight*) omarchy-toggle-nightlight ;; 
  *Idle*) omarchy-toggle-idle ;; 
  *Bar*) omarchy-toggle-waybar ;;
  *) show_trigger_menu ;;
  esac
}

ShowRemoveMenu(){
    case $(Menu "Remove" "󰣇  Package\n  Web App\n  TUI\n󰸌  Theme") in
  *Package*) Terminal pkg-remove ;;
  *Web*) PresentTerminal "webapp-remove" ;;
  *TUI*) PresentTerminal "tui-remove" ;;
  *Theme*) PresentTerminal theme-remove ;;
  *) ShowMainMenu ;;
  esac
}

ShowSystemMenu(){
  case $(Menu "System" "  Lock\n󱄄  Screensaver\n󰤄  Suspend\n󰜉  Restart\n󰐥  Shutdown") in
  *Lock*) lock-screen ;;
  *Logout*) uwsm stop ;;
  *Restart*) systemctl reboot --no-wall ;; # Try uwsm stop -poweroff
  *Shutdown*) systemctl poweroff ;;
  *) back_to ShowMainMenu ;;
  esac
}

ShowMainMenu() {
  GoToMenu "$(Menu "Go" "󰀻  Apps\n󰧑  Learn\n󱓞  Trigger\n  Style\n  Setup\n󰉉  Install\n󰭌  Remove\n  Update\n  About\n  Power")"
}

ShowInstallMenu(){
  case $(Menu "Install" "󰣇  Package\n󰣇  AUR\n  Web App\n  TUI\n") in
  *Package*) Terminal pkg-install ;;
  *AUR*) Terminal pkg-aur-install ;;
  *Web*) PresentTerminal webapp-install ;;
  *TUI*) PresentTerminal tui-install ;;
  *) ShowMainMenu ;;
  esac
}

#GoToMenu(){
#  case "${1,,}" in
#  *apps*) walker -p "Launch…" ;;
#  *learn*) show_learn_menu ;;
#  *trigger*) show_trigger_menu ;;
#  *share*) show_share_menu ;;
#  *style*) show_style_menu ;;
#  *theme*) show_theme_menu ;;
#  *screenshot*) show_screenshot_menu ;;
#  *screenrecord*) show_screenrecord_menu ;;
#  *setup*) show_setup_menu ;;
#  *power*) show_setup_power_menu ;;
#  *install*) show_install_menu ;;
#  *remove*) show_remove_menu ;;
#  *update*) show_update_menu ;;
#  *about*) omarchy-launch-about ;;
#  *system*) show_system_menu ;;
#  esac
#}

GoToMenu(){
  case "${1,,}" in
  *apps*) walker -p "Launch…" ;;
  *learn*) ShowLearnMenu ;;
  *power*)  ShowSystemMenu ;;
  *remove*) ShowRemoveMenu ;;
  *trigger*) ShowTriggerMenu ;;
  *install*) ShowInstallMenu ;;
  esac
}

if [[ -n "$1" ]]; then
  back_to_exit=true
  GoToMenu "$1"
else
  ShowMainMenu
fi

# TODO
  #ShowShareMenu
  #ShowStyle/ThemeMenu
  #ShowSetupMenu
  #ShowPowerMenu
  #ShowInstallMenu
  #ShowRemoveMenu
  #ShowUpdateMenu
  #omarchy-state
  #omarchy-lock-screen
  #omarchy-launch-about
  #omarchy-toggle-screensaver
  #omarchy-toggle-idle 
  #omarchy-toggle-waybar
  #omarchy-toggle-nightlight
  #show-trigger-menu
  #show-capture-menu
  #omarchy-webapp-remove
  #omarchy-tui-remove
  #omarchy-theme-remove
