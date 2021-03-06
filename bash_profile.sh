#   _               _                        __ _ _
#  | |__   __ _ ___| |__    _ __  _ __ ___  / _(_) | ___
#  | '_ \ / _` / __| '_ \  | '_ \| '__/ _ \| |_| | |/ _ \
#  | |_) | (_| \__ \ | | | | |_) | | | (_) |  _| | |  __/
#  |_.__/ \__,_|___/_| |_| | .__/|_|  \___/|_| |_|_|\___|
#                          |_|
# https://www.kirsle.net/wizards/ps1.html
# http://ss64.com/bash/syntax-prompt.html
# https://dougbarton.us/Bash/Bash-prompts.html
# http://sage.ucsc.edu/xtal/iterm_tab_customization.html

# SYSTEM SETTINGS ##

# Directory of Script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# load bashrc if possible
if [ -f "$HOME/.bashrc" ]; then
  source "$HOME/.bashrc"
fi

if [ -f "$HOME/.gitprompt.sh" ]; then
  source "$HOME/.gitprompt.sh"
fi

# ==================
# Path
# ==================

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
PS1="${style_user}\u"               # Username
PS1+="${style_chars} @ "            # break
PS1+="${style_time}\h "             # Computer ID
PS1+="${style_path}\w"              # Working directory
# PS1+="\$(__git_ps1)"              # Git details
PS1+="\$(__git_prompt)"             # Git details
PS1+="\n"                           # Newline
PS1+="${style_cmd}\$ \[${RESET}\]"  # $ (and reset color)

# =================
# Other System Settings
# =================

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

eval "$(rbenv init -)"
eval "$(pyenv init -)"

# Other Settings ##

# =================
# Source Files
# =================

for file in ~/.dotfiles/{exports.sh,aliases.sh,functions.sh,macos.sh,secrets.sh,tmuxinator.zsh}; do
  [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file

export PATH="$HOME/.poetry/bin:$PATH"
