# paths
config="$HOME/.config"
nvim="$config/nvim"
xresources="$HOME/.Xresources"
gtk3="$config/gtk-3.0"
gtk4="$config/gtk-4.0"
alacritty_dir="$config/alacritty"

alacritty() {
    rm "$alacritty_dir/colors/theme.toml"
    ln -s "$alacritty_dir/colors/$1.toml" "$alacritty_dir/colors/theme.toml"
    # add a line to and remove it from alacritty.toml to trigger alacritty's auto reloading
    echo "" >> "$alacritty_dir/alacritty.toml"
    sed -i '$ d' "$alacritty_dir/alacritty.toml"
}

term() {
    # Xresources
    sed -i -e "s/#define FG .*/#define FG $FG/g" \
           -e "s/#define BG .*/#define BG $BASE/g" \
           -e "s/#define BL .*/#define BL $BLACK/g" \
           -e "s/#define WH .*/#define WH $WHITE/g" \
           -e "s/#define R .*/#define R $RED/g" \
           -e "s/#define G .*/#define G $GREEN/g" \
           -e "s/#define Y .*/#define Y $YELLOW/g" \
           -e "s/#define B .*/#define B $BLUE/g" \
           -e "s/#define M .*/#define M $MAGENTA/g" \
           -e "s/#define C .*/#define C $CYAN/g" $xresources

    # Update Xresources, Terminals, and Vim
    xrdb $xresources
}

gtk() {
    rm -rf "$gtk3" "$gtk4"
    mv "/tmp/backup/gtk-3.0" "$config"
    mv "/tmp/backup/gtk-4.0" "$config"
}

userchrome() {
    # $1 = firefox install method; $2 = firefox profile
    if [[ $1 = "native" ]]; then
        firefox="$HOME/.mozilla/firefox/$2"
    elif [[ $1 = "flatpak" ]]; then
        firefox="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$2"
    fi

    rm "$firefox/chrome/userChrome.css"
    mv "/tmp/backup/userChrome.css" "$firefox/chrome/userChrome.css"
}

# currently unused
usercontent() {
    # $1 = firefox install method; $2 = firefox profile
    if [[ $1 = "native" ]]; then
        firefox="$HOME/.mozilla/firefox/$2"
    elif [[ $1 = "flatpak" ]]; then
        firefox="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$2"
    fi

    rm "$firefox/chrome/userContent.css"
    mv "/tmp/backup/userContent.css" "$firefox/chrome/userContent.css"
}

discord() {
    local discord_theme=""
    if [[ $1 = "native" ]]; then
        discord_theme="$config/$2/themes/current_theme.css"
    elif [[ $1 = "flatpak" ]]; then
        discord_theme="$HOME/.var/app/com.discordapp.Discord/config/$2/themes/current_theme.css"
    fi

    rm "$discord_theme"
}

