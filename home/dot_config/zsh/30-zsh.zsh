#          _
#  _______| |__
# |_  / __| '_ \
#  / /\__ \ | | |
# /___|___/_| |_|
#
# zsh-specific config (not sourced by bash)

# Edit command line in $EDITOR with Ctrl-X Ctrl-E
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Insert git commit template with Ctrl-X g c
git-commit-widget() {
  BUFFER='git commit -m ""'
  CURSOR=$((${#BUFFER} - 1))
}
zle -N git-commit-widget
bindkey '^Xgc' git-commit-widget

# History ----------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

# Suffix aliases ---------------------------------------------------------------
# View with bat
alias -s {md,json,yaml,yml}=bat
# Edit source files
alias -s {py,rb,js,ts}=${EDITOR:-vi}
# Tail log files
alias -s log='tail -f'
