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
export HISTIGNORE="&:[bf]g:c:clear:history:exit:q:pwd:* --help"
setopt autocd beep notify
bindkey -v

# options
setopt AUTO_CD
setopt NO_NOMATCH
setopt CD_SILENT
setopt APPEND_HISTORY
setopt -h # HIST_IGNORE_DUPS

# aliases
alias l="eza --icons --hyperlink"
alias ls="eza --icons --hyperlink --git -l"
alias lt="eza --icons --hyperlink --git --tree"

alias v="nvim"
alias t="tmux"
alias lg="lazygit"

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
    --preview 'cat {}'
    --color=bg+:#313244,bg:#181825,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# set bat's theme (no shit)
export BAT_THEME="Catppuccin Mocha"

# configure clipmenu to use rofi
export CM_LAUNCHER=rofi

export EDITOR=nvim
export SUDO_EDITOR=nvim
export TERM=alacritty
export XDG_CONFIG_HOME=$HOME/.config

export PATH="$HOME/.config/rofi/scripts:$HOME/.cargo/bin:$PATH:$HOME/.local/bin"

eval "$(starship init zsh)"


# pnpm
export PNPM_HOME="/home/nathan/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
