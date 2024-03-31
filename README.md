# My dotfiles
![image](https://github.com/naan187/.dotfiles/assets/99505972/2e6adccf-db1d-4d1e-b121-af4ce567500c)

## Featuring
<details>
  <summary>
  <b>
    A launcher, based on <a href="https://github.com/Stardust-kyun/dotfiles/blob/main/home/.config/awesome/theme/launcher.lua">Stardust-kyun's launcher</a>, but made _blazingly fast_ using <a href="https://github.com/swarn/fzy-lua">fzy-lua</a>
  </b>
  </summary>
  <i>this also serves as a showcase of my skill issues in typing</i>
  <video width=200 src="https://github.com/naan187/.dotfiles/assets/99505972/731106ba-ff85-4d47-ae41-d04c1bce9afa" type="video/mp4" />
</details>

<details>
  <summary> <b>An autohiding dock</b> </summary>
  <i>I couldn't get it to properly hide when tiling/untiling the window, it currently does nothing</i>
  <video width=200 src="https://github.com/naan187/.dotfiles/assets/99505972/9b87a72c-61c1-45db-9b18-6dc7630391ff" type="video/mp4" />
</details>

<details>
  <summary> <b>Smooth animations, thanks to <a href="https://github.com/andOrlando/rubato">rubato</a></b> </summary>
  <i>Animations are smoother and less weird when not recording with OBS</i>
  <video width=200 src="https://github.com/naan187/.dotfiles/assets/99505972/96f684e7-c803-4c93-9813-323c38d6f2fa" type="video/mp4" />
</details>

<details>
  <summary> <b>A Lock screen with <a href="https://github.com/RMTT/lua-pam">lua-pam</a> integration</b> </summary>
  <i>Ignore the 1 in the bar, that's from the screenshot tool's countdown. Somehow it slips into the screenshot when locking the screen</i>
  <img src="https://github.com/naan187/.dotfiles/assets/99505972/a70d1bfa-1b64-40ce-835b-33565e80c138" \>
</details>

<details>
  <summary> <b>Various right-click menus (menu code mostly stolen from <a href="https://github.com/rxyhn/yoru">yoru</a>)</b> </summary>
  <img src="https://github.com/naan187/.dotfiles/assets/99505972/e11ed940-f90e-48a4-8f0e-94deb0e794c9" \>
  <img src="https://github.com/naan187/.dotfiles/assets/99505972/83c46787-f95d-4104-9685-12f98702f846" \>
</details>

<details>
  <summary> <b>A screenshot tool (I made this before I found out about `awful.screenshot`'s interactive snipping mode)</b> </summary>
  <i>Yes, the inward curve is part of the bar</i>
  <video width=200 src="https://github.com/naan187/.dotfiles/assets/99505972/c68b4817-4e9f-4ff1-8030-473eeec595b6" type="video/mp4" />
</details>

<details>
  <summary> <b>Highly customized application themes</b> </summary>
  This includes:
  <ul>
    <li>Firefox</li>
    <li>Gtk</li>
    <li>Discord (with a client mod that supports custom css, like Vencord or BetterDiscord)</li>
    <li>Alacritty</li>
    <li>Neovim</li>
    <li>Any Xresources-based terminal (Hopefully, haven't tested)</li>
  </ul>
  You can see most of them in the screenshots and videos
</details>

<details>
  <summary> <b>Json configuration (and yes, theme switcher)</b> </summary>
  The json config was intended to make it easier for me to implement a gui theme switcher, and I did have a prototype for it, but I ended up scrapping that because the code was messy, and so that I could focus on other stuff
  There currently are only a couple themes (including all their variants):
  
  - Catppuccin
  - Rose Pine
  - Biscuit
	
  https://github.com/naan187/.dotfiles/assets/99505972/fe197e49-b5c3-409c-b18e-779c36aaec8e
</details>

<details>
  <summary> <b>Simple and beautiful <a href="https://github.com/naan187/nvim">Neovim</a> & tmux configs</b> </summary>
  <img src="https://github.com/naan187/.dotfiles/assets/99505972/17a657bd-af7d-4143-ba5f-9c7ae61034e3" \>
</details>

## My Setup
- OS: [Nobara Linux](https://nobaraproject.org)
- WM: [AwesomeWM](https://github.com/awesomeWM/awesome)
- Comp: [fdev31 picom](https://github.com/fdev31/picom)
- Terminal: [Alacritty](https://github.com/alacritty/alacritty)
- Code Editor/IDE: [Neovim](https://github.com/neovim/neovim)
- Shell: [zsh](https://zsh.org)

## Issues
- Neovim and Xresources themes don't get reverted (not implemented)
- Lockscreen breaks when taking a screenshot of it using the screenshot tool
- Color animations on buttons sometimes break
- Bling tag & task preview show on the wrong screen
- Button widget breaks `awful.widget.{tag|task}list`
- General picom bugs

## Installation
### Prerequisites
- [AwesomeWM](https://github.com/AwesomeWM/awesome?tab=readme-ov-file##building-and-installation) (duh)
  Use the git version. 4.3 is old and outdated. This config WILL NOT work with Awesome 4.3

1. Clone the repo *in your home directory*
   ```sh
   git clone https://github.com/naan187/.dotfiles.git
   cd .dotfiles
   ```
2. Run `setup.sh`. This will install dependencies for the awm config and install the dotfiles using `stow`
   ```sh
   chmod +x setup.sh
   ./setup.sh
   ```
> [!NOTE]
> `stow` will not override your existing configs, it is your job to back them up before installing

### Post-install

#### Setup wifi
In `settings.json`, set `device.network.wifi` and `device.network.lan` to the corresponding network interfaces.
The easiest way to find out what they're called is to run `nmcli` a terminal

There's some extra things you have to do to use the theme switcher with some apps.

Common step for all: set `theme.<app>.enabled` to `true` in `~/.config/awesome/settings.json`

#### Firefox
1. Enable firefox css:
   - Go to `about:config` and click 'Accept the Risk and Continue'
   - Type 'legacyuser' and in the results, set `toolkit.legacyUserProfileCustomizations.stylesheets` to true (press the second button from the right)
3. Get your firefox profile:
   - Open `about:profiles` and locate the profile that says `"This is the profile in use and it cannot be deleted."`
   - Set `theme.firefox.profile` to the part of the Root Directory after the last `/`
3. Determine your firefox install method:
   - If you're using the firefox flatpak, set `theme.firefox.install` to "flatpak", otherwise set it to "native"

### Discord
1. Install a Discord client mod and tell the config which one you chose:
   - It has to support custom css
   - Set `theme.discord.client_mod` to the name of your client mod
2. Tell the config how you installed Discord:
   - If you're using the Discord flatpak, set `theme.discord.install` to "flatpak", otherwise set it to "native"

### Neovim
If you're using lazy.nvim, you can put [this file](https://github.com/naan187/nvim/blob/main/lua/plugins/colors.lua) in your lazy config **in ~/.config/nvim/lua/plugins/colors.lua**

**Otherwise:**
1. Put [this function](https://github.com/naan187/nvim/blob/main/lua/plugins/colors.lua#L1) in your init.lua
2. Install the corresponding theme plugins: [Catppuccin](https://github.com/catppuccin/nvim), [Rose Pine](https://github.com/rose-pine/neovim), [Biscuit](https://github.com/Biscuit-Colorscheme/nvim)

**OR:**
Just use [my config](https://github.com/naan187/nvim)

## Special Thanks
- [The AwesomeWM Team](https://github.com/awesomeWM) for [their amazing window manager](https://github.com/awesomeWM/awesome)
- [yshui](https://github.com/yshui) for creating [picom](https://github.com/yshui/picom) and [FT-Labs](https://github.com/FT-Labs) for the _shmooth_, but buggy animations in [his fork](https://github.com/FT-Labs/picom),
  and [fdev31](https://github.com/fdev31) for [fixing it up a bit](https://github.com/fdev31/picom)
- [Amitabha](https://github.com/Amitabha37377), [rxyhn](https://github.com/rxyhn), [Stardust-kyun](https://github.com/Stardust-kyun), [Tsukki](https://github.com/tsukki9696) for their amazing dotfiles as a great resource to learn awm
- [Firanel](https://github.com/Firanel), [Streetturtle](https://github.com/streetturtle), [The Bling people](https://github.com/BlingCorp) and [andOrlando](https://github.com/andOrlando) for creating great libraries that made my life so much easier
and more...

<!--
vim:shiftwidth=2
-->
