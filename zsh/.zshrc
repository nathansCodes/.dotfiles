eval "$(starship init zsh)"

# aliases
alias l="exa --icons"
alias ls="exa --icons --git -l"
alias lt="exa --icons --git --tree"

alias v="nvim"
alias t="tmux"

export FZF_DEFAULT_OPTS="
	--color=fg:#908caa,hl:#ea9a97
	--color=fg+:#e0def4,hl+:#ea9a97
	--color=border:#44415a,header:#3e8fb0,gutter:#232136
	--color=spinner:#f6c177,info:#9ccfd8,separator:#44415a
	--color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

# configure clipmenu to use rofi
export CM_LAUNCHER=rofi

export PATH=$HOME/.config/rofi/scripts:$PATH

neofetch
