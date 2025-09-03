# Aliases
alias l="eza --icons --hyperlink"
alias ls="eza --icons --hyperlink --git -l"
alias lt="eza --icons --hyperlink --git --tree"
alias v=nvim
alias t=tmux
alias lg=lazygit
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
alias kb=setxkbmap

# Environment Variables
set -gx HISTFILE ~/.histfile
set -gx HISTSIZE 1000
set -gx SAVEHIST 1000
set -gx HISTIGNORE "&:[bf]g:c:clear:history:exit:q:pwd:* --help"
set -gx FZF_DEFAULT_OPTS ""
set -gx BAT_THEME "Catppuccin Mocha"
set -gx EDITOR nvim
set -gx SUDO_EDITOR nvim
set -gx TERM alacritty
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx PATH $HOME/.cargo/bin:$PATH:$HOME/.local/bin
set -gx FZF_DEFAULT_OPTS "
    --preview 'cat {}'
    --color=bg+:#313244,bg:#181825,spinner:#f5e0dc,hl:#f38ba8
    --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
    --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Functions
