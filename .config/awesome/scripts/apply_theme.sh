# paths
config="$HOME/.config"
nvim="$config/nvim"
xresources="$HOME/.Xresources"
gtk3="$config/gtk-3.0"
gtk4="$config/gtk-4.0"
alacritty_dir="$config/alacritty"

mkdir /tmp/backup

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

    if [ ! -f ~/.Xresources ]; then
        echo " " > ~/.Xresources
    fi
    if [ ! -s ~/.Xresources ]; then
        echo " " > ~/.Xresources
    fi

    # replace colors and append to file if not found.
    # NOTE: this doesn't work if ~/.Xresources is empty,
    # hence why above I put a space in it if it doesn't exist or is empty
    grep -q "^#define FG " ~/.Xresources && sed "s/^#define FG .*/#define FG $FG/" -i ~/.Xresources ||
        sed "$ a\#define FG $FG" -i ~/.Xresources
    grep -q "^#define BG " ~/.Xresources && sed "s/^#define BG .*/#define BG $OVERLAY/" -i ~/.Xresources ||
        sed "$ a\#define BG $OVERLAY" -i ~/.Xresources
    grep -q "^#define BL " ~/.Xresources && sed "s/^#define BL .*/#define BL $BLACK/" -i ~/.Xresources ||
        sed "$ a\#define BL $BLACK" -i ~/.Xresources
    grep -q "^#define WH " ~/.Xresources && sed "s/^#define WH .*/#define WH $WHITE/" -i ~/.Xresources ||
        sed "$ a\#define WH $WHITE" -i ~/.Xresources
    grep -q "^#define R " ~/.Xresources && sed "s/^#define R .*/#define R $RED/" -i ~/.Xresources ||
        sed "$ a\#define R $RED" -i ~/.Xresources
    grep -q "^#define G " ~/.Xresources && sed "s/^#define G .*/#define G $GREEN/" -i ~/.Xresources ||
        sed "$ a\#define G $GREEN" -i ~/.Xresources
    grep -q "^#define Y " ~/.Xresources && sed "s/^#define Y .*/#define Y $YELLOW/" -i ~/.Xresources ||
        sed "$ a\#define Y $YELLOW" -i ~/.Xresources
    grep -q "^#define B " ~/.Xresources && sed "s/^#define B .*/#define B $BLUE/" -i ~/.Xresources ||
        sed "$ a\#define B $BLUE" -i ~/.Xresources
    grep -q "^#define M " ~/.Xresources && sed "s/^#define M .*/#define M $MAGENTA/" -i ~/.Xresources ||
        sed "$ a\#define M $MAGENTA" -i ~/.Xresources
    grep -q "^#define C " ~/.Xresources && sed "s/^#define C .*/#define C $CYAN/" -i ~/.Xresources ||
        sed "$ a\#define C $CYAN" -i ~/.Xresources

    # Update Xresources, Terminals, and Vim
    xrdb ~/.Xresources
    pidof st | xargs kill -s USR1
}

gtk() {
    # for real
    rm -fr "/tmp/backup/gtk-4.0/"
    mv "$gtk4/" "/tmp/backup/"
    mkdir "$gtk4"
    cat "$config/awesome/ui/theme/gtk.template.css" > "$gtk4/gtk.css"

    sed -i -e "s/color bg .*/color bg $BASE;/" \
        -e "s/color second_bg .*/color second_bg $OVERLAY;/" \
        -e "s/color text .*/color text $FG;/" \
        -e "s/color accent .*/color accent $ACCENT;/" \
        -e "s/color error .*/color error $ERROR;/" \
        -e "s/color warn .*/color warn $WARN;/" \
        -e "s/color success .*/color success $SUCCESS;/" \
        -e "s/color close .*/color close $CLOSE;/" \
        -e "s/color maximize .*/color maximize $MAXIMIZE;/" \
        -e "s/color minimize .*/color minimize $MINIMIZE;/" $gtk4/gtk.css

    rm -rf "/tmp/backup/gtk-3.0/"
    mv "$gtk3/" "/tmp/backup/"
    mkdir "$gtk3"
    cat "$config/awesome/ui/theme/gtk.template.css" > "$gtk3/gtk.css"

    sed -i -e "s/color bg .*/color bg $BASE;/" \
        -e "s/color second_bg .*/color second_bg $OVERLAY;/" \
        -e "s/color text .*/color text $FG;/" \
        -e "s/color accent .*/color accent $ACCENT;/" \
        -e "s/color error .*/color error $ERROR;/" \
        -e "s/color warn .*/color warn $WARN;/" \
        -e "s/color success .*/color success $SUCCESS;/" \
        -e "s/color close .*/color close $CLOSE;/" \
        -e "s/color maximize .*/color maximize $MAXIMIZE;/" \
        -e "s/color minimize .*/color minimize $MINIMIZE;/" $gtk3/gtk.css

    cp "/tmp/backup/gtk-3.0/settings.ini" "$gtk3/settings.ini"
    sed -i -e "s/gtk-theme-name=.*/gtk-theme-name=adw-gtk3/" "$gtk3/settings.ini"

    cp "/tmp/backup/gtk-4.0/settings.ini" "$gtk4/settings.ini"
    sed -i -e "s/gtk-theme-name=.*/gtk-theme-name=adw-gtk3/" "$gtk4/settings.ini"

    sed -i -e "s/Net\/ThemeName .*/Net\/ThemeName \"adw-gtk3\"/" $HOME/.config/xsettingsd/xsettingsd.conf

    # Apply
    killall xsettingsd
    xsettingsd &
    gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3
}

userchrome() {
    # $1 = firefox install method; $2 = firefox profile
    if [[ $1 = "native" ]]; then
        firefox="$HOME/.mozilla/firefox/$2"
    elif [[ $1 = "flatpak" ]]; then
        firefox="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/$2"
    fi

    # create chrome dir if it doesn't exist
    if [[ ! -d "$firefox/chrome" ]]; then
        mkdir "$firefox/chrome/"
    fi

    # back up userChrome.css if it exists already
    if [[ -f "$firefox/userChrome/userChrome.css" ]]; then
        mv "$firefox/userChrome/userChrome.css" "/tmp/backup/userChrome.css"
    fi

    # copy template to the profile's chrome folder
    cp "$config/awesome/ui/theme/userChrome.template.css" "$firefox/chrome/userChrome.css"

    # change colors to correct color scheme
    sed -i -e "s/--bg: .*/--bg: $BASE;/g" \
           -e "s/--bg2: .*/--bg2: $SURFACE;/g" \
           -e "s/--fg: .*/--fg: $FG;/g" \
           -e "s/--inactive: .*/--inactive: $INACTIVE;/g" \
           -e "s/--accent: .*/--accent: $ACCENT;/g" \
           -e "s/--accent2: .*/--accent2: $ACCENT2;/g" $firefox/chrome/userChrome.css
}

# currently unused
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
    sed -i -e "s/colorscheme('.*'/colorscheme('$1'/" \
           -e "s/colorscheme(\".*\"/colorscheme(\"$1\"/" $nvim/lua/plugins/colors.lua
    sed -i -e "s/colorscheme '.*'/colorscheme '$1'/" \
           -e "s/colorscheme \".*\"/colorscheme \"$1\"/" $nvim/init.lua
    if [ "$2" = "lazy" ]; then
        sleep 2
    else
        python "$config/awesome/scripts/nvim_reload.py" "so $nvim/lua/plugins/colors.lua"
    fi
    python "$config/awesome/scripts/nvim_reload.py" "lua Colors()"
}

# needed for DiscordRecolor to work properly
hex_to_rgb() {
    printf "%d, %d, %d\n" 0x${1:1:2} 0x${1:3:2} 0x${1:5:2}
}

discord() {
    discord_theme=""
    if [[ $1 = "native" ]]; then
        discord_theme="$config/$2/themes/current_theme.css"
    elif [[ $1 = "flatpak" ]]; then
        discord_theme="$HOME/.var/app/com.discordapp.Discord/config/$2/themes/current_theme.css"
    fi

    cp -f "$config/awesome/ui/theme/discord.template.css" "$discord_theme"

    sed -i -e "s/--base: .*;/--base: $(hex_to_rgb $BASE);/" \
    	-e "s/--surface: .*;/--surface: $(hex_to_rgb $SURFACE);/" \
    	-e "s/--overlay: .*;/--overlay: $(hex_to_rgb $OVERLAY);/" \
    	-e "s/--ignored: .*;/--ignored: $(hex_to_rgb $IGNORED);/" \
    	-e "s/--inactive: .*;/--inactive: $(hex_to_rgb $INACTIVE);/" \
    	-e "s/--highlight_low: .*;/--highlight_low: $(hex_to_rgb $HL_LOW);/" \
    	-e "s/--highlight_med: .*;/--highlight_med: $(hex_to_rgb $HL_MED);/" \
        -e "s/--highlight_high: .*;/--highlight_high: $(hex_to_rgb $HL_HIGH);/" \
    	-e "s/--white: .*;/--white: $(hex_to_rgb $WHITE);/" \
    	-e "s/--text: .*;/--text: $(hex_to_rgb $FG);/" \
    	-e "s/--red: .*;/--red: $(hex_to_rgb $RED);/" \
    	-e "s/--yellow: .*;/--yellow: $(hex_to_rgb $YELLOW);/" \
    	-e "s/--cyan: .*;/--cyan: $(hex_to_rgb $CYAN);/" \
    	-e "s/--green: .*;/--green: $(hex_to_rgb $GREEN);/" \
    	-e "s/--blue: .*;/--blue: $(hex_to_rgb $BLUE);/" \
    	-e "s/--magenta: .*;/--magenta: $(hex_to_rgb $MAGENTA);/" \
    	-e "s/--accent: .*;/--accent: $(hex_to_rgb $ACCENT);/" \
    	-e "s/--second_accent: .*;/--second_accent: $(hex_to_rgb $ACCENT2);/" \
    	-e "s/--third_accent: .*;/--third_accent: $(hex_to_rgb $ACCENT3);/" "$discord_theme"
}
