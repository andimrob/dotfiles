#   _               _                        __ _ _
#  | |__   __ _ ___| |__    _ __  _ __ ___  / _(_) | ___
#  | '_ \ / _` / __| '_ \  | '_ \| '__/ _ \| |_| | |/ _ \
#  | |_) | (_| \__ \ | | | | |_) | | | (_) |  _| | |  __/
#  |_.__/ \__,_|___/_| |_| | .__/|_|  \___/|_| |_|_|\___|
#                          |_|
# When Bash starts, it executes the commands in this script
# http://en.wikipedia.org/wiki/Bash_(Unix_shell)
#
# =====================
# Resources
# =====================
# http://cli.learncodethehardway.org/bash_cheat_sheet.pdf
# http://ss64.com/bash/syntax-prompt.html
# https://dougbarton.us/Bash/Bash-prompts.html
# http://sage.ucsc.edu/xtal/iterm_tab_customization.html

# ====================
# TOC
# ====================
# --------------------
# System Settings
# --------------------
#  1. Path List
#  2. File Navigation
#  3. History
#  4. Bash Prompt
#  5. Other System Settings
# --------------------
# Application Settings
# --------------------
#  6. Application Aliases
#  7. Sublime
#  8. Git
#  9. Rails
# 10. rbenv
# --------------------
# Other Settings
# --------------------
# 11. Shortcuts
# 12. Source Files
# 13. Environmental Variables and API Keys
# 14. Reserved


# SYSTEM SETTINGS
##########################################################################

# Directory of Script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load bashrc if possible
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

if [ -f "$HOME/.git-prompt.sh" ]; then
  source "$HOME/.git-prompt.sh"
fi

if [ -f "$HOME/.git-completion.bash" ]; then
  source "$HOME/.git-completion.bash"
fi

# ==================
# Path
# This is a list of all directories in which to look for commands, scripts and programs
# ==================

# Load RVM into a shell session *as a function*
#[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # PJ: using rbenv now...
# Home brew directories
PATH="/usr/local/bin:$PATH"
# Node Package Manager
PATH="/usr/local/share/npm/bin:$PATH"
# Heroku Toolbelt
PATH="/usr/local/heroku/bin:$PATH"
# Python goodies
PATH="/usr/local/bin/python:$PATH"
# super binaries
PATH="/usr/local/sbin:$PATH"
# Add Postgresql 9.4
PATH="/usr/local/opt/postgresql@9.4/bin:$PATH"

# ====================
# Dev Shortcuts
# ====================

export DOTFILE_DIR="$HOME/.dotfiles"
export PROJECT_HOME=$HOME/dev
export WORKON_HOME=$HOME/.virtualenvs
export JAVA_HOME=$(/usr/libexec/java_home)
export GOPATH="$HOME/go"

# ====================
# File Navigation
# ====================

# Adds colors to LS
export CLICOLOR=1
# http://geoff.greer.fm/lscolors/
# Describes what color to use for which attribute (files, folders etc.)
export LSCOLORS=faexcxdxbxegedabagacad # PJ: turned off
## Tab improvements
## Might not need?
bind 'set completion-ignore-case on'
# make completions appear immediately after pressing TAB once
bind 'set show-all-if-ambiguous on'
bind 'TAB: menu-complete'
# Prefer US English
export LC_ALL="en_US.UTF-8"
# use UTF-8
export LANG="en_US"

# =================
# History
# =================
# http://jorge.fbarr.net/2011/03/24/making-your-bash-history-more-efficient/
# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768
export HISTFILESIZE=$HISTSIZE
# don't put duplicate lines in the history.
export HISTCONTROL=ignoredups
# ignore same sucessive entries.
export HISTCONTROL=ignoreboth
# Make some commands not show up in history
export HISTIGNORE="h:ls:ls *:ll:ll *:"

# =================
# Bash Prompt
# =================
# --------------------
# Colors for the prompt
# --------------------
# Set the TERM var to xterm-256color
if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
  export TERM=gnome-256color
elif infocmp xterm-256color >/dev/null 2>&1; then
  export TERM=xterm-256color
fi
if tput setaf 1 &> /dev/null; then
  tput sgr0
  if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
    # this is for xterm-256color
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 226)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    WHITE=$(tput setaf 7)
    ORANGE=$(tput setaf 172)
    # GREEN=$(tput setaf 190)
    PURPLE=$(tput setaf 141)
    BG_BLACK=$(tput setab 0)
    BG_RED=$(tput setab 1)
    BG_GREEN=$(tput setab 2)
    BG_BLUE=$(tput setab 4)
    BG_MAGENTA=$(tput setab 5)
    BG_CYAN=$(tput setab 6)
    BG_YELLOW=$(tput setab 226)
    BG_ORANGE=$(tput setab 172)
    BG_WHITE=$(tput setab 7)
  else
    MAGENTA=$(tput setaf 5)
    ORANGE=$(tput setaf 4)
    GREEN=$(tput setaf 2)
    PURPLE=$(tput setaf 1)
    WHITE=$(tput setaf 7)
  fi
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
  UNDERLINE=$(tput sgr 0 1)
else
  BLACK="\[\e[0;30m\]"
  RED="\033[1;31m"
  ORANGE="\033[1;33m"
  GREEN="\033[1;32m"
  PURPLE="\033[1;35m"
  WHITE="\033[1;37m"
  YELLOW="\[\e[0;33m\]"
  CYAN="\[\e[0;36m\]"
  BLUE="\[\e[0;34m\]"
  BOLD=""
  RESET="\033[m"
fi
# ---------------------
# Print Stats on terminal load
# ---------------------
function welcome() {
  sed -i.bak s/welcome_prompt=false/welcome_prompt=true/g ~/.welcome_prompt
  echo "Message returned."
}

# Show/Hide stats on terminal load
function unwelcome() {
  sed -i.bak s/welcome_prompt=true/welcome_prompt=false/g ~/.welcome_prompt
  echo "Message removed. Type ${BOLD}welcome${RESET} to return the message."
}

# ---------------------
# style the prompt
# ---------------------
style_time="\[${RESET}${YELLOW}\]"
style_user="\[${RESET}${ORANGE}\]"
style_path="\[${RESET}${CYAN}\]"
style_chars="\[${RESET}${WHITE}\]"
style_cmd="\[${RESET}${BLUE}\]"
style_branch="${RED}"
# ---------------------
# Build the prompt
# ---------------------
# Example with committed changes: username ~/documents/GA/wdi on master[+]
PS1="${style_user}\u"                    # Username
PS1+="${style_chars} @ "                # break
PS1+="${style_time}\h "                  # Computer ID
PS1+="${style_path}\w"                  # Working directory
# PS1+="\$(__git_ps1)"                    # Git details
PS1+="\$(__git_prompt)"                    # Git details
PS1+="\n"                                # Newline
PS1+="${style_cmd}\$ \[${RESET}\]"       # $ (and reset color)

# =================
# Other System Settings
# =================

# Start an HTTP server from a directory, optionally specifying the port
function server() {
  local port="${1:-8000}"
  open "http://localhost:${port}/"
  # Set the default Content-Type to `text/plain` instead of `application/octet-stream`
  # And serve everything as UTF-8 (although not technically correct, this doesn’t break anything for binary files)
  python -c $'import SimpleHTTPServer;\nmap = SimpleHTTPServer.SimpleHTTPRequestHandler.extensions_map;\nmap[""] = "text/plain";\nfor key, value in map.items():\n\tmap[key] = value + ";charset=UTF-8";\nSimpleHTTPServer.test();' "$port"
}

# APPLICATION SETTINGS
##########################################################################

# ================
# Application Aliases
# ================

# Sublime should be symlinked. Otherwise use one of these
# alias subl='open -a "Sublime Text”’
# alias subl='open -a "Sublime Text 2"'

# ================
# Sublime
# ================

# Make sublime our editor of choice
export EDITOR="subl -w"

# =================
# Git
# =================

# -----------------
# For the prompt
# -----------------
# Long git to show + ? !
__is_git_repo() {
    $(git rev-parse --is-inside-work-tree &> /dev/null)
}
__is_git_dir() {
    $(git rev-parse --is-inside-git-dir 2> /dev/null)
}
__get_git_branch() {
    local branch_name
    # Get the short symbolic ref
    branch_name=$(git symbolic-ref --quiet --short HEAD 2> /dev/null) ||
    # If HEAD isn't a symbolic ref, get the short SHA
    branch_name=$(git rev-parse --short HEAD 2> /dev/null) ||
    # Otherwise, just give up
    branch_name="(unknown)"
    printf $branch_name
}
# Git status information
__git_prompt() {
    local git_info git_state uc us ut st
    if ! __is_git_repo || __is_git_dir; then
        return 1
    fi
    git_info=$(__get_git_branch)
    # Check for uncommitted changes in the index
    if ! $(git diff --quiet --ignore-submodules --cached); then
        uc="+"
    fi
    # Check for unstaged changes
    if ! $(git diff-files --quiet --ignore-submodules --); then
        us="!"
    fi
    # Check for untracked files
    if [ -n "$(git ls-files --others --exclude-standard)" ]; then
        ut="${RED}?"
    fi
    # Check for stashed files
    if $(git rev-parse --verify refs/stash &>/dev/null); then
        st="$"
    fi
    git_state=$uc$us$ut$st
    # Combine the branch name and state information
    if [[ $git_state ]]; then
        git_info="$git_info${RESET}[$git_state${RESET}]"
    fi
    printf "${WHITE} on ${style_branch}${git_info}"
}

# =================
# Rails
# =================
# Migrate Dev and Test databases and annotate models
alias migrate='bundle exec rake db:migrate; bundle exec rake db:migrate RAILS_ENV=test; bundle exec annotate'

# =================
# rbenv
# =================
# start rbenv (our Ruby environment and version manager) on open
eval "$(rbenv init -)"
eval "$(pyenv init -)"

# Other Settings
##########################################################################


# =================
# Shortcuts
# =================
# Students can add a shortcut to quickly access their GA folder

zipf () { zip -r "$1".zip "$1" ; } # zipf: To create a ZIP archive of a folder

# =================
# Source Files
# =================
# .bash_settings and .bash_prompt should be added to .gitignore_global
# An extra file where you can create other settings, such as your
# application usernames or API keys...

if [ -f "$HOME/.bash_settings" ]; then
  source "$HOME/.bash_settings"
fi

# an extra file where you can create other settings for your prompt.
if [ -f "$HOME/.bash_prompt" ]; then
  source "$HOME/.bash_prompt"
fi

# a welcome prompt with stats for sanity checks
if [ -f "$DOTFILE_DIR/sh/welcome_prompt" ]; then
  source "$DOTFILE_DIR/sh/welcome_prompt"
fi

# env vars, secrets, and keys we don't want to keep in the repo
if [ -f "$DOTFILE_DIR/sh/api_keys" ]; then
  source "$DOTFILE_DIR/sh/api_keys"
fi

# helpful aliases
if [ -f "$DOTFILE_DIR/sh/bash_aliases" ]; then
  source "$DOTFILE_DIR/sh/bash_aliases"
fi

# helpful functions
if [ -f "$DOTFILE_DIR/sh/bash_functions" ]; then
  source "$DOTFILE_DIR/sh/bash_functions"
fi

# TODO: not sure if this is necessary for me, or anymore
if [ -f "/usr/local/bin/virtualenvwrapper.sh" ]; then
  source "/usr/local/bin/virtualenvwrapper.sh"
fi

# Below here is an area for other commands added by outside programs or
# commands. Attempt to reserve this area for their use!
##########################################################################
