#source /usr/share/cachyos-fish-config/cachyos-config.fish

alias proj="cd /home/graham/Projects/phys-eng/ && tmux"
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias settings="cd $HOME/.config/hypr/ & nvim"
alias changewal="$HOME/.config/hypr/scripts/changewallpaper.sh"
alias cachy-update=arch-update
alias ls="ls -l"
# overwrite greeting
# potentially disabling fastfetch
function fish_greeting
    # smth smth
end
