# paths
config="$HOME/.config"
nvim="$config/nvim"
xresources="$HOME/.Xresources"
gtk3="$config/gtk-3.0"
gtk4="$config/gtk-4.0"
alacritty_dir="$config/alacritty"

alacritty() {
    rm "$alacritty_dir/colors/theme.yml"
    ln -s "$alacritty_dir/colors/$1.yml" "$alacritty_dir/colors/theme.yml"
    # add a line to and remove it from alacritty.yml to trigger alacritty's auto reloading
    echo "" >> "$alacritty_dir/alacritty.yml"
    sed -i '$ d' "$alacritty_dir/alacritty.yml"
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
    pidof st | xargs kill -s USR1
}

gtk() {
    # create backup of gtk4 gtk.css and copy the template if it's different
    if [[ $(diff -q $gtk4/gtk.css $config/awesome/ui/theme/gtk.template.css) ]]; then
        rm "$gtk4/gtk.css.bak"
        mv "$gtk4/gtk.css" "$gtk4/gtk.css.bak"

        cat "$config/awesome/ui/theme/gtk.template.css" > "$gtk4/gtk.css"
    fi

    sed -i -e "s/color bg .*/color bg $BASE;/" \
        -e "s/color second_bg .*/color second_bg $SURFACE;/" \
        -e "s/color text .*/color text $FG;/" \
        -e "s/color accent .*/color accent $ACCENT;/" \
        -e "s/color error .*/color error $ERROR;/" \
        -e "s/color warn .*/color warn $WARN;/" \
        -e "s/color success .*/color success $SUCCESS;/" \
        -e "s/color close .*/color close $CLOSE;/" \
        -e "s/color maximize .*/color maximize $MAXIMIZE;/" \
        -e "s/color minimize .*/color minimize $MINIMIZE;/" $gtk4/gtk.css

    # create backup of gtk3 gtk.css and copy the template if it's different
    if [[ $(diff -q $gtk3/gtk.css $config/awesome/ui/theme/gtk.template.css) ]]; then
        rm "$gtk3/gtk.css.bak"
        mv "$gtk3/gtk.css" "$gtk3/gtk.css.bak"

        cat "$config/awesome/ui/theme/gtk.template.css" > "$gtk3/gtk.css"
    fi

    sed -i -e "s/color bg .*/color bg $BASE;/" \
        -e "s/color second_bg .*/color second_bg $SURFACE;/" \
        -e "s/color text .*/color text $FG;/" \
        -e "s/color accent .*/color accent $ACCENT;/" \
        -e "s/color error .*/color error $ERROR;/" \
        -e "s/color warn .*/color warn $WARN;/" \
        -e "s/color success .*/color success $SUCCESS;/" \
        -e "s/color close .*/color close $CLOSE;/" \
        -e "s/color maximize .*/color maximize $MAXIMIZE;/" \
        -e "s/color minimize .*/color minimize $MINIMIZE;/" $gtk3/gtk.css

    sed -i -e "s/gtk-theme-name=.*/gtk-theme-name=adw-gtk3/" $gtk3/settings.ini
    sed -i -e "s/Net\/ThemeName .*/Net\/ThemeName \"adw-gtk3\"/" $HOME/.config/xsettingsd/xsettingsd.conf

    # Apply
    killall xsettingsd
    xsettingsd &
}

userchrome() {
    # $1 = firefox install method; $2 = firefox profile
    if [[ $1 = "native" ]]; then
        firefox="$HOME/.mozilla/firefox/$2"
    elif [[ $1 = "flatpak" ]]; then
        firefox="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$2"
    fi
    sed -i -e "s/--bg: .*/--bg: $BASE;/g" \
           -e "s/--bg2: .*/--bg2: $SURFACE;/g" \
           -e "s/--fg: .*/--fg: $FG;/g" \
           -e "s/--inactive: .*/--inactive: $INACTIVE;/g" \
           -e "s/--accent: .*/--accent: $ACCENT;/g" \
           -e "s/--accent2: .*/--accent2: $ACCENT2;/g" $firefox/chrome/userChrome.css
}

usercontent() {
    # $1 = firefox install method; $2 = firefox profile
    if [[ $1 = "native" ]]; then
        firefox="$HOME/.mozilla/firefox/$2"
    elif [[ $1 = "flatpak" ]]; then
        firefox="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$2"
    fi
    sed -i -e "s/--bg: .*/--bg: $BASE;/g" \
           -e "s/--bg2: .*/--bg2: $OVERLAY;/g" \
           -e "s/--fg: .*/--fg: $FG;/g" \
           -e "s/--inactive: .*/--inactive: $INACTIVE;/g" \
           -e "s/--accent: .*/--accent: $ACCENT;/g" \
           -e "s/--accent2: .*/--accent2: $ACCENT2;/g" $firefox/chrome/userContent.css
}

nvim() {
    sed -i -e "s/color or '.*'/color or '$1'/" $nvim/after/plugin/colors.lua
    sed -i -e "s/color or \".*\"/color or \"$1\"/" $nvim/after/plugin/colors.lua
    sed -i -e "s/colorscheme '.*'/colorscheme '$1'/" $nvim/init.lua
    sed -i -e "s/colorscheme \".*\"/colorscheme \"$1\"/" $nvim/init.lua
    python "$config/awesome/scripts/nvim_reload.py" "so $nvim/after/plugin/colors.lua"
}

discord() {
    discord_theme=""
    if [[ $1 = "native" ]]; then
        discord_theme="$config/Vencord/themes/current_theme.css"
    elif [[ $1 = "flatpak" ]]; then
        discord_theme="$HOME/.var/app/com.discordapp.Discord/config/Vencord/themes/current_theme.css"
    fi

    cat "$config/awesome/ui/theme/discord.template.css" > "$discord_theme"

    sed -i -e "s/--base: .*;/--base: $BASE;/" \
    	-e "s/--surface: .*;/--surface: $SURFACE;/" \
    	-e "s/--overlay: .*;/--overlay: $OVERLAY;/" \
    	-e "s/--inactive: .*;/--inactive: $INACTIVE;/" \
    	-e "s/--highlight_low: .*;/--highlight_low: $HL_LOW;/" \
    	-e "s/--highlight_med: .*;/--highlight_med: $HL_MED;/" \
        -e "s/--highlight_high: .*;/--highlight_high: $HL_HIGH;/" \
    	-e "s/--white: .*;/--white: $WHITE;/" \
    	-e "s/--text: .*;/--text: $FG;/" \
    	-e "s/--red: .*;/--red: $RED;/" \
    	-e "s/--yellow: .*;/--yellow: $YELLOW;/" \
    	-e "s/--cyan: .*;/--cyan: $CYAN;/" \
    	-e "s/--green: .*;/--green: $GREEN;/" \
    	-e "s/--blue: .*;/--blue: $BLUE;/" \
    	-e "s/--magenta: .*;/--magenta: $MAGENTA;/" \
    	-e "s/--accent: .*;/--accent: $ACCENT;/" \
    	-e "s/--second_accent: .*;/--second_accent: $ACCENT2;/" \
    	-e "s/--third_accent: .*;/--third_accent: $ACCENT3;/" "$discord_theme"
}
