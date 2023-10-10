eval "$(starship init zsh)"

# options
setopt AUTO_CD
setopt CD_SILENT
setopt APPEND_HISTORY
setopt -h # HIST_IGNORE_DUPS

# aliases
alias l="eza --icons"
alias ls="eza --icons --git -l"
alias lt="eza --icons --git --tree"

alias v="nvim"
alias t="tmux"

export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,hl:#ea9a97
	--color=fg+:#e0def4,hl+:#ea9a97
	--color=border:#44415a,header:#3e8fb0,gutter:#232136
	--color=spinner:#f6c177,info:#9ccfd8,separator:#44415a
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# set bat's theme (no shit)
export BAT_THEME="Catppuccin-mocha"

# configure clipmenu to use rofi
export CM_LAUNCHER=rofi

export PATH=$HOME/.config/rofi/scripts:$PATH

neofetch
