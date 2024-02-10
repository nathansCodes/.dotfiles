zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list 'r:|[._-/\|;:,<>=+`~]=** r:|=**' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '' 'l:|=* r:|=*'
zstyle :compinstall filename '/home/nathan/.zshrc'

autoload -Uz compinit
compinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep notify
bindkey -v

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

alias gs="git status"
alias gst="git stash"
alias ga="git add"
alias gr="git restore"
alias grm="git rm"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gb="git branch"
alias gm="git submodule"

alias kb="setxkbmap"

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

export EDITOR=nvim
export SUDO_EDITOR=nvim
export TERM=alacritty
export XDG_CONFIG_HOME=$HOME/.config

export PATH="$HOME/.config/rofi/scripts:$HOME/.cargo/bin:$PATH:$HOME/.local/bin"

case "$TERM" in (rxvt|rxvt-*|st|st-*|*xterm*|(dt|k|E)term|alacritty)
    local term_title () { print -n "\e]0;${(j: :q)@}\a" }
    precmd () {
      local DIR="$(print -P '%d')"
      term_title "$DIR"
    }
    preexec () {
      local DIR="$(print -P '%d')"
      local CMD="${(j:\n:)${(f)1}}"
      term_title "$DIR" "$CMD"
    }
  ;;
esac

eval "$(starship init zsh)"

