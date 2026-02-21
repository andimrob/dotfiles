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

# Suffix aliases ---------------------------------------------------------------
# View with bat
alias -s {md,json,yaml,yml}=bat
# Edit source files
alias -s {py,rb,js,ts}=${EDITOR:-vi}
# Tail log files
alias -s log='tail -f'
