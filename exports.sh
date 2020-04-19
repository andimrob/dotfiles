#                             _
#   _____  ___ __   ___  _ __| |_ ___
#  / _ \ \/ / '_ \ / _ \| '__| __/ __|
# |  __/>  <| |_) | (_) | |  | |_\__ \
#  \___/_/\_\ .__/ \___/|_|   \__|___/
#           |_|

export PATH="$HOME/.rbenv/bin:$PATH"
export EDITOR="vim"
export SSH_KEY_PATH="~/.ssh/id_rsa"
export DOTFILE_DIR=$(dirname "$0")
export PROJECT_HOME="$HOME/src"

# Locale ##########
# Prefer US English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# History ######### http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
# don't put duplicate lines in the history.
export HISTCONTROL=ignoredups
# ignore same successive entries.
export HISTCONTROL=ignoreboth
# Make some commands not show up in history
export HISTIGNORE="h:ls:ls *:ll:ll *:"

# Colorize LS ##### http://geoff.greer.fm/lscolors/
export CLICOLOR=1
# Describes what color to use for which attribute (files, folders etc.)
export LSCOLORS=faexcxdxbxegedabagacad
