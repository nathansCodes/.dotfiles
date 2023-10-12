#!/usr/bin/bash

DOTFILES_DIR=$(dirname "$(dirname "$(readlink -f -- "$0")")")

current_cfg_name=""

try_apply_config () {
    config_dir="${XDG_CONFIG_HOME}/$current_cfg_name"
    if [[ -L $config_dir ]]; then
        echo "$current_cfg_name configuration has already been symlinked."
        echo -n "Replace anyway? (y/n) "
        read -r replace

        if [[ $replace = "y" ]]; then
            ln -s "$DOTFILES_DIR/$current_cfg_name" "$config_dir"
        fi
        echo ""
    elif [[ -d $config_dir ]]; then
        echo "$current_cfg_name configuration found at $config_dir."
        echo -n "Do you want to replace it? (y/n) "
        read -r replace

        if [[ $replace = "y" ]]; then
            echo -n "Back up current configuration? (y/n) "
            read -r backup

            if [[ $backup = "y" ]]; then
                mv "$config_dir" "$config_dir.bak"
            else
                rm -rf "$config_dir"
            fi

            ln -s "$DOTFILES_DIR/$current_cfg_name" "$config_dir"
            echo "symlinked $DOTFILES_DIR/$current_cfg_name to $config_dir"
        fi
        echo ""
    else
        ln -s "$DOTFILES_DIR/$current_cfg_name" "$config_dir"
        echo "symlinked $DOTFILES_DIR/$current_cfg_name to $config_dir"

        echo ""
    fi
}

current_cfg_name="nvim"
try_apply_config
current_cfg_name="awesome"
try_apply_config
current_cfg_name="picom"
try_apply_config
current_cfg_name="alacritty"
try_apply_config
current_cfg_name="rofi"
try_apply_config
current_cfg_name="neofetch"
try_apply_config
current_cfg_name="zsh"
try_apply_config
current_cfg_name="tmux"
try_apply_config
current_cfg_name="btop"
try_apply_config
